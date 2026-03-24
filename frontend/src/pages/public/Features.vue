<template>
  <div class="features-page min-h-screen pt-24 pb-16 sm:pt-48 sm:pb-40 overflow-hidden relative">
    <!-- Sophisticated 3D Background System -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-teal-500/10 blur-[150px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-blue-600/10 blur-[180px] animate-pulse-slow" style="animation-delay: 2s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <!-- Hero Section -->
    <section class="relative mb-24">
  <div class="container mx-auto px-6 text-center">
    <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8 animate-fade-in">
      <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
      <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">System Capability</span>
    </div>
    
    <h1 class="text-4xl sm:text-7xl font-black text-white mb-6 tracking-tighter uppercase italic leading-[0.9] animate-title">
      Autonomous<br>
      <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent">Grid Logic</span>
    </h1>
    
    <p class="text-lg sm:text-xl text-white/40 max-w-3xl mx-auto font-medium tracking-tight animate-fade-in" style="animation-delay: 0.2s">
      Deep-layer integration of advanced sensing protocols and neural monitoring.
    </p>
  </div>
</section>

    <!-- Main Features Grid -->
    <section class="pb-32">
      <div class="container mx-auto px-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
          <div 
            v-for="(feature, index) in features"
            :key="index"
            class="group relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 hover:border-teal-500/30 transition-all duration-700 hover:shadow-[0_20px_60px_rgba(0,0,0,0.5)]"
          >
            <div class="w-16 h-16 bg-white/5 rounded-2xl flex items-center justify-center mb-10 border border-white/10 group-hover:bg-teal-400 transition-all duration-500">
              <component 
                :is="feature.icon" 
                class="w-8 h-8 text-teal-400 group-hover:text-gray-950 transition-colors"
                v-html="feature.iconTemplate"
              />
            </div>
            <h3 class="text-2xl font-black text-white mb-4 uppercase tracking-tight">
              {{ feature.title }}
            </h3>
            <p class="text-white/40 leading-relaxed font-medium">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Feature Details -->
    <section class="py-16 sm:py-40 bg-white/[0.01] relative overflow-hidden">
      <div class="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent"></div>
      <div class="container mx-auto px-6">
        <!-- Detail 1 -->
        <div class="flex flex-col lg:flex-row items-center gap-12 lg:gap-20 mb-24 sm:mb-40">
          <div class="lg:w-1/2">
            <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 mb-8">
              <span class="w-1.5 h-1.5 rounded-full bg-blue-400"></span>
              <span class="text-[10px] font-black uppercase tracking-[0.3em] text-blue-400">Zero Latency</span>
            </div>
            <h2 class="text-3xl sm:text-6xl font-black text-white mb-6 sm:mb-8 tracking-tighter uppercase italic leading-[1.1]">
              Instant Pulse<br>Notifications
            </h2>
            <p class="text-xl text-white/40 mb-10 font-medium leading-relaxed">
              Immediate algorithmic warnings deployed across multiple encrypted channels.
            </p>
            <ul class="space-y-6">
              <li v-for="item in alertDetails" :key="item" class="flex items-center group/item">
                <div class="w-1.5 h-1.5 rounded-full bg-teal-400 mr-4 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
                <span class="text-xs font-black uppercase tracking-widest text-white/60 group-hover/item:text-white transition-colors">{{ item }}</span>
              </li>
            </ul>
          </div>
          <div class="lg:w-1/2 relative group">
            <div class="absolute inset-0 bg-blue-400/20 blur-[100px] opacity-10 group-hover:opacity-30 transition-opacity"></div>
            <div class="relative overflow-hidden rounded-3xl sm:rounded-[3rem] border border-white/10 bg-gray-900 shadow-2xl">
              <img 
                src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=1632&q=80" 
                alt="Architecture" 
                class="w-full h-auto opacity-40 group-hover:opacity-100 transition-all duration-1000 group-hover:scale-105"
              >
            </div>
          </div>
        </div>

        <!-- Detail 2 -->
        <div class="flex flex-col lg:flex-row-reverse items-center gap-12 lg:gap-20">
          <div class="lg:w-1/2">
            <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8">
              <span class="w-1.5 h-1.5 rounded-full bg-teal-400"></span>
              <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">Deep Analytics</span>
            </div>
            <h2 class="text-3xl sm:text-6xl font-black text-white mb-6 sm:mb-8 tracking-tighter uppercase italic leading-[1.1]">
              Historical<br>Trend Logic
            </h2>
            <p class="text-xl text-white/40 mb-10 font-medium leading-relaxed">
              Mapping consumption paths to optimize efficiency and security.
            </p>
            <ul class="space-y-6">
              <li v-for="item in analyticsDetails" :key="item" class="flex items-center group/item">
                <div class="w-1.5 h-1.5 rounded-full bg-teal-400 mr-4 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
                <span class="text-xs font-black uppercase tracking-widest text-white/60 group-hover/item:text-white transition-colors">{{ item }}</span>
              </li>
            </ul>
          </div>
          <div class="lg:w-1/2 relative group">
            <div class="absolute inset-0 bg-teal-400/20 blur-[100px] opacity-10 group-hover:opacity-30 transition-opacity"></div>
            <div class="relative overflow-hidden rounded-3xl sm:rounded-[3rem] border border-white/10 bg-gray-900 shadow-2xl">
              <img 
                src="https://images.unsplash.com/photo-1551434678-e076c223a692?ixlib=rb-4.0.3&auto=format&fit=crop&w=1740&q=80" 
                alt="System Analytics" 
                class="w-full h-auto opacity-40 group-hover:opacity-100 transition-all duration-1000 group-hover:scale-105"
              >
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-32 bg-white/[0.01] relative overflow-hidden">
      <div class="absolute bottom-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent"></div>
      <div class="container mx-auto px-6 text-center">
        <div class="max-w-4xl mx-auto bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[4rem] p-10 sm:p-20 relative overflow-hidden">
          <div class="absolute -right-20 -bottom-20 w-64 h-64 bg-teal-400/10 blur-[100px] rounded-full"></div>
          
          <h2 class="text-3xl sm:text-6xl font-black text-white mb-8 sm:mb-10 tracking-tighter uppercase italic leading-tight relative z-10">
            Initialize Your<br>Safe Grid
          </h2>
          <p class="text-white/40 font-medium mb-12 max-w-2xl mx-auto relative z-10 uppercase tracking-widest text-xs">
            Join the collective intelligence network protecting tomorrow's infrastructure.
          </p>
          <div class="flex flex-col sm:flex-row justify-center gap-6 relative z-10">
            <router-link 
              to="/register" 
              class="px-10 py-5 sm:px-12 sm:py-6 bg-teal-400 text-gray-950 font-black rounded-2xl transition-all duration-500 hover:scale-110 hover:shadow-[0_0_80px_rgba(45,212,191,0.5)] uppercase tracking-[0.2em] text-sm"
            >
              Access Network
            </router-link>
            <router-link 
              to="/contact" 
              class="px-10 py-5 sm:px-12 sm:py-6 bg-white/5 border border-white/10 text-white font-black rounded-2xl transition-all duration-500 hover:bg-white/10 uppercase tracking-[0.2em] text-sm"
            >
              Contact Command
            </router-link>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const features = ref([
  {
    title: "Pulse Tracking",
    description: "24/7 autonomous monitoring of nodes with 30-second interval validation.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" /></svg>`
  },
  {
    title: "Logic Alerts",
    description: "Customizable neural interrupts for low-threshold or unsafe conditions.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>`
  },
  {
    title: "Trend Engine",
    description: "Deep analytics for consumption pattern mapping and efficiency optimization.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" /></svg>`
  },
  {
    title: "Mesh Storage",
    description: "Distributed historical logs with immutable backup protocols.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" /></svg>`
  },
  {
    title: "Security Nodes",
    description: "Automatic intervention protocols during critical danger detection.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>`
  },
  {
    title: "Universal Link",
    description: "Seamless synchronization with global smart-grid home platforms.",
    iconTemplate: `<svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" /></svg>`
  }
]);

const alertDetails = [
  "Encrypted mobile push interrupts",
  "Neural log reporting via email",
  "Critical SMS override pulse"
];

const analyticsDetails = [
  "Consumption bias identification",
  "Predictive swarm replenishment",
  "Efficiency curve optimization"
];
</script>

<style scoped>
.features-page {
  scroll-behavior: smooth;
}
@keyframes pulse-slow {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.15; transform: scale(1.05); }
}
.animate-pulse-slow { 
  animation: pulse-slow 8s ease-in-out infinite; 
}

<style scoped>
.features-page {
  scroll-behavior: smooth;
}

/* New Animations */
@keyframes fade-in { 
  from { opacity: 0; transform: translateY(30px); } 
  to { opacity: 1; transform: translateY(0); } 
}

@keyframes title-slide {
  from { letter-spacing: -2em; filter: blur(20px); opacity: 0; }
  to { letter-spacing: -0.05em; filter: blur(0); opacity: 1; }
}

@keyframes pulse-slow {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.15; transform: scale(1.05); }
}

/* Animation Classes */
.animate-fade-in { 
  animation: fade-in 1.2s cubic-bezier(0.16, 1, 0.3, 1) forwards; 
}

.animate-title { 
  animation: title-slide 1.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; 
}

.animate-pulse-slow { 
  animation: pulse-slow 8s ease-in-out infinite; 
}

</style>
