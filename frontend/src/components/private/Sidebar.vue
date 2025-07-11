<template>
  <aside 
    class="fixed top-0 left-0 h-screen bg-gray-900 text-white flex flex-col shadow-xl transition-all duration-300 z-50 border-r border-gray-700"
    :class="{
       'w-72': isOpen,
       'w-0 overflow-hidden': !isOpen,
       'md:w-72': !isMobile,
    }"
    role="navigation"
    aria-label="Gas Monitoring Sidebar"
  >
    <!-- Logo Section with Status Indicator -->
    <div class="p-5 border-b border-gray-800 bg-gray-900/50" v-if="isOpen || !isMobile">
      <div class="flex items-center space-x-3">
        <div class="relative">
          <div class="w-10 h-10 rounded-lg bg-blue-600 flex items-center justify-center">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
          </div>
          <span class="absolute -top-1 -right-1 w-3 h-3 rounded-full border-2 border-gray-900"
                :class="userStore.systemStatus.operational ? 'bg-green-500' : 'bg-red-500'"></span>
        </div>
        <div>
          <h1 class="text-xl font-bold bg-gradient-to-r from-blue-400 to-blue-300 bg-clip-text text-transparent">GasTrack Pro</h1>
          <p class="text-xs text-gray-400">Monitoring System v2.1</p>
        </div>
      </div>
    </div>

    <!-- System Status Summary -->
    <div class="px-4 py-3 border-b border-gray-800 bg-gray-900/30" v-if="isOpen || !isMobile">
      <div class="flex items-center justify-between mb-2">
        <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wider">System Status</h3>
        <span class="text-xs px-2 py-1 rounded"
              :class="userStore.systemStatus.operational ? 'bg-green-900/50 text-green-400' : 'bg-red-900/50 text-red-400'">
          {{ userStore.systemStatus.operational ? 'Online' : 'Offline' }}
        </span>
      </div>
      <div class="grid grid-cols-3 gap-2 text-center">
        <div class="p-2 rounded bg-gray-800/50">
          <p class="text-2xl font-bold text-blue-400">{{ userStore.systemStatus.tanks }}</p>
          <p class="text-xs text-gray-400">Tanks</p>
        </div>
        <div class="p-2 rounded bg-gray-800/50">
          <p class="text-2xl font-bold text-green-400">{{ userStore.systemStatus.normal }}</p>
          <p class="text-xs text-gray-400">Normal</p>
        </div>
        <div class="p-2 rounded bg-gray-800/50">
          <p class="text-2xl font-bold text-yellow-400">{{ userStore.systemStatus.warning }}</p>
          <p class="text-xs text-gray-400">Warning</p>
        </div>
      </div>
      <div class="mt-2 text-xs text-gray-400 text-right">
        Updated: {{ formatTime(userStore.systemStatus.lastUpdate) }}
      </div>
    </div>

    <!-- Navigation Menu -->
    <nav class="flex-1 overflow-y-auto py-3" v-if="isOpen || !isMobile">
      <ul class="space-y-1 px-3">
        <li v-for="(link, index) in links.main" :key="index">
          <router-link
            :to="link.path"
            class="flex items-center p-3 rounded-lg hover:bg-gray-800/50 transition-all group"
            :class="{ 'bg-blue-900/30 border-l-4 border-blue-400': activeLink === link.path }"
            @click="closeSidebar"
          >
            <div class="relative">
              <svg class="w-5 h-5 mr-3 text-gray-400 group-hover:text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="link.icon"/>
              </svg>
            </div>
            <span class="text-gray-300 group-hover:text-white">{{ link.name }}</span>
          </router-link>
        </li>

        <!-- Tank Monitoring Section -->
        <li class="mt-4">
          <p class="text-xs font-semibold text-gray-400 px-3 py-2 uppercase tracking-wider">Tank Monitoring</p>
          <ul class="mt-1 space-y-1">
            <li v-for="(link, index) in links.tankMonitoring" :key="index">
              <router-link
                :to="link.path"
                class="flex items-center p-3 rounded-lg hover:bg-gray-800/50 transition-all group"
                :class="{ 'bg-blue-900/30 border-l-4 border-blue-400': activeLink === link.path }"
                @click="closeSidebar"
              >
                <svg class="w-5 h-5 mr-3 text-gray-400 group-hover:text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="link.icon"/>
                </svg>
                <span class="text-gray-300 group-hover:text-white">{{ link.name }}</span>
              </router-link>
            </li>
          </ul>
        </li>

        <!-- Alerts & Notifications Section -->
        <li class="mt-4">
          <p class="text-xs font-semibold text-gray-400 px-3 py-2 uppercase tracking-wider">Alerts</p>
          <ul class="mt-1 space-y-1">
            <li v-for="(link, index) in links.alerts" :key="index">
              <router-link
                :to="link.path"
                class="flex items-center p-3 rounded-lg hover:bg-gray-800/50 transition-all group"
                :class="{ 'bg-blue-900/30 border-l-4 border-blue-400': activeLink === link.path }"
                @click="closeSidebar"
              >
                <div class="relative">
                  <svg class="w-5 h-5 mr-3 text-gray-400 group-hover:text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="link.icon"/>
                  </svg>
                  <span v-if="link.alertCount" class="absolute -top-1 -right-1 w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
                </div>
                <span class="text-gray-300 group-hover:text-white">{{ link.name }}</span>
                <span v-if="link.alertCount" class="ml-auto px-2 py-0.5 text-xs rounded-full bg-red-900/50 text-red-300">{{ link.alertCount }}</span>
              </router-link>
            </li>
          </ul>
        </li>

        <!-- System Configuration -->
        <li class="mt-4">
          <p class="text-xs font-semibold text-gray-400 px-3 py-2 uppercase tracking-wider">Configuration</p>
          <ul class="mt-1 space-y-1">
            <li v-for="(link, index) in links.configuration" :key="index">
              <router-link
                :to="link.path"
                class="flex items-center p-3 rounded-lg hover:bg-gray-800/50 transition-all group"
                :class="{ 'bg-blue-900/30 border-l-4 border-blue-400': activeLink === link.path }"
                @click="closeSidebar"
              >
                <svg class="w-5 h-5 mr-3 text-gray-400 group-hover:text-blue-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="link.icon"/>
                </svg>
                <span class="text-gray-300 group-hover:text-white">{{ link.name }}</span>
              </router-link>
            </li>
          </ul>
        </li>
      </ul>
    </nav>

    <!-- Bottom Section - User & Logout -->
    <div class="p-4 border-t border-gray-800 bg-gray-900/50 mt-auto" v-if="isOpen || !isMobile">
      <div class="flex items-center space-x-3 mb-4">
        <div class="relative">
          <!-- Profile Image with Fallback -->
          <div v-if="userStore.userProfile?.profile_image_url" class="w-10 h-10 rounded-full overflow-hidden border-2 border-blue-500/30">
            <img 
              class="w-full h-full object-cover" 
              :src="userStore.userProfile.profile_image_url" 
              alt="User profile"
              @error="handleImageError"
            >
          </div>
          <!-- Fallback Avatar -->
          <div v-else class="w-10 h-10 rounded-full bg-gray-600 border-2 border-blue-500/30 flex items-center justify-center">
            <svg class="w-6 h-6 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
            </svg>
          </div>
          <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-gray-900"></span>
        </div>
        <div>
          <p class="font-medium text-gray-200">{{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}</p>
          <p class="text-xs text-gray-400">{{ userStore.userProfile?.role || 'User' }}</p>
        </div>
      </div>
      <button 
        @click="logout"
        class="w-full flex items-center justify-center p-2 rounded-lg bg-gray-800 hover:bg-gray-700/70 text-gray-300 hover:text-white transition-colors"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
        </svg>
        Logout
      </button>
    </div>
  </aside>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '../../stores/user';

// Define props
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  isMobile: {
    type: Boolean,
    default: false,
  },
});

// Define emits
const emit = defineEmits(['close-sidebar']);

// Get router and route instances
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();

// Track active link
const activeLink = ref('');

// Format time
const formatTime = (date) => {
  return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};

// Organized links by section with custom icons
const links = {
  main: [
    { 
      name: "Dashboard", 
      path: "/admin",
      icon: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" 
    },
    { 
    name: "Pricing", 
    path: "/admin/pricing",
    icon: "M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3z" 
  }
  ],
  tankMonitoring: [
    { 
      name: "Analytics", 
      path: "/admin/analytics",
      icon: "M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" 
    },
    { 
      name: "Tank Locations", 
      path: "/admin/tanks/map",
      icon: "M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" 
    },
  ],
  alerts: [
    { 
      name: "Active Alerts", 
      path: "/admin/alerts",
      icon: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9", 
      alertCount: userStore.notifications.filter(n => !n.read).length 
    },
    { 
      name: "Alert History", 
      path: "/admin/alerts/history",
      icon: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" 
    },
  ],
  configuration: [
    {   
      name: "Profile", 
      path: "/admin/profile",
      icon: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" 
    },
    { 
      name: "System Settings", 
      path: "/admin/settings",
      icon: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z" 
    },
    { 
      name: "User Management", 
      path: "/admin/users",
      icon: "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" 
    },
  ]
};

// Update active link when route changes
watch(
  () => route.path,
  (newPath) => {
    activeLink.value = newPath;
  },
  { immediate: true }
);

// Fetch user profile if not loaded
onMounted(async () => {
  if (!userStore.userProfile) {
    await userStore.fetchUserProfile();
  }
  await userStore.fetchSystemStatus();
  await userStore.fetchNotifications();
  
  // Set up periodic refresh (every 5 minutes)
  const statusUpdateInterval = setInterval(userStore.fetchSystemStatus, 300000);
  const notificationsUpdateInterval = setInterval(userStore.fetchNotifications, 300000);
  
  // Clean up intervals when component is unmounted
  onUnmounted(() => {
    clearInterval(statusUpdateInterval);
    clearInterval(notificationsUpdateInterval);
  });
});

// Methods
const closeSidebar = () => {
  if (props.isMobile) {
    emit('close-sidebar');
  }
};

// Handle image loading errors
const handleImageError = () => {
  userStore.userProfile.profile_image_url = '';
};

const logout = () => {
  userStore.clearAuth();
  router.push('/login');
};
</script>

<style scoped>
/* Custom scrollbar for sidebar */
nav::-webkit-scrollbar {
  width: 4px;
}

nav::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}

nav::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
}

nav::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.2);
}

/* Smooth transitions for active states */
.router-link-active {
  transition: all 0.2s ease;
}

/* Gradient border effect for active items */
.border-l-4 {
  border-image: linear-gradient(to bottom, #3b82f6, #1d4ed8) 1;
}

/* Animation for the status indicator */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
.animate-pulse {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
</style>