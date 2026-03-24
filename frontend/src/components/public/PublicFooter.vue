<template>
  <footer class="relative z-20 bg-gray-950/20 backdrop-blur-3xl border-t border-white/5 py-20 overflow-hidden">
    <!-- Subtle Glow -->
    <div class="absolute -bottom-40 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-teal-500/10 blur-[120px] rounded-full pointer-events-none"></div>

    <div class="container mx-auto px-4 sm:px-6 relative">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-16">
        <!-- Brand Section -->
        <div class="space-y-8">
          <router-link to="/" class="flex items-center space-x-3 group">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-teal-400 to-blue-600 flex items-center justify-center transform group-hover:scale-110 transition-all duration-500 shadow-xl shadow-teal-500/20">
              <svg class="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <span class="text-2xl font-black tracking-tighter text-white">
              Gas<span class="text-teal-400">Track</span>
            </span>
          </router-link>
          <p class="text-gray-400 text-sm leading-relaxed max-w-xs">
            Next-generation gas monitoring for institutional and residential intelligence. Capture, structure, and leverage your energy data at scale.
          </p>
          <div class="flex space-x-6">
            <a v-for="social in socialLinks" :key="social.label" :href="social.path" class="text-gray-500 hover:text-teal-400 transition-colors duration-300">
              <span class="sr-only">{{ social.label }}</span>
              <component :is="social.icon" class="h-5 w-5" />
            </a>
          </div>
        </div>

        <!-- Links Columns -->
        <div v-for="group in linkGroups" :key="group.title">
          <h3 class="text-[11px] font-black uppercase tracking-[0.2em] text-white/40 mb-8">{{ group.title }}</h3>
          <ul class="space-y-4">
            <li v-for="link in group.links" :key="link.label">
              <router-link 
                :to="link.path" 
                class="text-sm text-gray-400 hover:text-white transition-colors duration-300 flex items-center group"
              >
                {{ link.label }}
                <svg class="w-3 h-3 ml-2 opacity-0 -translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-300 text-teal-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7" />
                </svg>
              </router-link>
            </li>
          </ul>
        </div>

        <!-- Newsletter -->
        <div class="space-y-8">
          <h3 class="text-[11px] font-black uppercase tracking-[0.2em] text-white/40 mb-8">Newsletter</h3>
          <p class="text-gray-400 text-sm">Get the latest insights on energy efficiency.</p>
          <form @submit.prevent="subscribe" class="relative group">
            <input
              v-model="email"
              type="email"
              required
              placeholder="Email address"
              class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl text-white text-sm focus:outline-none focus:border-teal-500/50 focus:ring-4 focus:ring-teal-500/10 transition-all duration-500"
            />
            <button
              type="submit"
              class="absolute right-2 top-2 bottom-2 px-4 bg-teal-500 text-gray-950 text-xs font-black uppercase tracking-widest rounded-xl hover:bg-teal-400 transition-colors duration-300"
            >
              Join
            </button>
          </form>
        </div>
      </div>

      <!-- Copyright -->
      <div class="mt-20 pt-8 border-t border-white/5 flex flex-col md:flex-row justify-between items-center text-[11px] font-bold uppercase tracking-widest text-white/20">
        <p>&copy; {{ new Date().getFullYear() }} GasTrack AI. All rights reserved.</p>
        <div class="flex space-x-8 mt-4 md:mt-0">
          <router-link to="/privacy" class="hover:text-white transition-colors">Privacy</router-link>
          <router-link to="/terms" class="hover:text-white transition-colors">Terms</router-link>
        </div>
      </div>
    </div>
  </footer>
</template>
  
<script setup>
import { ref, h } from 'vue';

const email = ref('');

const socialLinks = [
  { 
    label: 'Twitter', 
    path: '#', 
    icon: () => h('svg', { fill: 'currentColor', viewBox: '0 0 24 24' }, [
      h('path', { d: 'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.045 4.126H5.078z' })
    ])
  },
  { 
    label: 'GitHub', 
    path: '#', 
    icon: () => h('svg', { fill: 'currentColor', viewBox: '0 0 24 24' }, [
      h('path', { 'fill-rule': 'evenodd', d: 'M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z', 'clip-rule': 'evenodd' })
    ])
  }
];

const linkGroups = [
  {
    title: 'Platform',
    links: [
      { path: '/features', label: 'Features' },
      { path: '/pricing', label: 'Pricing' },
      { path: '/how-it-works', label: 'Intelligence' },
      { path: '/integrations', label: 'Network' }
    ]
  },
  {
    title: 'Company',
    links: [
      { path: '/about', label: 'About Us' },
      { path: '/blog', label: 'Insights' },
      { path: '/careers', label: 'Careers' },
      { path: '/contact', label: 'Contact' }
    ]
  }
];

const subscribe = () => {
  console.log('Subscribed:', email.value);
  email.value = '';
};
</script>

<style scoped>
/* .router-link-active {
  @apply text-blue-400;
} */
</style>