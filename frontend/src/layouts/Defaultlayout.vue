<template>
  <div :class="[isDark ? 'bg-gray-950' : 'bg-gray-50', 'min-h-screen flex flex-col relative overflow-hidden transition-colors duration-700']">
    <!-- Header -->
    <Header
      :sidebar-collapsed="sidebarCollapsed"
      :unread-notifications="unreadNotifications"
      :is-mobile="isMobile"
      @toggle-sidebar="handleSidebarToggle"
      @show-notifications="handleNotifications"
    />
    
    <div class="flex flex-1 flex-col md:flex-row relative">
      <!-- Sidebar -->
      <Sidebar
        :is-open="!sidebarCollapsed"
        :is-mobile="isMobile"
        @close-sidebar="handleSidebarToggle(true)"
      />
      
      <!-- Main content area (Body) -->
      <Body
        :is-sidebar-collapsed="sidebarCollapsed"
        :is-mobile="isMobile"
      />
      
      <!-- Backdrop for mobile sidebar -->
      <transition
        enter-active-class="transition-opacity duration-700"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition-opacity duration-500"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isMobile && !sidebarCollapsed"
          class="fixed inset-0 bg-gray-950/80 backdrop-blur-md z-[60] md:hidden cursor-pointer"
          @click="handleSidebarToggle(true)"
        ></div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import Header from '../components/private/Header.vue';
import Sidebar from '../components/private/Sidebar.vue';
import Body from '../components/private/Body.vue';
import { useUserStore } from '../stores/user';
import { useTheme } from '../composables/useTheme';

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme(); 

const userStore = useUserStore();
const sidebarCollapsed = ref(window.innerWidth < 1024);
const isMobile = ref(window.innerWidth < 1024);
const unreadNotifications = ref(3); // Example value for notifications

const handleSidebarToggle = (isCollapsed) => {
  sidebarCollapsed.value = isCollapsed !== undefined ? isCollapsed : !sidebarCollapsed.value;
};

const handleNotifications = () => {
  console.log('Notifications clicked');
};

const checkMobile = () => {
  isMobile.value = window.innerWidth < 1024;
  if (isMobile.value) {
    sidebarCollapsed.value = true;
  } else {
    sidebarCollapsed.value = false;
  }
};

onMounted(async () => {
  try {
    await userStore.fetchUserProfile();
  } catch (error) {
    console.error('Failed to fetch user profile:', error);
  }
  window.addEventListener('resize', checkMobile);
});

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile);
});
</script>

<style scoped>
/* Ensure smooth transitions for the layout */
.transition-all {
  transition: all 0.3s ease-in-out;
}
</style>