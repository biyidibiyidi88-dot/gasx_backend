<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
    <!-- Glow Effect -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-teal-500/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>

    <header class="z-20 bg-white/[0.01] backdrop-blur-xl border-b border-white/5 relative shadow-xl">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
           <div class="w-2 h-2 rounded-full bg-teal-400 animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
           <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Geospatial Intelligence / <span class="text-white/80">Vendor Network</span></h1>
        </div>
      </div>
    </header>

    <main class="flex-1 relative z-10 flex flex-col lg:flex-row h-full lg:overflow-hidden min-h-[calc(100vh-65px)]">
      <!-- Sidebar -->
      <div class="w-full lg:w-[400px] shrink-0 bg-white/[0.02] backdrop-blur-3xl border-r border-white/5 flex flex-col h-[40vh] lg:h-full z-20 shadow-2xl order-2 lg:order-1 relative">
        <div class="p-6 border-b border-white/5 bg-gray-950/40">
          <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter mb-1">Local Suppliers</h2>
          <p class="text-[9px] font-black uppercase tracking-widest text-teal-400">Authorized Distribution Nodes</p>
        </div>
        
        <div class="flex-1 overflow-y-auto p-4 space-y-4 custom-scrollbar">
          <div v-if="loading" class="flex flex-col items-center justify-center p-8 space-y-4">
            <div class="w-8 h-8 border-2 border-teal-400/20 border-t-teal-400 rounded-full animate-spin"></div>
            <span class="text-[9px] font-black uppercase tracking-[0.2em] text-white/40 italic">Scanning Area...</span>
          </div>
          
          <div v-for="vendor in vendors" :key="vendor.id" 
               @click="selectVendor(vendor)"
               :class="['p-5 rounded-2xl border transition-all duration-300 cursor-pointer group hover:bg-white/[0.04]', 
                        selectedVendor?.id === vendor.id ? 'bg-teal-400/10 border-teal-400/30' : 'bg-white/[0.02] border-white/5']">
            <h3 class="text-sm font-black text-white uppercase italic tracking-wider">{{ vendor.store_name }}</h3>
            <p class="text-[10px] text-white/50 tracking-wide mb-2">{{ vendor.address }}</p>
          </div>
        </div>
      </div>

      <!-- Map Area -->
      <div class="flex-1 relative bg-gray-950 order-1 lg:order-2 h-[60vh] lg:h-full z-10 min-h-[400px]">
        <div ref="mapContainer" class="absolute inset-0 w-full h-full"></div>
        
        <div v-if="!mapLoaded" class="absolute inset-0 bg-gray-950/80 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
          <div class="w-12 h-12 border-2 border-teal-400/20 border-t-teal-400 rounded-full animate-spin mb-4"></div>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Synchronizing Jawg Matrix...</span>
        </div>

        <!-- Detail Overlay -->
        <transition name="slide-up">
          <div v-if="selectedVendor" class="absolute bottom-6 left-6 right-6 lg:left-1/2 lg:-translate-x-1/2 lg:w-[450px] bg-gray-900/90 backdrop-blur-2xl border border-white/10 rounded-3xl p-6 shadow-2xl z-30">
            <h3 class="text-xl font-black text-white italic uppercase tracking-tighter mb-1">{{ selectedVendor.store_name }}</h3>
            <p class="text-[10px] uppercase font-bold text-white/50 tracking-widest mb-4">{{ selectedVendor.address }}</p>
            
            <button @click="openNavigation" class="w-full py-3.5 bg-gradient-to-r from-teal-400 to-blue-500 rounded-xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_20px_rgba(45,212,191,0.3)] transition-all flex items-center justify-center">
              Launch Navigation Route
            </button>
          </div>
        </transition>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import api from '../../config/api';
import { useTheme } from '../../composables/useTheme';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

const { themeClasses } = useTheme();
const vendors = ref([]);
const loading = ref(true);
const selectedVendor = ref(null);
const mapLoaded = ref(false);
const mapContainer = ref(null);
let map = null;
let markers = [];

// JAWG ACCESS TOKEN
const JAWG_TOKEN = 'QWSZT4r4RnGLINur1NGRr2YTcTCLVbIPPbijitdYg4K5imZqo0dqSzPajpWqMPWB';

const loadVendors = async () => {
  try {
    const response = await api.get('public/vendors/');
    vendors.value = response.data;
    if (mapLoaded.value) plotMarkers();
  } catch (err) {
    console.error('Vendor API error:', err);
  } finally {
    loading.value = false;
  }
};

const initMap = () => {
  if (!mapContainer.value) return;

  mapboxgl.accessToken = JAWG_TOKEN;
  map = new mapboxgl.Map({
    container: mapContainer.value,
    // Using Jawg's official dark style
    style: `https://api.jawg.io/styles/jawg-dark.json?access-token=${JAWG_TOKEN}`,
    center: [9.7085, 4.0511], // Douala
    zoom: 12
  });

  map.on('load', () => {
    mapLoaded.value = true;
    plotMarkers();
  });
};

const plotMarkers = () => {
  if (!map) return;
  markers.forEach(m => m.remove());
  markers = [];
  
  vendors.value.forEach(vendor => {
    if (vendor.latitude && vendor.longitude) {
      const el = document.createElement('div');
      el.className = 'w-4 h-4 rounded-full bg-teal-400 border-2 border-white shadow-[0_0_10px_rgba(45,212,191,1)] cursor-pointer hover:scale-125 transition-transform';
      
      const marker = new mapboxgl.Marker(el)
        .setLngLat([parseFloat(vendor.longitude), parseFloat(vendor.latitude)])
        .addTo(map);
        
      el.addEventListener('click', () => selectVendor(vendor));
      markers.push(marker);
    }
  });
};

const selectVendor = (v) => {
  selectedVendor.value = v;
  map.flyTo({ 
    center: [parseFloat(v.longitude), parseFloat(v.latitude)], 
    zoom: 15,
    essential: true 
  });
};

const openNavigation = () => {
  if (!selectedVendor.value) return;
  const { latitude, longitude } = selectedVendor.value;
  // External link for reliability
  const url = `https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`;
  window.open(url, '_blank');
};

onMounted(() => {
  loadVendors();
  nextTick(() => initMap());
});

onUnmounted(() => {
  if (map) map.remove();
});
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 3px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(45, 212, 191, 0.2); border-radius: 10px; }
.slide-up-enter-active, .slide-up-leave-active { transition: all 0.4s ease; }
.slide-up-enter-from, .slide-up-leave-to { opacity: 0; transform: translateY(30px) translateX(-50%); }
</style>