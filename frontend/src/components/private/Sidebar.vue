<template>
  <aside :class="[
      isDark ? 'bg-gray-950/60 backdrop-blur-3xl border-white/5' : 'bg-white/95 backdrop-blur-xl border-gray-200',
      themeClasses.text.primary,
      'fixed top-0 left-0 h-screen flex flex-col transition-all duration-700 cubic-bezier(0.4, 0, 0.2, 1) z-[70] border-r shadow-[20px_0_50px_rgba(0,0,0,0.5)]',
      {
        'w-80 translate-x-0': isOpen,
        '-translate-x-full lg:translate-x-0': !isOpen,
        'lg:w-80': !isMobile,
        'w-0 overflow-hidden hidden': !isOpen && isMobile,
        'p-6 sm:p-8': isMobile
      }
    ]" role="navigation" aria-label="GaSX Sidebar">
    
    <!-- Mobile Close Button -->
    <button 
      v-if="isMobile && isOpen"
      @click="emit('close-sidebar')"
      class="absolute top-8 right-6 w-10 h-10 flex items-center justify-center rounded-xl bg-white/5 border border-white/10 text-white hover:bg-red-500/20 hover:border-red-500/50 hover:text-red-400 transition-all duration-300 z-[80]"
      aria-label="Close sidebar"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/>
      </svg>
    </button>
    
    <!-- Logo Section -->
    <div class="p-8 relative overflow-hidden group">
      <div class="absolute -top-10 -left-10 w-40 h-40 bg-teal-500/10 blur-[80px] group-hover:bg-teal-500/20 transition-all duration-700"></div>
      <div class="flex items-center space-x-5 relative z-10">
        <div class="relative">
          <div class="absolute inset-0 bg-teal-400 blur-xl opacity-20 group-hover:opacity-40 transition-opacity"></div>
          <div class="relative w-12 h-12 rounded-2xl bg-gradient-to-br from-teal-400 to-blue-600 flex items-center justify-center shadow-2xl shadow-teal-500/20 transform group-hover:scale-110 group-hover:rotate-6 transition-all duration-500">
            <svg class="w-7 h-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <span
            :class="['absolute -top-1 -right-1 w-4 h-4 rounded-full border-[3px]', isDark ? 'border-gray-950' : 'border-white', userStore.systemStatus.operational ? 'bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]' : 'bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.5)]']"></span>
        </div>
        <div class="flex flex-col text-left">
          <h1 class="text-2xl font-black tracking-tighter text-white uppercase leading-none">
            Ga<span class="text-teal-400">SX</span>
          </h1>
          <div class="flex items-center space-x-1.5 mt-1">
            <span class="w-1 h-1 rounded-full bg-teal-500 animate-pulse"></span>
            <span class="text-[9px] font-black tracking-[0.3em] text-white/40 uppercase">Intelligence Pro</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Live Metrics Summary -->
    <div class="px-8 py-2 mb-6" v-if="isOpen || !isMobile">
      <div class="relative group">
        <div class="absolute inset-0 bg-gradient-to-r from-teal-500/10 to-blue-500/10 blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
        <div :class="[isDark ? 'bg-white/[0.03] border-white/5' : 'bg-gray-100 border-gray-200', 'relative rounded-[2rem] p-5 border backdrop-blur-sm transition-all duration-500 group-hover:border-white/10 group-hover:translate-y-[-2px]']">
          <div class="flex items-center justify-between mb-5">
            <span class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30">Network Status</span>
            <div class="px-2.5 py-1 rounded-full bg-teal-400/10 border border-teal-400/20">
              <span class="text-[9px] font-black text-teal-400 uppercase tracking-widest">Active</span>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-6 text-left">
            <div class="flex flex-col">
              <span class="text-3xl font-black text-white leading-none tracking-tighter">{{ userStore.systemStatus.tanks }}</span>
              <span class="text-[9px] font-bold uppercase tracking-widest text-white/20 mt-2">Nodes</span>
            </div>
            <div class="flex flex-col border-l border-white/5 pl-6">
              <span class="text-3xl font-black text-teal-400 leading-none tracking-tighter">{{ userStore.systemStatus.normal }}</span>
              <span class="text-[9px] font-bold uppercase tracking-widest text-white/20 mt-2">Optimal</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Navigation Menu -->
    <nav class="flex-1 overflow-y-auto px-6 custom-scrollbar" v-if="isOpen || !isMobile">
      <div class="space-y-10 pt-4 pb-10">
        <!-- Section: Analytics -->
        <div v-for="(group, groupName) in links" :key="groupName" class="text-left">
          <span class="px-5 text-[10px] font-black uppercase tracking-[0.3em] text-white/20 mb-6 block">
            {{ groupName }}
          </span>
          <ul class="space-y-2">
            <li v-for="link in group" :key="link.path">
              <router-link :to="link.path" :class="[
                  'flex items-center px-5 py-4 rounded-2xl transition-all duration-500 group relative overflow-hidden',
                  activeLink === link.path 
                    ? 'bg-teal-400/10 text-white font-black shadow-[0_10px_30px_rgba(45,212,191,0.1)]'
                    : 'text-white/40 hover:text-white hover:bg-white/[0.03]'
                ]" @click="closeSidebar">
                <!-- Active Indicator -->
                <div v-if="activeLink === link.path" class="absolute left-0 top-4 bottom-4 w-1 bg-teal-400 rounded-full shadow-[0_0_15px_rgba(45,212,191,1)]"></div>
                
                <svg
                  :class="['w-5 h-5 mr-4 transition-all duration-500 group-hover:scale-110 group-hover:rotate-3', activeLink === link.path ? 'text-teal-400 drop-shadow-[0_0_8px_rgba(45,212,191,0.5)]' : 'text-current']"
                  fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" :d="link.icon" />
                </svg>
                <span class="text-[13px] tracking-wide uppercase font-bold">{{ link.name }}</span>
                
                <!-- Alert Badge -->
                <div v-if="link.alertCount" class="ml-auto flex items-center">
                  <span class="w-1.5 h-1.5 rounded-full bg-red-500 animate-ping absolute"></span>
                  <span class="relative w-1.5 h-1.5 rounded-full bg-red-500"></span>
                </div>
              </router-link>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <!-- User Profile & Session -->
    <div class="p-8 bg-gray-950/40 border-t border-white/5 relative overflow-hidden group/session" v-if="isOpen || !isMobile">
      <div class="absolute inset-0 bg-teal-500/5 translate-y-full group-hover/session:translate-y-0 transition-transform duration-700"></div>
      
      <router-link to="/admin/profile" class="flex items-center space-x-4 mb-8 relative group/profile">
        <div class="relative">
          <div class="absolute inset-0 bg-teal-400/20 blur opacity-0 group-hover/profile:opacity-100 transition-opacity duration-500"></div>
          <div class="w-14 h-14 rounded-[1.2rem] overflow-hidden border-2 border-white/10 relative z-10 p-0.5">
            <div class="w-full h-full rounded-[1rem] overflow-hidden bg-gray-900">
              <img v-if="userStore.userProfile?.profile_image_url" 
                   class="w-full h-full object-cover grayscale group-hover/profile:grayscale-0 transition-all duration-700 scale-100 group-hover/profile:scale-110" 
                   :src="userStore.userProfile.profile_image_url" 
                   alt="Profile"
                   @error="handleImageError">
              <div v-else class="w-full h-full flex items-center justify-center text-white/20">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
            </div>
          </div>
          <div class="absolute -bottom-1 -right-1 w-4 h-4 bg-teal-400 rounded-full border-[3px] border-gray-950 z-20 shadow-lg"></div>
        </div>
        <div class="flex flex-col min-w-0 text-left">
          <p class="text-sm font-black text-white truncate uppercase tracking-tighter leading-none mb-1.5">
            {{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}
          </p>
          <p class="text-[9px] font-black text-white/30 uppercase tracking-[0.2em] leading-none">
            {{ userStore.userProfile?.role || 'Operator' }}
          </p>
        </div>
      </router-link>

      <button @click="logout"
        class="w-full py-4 px-6 rounded-2xl bg-white/[0.03] hover:bg-red-500 border border-white/5 hover:border-red-500 text-white/40 hover:text-white transition-all duration-500 group/logout shadow-2xl overflow-hidden relative">
        <div class="relative z-10 flex items-center justify-center">
          <svg class="w-5 h-5 mr-3 transition-transform duration-500 group-hover/logout:-translate-x-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          <span class="text-[11px] font-black uppercase tracking-[0.2em]">End Session</span>
        </div>
      </button>
    </div>
  </aside>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useUserStore } from '../../stores/user';
import { useTheme } from '../../composables/useTheme';

// Theme composable
const { isDark, themeClasses } = useTheme();

// Define props
const props = defineProps({
  isOpen: { type: Boolean, default: false },
  isMobile: { type: Boolean, default: false }
});

const emit = defineEmits(['close-sidebar']);
const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const activeLink = ref('');

// Organized links by section
const links = computed(() => {
  const role = userStore.userProfile?.role;
  const isAdmin = userStore.userProfile?.is_admin || role === 'Super Admin' || role === 'Admin';
  
  if (role === 'Vendor') {
    return {
      "Vendor Dashboard": [
        { 
          name: "My Inventory", 
          path: "/admin/vendor-inventory",
          icon: "M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" 
        },
        { 
          name: "Profile & Documents", 
          path: "/admin/vendor-profile",
          icon: "M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" 
        }
      ]
    };
  }

  const nav = {
    Analytics: [
      { 
        name: "Intelligence", 
        path: "/admin",
        icon: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" 
      },
      { 
        name: "Network", 
        path: "/admin/pricing",
        icon: "M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3z" 
      }
    ],
    Monitoring: [
      { 
        name: "Alerts", 
        path: "/admin/alerts",
        icon: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9",
        alertCount: userStore.notifications.filter(n => !n.read).length 
      },
      { 
        name: "AI Hub", 
        path: "/admin/ai-chat",
        icon: "M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" 
      },
      { 
        name: "Find Gas", 
        path: "/admin/gas-map",
        icon: "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z" 
      }
    ],
    System: [
      {   
        name: "Identity", 
        path: "/admin/profile",
        icon: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" 
      }
    ]
  };

  if (isAdmin) {
    nav.System.push(
      { 
        name: "Controls", 
        path: "/admin/users",
        icon: "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" 
      },
      { 
        name: "Vendor Validation", 
        path: "/admin/vendor-validation",
        icon: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" 
      }
    );
  }

  return nav;
});

watch(() => route.path, (newPath) => { activeLink.value = newPath; }, { immediate: true });

onMounted(async () => {
  if (!userStore.userProfile) await userStore.fetchUserProfile();
  await userStore.fetchSystemStatus();
  await userStore.fetchNotifications();
  const updateInterval = setInterval(() => {
    userStore.fetchSystemStatus();
    userStore.fetchNotifications();
  }, 300000);
  onUnmounted(() => clearInterval(updateInterval));
});

const closeSidebar = () => { if (props.isMobile) emit('close-sidebar'); };
const handleImageError = () => { if (userStore.userProfile) userStore.userProfile.profile_image_url = ''; };
const logout = () => { userStore.clearAuth(); router.push('/login'); };
</script>

<style scoped>
nav::-webkit-scrollbar { width: 4px; }
nav::-webkit-scrollbar-track { background: transparent; }
nav::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
nav::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

@keyframes pulse {
  0%, 100% { opacity: 1; filter: brightness(1); }
  50% { opacity: 0.7; filter: brightness(1.5); }
}
.animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }

.cubic-bezier { transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); }
</style>