import axios from 'axios';
import { Capacitor } from '@capacitor/core';

// Smart API configuration that detects environment
const getApiBaseUrl = () => {
  const isDevelopment = import.meta.env.DEV;

  // Android build routing logic
  if (Capacitor.isNativePlatform()) {
    if (isDevelopment) {
      // Local dev builds map strictly to the host computer's backend
      return 'http://10.0.2.2:8000/api/';
    } else {
      // Production builds map strictly to the Render cloud backend
      return 'https://gas-monitor-sfk3.onrender.com/api/';
    }
  }

  // If we have an explicit environment variable, use it (highest priority)
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL;
  }

  // Check if we're running locally (localhost or 127.0.0.1)
  const isLocalhost = window.location.hostname === 'localhost' || 
                     window.location.hostname === '127.0.0.1' ||
                     window.location.hostname === '0.0.0.0';
  
  // Only use local backend if we're both in dev mode AND on localhost
  if (isDevelopment && isLocalhost) {
    // Local development - use local Django server
    return 'http://127.0.0.1:8000/';
  } else {
    // Production or deployed frontend - use Render backend
    return 'https://gas-monitor-sfk3.onrender.com/api';
  }
};

const api = axios.create({
  baseURL: getApiBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 second timeout
});

// Request interceptor to add auth token to every request
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Token ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

// Response interceptor for better error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid - redirect to login
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Export the current API base URL for debugging
export const getCurrentApiUrl = () => getApiBaseUrl();

// Log current configuration in development
if (import.meta.env.DEV) {
  console.log('🔧 API Configuration:', {
    baseURL: getApiBaseUrl(),
    environment: import.meta.env.DEV ? 'development' : 'production',
    hostname: window.location.hostname
  });
}

export default api;
