<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-orange-500/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>

    <header class="z-20 bg-white/[0.01] backdrop-blur-xl border-b border-white/5 shadow-xl relative">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
          <router-link to="/admin/delivery-dashboard" class="text-white/40 hover:text-white transition-colors p-2 rounded-xl hover:bg-white/5">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/>
            </svg>
          </router-link>
          <div class="w-2 h-2 rounded-full bg-orange-400 animate-pulse shadow-[0_0_10px_rgba(251,146,60,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Route / <span class="text-white/80">Delivery #{{ id }}</span></h1>
        </div>
      </div>
    </header>

    <main class="flex-1 relative z-10 flex flex-col lg:flex-row h-full lg:overflow-hidden min-h-[calc(100vh-65px)]">
      <!-- Info Sidebar -->
      <div class="w-full lg:w-[400px] shrink-0 bg-white/[0.02] backdrop-blur-3xl border-r border-white/5 flex flex-col z-20 shadow-2xl order-2 lg:order-1 relative">
        <div class="p-6 border-b border-white/5 bg-gray-950/40 flex flex-col gap-1">
          <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Delivery Route</h2>
          <p class="text-[9px] font-black uppercase tracking-widest text-orange-400">Point A → Point B</p>
        </div>

        <div v-if="delivery" class="flex-1 p-6 space-y-6 overflow-y-auto custom-scrollbar">
          <!-- Status -->
          <div class="flex items-center gap-3">
            <span class="text-[9px] font-black uppercase tracking-widest px-3 py-1 rounded-full border"
              :class="statusStyle(delivery.status)">
              {{ delivery.status_display }}
            </span>
          </div>

          <!-- Cylinder -->
          <div class="bg-white/[0.02] rounded-2xl p-5 border border-white/5">
            <p class="text-[8px] text-white/20 uppercase tracking-widest mb-1">Cylinder</p>
            <p class="text-base font-black text-white italic">{{ delivery.bottle_detail }}</p>
          </div>

          <!-- Origin -->
          <div class="bg-teal-400/5 rounded-2xl p-5 border border-teal-400/10">
            <div class="flex items-center gap-2 mb-2">
              <div class="w-2 h-2 rounded-full bg-teal-400"></div>
              <p class="text-[8px] text-teal-400 uppercase tracking-widest font-black">Origin — Supplier</p>
            </div>
            <p class="text-sm font-bold text-white">{{ delivery.vendor_name }}</p>
            <p class="text-xs text-white/50">{{ delivery.vendor_address }}</p>
          </div>

          <!-- Destination -->
          <div class="bg-orange-400/5 rounded-2xl p-5 border border-orange-400/10">
            <div class="flex items-center gap-2 mb-2">
              <div class="w-2 h-2 rounded-full bg-orange-400"></div>
              <p class="text-[8px] text-orange-400 uppercase tracking-widest font-black">Destination — Client</p>
            </div>
            <p class="text-sm font-bold text-white">{{ delivery.client_name }}</p>
            <p class="text-xs text-white/50">{{ delivery.delivery_address }}</p>
          </div>

          <!-- Navigate Button -->
          <button
            @click="openNav"
            class="w-full py-4 bg-gradient-to-r from-orange-400 to-red-500 rounded-2xl text-[10px] font-black uppercase tracking-[0.3em] text-white hover:shadow-[0_0_30px_rgba(251,146,60,0.4)] transition-all flex items-center justify-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            Launch Navigation
          </button>
        </div>

        <div v-else-if="loading" class="flex-1 flex items-center justify-center">
          <div class="w-8 h-8 border-2 border-orange-400/20 border-t-orange-400 rounded-full animate-spin"></div>
        </div>
      </div>

      <!-- Map -->
      <div class="flex-1 relative bg-gray-950 order-1 lg:order-2 h-[60vh] lg:h-full z-10 min-h-[400px]">
        <div ref="mapContainer" class="absolute inset-0 w-full h-full"></div>
        <div v-if="!mapLoaded" class="absolute inset-0 bg-gray-950/80 backdrop-blur-sm z-20 flex flex-col items-center justify-center">
          <div class="w-12 h-12 border-2 border-orange-400/20 border-t-orange-400 rounded-full animate-spin mb-4"></div>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-orange-400 italic">Plotting Route...</span>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue';
import { useRoute } from 'vue-router';
import api from '../../../config/api';
import { useTheme } from '../../../composables/useTheme';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

const { themeClasses } = useTheme();
const route = useRoute();
const id = route.params.id;

const delivery = ref(null);
const loading = ref(true);
const mapLoaded = ref(false);
const mapContainer = ref(null);
let map = null;

const JAWG_TOKEN = 'QWSZT4r4RnGLINur1NGRr2YTcTCLVbIPPbijitdYg4K5imZqo0dqSzPajpWqMPWB';

const statusStyle = (status) => {
  const map = {
    PENDING: 'text-orange-400 border-orange-400/30 bg-orange-400/10',
    ASSIGNED: 'text-blue-400 border-blue-400/30 bg-blue-400/10',
    OUT_FOR_DELIVERY: 'text-purple-400 border-purple-400/30 bg-purple-400/10',
    DELIVERED: 'text-teal-400 border-teal-400/30 bg-teal-400/10',
    CANCELLED: 'text-red-400 border-red-400/30 bg-red-400/10',
  };
  return map[status] || 'text-white/40 border-white/10 bg-white/5';
};

const loadDelivery = async () => {
  try {
    const res = await api.get(`deliveries/${id}/`);
    delivery.value = res.data;
  } catch (e) {
    console.error('Failed to load delivery', e);
  } finally {
    loading.value = false;
  }
};

const initMap = () => {
  if (!mapContainer.value) return;
  mapboxgl.accessToken = JAWG_TOKEN;
  const center = [9.7085, 4.0511];
  map = new mapboxgl.Map({
    container: mapContainer.value,
    style: `https://api.jawg.io/styles/jawg-dark.json?access-token=${JAWG_TOKEN}`,
    center,
    zoom: 12,
  });
  map.on('load', () => {
    mapLoaded.value = true;
    plotMarkers();
  });
};

const plotMarkers = () => {
  if (!map || !delivery.value) return;
  const d = delivery.value;

  // Supplier origin marker (teal)
  if (d.vendor_latitude && d.vendor_longitude) {
    const el = document.createElement('div');
    el.className = 'w-5 h-5 rounded-full bg-teal-400 border-2 border-white shadow-[0_0_12px_rgba(45,212,191,1)]';
    new mapboxgl.Marker(el)
      .setLngLat([parseFloat(d.vendor_longitude), parseFloat(d.vendor_latitude)])
      .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(`<p class="text-xs font-bold">${d.vendor_name}</p><p class="text-[10px]">Origin</p>`))
      .addTo(map);
  }

  // Client destination marker (orange)
  if (d.latitude && d.longitude) {
    const el2 = document.createElement('div');
    el2.className = 'w-5 h-5 rounded-full bg-orange-400 border-2 border-white shadow-[0_0_12px_rgba(251,146,60,1)]';
    new mapboxgl.Marker(el2)
      .setLngLat([parseFloat(d.longitude), parseFloat(d.latitude)])
      .setPopup(new mapboxgl.Popup({ offset: 25 }).setHTML(`<p class="text-xs font-bold">${d.client_name}</p><p class="text-[10px]">Destination</p>`))
      .addTo(map);

    // Fly to destination
    map.flyTo({ center: [parseFloat(d.longitude), parseFloat(d.latitude)], zoom: 13, essential: true });
  } else if (d.vendor_latitude && d.vendor_longitude) {
    map.flyTo({ center: [parseFloat(d.vendor_longitude), parseFloat(d.vendor_latitude)], zoom: 13 });
  }
};

const openNav = () => {
  if (!delivery.value) return;
  const { latitude, longitude } = delivery.value;
  if (!latitude || !longitude) return;
  window.open(`https://www.google.com/maps/dir/?api=1&destination=${latitude},${longitude}`, '_blank');
};

onMounted(async () => {
  await loadDelivery();
  nextTick(() => initMap());
});

onUnmounted(() => { if (map) map.remove(); });
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 3px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(251, 146, 60, 0.2); border-radius: 10px; }
</style>
