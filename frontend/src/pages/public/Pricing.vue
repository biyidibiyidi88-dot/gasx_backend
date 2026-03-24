<template>
  <div class="pricing-page min-h-screen pt-24 pb-16 sm:pt-56 sm:pb-48 overflow-hidden font-['Inter',-apple-system,BlinkMacSystemFont,sans-serif] bg-transparent relative">
    
    <!-- Sophisticated Background Accents -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 left-1/4 w-[600px] h-[600px] bg-teal-500/10 blur-[180px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 right-1/4 w-[700px] h-[700px] bg-blue-600/10 blur-[200px] animate-pulse-slow" style="animation-delay: 1s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <!-- Hero Section -->
    <section class="relative mb-32">
      <div class="container mx-auto px-6 text-center">
        <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8 animate-fade-in shadow-[0_0_30px_rgba(45,212,191,0.1)]">
          <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Commercial Protocols</span>
        </div>
        
        <h1 class="text-4xl sm:text-7xl font-black text-white mb-6 tracking-tighter uppercase italic leading-[0.9] animate-title">
          TRANSPARENT<br>
          <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent decoration-white/10 underline-offset-8">SCALABILITY</span>
        </h1>
        
        <p class="text-lg sm:text-2xl text-white/30 max-w-3xl mx-auto font-medium italic uppercase tracking-tighter animate-fade-in" style="animation-delay: 0.2s">
          Acquire precision monitoring at any scale. No hidden bias. Just raw logic.
        </p>
      </div>
    </section>

    <!-- Pricing Toggle -->
    <div class="mb-16 sm:mb-32 animate-fade-in" style="animation-delay: 0.4s">
      <div class="container mx-auto px-6">
        <div class="flex justify-center">
          <div class="p-2 rounded-2xl bg-white/[0.02] backdrop-blur-3xl border border-white/5 flex items-center shadow-2xl overflow-x-auto max-w-full">
            <button
              @click="billingCycle = 'monthly'"
              :class="billingCycle === 'monthly' ? 'bg-teal-400 text-gray-950 shadow-[0_0_30px_rgba(45,212,191,0.4)]' : 'text-white/30 hover:text-white'"
              class="whitespace-nowrap px-6 sm:px-10 py-3.5 text-[9px] sm:text-[10px] font-black uppercase tracking-widest rounded-xl transition-all duration-700 italic"
            >
              Pulse Monthly
            </button>
            <button
              @click="billingCycle = 'annually'"
              :class="billingCycle === 'annually' ? 'bg-teal-400 text-gray-950 shadow-[0_0_30px_rgba(45,212,191,0.4)]' : 'text-white/30 hover:text-white'"
              class="whitespace-nowrap px-6 sm:px-10 py-3.5 text-[9px] sm:text-[10px] font-black uppercase tracking-widest rounded-xl transition-all duration-700 ml-2 italic"
            >
              Annual Stream <span class="ml-1 sm:ml-2 opacity-50">(-20%)</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Pricing Plans Grid -->
    <section class="mb-56 relative">
      <div class="container mx-auto px-6">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-10 max-w-7xl mx-auto items-center">
          
          <!-- Basic Tier -->
          <div class="group relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 transition-all duration-700 hover:border-white/20 hover:bg-white/[0.04] overflow-hidden">
            <div class="absolute -top-20 -right-20 w-40 h-40 bg-white/5 blur-[80px]"></div>
            
            <div class="mb-14 relative z-10">
              <h2 class="text-[10px] font-black uppercase tracking-[0.4em] text-teal-400/60 mb-6 italic">Initial Node</h2>
              <div class="flex items-baseline gap-2">
                <span class="text-6xl font-black text-white tracking-tighter italic">
                  {{ billingCycle === 'monthly' ? '9,990' : '7,990' }}
                </span>
                <span class="text-[10px] font-black text-white/20 uppercase tracking-widest italic">FCFA / Pulse</span>
              </div>
            </div>
            
            <ul class="space-y-6 mb-14 relative z-10">
              <li v-for="feat in basicFeatures" :key="feat" class="flex items-center group/item transition-all duration-500 hover:translate-x-1">
                <div class="w-1.5 h-1.5 rounded-full bg-teal-400/40 mr-4"></div>
                <span class="text-[10px] font-bold uppercase tracking-widest text-white/30 group-hover/item:text-white/60 italic">{{ feat }}</span>
              </li>
            </ul>

            <router-link to="/register" class="block w-full py-5 text-center bg-white/5 border border-white/10 rounded-2xl text-[10px] font-black uppercase tracking-[0.3em] text-white/80 hover:bg-white/10 hover:text-white transition-all duration-700 italic">
              Initialize_Logic
            </router-link>
          </div>

          <!-- Professional Tier (Featured) -->
          <div class="relative bg-white/[0.02] backdrop-blur-3xl border-2 border-teal-400/40 rounded-3xl sm:rounded-[2.5rem] p-10 sm:p-14 shadow-[0_50px_120px_rgba(0,0,0,0.8)] sm:scale-105 z-20 group/featured overflow-hidden">
            <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_rgba(45,212,191,0.08),_transparent)]"></div>
            
            <div class="absolute top-0 left-1/2 -translate-x-1/2 px-8 py-2.5 bg-teal-400 rounded-b-3xl">
              <span class="text-[9px] font-black uppercase tracking-[0.3em] text-gray-950 italic">Optimum_Bias</span>
            </div>
            
            <div class="mb-14 relative z-10">
              <h2 class="text-[10px] font-black uppercase tracking-[0.4em] text-teal-400 mb-6 italic">Neural Grid</h2>
              <div class="flex items-baseline gap-2">
                <span class="text-8xl font-black text-white tracking-tighter italic">
                  {{ billingCycle === 'monthly' ? '19,990' : '15,990' }}
                </span>
                <span class="text-[11px] font-black text-white/20 uppercase tracking-widest italic">FCFA / Pulse</span>
              </div>
            </div>
            
            <ul class="space-y-8 mb-16 relative z-10">
              <li v-for="feat in proFeatures" :key="feat" class="flex items-center group/item transition-all duration-700">
                <div class="w-2.5 h-2.5 rounded-full bg-teal-400 mr-6 shadow-[0_0_15px_#2dd4bf] animate-pulse"></div>
                <span class="text-[11px] font-black uppercase tracking-[0.15em] text-white italic group-hover/item:translate-x-2 transition-transform">{{ feat }}</span>
              </li>
            </ul>

            <router-link to="/register" class="block w-full py-6 text-center bg-teal-400 rounded-2.5xl text-[11px] font-black uppercase tracking-[0.4em] text-gray-950 hover:scale-[1.05] hover:shadow-[0_0_60px_rgba(45,212,191,0.5)] transition-all duration-700 italic">
              Access Network
            </router-link>
          </div>

          <!-- Enterprise Tier -->
          <div class="group relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[4rem] p-8 sm:p-12 transition-all duration-700 hover:border-white/20 hover:bg-white/[0.04] overflow-hidden">
            <div class="absolute -top-20 -right-20 w-40 h-40 bg-blue-500/5 blur-[80px]"></div>
            
            <div class="mb-14 relative z-10">
              <h2 class="text-[10px] font-black uppercase tracking-[0.4em] text-blue-400/60 mb-6 italic">Global Swarm</h2>
              <div class="flex items-baseline gap-2">
                <span class="text-6xl font-black text-white tracking-tighter italic">49,990</span>
                <span class="text-[10px] font-black text-white/20 uppercase tracking-widest italic">FCFA / Pulse</span>
              </div>
            </div>
            
            <ul class="space-y-6 mb-14 relative z-10">
              <li v-for="feat in enterpriseFeatures" :key="feat" class="flex items-center group/item transition-all duration-500 hover:translate-x-1">
                <div class="w-1.5 h-1.5 rounded-full bg-blue-400/40 mr-4"></div>
                <span class="text-[10px] font-bold uppercase tracking-widest text-white/30 group-hover/item:text-white/60 italic">{{ feat }}</span>
              </li>
            </ul>

            <router-link to="/contact" class="block w-full py-5 text-center bg-white/5 border border-white/10 rounded-2xl text-[10px] font-black uppercase tracking-[0.3em] text-white/80 hover:bg-white/10 hover:text-white transition-all duration-700 italic">
              Request Command
            </router-link>
          </div>

        </div>
      </div>
    </section>

    <!-- Comparison Matrix -->
    <section class="py-32 relative overflow-hidden bg-white/[0.005]">
      <div class="absolute top-0 inset-x-0 h-px bg-gradient-to-r from-transparent via-teal-400/20 to-transparent"></div>
      
      <div class="container mx-auto px-6">
        <div class="text-center mb-16 sm:mb-32">
          <p class="text-xs font-black text-teal-400 uppercase tracking-[0.6em] mb-4 italic">Analytical Buffer</p>
          <h2 class="text-4xl sm:text-8xl font-black text-white tracking-tighter uppercase italic leading-[0.8]">Logic Matrix</h2>
        </div>
        
        <div class="max-w-6xl mx-auto overflow-hidden rounded-3xl sm:rounded-[2.5rem] border border-white/5 bg-white/[0.02] backdrop-blur-3xl shadow-3xl">
          <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse min-w-[800px]">
              <thead>
                <tr class="border-b border-white/5 bg-white/[0.01]">
                  <th class="px-6 sm:px-12 py-6 sm:py-10 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.3em] sm:tracking-[0.5em] text-white/20 italic">PROTOCOL_SPEC</th>
                  <th class="px-6 sm:px-12 py-6 sm:py-10 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.3em] sm:tracking-[0.5em] text-teal-400/40 italic">NODE</th>
                  <th class="px-6 sm:px-12 py-6 sm:py-10 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.3em] sm:tracking-[0.5em] text-teal-400 italic">GRID</th>
                  <th class="px-6 sm:px-12 py-6 sm:py-10 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.3em] sm:tracking-[0.5em] text-blue-400/40 italic">SWARM</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr v-for="feat in comparisonFeatures" :key="feat.name" class="hover:bg-white/[0.02] transition-colors group/row">
                  <td class="px-6 sm:px-12 py-6 sm:py-8 text-[10px] sm:text-[11px] font-black uppercase tracking-[0.2em] text-white/30 group-hover/row:text-white/60 transition-colors italic">
                    {{ feat.name }}
                  </td>
                  <td v-for="plan in ['basic', 'pro', 'enterprise']" :key="plan" class="px-6 sm:px-12 py-6 sm:py-8 text-center sm:text-left">
                    <div v-if="feat[plan]" class="w-2.5 h-2.5 rounded-full bg-teal-400 shadow-[0_0_10px_#2dd4bf]"></div>
                    <div v-else class="w-2 h-2 rounded-full border border-white/10"></div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>

    <!-- Final CTA -->
    <section class="py-32 sm:py-64 relative text-center">
      <div class="container mx-auto px-6">
        <div class="max-w-4xl mx-auto space-y-16">
          <h2 class="text-3xl sm:text-6xl font-black text-white mb-6 sm:mb-8 tracking-tighter uppercase italic leading-[1.1] animate-pulse-slow">
            DEPLOY<br>ACQUISITION
          </h2>
          <router-link 
            to="/register" 
            class="group relative inline-block px-12 py-6 sm:px-24 sm:py-10 bg-teal-400 text-gray-950 font-black rounded-3xl sm:rounded-[3rem] transition-all duration-700 hover:scale-110 hover:shadow-[0_0_120px_rgba(45,212,191,0.6)] uppercase tracking-[0.5em] text-xs"
          >
            <span class="relative z-10 italic">Initialize Network Sync</span>
            <div class="absolute inset-0 bg-white/40 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000 skew-x-[-20deg]"></div>
          </router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const billingCycle = ref('monthly');

const basicFeatures = ['Real-time Hub Access', 'Uplink Alert Buffer', 'Single Node Mapping', '7-Cycle Log History', 'Core Logic Connectivity'];
const proFeatures = ['Neural Alert Stream', 'Deep Analytics Grid', '5-Node Mesh Mapping', '30-Cycle Log History', 'Priority Uplink Slot'];
const enterpriseFeatures = ['Infinite Swarm Nodes', 'Multi-Tenant Logic', 'Autonomous Reporting', 'Global Log Stream', '24/7 Deep Link', 'Elite Node Master'];

const comparisonFeatures = [
  { name: 'Neural Stream', basic: true, pro: true, enterprise: true },
  { name: 'Core Alerts', basic: true, pro: true, enterprise: true },
  { name: 'Push Protocol', basic: false, pro: true, enterprise: true },
  { name: 'SMS Override', basic: false, pro: true, enterprise: true },
  { name: 'Deep Analytics', basic: false, pro: true, enterprise: true },
  { name: 'Multi-Node', basic: false, pro: true, enterprise: true },
  { name: 'Swarm Reports', basic: false, pro: false, enterprise: true },
  { name: 'Direct Logic', basic: false, pro: false, enterprise: true }
];
</script>

<style scoped>
@keyframes fade-in { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
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