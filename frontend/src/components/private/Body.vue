<template>
    <main
      :class="[
        themeClasses.bg.primary,
        'flex-1 transition-all duration-300 overflow-y-auto min-h-screen mt-16',
        {
          'ml-72': !isSidebarCollapsed && !isMobile,
          'ml-0': isSidebarCollapsed || isMobile,
          'w-full': isMobile
        }
      ]"
    >
      <div class="max-w-7xl mx-auto p-6">
        <router-view />
      </div>
    </main>
  </template>
  
  <script setup>
  import { useTheme } from '../../composables/useTheme';
  
  // Theme composable
  const { isDark, toggleTheme, themeClasses } = useTheme();
  
  // Define props
  const props = defineProps({
    isSidebarCollapsed: {
      type: Boolean,
      default: false,
    },
    isMobile: {
      type: Boolean,
      default: false,
    }
  });
  </script>
  
  <style scoped>
  main {
    transition-property: margin, width;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  main::-webkit-scrollbar {
    width: 8px;
  }
  
  main::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.05);
  }
  
  main::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.1);
    border-radius: 4px;
  }
  
  main::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 0, 0, 0.2);
  }
  </style>