<template>
  <div class="about-page min-h-screen pt-24 pb-16 sm:pt-56 sm:pb-48 overflow-hidden font-['Inter',-apple-system,BlinkMacSystemFont,sans-serif] bg-transparent relative">
    
    <!-- Sophisticated Background Accents -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 right-1/4 w-[600px] h-[600px] bg-teal-500/10 blur-[180px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 left-1/4 w-[700px] h-[700px] bg-blue-600/10 blur-[200px] animate-pulse-slow" style="animation-delay: 2s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <!-- Hero Section -->
    <section class="relative mb-32">
      <div class="container mx-auto px-6 text-center">
        <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8 animate-fade-in shadow-[0_0_30px_rgba(45,212,191,0.1)]">
          <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">The Mission Arc</span>
        </div>
        
        <h1 class="text-4xl sm:text-7xl font-black text-white mb-6 tracking-tighter uppercase italic leading-[0.9] animate-title">
          SMARTER SAFETY<br>
          <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent decoration-white/10 underline-offset-8">TOTAL_LOGIC</span>
        </h1>
        
        <p class="text-lg sm:text-2xl text-white/30 max-w-3xl mx-auto font-medium italic uppercase tracking-tighter animate-fade-in" style="animation-delay: 0.2s">
          Engineering the future of home infrastructure monitoring with autonomous precision.
        </p>
      </div>
    </section>

    <!-- Our Genesis -->
    <section class="py-16 sm:py-32 relative overflow-hidden">
      <div class="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-teal-400/20 to-transparent"></div>
      
      <div class="container mx-auto px-6">
        <div class="flex flex-col lg:flex-row items-center gap-16 lg:gap-32">
          <div class="lg:w-1/2 space-y-8 sm:space-y-12">
            <div>
              <p class="text-xs font-black text-teal-400 uppercase tracking-[0.5em] mb-4 italic">Origin_Sequence</p>
              <h2 class="text-4xl sm:text-7xl font-black text-white tracking-tighter uppercase italic leading-none mb-6 sm:mb-10">Our Genesis</h2>
              
              <div class="space-y-6 sm:space-y-8 text-lg sm:text-xl text-white/30 font-bold uppercase tracking-tighter italic leading-relaxed">
                <p>Founded in 2023, GasMonitor emerged with a singular purpose: to replace binary protocols with intelligent awareness.</p>
                <p>We've evolved into a trusted global node, securing thousands of households through zero-latency sensing and predictive analysis.</p>
              </div>
            </div>
            
            <div class="flex items-center gap-8 sm:gap-12 pt-8 border-t border-white/5">
              <div class="flex flex-col">
                <span class="text-3xl sm:text-5xl font-black text-white tracking-tighter italic">2023</span>
                <span class="text-[9px] font-black uppercase tracking-[0.3em] text-teal-400 mt-2 italic shadow-teal-400/20 shadow-sm">Est_Deployment</span>
              </div>
              <div class="w-px h-16 bg-white/10"></div>
              <div class="flex flex-col">
                <span class="text-3xl sm:text-5xl font-black text-white tracking-tighter italic">99.9%</span>
                <span class="text-[9px] font-black uppercase tracking-[0.3em] text-teal-400 mt-2 italic">Logic_Accuracy</span>
              </div>
            </div>
          </div>

          <div class="lg:w-1/2 relative group/image">
            <div class="absolute inset-0 bg-teal-400/20 blur-[150px] opacity-10 group-hover/image:opacity-30 transition-all duration-1000"></div>
            <div class="relative overflow-hidden rounded-3xl sm:rounded-[4rem] border border-white/10 bg-white/[0.02] backdrop-blur-3xl p-2 shadow-2xl transition-all duration-1000 group-hover/image:scale-[1.02] group-hover/image:rotate-2">
              <img 
                src="https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=1632&q=80" 
                alt="Architecture" 
                class="w-full h-auto grayscale opacity-40 group-hover/image:grayscale-0 group-hover/image:opacity-100 transition-all duration-1000 rounded-2xl sm:rounded-[3.5rem] scale-110 group-hover/image:scale-100"
              >
              <!-- HUD Overlay -->
              <div class="absolute inset-10 border border-teal-400/20 rounded-[2.5rem] pointer-events-none opacity-0 group-hover/image:opacity-100 transition-all duration-1000">
                 <div class="absolute top-6 left-6 text-[8px] font-black text-teal-400 uppercase tracking-widest italic">Matrix_Scan_Active</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Logic Core Grid -->
    <section class="py-16 sm:py-56 bg-white/[0.005] relative overflow-hidden">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_center,_rgba(45,212,191,0.03),_transparent)]"></div>
      
      <div class="container mx-auto px-6 relative z-10">
        <div class="text-center mb-16 sm:mb-32">
          <p class="text-xs font-black text-teal-400 uppercase tracking-[0.6em] mb-4 italic">Proprietary Principles</p>
          <h2 class="text-4xl sm:text-8xl font-black text-white tracking-tighter uppercase italic leading-[0.8] mb-8">Logic Core</h2>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-10">
          <div 
            v-for="(value, index) in values"
            :key="index"
            class="group relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 hover:border-teal-500/30 transition-all duration-700 hover:translate-y-[-10px]"
          >
            <div class="w-20 h-20 bg-teal-400/10 rounded-[2rem] flex items-center justify-center mb-10 border border-teal-400/20 group-hover:bg-teal-400 transition-all duration-700 group-hover:shadow-[0_0_30px_rgba(45,212,191,0.3)]">
              <div v-html="value.iconTemplate" class="text-teal-400 group-hover:text-gray-950 transition-colors duration-700"></div>
            </div>
            
            <h3 class="text-3xl font-black text-white mb-6 uppercase tracking-tighter italic">
              {{ value.title }}
            </h3>
            <p class="text-white/30 leading-relaxed font-bold text-sm tracking-tight italic uppercase">
              {{ value.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Network Architects (Team) -->
    <section class="py-16 sm:py-56 relative">
      <div class="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent"></div>
      
      <div class="container mx-auto px-6">
        <div class="text-center mb-16 sm:mb-32">
          <p class="text-xs font-black text-teal-400 uppercase tracking-[0.6em] mb-4 italic">The Intelligence Layer</p>
          <h2 class="text-4xl sm:text-8xl font-black text-white tracking-tighter uppercase italic leading-[0.8]">Network Architects</h2>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
          <div 
            v-for="(member, index) in team"
            :key="index"
            class="group text-center"
          >
            <div class="relative w-40 h-40 sm:w-56 sm:h-56 mx-auto mb-10 group-hover:scale-110 transition-transform duration-700">
              <div class="absolute inset-0 bg-teal-400/30 blur-[60px] opacity-0 group-hover:opacity-40 transition-opacity duration-700"></div>
              <div class="relative w-full h-full rounded-3xl sm:rounded-[2.5rem] overflow-hidden border-2 border-white/5 group-hover:border-teal-400/40 transition-all duration-700 p-1 bg-white/[0.02] backdrop-blur-3xl shadow-2xl">
                <img 
                  :src="member.image" 
                  :alt="member.name"
                  class="w-full h-full object-cover rounded-[3rem] grayscale group-hover:grayscale-0 transition-all duration-1000 opacity-40 group-hover:opacity-100"
                >
              </div>
            </div>
            
            <h3 class="text-2xl font-black text-white uppercase tracking-tighter italic mb-2 group-hover:text-teal-400 transition-colors duration-500">{{ member.name }}</h3>
            <p class="text-[10px] font-black text-teal-400/60 uppercase tracking-[0.3em] mb-6 italic">
              {{ member.position }}
            </p>
            <p class="text-[11px] text-white/20 font-black uppercase tracking-widest leading-relaxed px-4 italic group-hover:text-white/40 transition-colors">
              {{ member.bio }}
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const values = ref([
  {
    title: "Safety Node",
    description: "Prioritizing environmental security through rigorous algorithmic validation.",
    iconTemplate: `<svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>`
  },
  {
    title: "Pure Logic",
    description: "Discarding legacy sensory metrics for next-gen neural pattern mapping.",
    iconTemplate: `<svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/></svg>`
  },
  {
    title: "Global Mesh",
    description: "Operating at scale to protect the collective infrastructure of the future.",
    iconTemplate: `<svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`
  }
]);

const team = ref([
  {
    name: "Alex Johnson",
    position: "Protocol Architect",
    bio: "Visionary specialized in decentralized system logic and infrastructure safety.",
    image: "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=774&q=80"
  },
  {
    name: "Maria Garcia",
    position: "Intelligence Lead",
    bio: "Expert in neural sensory networks and zero-bias environmental tracking.",
    image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=776&q=80"
  },
  {
    name: "Sam Wilson",
    position: "Visual Experience",
    bio: "Crafting the immersive interfaces that bridge human intent with machine logic.",
    image: "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?auto=format&fit=crop&w=1740&q=80"
  },
  {
    name: "Taylor Chen",
    position: "Global Support",
    bio: "Ensuring near-perfect reliability across the entire distributed monitoring grid.",
    image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=774&q=80"
  }
]);
</script>

<style scoped>
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