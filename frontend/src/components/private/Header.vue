<template>
  <header
    :class="[
      'fixed top-0 right-0 h-16 bg-gray-900 shadow-lg flex items-center justify-between px-4 sm:px-6 z-30 transition-all duration-300 border-b border-gray-800',
      sidebarCollapsed ? 'left-0' : 'left-72',
      isMobile ? 'left-0' : ''
    ]"
  >
    <!-- Mobile menu button -->
    <button 
      v-if="isMobile" 
      @click="emit('toggle-sidebar', !sidebarCollapsed)" 
      class="text-gray-400 hover:text-blue-400 focus:outline-none transition-colors"
      aria-label="Toggle sidebar"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
      </svg>
    </button>

    <!-- System status indicators -->
    <div class="flex items-center space-x-4 ml-4">
      <div class="hidden sm:flex items-center space-x-2">
        <span class="text-xs text-gray-400">System Status:</span>
        <span class="flex items-center">
          <span class="w-2 h-2 rounded-full mr-1 animate-pulse"
                :class="userStore.systemStatus.operational ? 'bg-green-500' : 'bg-red-500'"></span>
          <span class="text-xs font-medium"
                :class="userStore.systemStatus.operational ? 'text-green-400' : 'text-red-400'">
            {{ userStore.systemStatus.operational ? 'Operational' : 'Degraded' }}
          </span>
        </span>
      </div>
      
      <div class="hidden md:flex items-center space-x-2">
        <span class="text-xs text-gray-400">Last Update:</span>
        <span class="text-xs font-medium text-gray-300">
          {{ formatTime(userStore.systemStatus.lastUpdate) }}
        </span>
      </div>
    </div>

    <!-- User controls -->
    <div class="flex items-center space-x-4">
      <!-- Notification button -->
      <div class="relative">
        <button 
          class="text-gray-400 hover:text-blue-400 focus:outline-none transition-colors relative p-1"
          @click="toggleNotifications"
          aria-label="Show notifications"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
          </svg>
          <span
            v-if="unreadNotificationsCount > 0"
            class="absolute top-0 right-0 h-2.5 w-2.5 rounded-full bg-red-500 border border-gray-900"
          >
            <span class="absolute top-0 right-0 h-full w-full rounded-full bg-red-500 animate-ping opacity-75"></span>
          </span>
        </button>

        <!-- Notifications dropdown -->
        <transition
          enter-active-class="transition ease-out duration-100"
          enter-from-class="transform opacity-0 scale-95"
          enter-to-class="transform opacity-100 scale-100"
          leave-active-class="transition ease-in duration-75"
          leave-from-class="transform opacity-100 scale-100"
          leave-to-class="transform opacity-0 scale-95"
        >
          <div
            v-show="notificationsOpen"
            class="absolute right-0 mt-2 w-72 bg-gray-800 rounded-md shadow-xl py-1 z-40 border border-gray-700 max-h-96 overflow-y-auto"
            @click.stop
          >
            <div class="px-4 py-2 border-b border-gray-700 flex justify-between items-center">
              <h3 class="text-sm font-medium text-white">Notifications</h3>
              <button 
                @click="markAllAsRead"
                class="text-xs text-blue-400 hover:text-blue-300"
                :disabled="unreadNotificationsCount === 0"
              >
                Mark all as read
              </button>
            </div>
            
            <template v-if="userStore.notifications.length > 0">
              <div 
                v-for="notification in userStore.notifications"
                :key="notification.id"
                class="px-4 py-3 border-b border-gray-700 last:border-b-0 hover:bg-gray-700/50 transition-colors"
                :class="{ 'bg-gray-700/30': !notification.read }"
                @click="handleNotificationClick(notification)"
              >
                <div class="flex items-start">
                  <div class="flex-shrink-0 pt-0.5">
                    <svg 
                      class="h-5 w-5"
                      :class="getNotificationIconClass(notification)"
                      fill="none" 
                      stroke="currentColor" 
                      viewBox="0 0 24 24"
                    >
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getNotificationIconPath(notification)"/>
                    </svg>
                  </div>
                  <div class="ml-3 flex-1">
                    <p class="text-sm font-medium text-white">
                      {{ notification.title }}
                    </p>
                    <p class="text-xs text-gray-300 mt-1">
                      {{ notification.message }}
                    </p>
                    <p class="text-xs text-gray-400 mt-1">
                      {{ formatTime(notification.timestamp) }}
                    </p>
                  </div>
                  <div v-if="!notification.read" class="ml-2 flex-shrink-0">
                    <span class="h-2 w-2 rounded-full bg-blue-500"></span>
                  </div>
                </div>
              </div>
            </template>
            
            <div v-else class="px-4 py-4 text-center">
              <p class="text-sm text-gray-400">No notifications</p>
            </div>
          </div>
        </transition>
      </div>

      <!-- Fullscreen toggle -->
      <button 
        class="text-gray-400 hover:text-blue-400 focus:outline-none transition-colors hidden sm:block"
        @click="toggleFullscreen"
        aria-label="Toggle fullscreen"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"/>
        </svg>
      </button>

      <!-- User profile dropdown -->
      <div class="relative">
        <button
          class="flex items-center space-x-2 focus:outline-none"
          @click.stop="toggleDropdown"
          aria-label="Toggle user dropdown"
        >
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

          <div class="hidden md:block text-left">
            <p class="text-xs font-medium text-gray-200 truncate max-w-[120px]">
              {{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}
            </p>
            <p class="text-xs text-gray-400">{{ userStore.userProfile?.role || 'User' }}</p>
          </div>
          <svg
            class="hidden md:block w-4 h-4 text-gray-500 transform transition-transform duration-200"
            :class="{ 'rotate-180': dropdownOpen }"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </button>

        <!-- Dropdown menu -->
        <transition
          enter-active-class="transition ease-out duration-100"
          enter-from-class="transform opacity-0 scale-95"
          enter-to-class="transform opacity-100 scale-100"
          leave-active-class="transition ease-in duration-75"
          leave-from-class="transform opacity-100 scale-100"
          leave-to-class="transform opacity-0 scale-95"
        >
          <div
            v-show="dropdownOpen"
            class="absolute right-0 mt-2 w-48 bg-gray-800 rounded-md shadow-xl py-1 z-40 border border-gray-700"
            @click.stop
          >
            <div class="px-4 py-2 border-b border-gray-700">
              <p class="text-sm font-medium text-white">{{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}</p>
              <p class="text-xs text-gray-400">{{ userStore.userProfile?.email }}</p>
            </div>
            <router-link 
              to="admin/profile" 
              class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white"
            >
              <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
              Profile
            </router-link>
            <router-link 
              to="/settings" 
              class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white"
            >
              <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
              </svg>
              Settings
            </router-link>
            <div class="border-t border-gray-700"></div>
            <a
              href="#"
              class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-red-400"
              @click.prevent="logout"
            >
              <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
              </svg>
              Logout
            </a>
          </div>
        </transition>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';
import { useUserStore } from '../../stores/user';

const props = defineProps({
  sidebarCollapsed: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['toggle-sidebar', 'show-notifications']);

const router = useRouter();
const userStore = useUserStore();
const isMobile = ref(window.innerWidth < 768);
const dropdownOpen = ref(false);
const notificationsOpen = ref(false);

// Format time
const formatTime = (date) => {
  return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};

// Computed properties
const unreadNotificationsCount = computed(() => {
  return userStore.notifications.filter(n => !n.read).length;
});

// Notification methods
const toggleNotifications = () => {
  notificationsOpen.value = !notificationsOpen.value;
  if (notificationsOpen.value && unreadNotificationsCount.value > 0) {
    userStore.fetchNotifications();
  }
};

const markAllAsRead = async () => {
  await userStore.clearNotifications();
};

const handleNotificationClick = async (notification) => {
  if (!notification.read) {
    await userStore.markNotificationAsRead(notification.id);
  }
  
  // Handle navigation based on notification type
  if (notification.link) {
    router.push(notification.link);
  }
  
  notificationsOpen.value = false;
};

const getNotificationIconClass = (notification) => {
  switch (notification.type) {
    case 'alert': return 'text-red-400';
    case 'warning': return 'text-yellow-400';
    case 'info': return 'text-blue-400';
    case 'success': return 'text-green-400';
    default: return 'text-gray-400';
  }
};

const getNotificationIconPath = (notification) => {
  switch (notification.type) {
    case 'alert': 
      return 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z';
    case 'warning':
      return 'M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z';
    case 'info':
      return 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z';
    case 'success':
      return 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z';
    default:
      return 'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9';
  }
};

// Toggle dropdown
const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
};

// Toggle fullscreen
const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen().catch(err => {
      console.error(`Error attempting to enable fullscreen: ${err.message}`);
    });
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    }
  }
};

// Close dropdown when clicking outside
const handleClickOutside = (event) => {
  if (dropdownOpen.value && !event.target.closest('.relative')) {
    dropdownOpen.value = false;
  }
  if (notificationsOpen.value && !event.target.closest('.relative')) {
    notificationsOpen.value = false;
  }
};

// Handle image error
const handleImageError = () => {
  userStore.userProfile.profile_image_url = '';
};

// Check mobile view
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
};

// Logout
const logout = async () => {
  try {
    await userStore.clearAuth();
    router.push('/login');
  } catch (error) {
    console.error('Logout failed:', error);
  }
};

// Lifecycle hooks
onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  window.addEventListener('resize', checkMobile);
  
  // Fetch notifications initially
  userStore.fetchNotifications();
  
  // Set up periodic refresh (every 10 minutes)
  const notificationsUpdateInterval = setInterval(userStore.fetchNotifications, 600000);
  
  onBeforeUnmount(() => {
    clearInterval(notificationsUpdateInterval);
  });
});

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside);
  window.removeEventListener('resize', checkMobile);
});
</script>

<style scoped>
.transition-all {
  transition: all 0.3s ease-in-out;
}

/* Animation for the notification ping */
@keyframes ping {
  0% {
    transform: scale(0.8);
    opacity: 0.8;
  }
  70%, 100% {
    transform: scale(2);
    opacity: 0;
  }
}
.animate-ping {
  animation: ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
}

/* Custom scrollbar for notifications dropdown */
::-webkit-scrollbar {
  width: 6px;
}
::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}
::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
}
::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.2);
}
</style>