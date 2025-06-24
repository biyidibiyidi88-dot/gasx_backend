
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
        @click="$emit('toggle-sidebar', !sidebarCollapsed)" 
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
            <span class="w-2 h-2 rounded-full bg-green-500 mr-1 animate-pulse"></span>
            <span class="text-xs font-medium text-green-400">Operational</span>
          </span>
        </div>
        
        <div class="hidden md:flex items-center space-x-2">
          <span class="text-xs text-gray-400">Last Update:</span>
          <span class="text-xs font-medium text-gray-300">2 min ago</span>
        </div>
      </div>
  
      <!-- User controls -->
      <div class="flex items-center space-x-4">
        <!-- Notification button with critical alerts indicator -->
        <div class="relative">
          <button 
            class="text-gray-400 hover:text-blue-400 focus:outline-none transition-colors relative p-1"
            @click="$emit('show-notifications')"
            aria-label="Show notifications"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
            <span
              v-if="unreadNotifications > 0"
              class="absolute top-0 right-0 h-2.5 w-2.5 rounded-full bg-red-500 border border-gray-900"
            >
              <span class="absolute top-0 right-0 h-full w-full rounded-full bg-red-500 animate-ping opacity-75"></span>
            </span>
          </button>
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
        <div class="relative group">
          <button
            class="flex items-center space-x-2 focus:outline-none"
            @click.stop="toggleDropdown"
            aria-label="Toggle user dropdown"
          >
            <div class="relative">
              <img 
                class="h-8 w-8 rounded-full border-2 border-blue-500/30" 
                src="https://randomuser.me/api/portraits/men/32.jpg" 
                alt="User profile"
              >
              <span class="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-green-500 border border-gray-900"></span>
            </div>
            <div class="hidden md:block text-left">
              <p class="text-xs font-medium text-gray-200 truncate max-w-[120px]">John Doe</p>
              <p class="text-xs text-gray-400">Administrator</p>
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
              <a href="#" class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white">
                <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
                Profile
              </a>
              <a href="#" class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white">
                <svg class="w-4 h-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                </svg>
                Settings
              </a>
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
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'MonitoringHeader',
    props: {
      sidebarCollapsed: {
        type: Boolean,
        default: false,
      },
      unreadNotifications: {
        type: Number,
        default: 0,
      },
    },
    data() {
      return {
        dropdownOpen: false,
        isMobile: window.innerWidth < 768,
        products: [],
      };
    },
    methods: {
      checkMobile() {
        this.isMobile = window.innerWidth < 768;
      },
      logout() {
        this.$router.push('/login');
        this.closeDropdown();
      },
      toggleDropdown() {
        this.dropdownOpen = !this.dropdownOpen;
      },
      closeDropdown() {
        this.dropdownOpen = false;
      },
      toggleFullscreen() {
        if (!document.fullscreenElement) {
          document.documentElement.requestFullscreen().catch(err => {
            console.error(`Error attempting to enable fullscreen: ${err.message}`);
          });
        } else {
          if (document.exitFullscreen) {
            document.exitFullscreen();
          }
        }
      },
    },



    mounted() {
      document.addEventListener('click', this.closeDropdown);
      window.addEventListener('resize', this.checkMobile);

      axios.get('http://127.0.0.1:8000/api/products/')
        .then(response => {
          this.products = response.data;
        })
        .catch(error => {
          console.error('Failed to fetch products:', error);
        });
    },



    beforeDestroy() {
      document.removeEventListener('click', this.closeDropdown);
      window.removeEventListener('resize', this.checkMobile);
    },
  };
  </script>
  
  <style scoped>
  /* Custom transition for dropdown */
  .transition-all {
    transition: all 0.3s ease-in-out;
  }
  </style>