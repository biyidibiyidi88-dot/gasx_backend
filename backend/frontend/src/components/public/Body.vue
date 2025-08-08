<template>
    <main class="min-h-screen pt-16 pb-12"> <!-- pt-16 accounts for fixed header -->
      <!-- Router view handles all page content -->
      <div class="container mx-auto px-4 sm:px-6 py-8">
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
  // No need to import page components here - they're handled by the router
  </script>
  
  <style>
  /* Smooth page transition effects */
  .page-fade-enter-active,
  .page-fade-leave-active {
    transition: opacity 0.3s ease;
  }
  
  .page-fade-enter-from,
  .page-fade-leave-to {
    opacity: 0;
  }
  
  /* Ensure proper spacing for all content */
  @media (min-width: 1024px) {
    .container {
      max-width: 1280px;
    }
  }
  </style>