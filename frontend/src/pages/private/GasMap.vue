<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
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
      <!-- Vendor List Sidebar -->
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
          
          <div v-else-if="vendors.length === 0" class="text-center p-8">
            <svg class="w-8 h-8 text-white/10 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            <p class="text-[10px] font-black text-white/30 uppercase tracking-widest">No suppliers detected in zone</p>
          </div>

          <!-- Vendor Card -->
          <div v-for="vendor in vendors" :key="vendor.id" 
               @click="selectVendor(vendor)"
               :class="['p-5 rounded-2xl border transition-all duration-300 cursor-pointer group hover:bg-white/[0.04]', 
                        selectedVendor?.id === vendor.id ? 'bg-teal-400/10 border-teal-400/30 shadow-[0_0_20px_rgba(45,212,191,0.1)]' : 'bg-white/[0.02] border-white/5']">
            <div class="flex justify-between items-start mb-3">
              <h3 class="text-sm font-black text-white uppercase tracking-wider italic flex items-center">
                <span v-if="selectedVendor?.id === vendor.id" class="w-1.5 h-1.5 rounded-full bg-teal-400 mr-2 shadow-[0_0_8px_rgba(45,212,191,1)]"></span>
                {{ vendor.store_name }}
              </h3>
              <div class="px-2 py-0.5 rounded bg-teal-400/10 border border-teal-400/20 text-[8px] font-black uppercase tracking-widest text-teal-400">
                Verified
              </div>
            </div>
            
            <p class="text-[10px] text-white/50 tracking-wide mb-4 line-clamp-2 leading-relaxed">
              {{ vendor.address }}
            </p>

            <div v-if="vendor.gas_bottles?.length > 0" class="flex flex-wrap gap-2">
              <span v-for="bottle in vendor.gas_bottles.slice(0,3)" :key="bottle.id" 
                    class="px-2 py-1 bg-white/5 rounded-lg text-[8px] font-bold text-white/70 tracking-widest uppercase border border-white/5">
                {{ bottle.brand_display || bottle.brand }}
              </span>
              <span v-if="vendor.gas_bottles.length > 3" class="px-2 py-1 bg-white/5 rounded-lg text-[8px] font-bold text-white/40 tracking-widest uppercase border border-white/5">
                +{{ vendor.gas_bottles.length - 3 }} more
              </span>
            </div>
            <div v-else class="text-[8px] font-bold text-red-400/60 uppercase tracking-widest">
              Inventory Depleted
            </div>
          </div>
        </div>
      </div>

      <!-- Map Area -->
      <div class="flex-1 relative bg-gray-950 order-1 lg:order-2 h-[60vh] lg:h-full z-10 min-h-[400px]">
        <div ref="mapContainer" class="absolute inset-0 w-full h-full"></div>
        
        <!-- Loading Overlay -->
        <div v-if="!mapLoaded" class="absolute inset-0 bg-gray-950/80 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
          <div class="w-12 h-12 border-2 border-teal-400/20 border-t-teal-400 rounded-full animate-spin mb-4"></div>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Initializing TomTom Engine...</span>
          <p v-if="mapError" class="mt-4 text-[10px] text-red-400 font-bold max-w-sm text-center bg-red-500/10 p-4 rounded-xl border border-red-500/20">
            {{ mapError }}
          </p>
        </div>

        <!-- Vendor Detail Overlay -->
        <transition name="slide-up">
          <div v-if="selectedVendor" class="absolute bottom-6 left-6 right-6 lg:left-1/2 lg:-translate-x-1/2 lg:w-[500px] bg-gray-900/90 backdrop-blur-2xl border border-white/10 rounded-3xl p-6 shadow-[0_20px_50px_rgba(0,0,0,0.5)] z-30 transform transition-transform">
            <button @click="selectedVendor = null" class="absolute top-4 right-4 text-white/40 hover:text-white bg-white/5 p-1.5 rounded-full transition-colors">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
            <h3 class="text-xl font-black text-white italic uppercase tracking-tighter mb-1">{{ selectedVendor.store_name }}</h3>
            <p class="text-[10px] uppercase font-bold text-white/50 tracking-widest mb-4">{{ selectedVendor.address }}</p>
            
            <div class="space-y-3 mb-6 max-h-40 overflow-y-auto custom-scrollbar pr-2">
              <div v-for="bottle in selectedVendor.gas_bottles" :key="bottle.id" class="flex justify-between items-center p-3 bg-white/5 rounded-xl border border-white/5">
                <div>
                  <div class="text-[10px] font-black text-white uppercase tracking-wider mb-0.5">{{ bottle.brand_display || bottle.brand }} <span class="text-white/40">//</span> {{ bottle.size_display || bottle.size }}</div>
                  <div class="text-sm font-black text-teal-400 italic">{{ bottle.price }} FCFA</div>
                </div>
                <div class="text-right">
                  <div class="text-[8px] font-bold text-white/40 uppercase tracking-widest mb-1">Available</div>
                  <div class="text-sm font-black text-white px-2 py-0.5 bg-white/10 rounded border border-white/5">{{ bottle.stock_quantity }}</div>
                </div>
              </div>
              <div v-if="!selectedVendor.gas_bottles?.length" class="text-center text-[10px] text-white/30 uppercase py-4">No Inventory Data</div>
            </div>

            <button @click="getDirections" class="w-full py-3.5 bg-gradient-to-r from-teal-400 to-blue-500 rounded-xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_20px_rgba(45,212,191,0.3)] transition-all flex items-center justify-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/></svg>
              Plot Intercept Route
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
import tt from '@tomtom-international/web-sdk-maps';
import ttServices from '@tomtom-international/web-sdk-services';



const { themeClasses } = useTheme();
const vendors = ref([]);
const loading = ref(true);
const selectedVendor = ref(null);
const routingActive = ref(false);

const mapLoaded = ref(false);
const mapError = ref('');
const mapContainer = ref(null);
let map = null;
let markers = [];
let userLocation = null;




const API_KEY = import.meta.env.VITE_TOMTOM_API_KEY || 'rCTBFt5f1TGazCyYag0gwW5QREP5oyVM';

const loadVendors = async () => {
  try {
    const response = await api.get('public/vendors/');
    vendors.value = response.data;
    if (mapLoaded.value) {
      plotMarkers();
    }
  } catch (err) {
    console.error('Failed to load vendors', err);
  } finally {
    loading.value = false;
  }
};

const selectVendor = (vendor) => {
  selectedVendor.value = vendor;
  if (map && vendor.latitude && vendor.longitude) {
    const lat = parseFloat(vendor.latitude);
    const lng = parseFloat(vendor.longitude);
    if (!isNaN(lat) && !isNaN(lng)) {
      map.flyTo({ center: [lng, lat], zoom: 16 });
    }
  }
};

const drawRoute = async () => {
  if (!selectedVendor.value?.latitude) return;
  if (!userLocation) {
    alert('Enable location services to get directions.');
    return;
  }
  try {
    const dest = selectedVendor.value;
    const routeOptions = {
        key: API_KEY,
        locations: [
            userLocation,
            [parseFloat(dest.longitude), parseFloat(dest.latitude)]
        ],
        routeType: 'fastest',
        traffic: false
    };

    const response = await ttServices.services.calculateRoute(routeOptions);
    const geojson = response.toGeoJson();
    
    if (map.getSource('route')) {
      map.getSource('route').setData(geojson);
    } else {
      map.addLayer({
        id: 'route',
        type: 'line',
        source: {
          type: 'geojson',
          data: geojson
        },
        layout: { 'line-join': 'round', 'line-cap': 'round' },
        paint: { 'line-color': '#2dd4bf', 'line-width': 5, 'line-opacity': 0.9 }
      });
    }
    routingActive.value = true;
    const bounds = new tt.LngLatBounds();
    bounds.extend(userLocation);
    bounds.extend([parseFloat(dest.longitude), parseFloat(dest.latitude)]);
    map.fitBounds(bounds, { padding: 60 });
  } catch (err) {
    console.error('Routing failed', err);
    alert('Route failed: ' + err.message);
  }
};

const getDirections = () => drawRoute();

const toggleRoute = () => {
  if (routingActive.value) {
    if (map && map.getLayer('route')) {
      map.removeLayer('route');
      map.removeSource('route');
    }
    routingActive.value = false;
  } else {
    drawRoute();
  }
};

const plotMarkers = () => {
  if (!map) return;
  
  markers.forEach(m => m.remove());
  markers = [];
  
  const bounds = new tt.LngLatBounds();
  let hasValidMarkers = false;

  vendors.value.forEach(vendor => {
    if (vendor.latitude && vendor.longitude) {
      const lat = parseFloat(vendor.latitude);
      const lng = parseFloat(vendor.longitude);
      if (isNaN(lat) || isNaN(lng)) return;
      
      const pos = [lng, lat];
      
      const el = document.createElement('div');
      el.className = 'w-6 h-6 rounded-full bg-teal-400 border-2 border-white shadow-[0_0_15px_rgba(45,212,191,0.8)] cursor-pointer hover:scale-110 transition-transform';
      
      const marker = new tt.Marker({ element: el })
        .setLngLat(pos)
        .addTo(map);
      
      el.addEventListener('click', () => { selectVendor(vendor); });
      
      markers.push(marker);
      bounds.extend(pos);
      hasValidMarkers = true;
    }
  });

  if (hasValidMarkers && !userLocation) {
    map.fitBounds(bounds, { padding: 50 });
  } else if (userLocation) {
    map.panTo(userLocation);
  }
};



const initMap = async () => {
  const defaultCenter = [9.7085, 4.0511]; // Lng, Lat
  
  try {
    if (!mapContainer.value) return;
    
    map = tt.map({
      key: API_KEY,
      container: mapContainer.value,
      style: `https://api.tomtom.com/map/1/style/21.1.0-0/basic_night.json?key=${API_KEY}`,
      center: defaultCenter,
      zoom: 13
    });

    map.on('load', () => {
      mapLoaded.value = true;

      map.addControl(new tt.NavigationControl(), 'top-left');
      new ResizeObserver(() => map && map.resize()).observe(mapContainer.value);
      plotMarkers();
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => {
            userLocation = [pos.coords.longitude, pos.coords.latitude];
            map.setCenter(userLocation);
            new tt.Marker({ color: '#2dd4bf' }).setLngLat(userLocation).addTo(map);
            plotMarkers();
          },
          () => plotMarkers(),
          { enableHighAccuracy: true }
        );
      }
    });

    map.on('error', (e) => {
      console.error('Map error:', e);
      mapError.value = e.error?.message || 'Map error';
    });

  } catch (err) {
    console.error('Map init failure:', err);
    mapError.value = err.message;
  }
};

onMounted(() => { loadVendors(); nextTick(() => initMap()); });
onUnmounted(() => { if (map) { map.remove(); map = null; } });
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

.slide-up-enter-active, .slide-up-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.slide-up-enter-from, .slide-up-leave-to { opacity: 0; transform: translateY(20px) translateX(-50%); }
@media (max-width: 1023px) {
  .slide-up-enter-from, .slide-up-leave-to { opacity: 0; transform: translateY(20px); }
}
</style>
