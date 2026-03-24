<template>
  <div class="home-page min-h-screen pt-24 pb-16 sm:pt-48 sm:pb-40 overflow-hidden font-['Inter',-apple-system,BlinkMacSystemFont,sans-serif]  relative selection:bg-teal-400 selection:text-gray-900">
    
    <!-- Sophisticated 3D Background Elements -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 left-1/4 w-[800px] h-[800px] bg-teal-500/10 blur-[180px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 right-1/4 w-[900px] h-[900px] bg-blue-600/10 blur-[200px] animate-pulse-slow" style="animation-delay: 2s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <!-- Hero Section -->
    <section class="relative pt-24 pb-16 sm:pt-56 sm:pb-48">
      <div class="container mx-auto px-6 relative z-10">
        <div class="max-w-5xl mx-auto text-center">
          <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8 animate-fade-in shadow-[0_0_30px_rgba(45,212,191,0.1)]">
            <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
            <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Autonomous Network v4.0.2</span>
          </div>
          
          <h1 class="text-4xl sm:text-7xl font-black text-white mb-6 tracking-tighter uppercase italic leading-[0.9] animate-title">
            LOGIC<br>
            <span class="bg-gradient-to-r from-teal-400 via-blue-500 to-indigo-600 bg-clip-text text-transparent">OVERDRIVE</span>
          </h1>
          
          <p class="text-lg sm:text-xl text-white/40 mb-12 max-w-3xl mx-auto font-medium tracking-tight leading-relaxed animate-fade-in" style="animation-delay: 0.2s">
            Industrial-grade gas telemetry powered by autonomous intelligence. Secure your infrastructure with zero-latency neural tracking.
          </p>
          
          <div class="flex flex-col sm:flex-row justify-center gap-4 sm:gap-8 animate-fade-in" style="animation-delay: 0.4s">
            <router-link 
              to="/register" 
              class="group relative px-10 py-5 sm:px-14 sm:py-6 bg-teal-400 text-gray-950 font-black rounded-2xl sm:rounded-3xl transition-all duration-700 hover:scale-105 hover:shadow-[0_0_60px_rgba(45,212,191,0.5)] uppercase tracking-[0.3em] text-xs overflow-hidden"
            >
              <span class="relative z-10 italic">Deploy Uplink</span>
              <div class="absolute inset-0 bg-white/30 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000 skew-x-[-20deg]"></div>
            </router-link>
            <router-link 
              to="/features" 
              class="px-10 py-5 sm:px-14 sm:py-6 bg-white/[0.02] backdrop-blur-2xl border border-white/10 text-white/60 font-black rounded-2xl sm:rounded-3xl transition-all duration-700 hover:bg-white/5 hover:text-white uppercase tracking-[0.3em] text-xs italic"
            >
              Intelligence Hub
            </router-link>
          </div>
        </div>
      </div>

      <!-- Scroll Indicator -->
      <div class="absolute bottom-10 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 opacity-20 hover:opacity-100 transition-opacity duration-700 cursor-pointer">
        <span class="text-[8px] font-black uppercase tracking-[0.5em] text-white italic">Stream Down</span>
        <div class="w-px h-16 bg-gradient-to-b from-teal-400 to-transparent"></div>
      </div>
    </section>

    <!-- Core Architecture -->
    <section class="py-16 sm:py-56 relative">
      <div class="absolute top-0 left-1/2 -translate-x-1/2 w-3/4 h-px bg-gradient-to-r from-transparent via-teal-400/20 to-transparent"></div>
      
      <div class="container mx-auto px-6">
        <div class="flex flex-col md:flex-row justify-between items-end gap-10 mb-24">
          <div class="max-w-2xl">
            <p class="text-xs font-black text-teal-400 uppercase tracking-[0.5em] mb-4 italic">Precision Engineering</p>
            <h2 class="text-4xl sm:text-7xl font-black text-white tracking-tighter uppercase italic leading-none">
              Core Network<br>Architecture
            </h2>
          </div>
          <div class="text-[9px] font-black text-white/20 uppercase tracking-[0.3em] italic border-l border-white/5 pl-8 md:max-w-[200px]">
            REDERIVING SCALABILITY THROUGH DECENTRALIZED SENSORY NODES.
          </div>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <div 
            v-for="(feature, index) in features"
            :key="index"
            class="group relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 hover:border-teal-500/30 transition-all duration-700 hover:translate-y-[-12px] overflow-hidden"
          >
            <!-- Card Glow -->
            <div class="absolute -top-20 -right-20 w-40 h-40 bg-teal-400/5 blur-[60px] group-hover:bg-teal-400/10 transition-all duration-700"></div>
            
            <div class="w-20 h-20 bg-teal-400/10 rounded-[2rem] flex items-center justify-center mb-10 border border-teal-400/20 group-hover:bg-teal-400 transition-all duration-700 group-hover:rotate-12 group-hover:shadow-[0_0_30px_rgba(45,212,191,0.3)]">
              <component :is="feature.icon" class="w-10 h-10 text-teal-400 group-hover:text-gray-950 transition-colors duration-700"/>
            </div>
            
            <h3 class="text-3xl font-black text-white mb-6 uppercase tracking-tighter italic">
              {{ feature.title }}
            </h3>
            <p class="text-white/30 leading-relaxed font-bold text-sm tracking-tight italic uppercase">
              {{ feature.description }}
            </p>

            <div class="mt-10 pt-8 border-t border-white/5 flex items-center justify-between opacity-0 group-hover:opacity-100 transition-opacity duration-700">
               <span class="text-[9px] font-black text-teal-400 uppercase tracking-widest italic">Sequence_0{{ index + 1 }}</span>
               <svg class="w-4 h-4 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M17 8l4 4m0 0l-4 4m4-4H3"/></svg>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Visual Layer -->
    <section class="py-16 sm:py-56 bg-white/[0.005] relative overflow-hidden">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_70%_50%,_rgba(45,212,191,0.05),_transparent)]"></div>
      
      <div class="container mx-auto px-6 relative z-10">
        <div class="flex flex-col lg:flex-row items-center gap-16 lg:gap-32">
          <div class="lg:w-5/12">
            <h2 class="text-3xl sm:text-6xl font-black text-white mb-6 sm:mb-8 tracking-tighter uppercase italic leading-[1.1]">
              ZERO BIAS<br>
              <span class="text-teal-400 decoration-white/10 underline underline-offset-8">TOTAL_LOGIC</span>
            </h2>
            <p class="text-xl text-white/30 mb-14 font-medium leading-relaxed italic uppercase tracking-tighter">
              Our neural interface provides real-time visualization of environmental metrics with military-grade precision.
            </p>
            <ul class="space-y-8">
              <li v-for="(item, index) in demoFeatures" :key="index" class="flex items-center group cursor-crosshair">
                <div class="w-8 h-8 rounded-2xl bg-teal-500/10 border border-teal-500/20 flex items-center justify-center mr-6 group-hover:bg-teal-400 group-hover:border-teal-400 transition-all duration-700 group-hover:scale-110">
                  <svg class="w-4 h-4 text-teal-400 group-hover:text-gray-950 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M5 13l4 4L19 7"/></svg>
                </div>
                <span class="text-white/40 font-black uppercase tracking-[0.2em] text-[10px] italic group-hover:text-white transition-colors duration-500">{{ item }}</span>
              </li>
            </ul>
          </div>

          <div class="lg:w-7/12 relative group/scene perspective-1000">
            <div class="absolute inset-0 bg-teal-400/30 blur-[150px] opacity-10 group-hover/scene:opacity-30 transition-all duration-1000"></div>
            
            <!-- High-Tech Mocker -->
            <div class="relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[4rem] p-10 sm:p-20 shadow-[0_40px_100px_rgba(0,0,0,0.8)] overflow-hidden transition-all duration-1000 group-hover/scene:rotate-x-12 group-hover/scene:rotate-y-[-12px] group-hover/scene:scale-105">
               <div class="aspect-video bg-white/[0.01] rounded-2xl sm:rounded-[3rem] overflow-hidden relative flex items-center justify-center border border-white/5">
                 <div class="absolute inset-0 opacity-20" style="background-image: linear-gradient(#2dd4bf 1px, transparent 1px), linear-gradient(90deg, #2dd4bf 1px, transparent 1px); background-size: 20px 20px;"></div>
                 
                 <!-- HUD Elements -->
                 <div class="relative z-10 w-full h-full p-12 flex flex-col justify-between">
                    <div class="flex justify-between items-start">
                       <div class="space-y-1">
                          <div class="text-[8px] font-black text-teal-400/50 uppercase tracking-widest italic">Signal_Strength</div>
                          <div class="w-32 h-1 bg-white/5 rounded-full overflow-hidden"><div class="w-3/4 h-full bg-teal-400 animate-pulse"></div></div>
                       </div>
                       <div class="w-12 h-12 rounded-full border border-teal-400/40 border-t-teal-400 animate-spin"></div>
                    </div>
                    
                    <div class="grid grid-cols-3 gap-8 items-end">
                       <div v-for="i in 3" :key="i" class="h-32 bg-white/5 border border-white/10 rounded-2xl relative overflow-hidden group/bar">
                          <div class="absolute bottom-0 inset-x-0 bg-teal-400/20 group-hover/bar:bg-teal-400/40 transition-all duration-1000" :style="`height: ${20 + i*20}%`"><div class="absolute top-0 inset-x-0 h-px bg-teal-400 shadow-[0_0_10px_#2dd4bf]"></div></div>
                       </div>
                    </div>
                 </div>
               </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-16 sm:py-64 relative overflow-hidden">
      <div class="absolute inset-0 bg-teal-500/[0.03] -skew-y-3 origin-right"></div>
      
      <div class="container mx-auto px-6 relative z-10 text-center">
        <div class="max-w-4xl mx-auto space-y-12">
          <div class="inline-block text-[10px] font-black text-teal-400 uppercase tracking-[0.6em] mb-4 italic">Final Validation</div>
          <h2 class="text-5xl sm:text-9xl font-black text-white mb-8 tracking-tighter uppercase italic leading-[0.8] animate-pulse-slow">
            SYNC YOUR<br>CONTROL
          </h2>
          <p class="text-2xl text-white/30 mb-20 max-w-2xl mx-auto font-medium italic uppercase tracking-tighter">
            Join the elite network of automated monitoring protocols.
          </p>
          <router-link 
            to="/register" 
            class="group relative inline-block px-12 py-6 sm:px-20 sm:py-8 bg-teal-400 text-gray-950 font-black rounded-3xl sm:rounded-[2.5rem] transition-all duration-700 hover:scale-110 hover:shadow-[0_0_100px_rgba(45,212,191,0.6)] uppercase tracking-[0.4em] text-xs"
          >
            <span class="relative z-10 italic">Initialize Deployment</span>
            <div class="absolute inset-0 bg-white/40 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000 skew-x-[-20deg]"></div>
          </router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, h } from 'vue';

const features = [
  {
    title: "Real-time Hub",
    description: "Nanosecond latency metrics delivered via our proprietary encrypted neural stream.",
    icon: () => h('svg', { fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' }, [
      h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2.5', d: 'M13 10V3L4 14h7v7l9-11h-7z' })
    ])
  },
  {
    title: "Log Analytics",
    description: "Deep-packet inspection of all environmental variables with autonomous anomaly detection.",
    icon: () => h('svg', { fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' }, [
      h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2.5', d: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z' })
    ])
  },
  {
    title: "Global Mesh",
    description: "Distributed monitoring network ensures redundant coverage across any infrastructure.",
    icon: () => h('svg', { fill: 'none', stroke: 'currentColor', viewBox: '0 0 24 24' }, [
      h('path', { 'stroke-linecap': 'round', 'stroke-linejoin': 'round', 'stroke-width': '2.5', d: 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9' })
    ])
  }
];

const demoFeatures = [
  "Autonomous sensory validation",
  "Dynamic threshold adaptation",
  "Neural pattern recognition",
  "Multi-tenant logic isolation",
  "99.999% Operational SLA"
];
</script>

<style scoped>
.home-page { scroll-behavior: smooth; }
.perspective-1000 { perspective: 1000px; }
.rotate-x-12 { transform: rotateX(12deg); }
.rotate-y-12-neg { transform: rotateY(-12deg); }

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

.animate-fade-in { animation: fade-in 1.2s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.animate-title { animation: title-slide 1.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.animate-pulse-slow { animation: pulse-slow 8s ease-in-out infinite; }
</style>