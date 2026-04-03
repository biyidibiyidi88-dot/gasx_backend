<template>
  <header class="fixed top-0 left-0 right-0 bg-gray-950/20 backdrop-blur-2xl border-b border-white/5 h-16 sm:h-24 z-50 transition-all duration-500">
    <div class="container mx-auto px-4 sm:px-6 lg:px-8 h-full">
      <div class="grid grid-cols-2 lg:grid-cols-3 items-center h-full">
        <!-- Logo -->
        <div class="flex items-center justify-start">
          <router-link 
            to="/" 
            class="flex items-center space-x-3 group"
            aria-label="Home"
          >
            <span class="text-xl sm:text-3xl font-black tracking-tighter text-white hidden sm:inline-block">
              Ga<span class="text-teal-400">SX</span>
            </span>
            <div class="relative">
              <div class="absolute inset-0 bg-teal-500 blur-xl opacity-20 group-hover:opacity-40 transition-opacity"></div>
              <div class="relative w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-gradient-to-br from-teal-400 to-blue-600 flex items-center justify-center transform group-hover:scale-110 transition-all duration-500 shadow-2xl shadow-teal-500/20 overflow-hidden">
                <img src="/favicon.png" alt="Logo" class="w-full h-full object-cover">
              </div>
            </div>
          </router-link>
        </div>

        <!-- Desktop Navigation - Centered -->
        <nav class="hidden lg:flex items-center justify-center space-x-2">
          <router-link 
            v-for="link in navLinks" 
            :key="link.path"
            :to="link.path"
            class="relative px-5 py-2 text-[13px] font-bold uppercase tracking-widest text-gray-400 hover:text-white transition-all duration-300 group"
          >
            {{ link.label }}
            <span class="absolute -bottom-1 left-5 right-5 h-0.5 bg-teal-400 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-500 origin-center"></span>
          </router-link>
        </nav>

        <!-- Auth Buttons - Desktop -->
        <div class="hidden lg:flex items-center justify-end space-x-8">
          <router-link 
            to="/login" 
            class="text-[13px] font-bold uppercase tracking-widest text-gray-400 hover:text-white transition-colors duration-300"
          >
            Sign In
          </router-link>
          <router-link 
            to="/register" 
            class="relative group px-8 py-3.5 bg-teal-500 text-gray-950 text-[13px] font-black uppercase tracking-[0.2em] rounded-full overflow-hidden transition-all duration-500 hover:scale-105 hover:shadow-[0_0_40px_rgba(45,212,191,0.4)]"
          >
            <div class="absolute inset-0 bg-gradient-to-r from-teal-400 to-blue-500 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
            <span class="relative z-10 transition-colors duration-500 group-hover:text-white">Book a demo</span>
          </router-link>
        </div>

        <!-- Mobile menu button -->
        <div class="flex items-center justify-end lg:hidden">
          <button 
            @click="isMobileMenuOpen = !isMobileMenuOpen"
            class="relative w-12 h-12 flex items-center justify-center rounded-2xl bg-white/5 border border-white/10 text-white hover:bg-white/10 transition-all duration-300"
            aria-label="Toggle menu"
          >
            <div class="w-6 h-6 relative flex flex-col justify-center items-center">
              <span :class="['w-6 h-0.5 bg-current rounded-full transition-all duration-500', isMobileMenuOpen ? 'rotate-45 translate-y-0.5' : '-translate-y-1.5']"></span>
              <span :class="['w-4 h-0.5 bg-current rounded-full transition-all duration-500 absolute', isMobileMenuOpen ? 'opacity-0 scale-0' : 'opacity-100 scale-100 translate-x-1']"></span>
              <span :class="['w-6 h-0.5 bg-current rounded-full transition-all duration-500', isMobileMenuOpen ? '-rotate-45 -translate-y-0.5' : 'translate-y-1.5']"></span>
            </div>
          </button>
        </div>
      </div>
    </div>

    <!-- Mobile menu -->
    <transition
      enter-active-class="transition ease-out duration-500"
      enter-from-class="transform opacity-0 -translate-y-20 scale-95"
      enter-to-class="transform opacity-100 translate-y-0 scale-100"
      leave-active-class="transition ease-in duration-300"
      leave-from-class="transform opacity-100 translate-y-0 scale-100"
      leave-to-class="transform opacity-0 -translate-y-20 scale-95"
    >
      <div 
        v-show="isMobileMenuOpen"
        class="lg:hidden absolute top-0 inset-x-0 h-screen bg-gray-950/95 backdrop-blur-3xl z-[-1] flex items-center justify-center"
      >
        <div class="container mx-auto px-10 flex flex-col items-center space-y-8">
          <router-link
            v-for="link in navLinks"
            :key="link.path"
            :to="link.path"
            @click="isMobileMenuOpen = false"
            class="text-4xl font-black text-gray-400 hover:text-white hover:scale-110 transition-all duration-300 uppercase tracking-tighter"
          >
            {{ link.label }}
          </router-link>
          
          <div class="w-full h-px bg-white/10 my-8"></div>
          
          <router-link
            to="/login"
            @click="isMobileMenuOpen = false"
            class="text-xl font-bold uppercase tracking-widest text-gray-400 hover:text-white"
          >
            Sign In
          </router-link>
          
          <router-link
            to="/register"
            @click="isMobileMenuOpen = false"
            class="w-full max-w-xs py-6 bg-teal-500 text-gray-950 text-center font-black uppercase tracking-[0.2em] rounded-full shadow-2xl shadow-teal-500/20"
          >
            Book a demo
          </router-link>
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