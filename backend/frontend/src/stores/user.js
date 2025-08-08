import { defineStore } from 'pinia';
import { ref } from 'vue';
import api from '../config/api';

export const useUserStore = defineStore('user', () => {
  const userProfile = ref({
    first_name: '',
    last_name: '',
    email: '',
    phone_number: '',
    profile_image_url: null
  });
  const authToken = ref(null);
  const isAuthenticated = ref(false);
  const systemStatus = ref({
    tanks: 0,
    normal: 0,
    warning: 0,
    critical: 0,
    operational: true,
    lastUpdate: new Date()
  });
  const notifications = ref([]);

  // Initialize from localStorage if available
  const initialize = () => {
    const token = localStorage.getItem('authToken');
    if (token) {
      authToken.value = token;
      isAuthenticated.value = true;
      api.defaults.headers.common['Authorization'] = `Token ${token}`;
    }
  };

  // Fetch user profile
  const fetchUserProfile = async () => {
    try {
      const response = await api.get('/users/profile/');
      userProfile.value = response.data;
      
      if (response.data.profile_image_url) {
        // Use VITE_BACKEND_URL from environment variables
        userProfile.value.profile_image_url = import.meta.env.VITE_BACKEND_URL + response.data.profile_image_url;
      }
      return userProfile.value;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      throw error;
    }
  };
  
  // Upload profile image
  const uploadProfileImage = async (formData) => {
    try {
      const response = await api.put('/users/profile/image/', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      userProfile.value = response.data;
      if (response.data.profile_image_url) {
        // Use VITE_BACKEND_URL from environment variables
        userProfile.value.profile_image_url = import.meta.env.VITE_BACKEND_URL + response.data.profile_image_url;
      }
      return userProfile.value;
    } catch (error) {
      console.error('Error uploading profile image:', error);
      throw error;
    }
  };

  // Remove profile image
  const removeProfileImage = async () => {
    try {
      const response = await api.delete('/users/profile/image/');
      userProfile.value = response.data;
      userProfile.value.profile_image_url = null;
      localStorage.removeItem('profile_image');
      return userProfile.value;
    } catch (error) {
      console.error('Error removing profile image:', error);
      throw error;
    }
  };

  // Update profile
  const updateProfile = async (profileData) => {
    try {
      const response = await api.put('/users/profile/', profileData);
      userProfile.value = response.data;
      return userProfile.value;
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  };

  // Fetch system status
  const fetchSystemStatus = async () => {
    try {
      const response = await api.get('/system/status/');
      systemStatus.value = {
        tanks: response.data.total_tanks,
        normal: response.data.normal_tanks,
        warning: response.data.warning_tanks,
        critical: response.data.critical_tanks,
        operational: response.data.system_status === 'operational',
        lastUpdate: new Date(response.data.last_updated)
      };
    } catch (error) {
      console.error('Error fetching system status:', error);
    }
  };

  // Fetch notifications
  const fetchNotifications = async () => {
    try {
      const response = await api.get('/notifications/');
      notifications.value = response.data;
    } catch (error) {
      console.error('Error fetching notifications:', error);
    }
  };

  // Mark notification as read
  const markNotificationAsRead = async (id) => {
    try {
      await api.patch(`/notifications/${id}/`, { read: true });
      await fetchNotifications();
    } catch (error) {
      console.error('Error marking notification as read:', error);
    }
  };

  // Clear all notifications
  const clearNotifications = async () => {
    try {
      await api.delete('/notifications/clear/');
      notifications.value = [];
    } catch (error) {
      console.error('Error clearing notifications:', error);
    }
  };

  // Clear authentication
  const clearAuth = () => {
    authToken.value = null;
    isAuthenticated.value = false;
    userProfile.value = null;
    localStorage.removeItem('authToken');
    localStorage.removeItem('profile_image');
    delete api.defaults.headers.common['Authorization'];
  };

  return {
    userProfile,
    authToken,
    isAuthenticated,
    systemStatus,
    notifications,
    initialize,
    fetchUserProfile,
    uploadProfileImage,
    removeProfileImage,
    updateProfile,
    fetchSystemStatus,
    fetchNotifications,
    markNotificationAsRead,
    clearNotifications,
    clearAuth
  };
});