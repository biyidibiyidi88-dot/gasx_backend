<template>
  <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[2.5rem] p-6 sm:p-8 flex flex-col h-full hover:border-white/10 transition-all duration-500 group">
    <!-- Header Area -->
    <div class="flex justify-between items-start mb-6">
      <div>
        <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 mb-1 italic flex items-center">
          <span class="w-1.5 h-1.5 rounded-full bg-teal-400 mr-2 animate-pulse shadow-[0_0_8px_rgba(45,212,191,0.5)]"></span>
          Gastronomic Capability
        </h3>
        <h2 class="text-xl font-black text-white italic tracking-tight uppercase">Cookable Foods</h2>
      </div>
      <div v-if="isLoading" class="flex space-x-1 mt-1">
        <div class="w-1.5 h-1.5 bg-teal-400/50 rounded-full animate-bounce" style="animation-delay: 0s"></div>
        <div class="w-1.5 h-1.5 bg-teal-400/50 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
        <div class="w-1.5 h-1.5 bg-teal-400/50 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
      </div>
    </div>

    <!-- Content Area -->
    <div class="flex-1 overflow-y-auto custom-scrollbar pr-2 space-y-3 -mr-2">
      <div v-if="cookableFoods.length === 0 && !isLoading" class="h-full flex flex-col items-center justify-center text-center py-8">
        <div class="text-white/20 mb-3">
          <svg class="w-12 h-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <p class="text-[10px] font-black uppercase tracking-widest text-white/40 italic">Resource Unviable</p>
        <p class="text-[9px] font-bold text-white/30 uppercase mt-1">Remaining gas insufficient for standard cooking protocols.</p>
      </div>

      <transition-group name="list" tag="div" class="space-y-3">
        <div 
          v-for="food in cookableFoods" 
          :key="food.id"
          class="bg-white/[0.03] border border-white/5 rounded-2xl p-4 flex items-center justify-between hover:bg-white/[0.05] hover:border-teal-400/20 transition-all duration-300"
        >
          <div class="flex items-center space-x-4">
            <div class="w-10 h-10 rounded-xl bg-teal-400/10 border border-teal-400/20 flex items-center justify-center text-teal-400">
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4" />
              </svg>
            </div>
            <div>
              <h4 class="text-sm font-bold text-white/90 italic tracking-tight">{{ food.name }}</h4>
              <div class="flex items-center space-x-3 mt-0.5">
                <span class="text-[9px] font-black text-white/30 tracking-widest uppercase flex items-center">
                  <svg class="w-3 h-3 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                  {{ food.cooking_time_minutes }}m
                </span>
                <span class="text-[9px] font-black text-teal-400/70 tracking-widest uppercase flex items-center">
                  <svg class="w-3 h-3 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" /></svg>
                  {{ food.estimated_gas_required }}kg
                </span>
              </div>
            </div>
          </div>
          <div class="text-[10px] font-black text-teal-400 italic">Viable</div>
        </div>
      </transition-group>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../../config/api';

const cookableFoods = ref([]);
const isLoading = ref(true);
const sensorId = ref(null);

const fetchFoods = async () => {
  isLoading.value = true;
  try {
    // 1. Get primary sensor
    const sensorRes = await api.get('sensors/');
    const sensors = sensorRes.data;
    
    if (sensors && sensors.length > 0) {
      sensorId.value = sensors[0].id;
      
      // 2. Get cookable foods using the primary sensor
      const foodRes = await api.get(`sensors/${sensorId.value}/cookable-foods/`);
      cookableFoods.value = foodRes.data;
    }
  } catch (error) {
    console.error('Failed to fetch cookable foods data', error);
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchFoods();
});

// Allow parent component to trigger a refresh
defineExpose({
  refreshData: fetchFoods
});
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

.list-enter-active,
.list-leave-active {
  transition: all 0.5s ease;
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}
</style>
