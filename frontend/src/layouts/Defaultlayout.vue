<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen flex flex-col relative']">
    <!-- Header -->
    <Header
      :sidebar-collapsed="sidebarCollapsed"
      :unread-notifications="unreadNotifications"
      @toggle-sidebar="handleSidebarToggle"
      @show-notifications="handleNotifications"
    />
    
    <div class="flex flex-1 flex-col md:flex-row">
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
      <div
        v-if="isMobile && !sidebarCollapsed"
        class="fixed inset-0 bg-black/50 z-40 md:hidden"
        @click="handleSidebarToggle(true)"
      ></div>
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
const sidebarCollapsed = ref(window.innerWidth < 768);
const isMobile = ref(window.innerWidth < 768);
const unreadNotifications = ref(3); // Example value for notifications

const handleSidebarToggle = (isCollapsed) => {
  sidebarCollapsed.value = isCollapsed !== undefined ? isCollapsed : !sidebarCollapsed.value;
};

const handleNotifications = () => {
  console.log('Notifications clicked');
};

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
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
    showNotificationMessage('Failed to load profile', 'error');
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