import { defineStore } from 'pinia';
import { ref } from 'vue';
import api from '../pages/public/api'; // Adjust the import based on your API setup

export const useUserStore = defineStore('user', {
  state: () => ({
    userProfile: ref(null),
  }),
  actions: {
    async fetchUserProfile() {
      try {
        const response = await api.get('/users/profile/');
        const backendUrl = import.meta.env.VITE_BACKEND_URL;
        this.userProfile = response.data;

        // Construct full URL for profile_image_url if it exists
        if (this.userProfile.profile_image_url) {
          this.userProfile.profile_image_url = `${backendUrl}${this.userProfile.profile_image_url}`;
          localStorage.setItem('profile_image', this.userProfile.profile_image_url);
        }
      } catch (error) {
        console.error('Error fetching user profile:', error);
      }
    },
    // Optional: Clear user profile (e.g., on logout)
    clearUserProfile() {
      this.userProfile = null;
      localStorage.removeItem('profile_image');
    },
  },
});