<template>
  <main
    :class="[
      isDark ? 'bg-gray-950' : 'bg-gray-50',
      'flex-1 transition-all duration-700 cubic-bezier(0.4, 0, 0.2, 1) overflow-y-auto min-h-screen pt-16 sm:pt-20',
      {
        'ml-80': !isSidebarCollapsed && !isMobile,
        'ml-0': isSidebarCollapsed || isMobile,
        'w-full': isMobile
      }
    ]"
  >
    <div class="max-w-8xl mx-auto p-4 sm:p-10 lg:p-14">
      <router-view v-slot="{ Component }">
        <transition
          name="page-fade"
          mode="out-in"
        >
          <component :is="Component" />
        </transition>
      </router-view>
    </div>
  </main>
</template>

<script setup>
import { useTheme } from '../../composables/useTheme';

const { isDark, themeClasses } = useTheme();

const props = defineProps({
  isSidebarCollapsed: { type: Boolean, default: false },
  isMobile: { type: Boolean, default: false }
});
</script>

<style scoped>
main {
  transition-property: margin, width, padding;
  scrollbar-gutter: stable;
}

/* Premium Scrollbar */
main::-webkit-scrollbar {
  width: 6px;
}

main::-webkit-scrollbar-track {
  background: transparent;
}

main::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
}

main::-webkit-scrollbar-thumb:hover {
  background: rgba(45, 212, 191, 0.2);
}

/* Page Transitions */
.page-fade-enter-active,
.page-fade-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.page-fade-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.98);
}

.page-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px) scale(0.98);
}
</style>