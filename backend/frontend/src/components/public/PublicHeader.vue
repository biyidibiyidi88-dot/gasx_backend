<template>
  <header class="fixed top-0 left-0 right-0 bg-gray-900/95 border-b border-gray-800 h-16 sm:h-20 z-50">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex items-center justify-between h-full">
        <!-- Logo -->
        <router-link 
          to="/" 
          class="flex items-center space-x-3 group"
          aria-label="Home"
        >
          <div class="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-blue-600 flex items-center justify-center transition-transform group-hover:scale-105">
            <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
          </div>
          <span class="text-lg sm:text-xl font-bold text-white hidden sm:inline-block">GasMonitor</span>
        </router-link>

        <!-- Desktop Navigation -->
        <nav class="hidden lg:flex items-center space-x-6 xl:space-x-8">
          <router-link 
            v-for="link in navLinks" 
            :key="link.path"
            :to="link.path"
            class="text-gray-300 hover:text-white px-2 py-2 text-sm font-medium transition-colors duration-200"
            active-class="text-blue-400 border-b-2 border-blue-400"
          >
            {{ link.label }}
          </router-link>
        </nav>

        <!-- Auth Buttons - Desktop -->
        <div class="hidden lg:flex items-center space-x-4">
          <router-link 
            to="/login" 
            class="text-gray-300 hover:text-white px-3 py-2 text-sm font-medium transition-colors duration-200"
          >
            Sign In
          </router-link>
          <router-link 
            to="/register" 
            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors duration-200"
          >
            Get Started
          </router-link>
        </div>

        <!-- Mobile menu button -->
        <button 
          @click="isMobileMenuOpen = !isMobileMenuOpen"
          class="lg:hidden text-gray-400 hover:text-white focus:outline-none transition-colors duration-200"
          aria-label="Toggle menu"
        >
          <svg class="h-6 w-6 sm:h-7 sm:w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path 
              stroke-linecap="round" 
              stroke-linejoin="round" 
              stroke-width="2" 
              :d="isMobileMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'" 
            />
          </svg>
        </button>
      </div>
    </div>

    <!-- Mobile menu -->
    <transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="transform opacity-0 -translate-y-2"
      enter-to-class="transform opacity-100 translate-y-0"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="transform opacity-100 translate-y-0"
      leave-to-class="transform opacity-0 -translate-y-2"
    >
      <div 
        v-show="isMobileMenuOpen"
        class="lg:hidden absolute top-16 sm:top-20 inset-x-0 bg-gray-900 border-t border-gray-800 shadow-lg"
      >
        <div class="px-4 pt-4 pb-4 space-y-2">
          <router-link
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            @click="isMobileMenuOpen = false"
            class="block px-4 py-3 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-800 transition-colors duration-200"
            active-class="text-blue-400 bg-gray-800"
          >
            {{ link.label }}
          </router-link>
          <div class="border-t border-gray-800 pt-3">
            <router-link
              to="/login"
              @click="isMobileMenuOpen = false"
              class="block px-4 py-3 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-800 transition-colors duration-200"
            >
              Sign In
            </router-link>
            <router-link
              to="/register"
              @click="isMobileMenuOpen = false"
              class="block px-4 py-3 rounded-md text-base font-medium text-white bg-blue-600 hover:bg-blue-700 transition-colors duration-200"
            >
              Get Started
            </router-link>
          </div>
        </div>
      </div>
    </transition>
  </header>
</template>

<script setup>
import { ref } from 'vue';
import { RouterLink } from 'vue-router';

const isMobileMenuOpen = ref(false);

const navLinks = [
  { path: '/', label: 'Home' },
  { path: '/features', label: 'Features' },
  { path: '/pricing', label: 'Pricing' },
  { path: '/about', label: 'About' },
  { path: '/contact', label: 'Contact' }
];
</script>

<style scoped>
/* .router-link-active:not(.router-link-exact-active) {
  @apply text-gray-300;
} */
</style>