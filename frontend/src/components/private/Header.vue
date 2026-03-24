<template>
  <header
    :class="[
      isDark ? 'bg-gray-950/40 backdrop-blur-3xl border-white/5' : 'bg-white/95 backdrop-blur-xl border-gray-200',
      'fixed top-0 right-0 h-16 sm:h-20 flex items-center justify-between px-6 sm:px-10 z-[80] transition-all duration-700 cubic-bezier(0.4, 0, 0.2, 1) border-b',
      isMobile || sidebarCollapsed ? 'left-0' : 'left-80 shadow-[0_10px_40px_rgba(0,0,0,0.3)]'
    ]"
  >
    <!-- Left: Mobile Toggle & Context -->
    <div class="flex items-center space-x-6">
      <button 
        v-if="isMobile" 
        @click="emit('toggle-sidebar', !sidebarCollapsed)" 
        class="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white hover:bg-white/10 transition-all duration-300"
        aria-label="Toggle sidebar"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 6h16M4 12h16M4 18h16"/>
        </svg>
      </button>

      <div class="flex items-center space-x-6">
        <div class="flex flex-col">
          <span class="text-[9px] font-black uppercase tracking-[0.2em] text-white/30 sm:flex hidden">System Status</span>
          <div class="flex items-center space-x-2 mt-1">
            <span :class="['w-2.5 h-2.5 rounded-full animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]', userStore.systemStatus.operational ? 'bg-teal-400' : 'bg-red-500']"></span>
            <span :class="['text-[10px] font-black uppercase tracking-widest', userStore.systemStatus.operational ? 'text-teal-400' : 'text-red-500', 'hidden sm:inline']">
              {{ userStore.systemStatus.operational ? 'Operational' : 'Degraded' }}
            </span>
          </div>
        </div>
        
        <div class="h-8 w-px bg-white/5 hidden sm:block"></div>

        <div class="hidden sm:flex flex-col">
          <span class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30">Last Pulse</span>
          <span class="text-xs font-black uppercase tracking-widest text-white mt-1">
            {{ formatTime(userStore.systemStatus.lastUpdate) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Right: Actions & User -->
    <div class="flex items-center space-x-6">
      <!-- Theme Toggle -->
      <button 
        @click="toggleTheme" 
        class="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white hover:bg-teal-500 hover:text-gray-950 transition-all duration-500 group"
      >
        <svg v-if="isDark" class="h-5 w-5 transform group-hover:rotate-45 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
        </svg>
        <svg v-else class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
        </svg>
      </button>

      <!-- Notifications -->
      <div class="relative">
        <button 
          @click="toggleNotifications"
          class="w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white hover:bg-teal-500 hover:text-gray-950 transition-all duration-500 relative"
          aria-label="Show notifications"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
          </svg>
          <span
            v-if="unreadNotificationsCount > 0"
            class="absolute -top-1 -right-1 flex h-4 w-4"
          >
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
            <span class="relative inline-flex rounded-full h-4 w-4 bg-red-500 border-2 border-gray-950 text-[8px] items-center justify-center font-black">{{ unreadNotificationsCount }}</span>
          </span>
        </button>

        <!-- Notifications dropdown -->
        <transition
          enter-active-class="transition ease-out duration-500"
          enter-from-class="transform opacity-0 -translate-y-4 scale-95"
          enter-to-class="transform opacity-100 translate-y-0 scale-100"
          leave-active-class="transition ease-in duration-300"
          leave-from-class="transform opacity-100 translate-y-0 scale-100"
          leave-to-class="transform opacity-0 -translate-y-4 scale-95"
        >
          <div
            v-show="notificationsOpen"
            class="absolute right-0 mt-4 w-96 rounded-3xl bg-gray-950/90 backdrop-blur-3xl border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] overflow-hidden z-50"
            @click.stop
          >
            <div class="px-6 py-5 border-b border-white/5 flex justify-between items-center bg-white/[0.02]">
              <h3 class="text-xs font-black uppercase tracking-[0.2em] text-white">Intelligence Log</h3>
              <button 
                @click="markAllAsRead"
                class="text-[10px] font-black uppercase tracking-widest text-teal-400 hover:text-teal-300 transition-colors"
                :disabled="unreadNotificationsCount === 0"
              >
                Clear all
              </button>
            </div>
            
            <div class="max-h-[32rem] overflow-y-auto custom-scrollbar">
              <template v-if="userStore.notifications.length > 0">
                <div 
                  v-for="notification in userStore.notifications"
                  :key="notification.id"
                  :class="[
                    'px-6 py-5 border-b border-white/5 last:border-b-0 transition-all duration-300 hover:bg-white/[0.03] cursor-pointer',
                    { 'bg-teal-500/[0.02]': !notification.read }
                  ]"
                  @click="handleNotificationClick(notification)"
                >
                  <div class="flex items-start">
                    <div class="flex-shrink-0 mt-1">
                      <div :class="['w-10 h-10 rounded-xl flex items-center justify-center', getNotificationBgClass(notification)]">
                        <svg 
                          class="w-5 h-5"
                          :class="getNotificationIconClass(notification)"
                          fill="none" 
                          stroke="currentColor" 
                          viewBox="0 0 24 24"
                        >
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" :d="getNotificationIconPath(notification)"/>
                        </svg>
                      </div>
                    </div>
                    <div class="ml-4 flex-1">
                      <div class="flex items-center justify-between mb-1">
                        <p class="text-[13px] font-black text-white uppercase tracking-tight">
                          {{ notification.title }}
                        </p>
                        <span class="text-[9px] font-bold text-white/20 uppercase">
                          {{ formatTime(notification.timestamp) }}
                        </span>
                      </div>
                      <p class="text-xs text-white/40 leading-relaxed">
                        {{ notification.message }}
                      </p>
                    </div>
                  </div>
                </div>
              </template>
              
              <div v-else class="px-6 py-10 text-center">
                <div class="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mx-auto mb-4">
                  <svg class="w-8 h-8 text-white/10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                  </svg>
                </div>
                <p class="text-[10px] font-black uppercase tracking-[0.2em] text-white/20">System idle</p>
              </div>
            </div>
          </div>
        </transition>
      </div>

      <!-- User Avatar -->
      <div class="relative ml-2">
        <button
          class="flex items-center space-x-4 group"
          @click.stop="toggleDropdown"
          aria-label="User menu"
        >
          <div class="hidden md:flex flex-col text-right">
            <p class="text-sm font-black text-white uppercase tracking-tighter leading-none mb-1">
              {{ userStore.userProfile?.first_name }}
            </p>
            <p class="text-[9px] font-black text-white/30 uppercase tracking-widest leading-none">
              Control
            </p>
          </div>
          <div class="relative">
            <div class="absolute inset-0 bg-teal-400 blur opacity-0 group-hover:opacity-40 transition-opacity"></div>
            <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl overflow-hidden border-2 border-white/10 group-hover:border-teal-500/50 transition-all duration-500 p-0.5 relative z-10">
              <div class="w-full h-full rounded-xl overflow-hidden bg-gray-900 flex items-center justify-center">
                <img v-if="userStore.userProfile?.profile_image_url" 
                     class="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-700" 
                     :src="userStore.userProfile.profile_image_url" 
                     alt="User"
                     @error="handleImageError">
                <svg v-else class="w-6 h-6 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
              </div>
            </div>
          </div>
        </button>

        <!-- Dropdown menu -->
        <transition
          enter-active-class="transition ease-out duration-500"
          enter-from-class="transform opacity-0 -translate-y-4 scale-95"
          enter-to-class="transform opacity-100 translate-y-0 scale-100"
          leave-active-class="transition ease-in duration-300"
          leave-from-class="transform opacity-100 translate-y-0 scale-100"
          leave-to-class="transform opacity-0 -translate-y-4 scale-95"
        >
          <div
            v-show="dropdownOpen"
            class="absolute right-0 mt-4 w-60 rounded-3xl bg-gray-950/90 backdrop-blur-3xl border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] py-2 z-50 overflow-hidden"
            @click.stop
          >
            <div class="px-6 py-4 border-b border-white/5 bg-white/[0.02] mb-2">
              <p class="text-[13px] font-black text-white uppercase tracking-tight truncate">{{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}</p>
              <p class="text-[10px] text-white/30 truncate mt-0.5">{{ userStore.userProfile?.email }}</p>
            </div>
            
            <router-link 
              to="/admin/profile" 
              class="flex items-center px-6 py-3.5 text-xs font-black uppercase tracking-widest text-white/50 hover:text-white hover:bg-white/[0.03] transition-all duration-300"
            >
              <svg class="w-4 h-4 mr-3 text-teal-400/50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
              Profile
            </router-link>
            
            <button
              @click="logout"
              class="w-full flex items-center px-6 py-3.5 text-xs font-black uppercase tracking-widest text-red-400 hover:text-white hover:bg-red-500/80 transition-all duration-300"
            >
              <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
              </svg>
              Logout
            </button>
          </div>
        </transition>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useUserStore } from '../../stores/user';
import { useTheme } from '../../composables/useTheme';

const { isDark, toggleTheme } = useTheme();
const userStore = useUserStore();
const router = useRouter();

const props = defineProps({
  sidebarCollapsed: { type: Boolean, default: false },
  isMobile: { type: Boolean, default: false }
});

const emit = defineEmits(['toggle-sidebar']);

const notificationsOpen = ref(false);
const dropdownOpen = ref(false);

const unreadNotificationsCount = computed(() => 
  userStore.notifications.filter(n => !n.read).length
);

const formatTime = (date) => {
  if (!date) return '--:--';
  return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};

const toggleNotifications = () => {
  notificationsOpen.value = !notificationsOpen.value;
  if (dropdownOpen.value) dropdownOpen.value = false;
};

const toggleDropdown = () => {
  dropdownOpen.value = !dropdownOpen.value;
  if (notificationsOpen.value) notificationsOpen.value = false;
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
  if (userStore.userProfile) {
    userStore.userProfile.profile_image_url = '';
  }
};

// Check mobile view
const checkMobile = () => {
  // Mobile check logic is already in Defaultlayout, but kept here for consistency if needed
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

let notificationsUpdateInterval;

// Lifecycle hooks
onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  window.addEventListener('resize', checkMobile);
  
  // Fetch notifications initially
  userStore.fetchNotifications();
  
  // Set up periodic refresh (every 10 minutes)
  notificationsUpdateInterval = setInterval(userStore.fetchNotifications, 600000);
});

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside);
  window.removeEventListener('resize', checkMobile);
  if (notificationsUpdateInterval) {
    clearInterval(notificationsUpdateInterval);
  }
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