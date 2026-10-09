import axios from 'axios';
import { Capacitor } from '@capacitor/core';

const ONLINE_API_BASE_URL = 'https://web-production-c23ce.up.railway.app/api/';
const normalizeBaseUrl = (url) => `${url.replace(/\/+$/, '')}/`;

const getLocalFallbackBaseUrl = () => {
  const explicitLocalUrl = import.meta.env.VITE_LOCAL_API_BASE_URL;
  if (explicitLocalUrl) {
    const normalized = normalizeBaseUrl(explicitLocalUrl);
    if (normalized !== ONLINE_API_BASE_URL) return normalized;
  }

  if (Capacitor.isNativePlatform() && Capacitor.getPlatform() === 'android') {
    // Android emulator address for a backend running on the development host.
    return 'http://10.0.2.2:8000/api/';
  }

  // Backwards-compatible alias for existing browser/iOS development configs.
  const legacyLocalUrl = import.meta.env.VITE_API_BASE_URL;
  if (legacyLocalUrl) {
    const normalized = normalizeBaseUrl(legacyLocalUrl);
    if (normalized !== ONLINE_API_BASE_URL) return normalized;
  }

  // Browser, iOS simulator, and desktop development. Physical devices can set
  // VITE_LOCAL_API_BASE_URL to the computer's LAN address.
  return 'http://127.0.0.1:8000/api/';
};

const LOCAL_API_BASE_URL = getLocalFallbackBaseUrl();

const isPaymentInitiation = (config) =>
  config?.method?.toLowerCase() === 'post' &&
  /(?:^|\/)payments\/(?:initiate|subscriptions\/initiate)\/?(?:\?|$)/i.test(config.url || '');

const isSafeRead = (config) =>
  ['get', 'head', 'options'].includes((config?.method || 'get').toLowerCase());

const isNetworkFailure = (error) => {
  if (error.response) return false;
  if (error.code === 'ERR_NETWORK' || error.message === 'Network Error') return true;

  // A read can be retried after a timeout. Do not replay writes after a
  // timeout because the online server may already have completed them.
  return isSafeRead(error.config) && ['ECONNABORTED', 'ETIMEDOUT'].includes(error.code);
};

const api = axios.create({
  baseURL: ONLINE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Attach the saved login token to every API request.
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Token ${token}`;
  }
  return config;
}, (error) => Promise.reject(error));

// Try the local backend only when the online server gives no HTTP response.
// HTTP errors such as 401, 404, or 500 are returned as-is.
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const config = error.config;
    const requestBaseUrl = normalizeBaseUrl(config?.baseURL || '');
    const canTryLocal =
      config &&
      requestBaseUrl === ONLINE_API_BASE_URL &&
      !config._localFallbackAttempted &&
      LOCAL_API_BASE_URL !== ONLINE_API_BASE_URL &&
      !isPaymentInitiation(config) &&
      isNetworkFailure(error);

    if (canTryLocal) {
      if (import.meta.env.DEV) {
        console.warn('Online backend is unreachable; retrying on the local backend.');
      }
      return api.request({
        ...config,
        baseURL: LOCAL_API_BASE_URL,
        _localFallbackAttempted: true,
      });
    }

    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const getCurrentApiUrl = () => ONLINE_API_BASE_URL;

if (import.meta.env.DEV) {
  console.log('API connection order:', {
    primary: ONLINE_API_BASE_URL,
    localFallback: LOCAL_API_BASE_URL,
  });
}

export default api;
