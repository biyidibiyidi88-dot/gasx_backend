<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-y-auto relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
    <!-- Background -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-blue-600/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-500/5 blur-[180px] -z-0 pointer-events-none animate-pulse" style="animation-delay: 2s"></div>

    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5 relative">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
           <div class="w-2 h-2 rounded-full animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]" :class="profile.is_approved ? 'bg-teal-400' : 'bg-yellow-400'"></div>
           <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Vendor Module / <span class="text-white/80">Identity & Location</span></h1>
        </div>
      </div>
    </header>

    <main class="flex-1 p-4 sm:p-6 lg:p-8 space-y-6 relative z-10 custom-scrollbar max-w-5xl mx-auto w-full">
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
        <div>
          <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Profile Configuration</h2>
          <p class="text-[10px] font-black uppercase tracking-widest text-white/40 mt-1 italic">Submit your documents to activate public listing.</p>
        </div>
      </div>

      <!-- Approval Notice -->
      <div v-if="profile.id && !profile.is_approved" class="p-6 bg-yellow-400/10 border border-yellow-400/20 rounded-[2rem] flex flex-col sm:flex-row items-start sm:items-center shadow-[0_0_30px_rgba(250,204,21,0.1)] gap-6 group hover:border-yellow-400/40 transition-all duration-500 relative overflow-hidden">
        <div class="absolute inset-0 bg-gradient-to-r from-yellow-400/0 via-yellow-400/5 to-yellow-400/0 -translate-x-full group-hover:translate-x-full transition-transform duration-1000"></div>
        <div class="w-14 h-14 rounded-2xl bg-yellow-400/10 border border-yellow-400/30 flex items-center justify-center flex-shrink-0 relative z-10">
          <svg class="w-7 h-7 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
        </div>
        <div class="relative z-10">
          <h3 class="text-xs font-black uppercase tracking-[0.3em] text-yellow-400 mb-1 italic">Verification Pending</h3>
          <p class="text-[11px] font-bold text-white/60 tracking-wide uppercase leading-relaxed">Your identity documents are under review by Network Intelligence. Once validated, your node will appear on the public consumer mapping grid.</p>
        </div>
      </div>

      <div v-else-if="profile.is_approved" class="p-6 bg-teal-400/10 border border-teal-400/20 rounded-[2rem] flex items-center shadow-[0_0_30px_rgba(45,212,191,0.15)] gap-4">
        <svg class="w-6 h-6 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        <span class="text-sm font-black uppercase tracking-widest text-teal-400 italic">Node Validated & Publicly Broadcasted</span>
      </div>

      <!-- Main Form Grid -->
      <form @submit.prevent="saveProfile" class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Identity Section -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 hover:border-white/10 transition-all duration-500 space-y-6">
          <div class="border-b border-white/5 pb-4 mb-6">
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Core Metadata</h3>
          </div>

          <div class="space-y-2">
            <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Commercial Node Name</label>
            <input type="text" v-model="profile.store_name" required class="w-full px-5 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic transition-colors">
          </div>

          <div class="space-y-4 pt-4 border-t border-white/5">
            <h4 class="text-[9px] font-black uppercase tracking-widest text-blue-400 italic">Required Intelligence Docs</h4>
            
            <div class="space-y-2">
              <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Birth Certificate (.pdf, .jpg)</label>
              <input type="file" accept="image/*,.pdf" @change="handleFileUpload('birth_certificate', $event)" class="w-full px-5 py-3 bg-white/5 border border-white/10 rounded-2xl file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-[9px] file:font-black file:uppercase file:tracking-[0.2em] file:bg-teal-400/10 file:text-teal-400 hover:file:bg-teal-400/20 text-white/40 text-[11px]">
              <div v-if="profile.birth_certificate" class="text-[9px] font-bold text-teal-400 ml-2 mt-1 truncate">Current: {{ getFileName(profile.birth_certificate) }}</div>
            </div>

            <div class="space-y-2">
              <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">National Identity Card (.pdf, .jpg)</label>
              <input type="file" accept="image/*,.pdf" @change="handleFileUpload('identity_card', $event)" class="w-full px-5 py-3 bg-white/5 border border-white/10 rounded-2xl file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-[9px] file:font-black file:uppercase file:tracking-[0.2em] file:bg-teal-400/10 file:text-teal-400 hover:file:bg-teal-400/20 text-white/40 text-[11px]">
              <div v-if="profile.identity_card" class="text-[9px] font-bold text-teal-400 ml-2 mt-1 truncate">Current: {{ getFileName(profile.identity_card) }}</div>
            </div>

            <div class="space-y-2">
              <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Trade Registration / Authorization (.pdf, .jpg)</label>
              <input type="file" accept="image/*,.pdf" @change="handleFileUpload('institution_document', $event)" class="w-full px-5 py-3 bg-white/5 border border-white/10 rounded-2xl file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-[9px] file:font-black file:uppercase file:tracking-[0.2em] file:bg-teal-400/10 file:text-teal-400 hover:file:bg-teal-400/20 text-white/40 text-[11px]">
              <div v-if="profile.institution_document" class="text-[9px] font-bold text-teal-400 ml-2 mt-1 truncate">Current: {{ getFileName(profile.institution_document) }}</div>
            </div>
          </div>
        </div>

        <!-- Location Section -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 hover:border-white/10 transition-all duration-500 space-y-6 flex flex-col justify-between">
          <div>
            <div class="border-b border-white/5 pb-4 mb-6">
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Geospatial Sync</h3>
            </div>

            <div class="space-y-6">
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Physical Address Line</label>
                <input type="text" v-model="profile.address" required class="w-full px-5 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic transition-colors" placeholder="e.g. 100 Main St, Douala">
              </div>

              <div class="space-y-4">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Interactive Geospatial Pinpoint</label>
                <div class="h-[200px] w-full rounded-2xl border border-white/10 overflow-hidden relative z-10 mt-2">
                  <div id="location-picker-map" class="absolute inset-0 z-0"></div>
                  <div v-if="!pickerMapLoaded" class="absolute inset-0 bg-gray-950/80 backdrop-blur-sm z-20 flex items-center justify-center">
                    <span class="text-[9px] font-black uppercase tracking-widest text-teal-400 animate-pulse">Initializing Map Module...</span>
                  </div>
                </div>
                <p class="text-[8px] font-bold text-white/40 ml-2 mb-4">Click anywhere on the map to set exact coordinates manually.</p>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Latitude Coord</label>
                  <input type="number" step="any" v-model="profile.latitude" required class="w-full px-5 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold tabular-nums italic placeholder-white/20" placeholder="0.000000">
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Longitude Coord</label>
                  <input type="number" step="any" v-model="profile.longitude" required class="w-full px-5 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold tabular-nums italic placeholder-white/20" placeholder="0.000000">
                </div>
              </div>
            </div>
          </div>

          <div class="space-y-4">
            <button type="button" @click="fetchCurrentLocation" class="w-full py-4 bg-blue-500/10 border border-blue-500/20 text-blue-400 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-blue-500/20 transition-all flex items-center justify-center">
              <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
              Auto-Sync GPS Device Coordinates
            </button>
            
            <button type="submit" class="w-full py-5 bg-gradient-to-r from-teal-400 to-blue-500 rounded-2xl text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_40px_rgba(45,212,191,0.5)] transition-all flex items-center justify-center relative overflow-hidden group/btn shadow-xl">
              <span class="relative z-10 flex items-center justify-center h-full">
                <span v-if="loading" class="animate-pulse">Transmitting Data...</span>
                <span v-else>Commit Profile Logic</span>
              </span>
            </button>
          </div>
        </div>
      </form>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue';
import api from '../../../config/api';
import { useTheme } from '../../../composables/useTheme';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

// JAWG ACCESS TOKEN
const JAWG_TOKEN = 'QWSZT4r4RnGLINur1NGRr2YTcTCLVbIPPbijitdYg4K5imZqo0dqSzPajpWqMPWB';



const { themeClasses } = useTheme();
const profile = ref({
  id: null,
  store_name: '',
  address: '',
  latitude: null,
  longitude: null,
  is_approved: false,
  birth_certificate: null,
  identity_card: null,
  institution_document: null
});

const files = ref({
  birth_certificate: null,
  identity_card: null,
  institution_document: null
});

const loading = ref(false);
const pickerMapLoaded = ref(false);
let pickerMap = null;
let pickerMarker = null;





const loadProfile = async () => {
  try {
    const response = await api.get('vendor/profile/');
    if (response.data) {
      profile.value = response.data;
      if (pickerMap && profile.value.latitude) {
        const pos = [parseFloat(profile.value.longitude), parseFloat(profile.value.latitude)];
        if (!pickerMarker) {
          pickerMarker = new tt.Marker({ color: '#2dd4bf', draggable: true })
            .setLngLat(pos).addTo(pickerMap);
          pickerMarker.on('dragend', () => {
            const lngLat = pickerMarker.getLngLat();
            profile.value.latitude = lngLat.lat.toFixed(6);
            profile.value.longitude = lngLat.lng.toFixed(6);
          });
        } else {
          pickerMarker.setLngLat(pos);
        }
        pickerMap.setCenter(pos).setZoom(15);
      }
    }
  } catch (err) {
    if (err.response && err.response.status !== 404) {
      console.error('Failed to load profile', err);
    }
  }
};

const handleFileUpload = (field, event) => {
  const file = event.target.files[0];
  if (file) {
    files.value[field] = file;
  }
};

const getFileName = (url) => {
  if (!url) return '';
  const parts = url.split('/');
  return parts[parts.length - 1] || 'Document Uploaded';
};

const fetchCurrentLocation = () => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        profile.value.latitude = parseFloat(position.coords.latitude.toFixed(6));
        profile.value.longitude = parseFloat(position.coords.longitude.toFixed(6));
        
        if (pickerMap) {
          const pos = [profile.value.longitude, profile.value.latitude];
          if (!pickerMarker) {
            pickerMarker = new tt.Marker({ color: '#2dd4bf', draggable: true })
              .setLngLat(pos).addTo(pickerMap);
            pickerMarker.on('dragend', () => {
              const lngLat = pickerMarker.getLngLat();
              profile.value.latitude = lngLat.lat.toFixed(6);
              profile.value.longitude = lngLat.lng.toFixed(6);
            });
          } else {
            pickerMarker.setLngLat(pos);
          }
          pickerMap.flyTo({ center: pos, zoom: 15 });
        }
        
        alert('Coordinates synchronized from satellite proxy.');
      },
      (error) => {
        alert('Geospatial Sync Failed: ' + error.message);
      },
      { enableHighAccuracy: true }
    );
  } else {
    alert("Geolocation is not supported by this command terminal.");
  }
};

const initPickerMap = async () => {
  try {
    const mapContainer = document.getElementById('location-picker-map');
    if (!mapContainer) return;

    const initialLat = profile.value.latitude || 4.0511;
    const initialLng = profile.value.longitude || 9.7085;

    mapboxgl.accessToken = JAWG_TOKEN;
    pickerMap = new mapboxgl.Map({
      container: 'location-picker-map',
      style: `https://api.jawg.io/styles/jawg-dark.json?access-token=${JAWG_TOKEN}`,
      center: [initialLng, initialLat],
      zoom: profile.value.latitude ? 15 : 12
    });

    pickerMap.on('load', () => {
      pickerMapLoaded.value = true;

      const el = document.createElement('div');
      el.className = 'w-4 h-4 rounded-full bg-teal-400 border-2 border-white shadow-[0_0_10px_rgba(45,212,191,1)] cursor-move hover:scale-125 transition-transform';

      pickerMarker = new mapboxgl.Marker({ element: el, draggable: true })
        .setLngLat([initialLng, initialLat])
        .addTo(pickerMap);

      pickerMarker.on('dragend', () => {
        const lngLat = pickerMarker.getLngLat();
        profile.value.latitude = lngLat.lat.toFixed(6);
        profile.value.longitude = lngLat.lng.toFixed(6);
      });

      pickerMap.on('click', (e) => {
        const pos = [e.lngLat.lng, e.lngLat.lat];
        profile.value.latitude = parseFloat(e.lngLat.lat.toFixed(6));
        profile.value.longitude = parseFloat(e.lngLat.lng.toFixed(6));
        pickerMarker.setLngLat(pos);
        pickerMap.flyTo({ center: pos, zoom: 15 });
      });

      new ResizeObserver(() => { if (pickerMap) pickerMap.resize(); }).observe(mapContainer);
    });

    pickerMap.on('error', (e) => console.error('Picker map error:', e));

  } catch (err) {
    console.error('Picker map initialization failure:', err);
    alert(`Map Error: ${err.message || 'Check API Key'}`);
  }
};

const saveProfile = async () => {
  loading.value = true;
  const formData = new FormData();
  formData.append('store_name', profile.value.store_name);
  formData.append('address', profile.value.address);
  if (profile.value.latitude !== null) formData.append('latitude', profile.value.latitude);
  if (profile.value.longitude !== null) formData.append('longitude', profile.value.longitude);

  if (files.value.birth_certificate) formData.append('birth_certificate', files.value.birth_certificate);
  if (files.value.identity_card) formData.append('identity_card', files.value.identity_card);
  if (files.value.institution_document) formData.append('institution_document', files.value.institution_document);

  try {
    let response;
    // Since API is RetrieveUpdateAPIView and automatically links to `request.user.vendor_profile`.
    // We can use PATCH. However, if they don't have a profile yet, usually get_object fails 404, we need to POST to register.
    // Let's check if we have profile.id
    if (profile.value.id) {
      response = await api.patch('vendor/profile/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
    } else {
      // POST to vendor/register/ if no profile yet
      response = await api.post('vendor/register/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
    }
    
    profile.value = response.data;
    alert('Vendor intelligence updated successfully.');
  } catch (err) {
    console.error('Failed to save profile', err);
    alert('Update failure: ' + JSON.stringify(err.response?.data || {}));
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadProfile();
  nextTick(() => {
    initPickerMap();
  });
});
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }
</style>
