<template>
    <footer class=" text-gray-400   bg-gray-900/ z-50 border-t border-gray-800">
      <div class="container mx-auto px-4 sm:px-6 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <!-- Logo and description -->
          <div class="space-y-4">
            <div class="flex items-center space-x-2">
              <div class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center">
                <svg class="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <span class="text-xl font-bold text-white">GasMonitor</span>
            </div>
            <p class="text-sm">
              Smart gas monitoring solutions for modern homes and businesses.
            </p>
            <div class="flex space-x-4">
              <a href="#" class="text-gray-400 hover:text-white transition-colors">
                <span class="sr-only">Twitter</span>
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" />
                </svg>
              </a>
              <a href="#" class="text-gray-400 hover:text-white transition-colors">
                <span class="sr-only">GitHub</span>
                <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path fill-rule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clip-rule="evenodd" />
                </svg>
              </a>
            </div>
          </div>
  
          <!-- Quick Links -->
          <div>
            <h3 class="text-sm font-semibold text-white uppercase tracking-wider">Solutions</h3>
            <ul class="mt-4 space-y-2">
              <li v-for="link in solutionLinks" :key="link.path">
                <router-link 
                  :to="link.path" 
                  class="text-sm hover:text-white transition-colors"
                >
                  {{ link.label }}
                </router-link>
              </li>
            </ul>
          </div>
  
          <!-- Support -->
          <div>
            <h3 class="text-sm font-semibold text-white uppercase tracking-wider">Support</h3>
            <ul class="mt-4 space-y-2">
              <li v-for="link in supportLinks" :key="link.path">
                <router-link 
                  :to="link.path" 
                  class="text-sm hover:text-white transition-colors"
                >
                  {{ link.label }}
                </router-link>
              </li>
            </ul>
          </div>
  
          <!-- Newsletter -->
          <div>
            <h3 class="text-sm font-semibold text-white uppercase tracking-wider">Stay Updated</h3>
            <p class="mt-4 text-sm">
              Subscribe to our newsletter for the latest updates.
            </p>
            <form @submit.prevent="subscribe" class="mt-4 flex">
              <input
                v-model="email"
                type="email"
                required
                placeholder="Your email"
                class="px-3 py-2 bg-gray-800 text-white text-sm rounded-l-md focus:outline-none focus:ring-1 focus:ring-blue-500 w-full"
              />
              <button
                type="submit"
                class="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-r-md hover:bg-blue-700 focus:outline-none focus:ring-1 focus:ring-blue-500 transition-colors"
              >
                Subscribe
              </button>
            </form>
          </div>
        </div>
  
        <!-- Copyright -->
        <div class="mt-12 pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center">
          <p class="text-sm">
            &copy; {{ new Date().getFullYear() }} GasMonitor. All rights reserved.
          </p>
          <div class="flex space-x-6 mt-4 md:mt-0">
            <router-link 
              to="/privacy" 
              class="text-sm hover:text-white transition-colors"
            >
              Privacy Policy
            </router-link>
            <router-link 
              to="/terms" 
              class="text-sm hover:text-white transition-colors"
            >
              Terms of Service
            </router-link>
          </div>
        </div>
      </div>
    </footer>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  
  const email = ref('');
  
  const solutionLinks = [
    { path: '/features', label: 'Features' },
    { path: '/pricing', label: 'Pricing' },
    { path: '/how-it-works', label: 'How It Works' },
    { path: '/integrations', label: 'Integrations' }
  ];
  
  const supportLinks = [
    { path: '/contact', label: 'Contact Us' },
    { path: '/faq', label: 'FAQs' },
    { path: '/documentation', label: 'Documentation' },
    { path: '/support', label: 'Customer Support' }
  ];
  
  const subscribe = () => {
    // Handle subscription logic
    console.log('Subscribed with:', email.value);
    email.value = '';
    alert('Thank you for subscribing!');
  };
  </script>
  
  <style scoped>
  /* .router-link-active {
    @apply text-blue-400;
  } */
  </style>