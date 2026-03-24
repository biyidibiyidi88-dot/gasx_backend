<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between px-6 sm:px-8 py-4 sm:py-5 gap-4">
        <div class="flex items-center space-x-4">
          <div class="w-1.5 h-1.5 sm:w-2 h-2 rounded-full bg-blue-400 shadow-[0_0_10px_rgba(96,165,250,0.5)]"></div>
          <h1 class="text-[10px] sm:text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Infrastructure / <span class="text-white/80">Hardware Node Alpha</span></h1>
        </div>
        
        <button 
          @click="toggleTheme" 
          class="p-2.5 rounded-xl bg-white/5 border border-white/10 text-white/40 hover:text-white hover:border-teal-400/30 transition-all group"
        >
          <svg v-if="isDark" class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
          <svg v-else class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-8 space-y-6 sm:space-y-8 custom-scrollbar">
      
      <div class="flex flex-col lg:flex-row gap-8 items-start">
        
        <!-- Interactive 3D Volumetric Visualization -->
        <div class="w-full lg:w-1/2 flex flex-col items-center justify-center bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] sm:rounded-[3.5rem] p-6 sm:p-12 min-h-[400px] sm:min-h-[700px] relative overflow-hidden group/viz">
          <div class="absolute inset-0 bg-gradient-to-b from-teal-400/[0.02] to-transparent opacity-0 group-hover/viz:opacity-100 transition-opacity duration-1000"></div>
          
          <div class="relative w-full max-w-[320px] aspect-[1/2] flex justify-center">
            
            <!-- Metallic Hardware Structure -->
            <div class="absolute inset-0 bg-gradient-to-r from-gray-800 to-gray-900 rounded-[5rem] border-[12px] border-white/5 shadow-2xl z-0 overflow-hidden">
               <!-- Liquid Container -->
               <div class="absolute inset-x-2 bottom-2 top-2 rounded-[4rem] bg-gray-950 overflow-hidden">
                  <!-- Volumetric Liquid -->
                  <div 
                    class="absolute bottom-0 inset-x-0 transition-all duration-1000 ease-in-out"
                    :class="[tank.level < 20 ? 'bg-red-500/80 shadow-[0_-20px_40px_rgba(239,68,68,0.3)]' : tank.level < 40 ? 'bg-yellow-500/80 shadow-[0_-20px_40px_rgba(234,179,8,0.3)]' : 'bg-teal-400/80 shadow-[0_-20px_40px_rgba(45,212,191,0.3)]']"
                    :style="`height: ${tank.level}%`"
                  >
                    <!-- Wave Effect -->
                    <div class="absolute top-0 inset-x-0 h-10 bg-white/20 blur-xl animate-pulse"></div>
                    <div class="absolute inset-x-0 bottom-0 h-full bg-gradient-to-t from-white/10 to-transparent"></div>
                    
                    <!-- Bubbles -->
                    <div v-for="bubble in bubbles" :key="bubble.id" 
                      class="absolute rounded-full bg-white/40 blur-[1px] animate-rise"
                      :style="`left: ${bubble.left}; width: ${bubble.size}; height: ${bubble.size}; animation-duration: ${bubble.animationDuration}; animation-delay: ${bubble.delay};`"
                    ></div>
                  </div>
               </div>

               <!-- Reflections -->
               <div class="absolute inset-0 bg-gradient-to-tr from-transparent via-white/5 to-transparent pointer-events-none"></div>
               <div class="absolute top-0 left-0 right-0 h-40 bg-gradient-to-b from-white/5 to-transparent pointer-events-none"></div>
            </div>

            <!-- Labels & Indicators -->
            <div class="absolute inset-x-0 top-1/4 translate-y-2 pointer-events-none z-10 text-center">
              <div class="text-[8px] sm:text-[10px] font-black uppercase tracking-[0.5em] text-white/20 mb-1 italic">Propane Node</div>
              <div class="text-2xl sm:text-4xl font-black text-white italic tracking-tighter uppercase drop-shadow-2xl">V2.Alpha</div>
            </div>

            <div class="absolute right-[-60px] top-1/2 -translate-y-1/2 flex flex-col justify-between h-[300px] text-[9px] font-black uppercase tracking-widest text-white/20 italic pb-2">
              <div class="flex items-center gap-2"><div class="w-4 h-0.5 bg-white/10"></div>100%</div>
              <div class="flex items-center gap-2"><div class="w-4 h-0.5 bg-white/10"></div>75%</div>
              <div class="flex items-center gap-2"><div class="w-4 h-0.5 bg-white/10"></div>50%</div>
              <div class="flex items-center gap-2" :class="tank.level < 40 ? 'text-yellow-400/40' : ''"><div class="w-4 h-0.5 bg-current opacity-20"></div>25%</div>
              <div class="flex items-center gap-2" :class="tank.level < 20 ? 'text-red-400/40' : ''"><div class="w-4 h-0.5 bg-current opacity-20"></div>MIN_CAP</div>
            </div>
          </div>

          <div class="mt-8 sm:mt-12 text-center group-hover/viz:scale-105 transition-transform duration-700">
             <div class="text-4xl sm:text-6xl font-black text-white italic tracking-tighter tabular-nums mb-1">{{ Math.round(tank.level) }}%</div>
             <div class="text-[8px] sm:text-[10px] font-black uppercase tracking-[0.4em] text-white/30 italic">Volumetric Saturation</div>
          </div>
        </div>

        <!-- Metadata & Protocol Controls -->
        <div class="w-full lg:w-1/2 space-y-8">
          
          <!-- Primary Metadata Card -->
          <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-10 hover:border-white/10 transition-all duration-500">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-10 pb-6 border-b border-white/5 gap-4">
               <div>
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Node Identification</h3>
                <h2 class="text-2xl sm:text-3xl font-black text-white italic uppercase tracking-tighter">Hardware Telemetry</h2>
              </div>
              <span :class="[statusBadgeClass, 'px-4 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border border-current opacity-80 italic']">
                {{ tank.status }} Protocol
              </span>
            </div>

            <div class="grid grid-cols-2 gap-8 mb-10">
              <div v-for="spec in tankSpecs" :key="spec.label" class="space-y-1">
                <div class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">{{ spec.label }}</div>
                <div class="text-lg font-black text-white italic tracking-tight uppercase">{{ spec.value }}</div>
              </div>
            </div>

            <!-- Intelligence Notification -->
            <div :class="[statusCardClass, 'p-6 rounded-2xl flex items-center gap-6 border backdrop-blur-md relative overflow-hidden group/alert']">
              <div class="absolute inset-0 bg-white/5 opacity-0 group-hover/alert:opacity-100 transition-opacity"></div>
              <div class="w-12 h-12 rounded-2xl bg-current opacity-10 flex items-center justify-center flex-shrink-0"></div>
              <div class="relative z-10">
                <h4 class="text-[10px] font-black uppercase tracking-[0.2em] italic mb-1" :class="statusTextClass">{{ statusMessage }}</h4>
                <p class="text-[11px] font-bold text-white/40 uppercase tracking-widest leading-relaxed italic">{{ statusSubmessage }}</p>
              </div>
              <svg class="h-6 w-6 absolute right-6 text-white/10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" :d="statusIconPath"/>
              </svg>
            </div>
          </div>

          <!-- Secondary Interaction Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <!-- Consumption Analysis -->
            <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 space-y-6">
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Cycle Analytics</h3>
              <div class="space-y-4">
                <div v-for="stat in usageStats" :key="stat.label" class="flex justify-between items-baseline border-b border-white/5 pb-2">
                  <span class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">{{ stat.label }}</span>
                  <span class="text-sm font-black text-white/80 italic tracking-tight uppercase">{{ stat.value }}</span>
                </div>
              </div>
            </div>

            <!-- Protocol Constraints -->
            <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 space-y-6">
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Security Guidelines</h3>
              <ul class="space-y-3">
                <li v-for="rule in safetyRules" :key="rule" class="flex items-start gap-3">
                  <div class="w-1 h-1 rounded-full bg-teal-400 mt-1.5 flex-shrink-0 shadow-[0_0_5px_rgba(45,212,191,0.5)]"></div>
                  <span class="text-[9px] font-bold text-white/30 uppercase tracking-widest leading-relaxed italic">{{ rule }}</span>
                </li>
              </ul>
            </div>
          </div>

          <!-- Executable Operations -->
          <div class="flex flex-col sm:flex-row gap-4">
            <button @click="refillTank" class="flex-1 py-4 sm:py-5 bg-teal-400 hover:bg-teal-300 rounded-2xl sm:rounded-[2rem] text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 transition-all hover:shadow-[0_0_40px_rgba(45,212,191,0.4)] flex items-center justify-center gap-3 active:scale-95">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M19 14l-7 7m0 0l-7-7m7 7V3"/></svg>
              Initialize Refill Protocol
            </button>
            <button class="py-4 sm:px-8 sm:py-5 bg-white/5 border border-white/10 rounded-2xl sm:rounded-[2rem] text-[10px] font-black uppercase tracking-[0.2em] text-white/40 hover:text-white transition-all group flex items-center justify-center">
              <svg class="h-5 w-5 group-hover:scale-110 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </button>
          </div>

        </div>

      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useTheme } from '../../composables/useTheme';

const router = useRouter();
const { isDark, toggleTheme, themeClasses } = useTheme();

// Hardware State
const tank = ref({ 
  level: 75, 
  status: 'Nominal' 
});

const tankSpecs = [
  { label: 'Propane Unit Type', value: 'V2 Cylinder' },
  { label: 'Node Capacity', value: '6 KG / PRO' },
  { label: 'Registry Serial', value: 'CAL-0842-AX' },
  { label: 'Manufacturer ID', value: 'Calor LDT' }
];

const usageStats = computed(() => [
  { label: 'Projected Uptime', value: `${estimatedRemaining.value} Cycles` },
  { label: 'Depletion Rate', value: '1.2 KG / CYCLE' },
  { label: 'Last Log Entry', value: '3 DAYS PRIOR' }
]);

const safetyRules = [
  'STORE UPRIGHT IN VENTILATED ZONE',
  'MAINTAIN THERMAL BIAS CLEARANCE',
  'REGULAR LEAK DETECTION PROTOCOL',
  'SECURE VALVE DURING DORMANT PHASES'
];

// Bubbles logic
const bubbles = ref([]);
let bubbleTick = null;

const generateBubbles = () => {
  const count = Math.floor(tank.value.level / 10) + 3;
  bubbles.value = Array.from({ length: count }, (_, i) => ({
    id: `b-${Date.now()}-${i}`,
    left: `${10 + Math.random() * 80}%`,
    size: `${2 + Math.random() * 8}px`,
    animationDuration: `${2 + Math.random() * 4}s`,
    delay: `${Math.random() * 3}s`
  }));
};

const updateTankStatus = () => {
  if (tank.value.level < 20) tank.value.status = 'Critical';
  else if (tank.value.level < 40) tank.value.status = 'Low';
  else tank.value.status = 'Nominal';
};

const refillTank = () => {
  let start = tank.value.level;
  const target = 100;
  const step = 0.5;
  const int = setInterval(() => {
    if (tank.value.level >= target) clearInterval(int);
    else tank.value.level += step;
  }, 10);
};

// Computed UI Styles
const statusBadgeClass = computed(() => ({
  'Nominal': 'text-teal-400 border-teal-400/30 bg-teal-400/5',
  'Low': 'text-yellow-400 border-yellow-400/30 bg-yellow-400/5',
  'Critical': 'text-red-400 border-red-400/30 bg-red-400/5'
}[tank.value.status]));

const statusCardClass = computed(() => ({
  'Nominal': 'bg-teal-400/10 border-teal-400/20 text-teal-400',
  'Low': 'bg-yellow-400/10 border-yellow-400/20 text-yellow-400',
  'Critical': 'bg-red-400/10 border-red-400/20 text-red-500'
}[tank.value.status]));

const statusMessage = computed(() => ({
  'Nominal': 'INTELLIGENCE_NOMINAL',
  'Low': 'LOW_RESERVE_BIAS',
  'Critical': 'CRITICAL_DEPLETION_ALARM'
}[tank.value.status]));

const statusSubmessage = computed(() => ({
  'Nominal': 'System operating within specified volumetric parameters.',
  'Low': 'Node reserves dropping below stable threshold. Recommend refill.',
  'Critical': 'Node failure imminent. Order immediate infrastructure resupply.'
}[tank.value.status]));

const statusIconPath = computed(() => ({
  'Nominal': 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
  'Low': 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
  'Critical': 'M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
}[tank.value.status]));

const statusTextClass = computed(() => tank.value.status === 'Critical' ? 'text-red-400' : tank.value.status === 'Low' ? 'text-yellow-400' : 'text-teal-400');
const estimatedRemaining = computed(() => Math.round((tank.value.level / 100) * 48));

watch(() => tank.value.level, updateTankStatus);

onMounted(() => {
  generateBubbles();
  bubbleTick = setInterval(generateBubbles, 3000);
});

onUnmounted(() => clearInterval(bubbleTick));
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }

@keyframes rise {
  0% { transform: translateY(0) scale(0.5); opacity: 0; }
  20% { opacity: 0.6; }
  80% { opacity: 0.6; }
  100% { transform: translateY(-300px) scale(1.5); opacity: 0; }
}

.animate-rise {
  animation: rise linear infinite;
}
</style>