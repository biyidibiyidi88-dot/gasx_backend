<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Logistics / <span class="text-white/80">Node Supply Matrix</span></h1>
        </div>
        
        <div class="flex items-center gap-4">
           <div class="px-4 py-1.5 rounded-full bg-teal-400/5 border border-teal-400/20 text-[9px] font-black text-teal-400 uppercase tracking-widest italic">
            GRID_ACTIVE: EU_WEST_1
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar">
      
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
        
        <!-- Interactive Node Radar (Map Placeholder) -->
        <div class="lg:col-span-2 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3.5rem] p-12 h-[500px] relative overflow-hidden group/radar">
          <div class="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-teal-400/[0.03] via-transparent to-transparent opacity-50 group-hover/radar:opacity-100 transition-opacity duration-1000"></div>
          
          <!-- Radar Grid -->
          <div class="absolute inset-0 opacity-10 pointer-events-none" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 40px 40px;"></div>
          
          <div class="relative h-full flex flex-col items-center justify-center text-center space-y-6">
            <div class="w-48 h-48 rounded-full border border-teal-400/20 flex items-center justify-center relative">
               <div class="absolute inset-0 border border-teal-400/10 rounded-full animate-ping opacity-20"></div>
               <div class="absolute inset-4 border border-teal-400/10 rounded-full"></div>
               <svg class="h-16 w-16 text-teal-400/40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            </div>
            
            <div class="space-y-2">
              <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Geo-Registry Radar</h2>
              <p class="text-[10px] font-bold text-white/30 uppercase tracking-[0.3em] italic">Visualizing regional supply nodes across active grid.</p>
            </div>

            <div v-if="selectedStation" class="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl flex items-center gap-4 backdrop-blur-md">
              <div class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></div>
              <span class="text-[9px] font-black text-white/80 uppercase tracking-widest italic">Locked on: {{ selectedStation.name }}</span>
            </div>
          </div>

          <!-- Radar Sweep Effect -->
          <div class="absolute inset-0 bg-gradient-to-r from-teal-400/10 to-transparent w-full h-full -translate-x-full animate-radar-sweep pointer-events-none"></div>
        </div>

        <!-- Node Registry (Stations List) -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem] overflow-hidden flex flex-col h-[500px]">
          <div class="px-8 py-6 border-b border-white/5 flex justify-between items-center">
            <h2 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/40 italic">Regional Nodes</h2>
            <div class="text-[9px] font-black text-teal-400 uppercase italic">{{ stations.length }} Detected</div>
          </div>
          
          <div class="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-3">
            <button
              v-for="station in stations"
              :key="station.id"
              @click="selectStation(station)"
              class="w-full group p-6 rounded-[2rem] border transition-all duration-500 relative overflow-hidden"
              :class="selectedStation?.id === station.id ? 'bg-teal-400/10 border-teal-400/30' : 'bg-white/5 border-white/5 hover:border-white/10'"
            >
              <div class="relative z-10 flex flex-col items-start gap-1">
                <div class="flex justify-between items-center w-full">
                  <span class="text-lg font-black italic uppercase tracking-tighter transition-colors" :class="selectedStation?.id === station.id ? 'text-white' : 'text-white/60 group-hover:text-white'">{{ station.name }}</span>
                  <span class="text-[9px] font-black text-teal-400/60 uppercase tracking-widest italic">{{ station.distance }} KM</span>
                </div>
                <p class="text-[10px] font-bold text-white/20 uppercase tracking-widest italic truncate w-full">{{ station.address }}</p>
              </div>
            </button>
          </div>
        </div>
      </div>

      <!-- Volumetric Inventory (Table) -->
      <div v-if="selectedStation" class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3.5rem] p-10 overflow-hidden relative group/inventory">
        <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-blue-500/[0.02] to-transparent pointer-events-none"></div>
        
        <div class="flex items-center gap-6 mb-10 pb-6 border-b border-white/5 relative z-10">
          <div class="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-white/20 border border-white/10 group-hover/inventory:border-blue-400/30 group-hover/inventory:text-blue-400 transition-all">
             <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
          </div>
          <div>
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">{{ selectedStation.name }} Matrix</h3>
            <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Available Capacities</h2>
          </div>
        </div>

        <div class="overflow-x-auto relative z-10">
          <table class="w-full">
            <thead>
              <tr class="text-left text-[10px] font-black uppercase tracking-[0.4em] text-white/20 italic">
                <th class="px-6 py-4">Matrix Component</th>
                <th class="px-6 py-4 text-center">Protocol Level</th>
                <th class="px-6 py-4 text-right">Acquisition</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr v-for="item in selectedStation.inventory" :key="item.type" class="group/row hover:bg-white/[0.02] transition-all">
                <td class="px-6 py-8">
                  <div class="flex items-center gap-4">
                    <div class="w-2 h-2 rounded-full" :class="item.quantity > 0 ? 'bg-teal-400' : 'bg-red-500'"></div>
                    <span class="text-lg font-black text-white italic uppercase tracking-tighter">{{ item.type }}</span>
                  </div>
                </td>
                <td class="px-6 py-8 text-center">
                  <span :class="[
                    item.quantity > 10 ? 'text-teal-400 bg-teal-400/10 border-teal-400/20' : 
                    item.quantity > 0 ? 'text-yellow-400 bg-yellow-400/10 border-yellow-400/20' : 
                    'text-red-500 bg-red-400/10 border-red-500/20',
                    'px-4 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border italic'
                  ]">
                    {{ item.quantity }} UNITS_IN_NODE
                  </span>
                </td>
                <td class="px-6 py-8 text-right">
                  <button v-if="item.quantity > 0" class="px-6 py-3 bg-white/5 border border-white/10 rounded-xl text-[10px] font-black uppercase tracking-widest text-white/40 hover:bg-teal-400 hover:text-gray-950 hover:border-teal-400 transition-all">Request Allocation</button>
                  <span v-else class="text-[9px] font-black text-white/10 uppercase tracking-widest italic">MATRIX_REMPTY</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useTheme } from '../../composables/useTheme'

const { isDark, themeClasses } = useTheme()

const stations = ref([
  {
    id: 1,
    name: 'City Gas Depot',
    address: '123 Main Street',
    city: 'Downtown',
    distance: 1.2,
    inventory: [
      { type: '6KG Propane Cylinder', quantity: 5 },
      { type: '12KG Propane Cylinder', quantity: 18 },
      { type: '25KG Industrial Node', quantity: 0 },
    ],
  },
  {
    id: 2,
    name: 'Neighborhood Point',
    address: '45 Oak Avenue',
    city: 'Westside',
    distance: 3.8,
    inventory: [
      { type: '6KG Propane Cylinder', quantity: 12 },
      { type: '12KG Propane Cylinder', quantity: 7 },
    ],
  },
  {
    id: 3,
    name: 'Highway Hub',
    address: 'Km 12, Highway Road',
    city: 'Industrial Zone',
    distance: 8.5,
    inventory: [
      { type: '12KG Propane Cylinder', quantity: 25 },
      { type: '50KG Heavy Infrastructure', quantity: 6 },
    ],
  },
])

const selectedStation = ref(stations.value[0] || null)
const selectStation = (station) => selectedStation.value = station
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }

@keyframes radar-sweep {
  from { transform: translateX(-100%) rotate(0deg); }
  to { transform: translateX(100%) rotate(0deg); }
}

.animate-radar-sweep {
  animation: radar-sweep 4s linear infinite;
  background: linear-gradient(90deg, transparent, rgba(45, 212, 191, 0.05), transparent);
}
</style>