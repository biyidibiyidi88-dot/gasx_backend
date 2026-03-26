<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-y-auto relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-red-600/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-500/5 blur-[180px] -z-0 pointer-events-none animate-pulse" style="animation-delay: 2s"></div>

    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5 relative">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
           <div class="w-2 h-2 rounded-full bg-teal-400 animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
           <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">System Command / <span class="text-white/80">Vendor Validation</span></h1>
        </div>
        <div class="flex items-center space-x-2">
          <button @click="loadVendors" class="p-2 text-white/40 hover:text-teal-400 transition-colors">
            <svg class="w-5 h-5" :class="{ 'animate-spin': loading }" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
          </button>
        </div>
      </div>
    </header>

    <main class="flex-1 p-4 sm:p-6 lg:p-8 space-y-6 relative z-10 custom-scrollbar max-w-7xl mx-auto w-full">
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
        <div>
          <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Vendor Applications</h2>
          <p class="text-[10px] font-black uppercase tracking-widest text-white/40 mt-1 italic">Review intelligence documents and authorize nodes.</p>
        </div>
        
        <div class="flex space-x-2 bg-white/5 p-1 rounded-xl border border-white/10">
          <button @click="filter = 'pending'" :class="[filter === 'pending' ? 'bg-teal-400 text-gray-900 border-teal-400/50 shadow-[0_0_15px_rgba(45,212,191,0.3)]' : 'text-white/40 hover:text-white', 'px-4 py-2 text-[10px] font-black uppercase tracking-widest rounded-lg transition-all border border-transparent']">
            Pending
          </button>
          <button @click="filter = 'all'" :class="[filter === 'all' ? 'bg-blue-500 text-white border-blue-500/50 shadow-[0_0_15px_rgba(59,130,246,0.3)]' : 'text-white/40 hover:text-white', 'px-4 py-2 text-[10px] font-black uppercase tracking-widest rounded-lg transition-all border border-transparent']">
            All Records
          </button>
        </div>
      </div>

      <div v-if="filteredVendors.length === 0" class="flex flex-col items-center justify-center p-12 bg-white/[0.02] border border-white/5 rounded-[2rem]">
        <div class="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center border border-white/10 mb-6">
          <svg class="w-8 h-8 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
        </div>
        <p class="text-sm font-bold text-white/40 uppercase tracking-widest italic mb-2">No Applications Found</p>
        <p class="text-[10px] text-white/20 uppercase tracking-[0.2em] max-w-sm text-center">There are currently no vendor nodes matching the selected filter criteria.</p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Vendor Cards -->
        <div v-for="vendor in filteredVendors" :key="vendor.id" class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-6 sm:p-8 flex flex-col group hover:border-white/10 transition-all duration-500 relative overflow-hidden">
          <div class="absolute inset-0 bg-gradient-to-br from-teal-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
          
          <div class="relative z-10 flex justify-between items-start mb-6">
            <div>
              <div class="flex items-center space-x-3 mb-2">
                <div :class="vendor.is_approved ? 'bg-teal-400' : 'bg-yellow-400'" class="w-2.5 h-2.5 rounded-full animate-pulse shadow-lg"></div>
                <h3 class="text-xl font-black text-white italic uppercase tracking-tighter">{{ vendor.store_name || 'UNNAMED NODE' }}</h3>
              </div>
              <p class="text-[10px] font-black uppercase tracking-[0.2em] text-white/40 flex items-center">
                <svg class="w-3 h-3 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                {{ vendor.address || 'Address not provided' }}
              </p>
            </div>
            <div class="px-3 py-1 rounded-full border text-[9px] font-black uppercase tracking-widest" :class="vendor.is_approved ? 'border-teal-400/30 text-teal-400 bg-teal-400/10' : 'border-yellow-400/30 text-yellow-500 bg-yellow-400/10'">
              {{ vendor.is_approved ? 'Authorized' : 'Pending Review' }}
            </div>
          </div>

          <div class="relative z-10 grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
            <DocumentLink label="Birth Certificate" :url="vendor.birth_certificate" />
            <DocumentLink label="Identity Card" :url="vendor.identity_card" />
            <DocumentLink label="Trade Registration" :url="vendor.institution_document" />
          </div>

          <div class="relative z-10 flex space-x-4 mt-auto border-t border-white/5 pt-6">
            <button v-if="!vendor.is_approved" @click="updateStatus(vendor.id, true)" class="flex-1 py-3.5 bg-teal-400/10 border border-teal-400/30 text-teal-400 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-teal-400/20 hover:border-teal-400/50 hover:shadow-[0_0_30px_rgba(45,212,191,0.2)] transition-all flex items-center justify-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>
              Authorize Node
            </button>
            <button v-if="vendor.is_approved" @click="updateStatus(vendor.id, false)" class="flex-1 py-3.5 bg-yellow-500/10 border border-yellow-500/30 text-yellow-500 rounded-2xl text-[10px] font-black uppercase tracking-widest hover:bg-yellow-500/20 hover:border-yellow-500/50 transition-all flex items-center justify-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              Suspend Node
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import api from '../../../config/api';
import { useTheme } from '../../../composables/useTheme';
import DocumentLink from './components/DocumentLink.vue';

const { themeClasses } = useTheme();
const vendors = ref([]);
const loading = ref(false);
const filter = ref('pending');

const filteredVendors = computed(() => {
  if (filter.value === 'pending') {
    return vendors.value.filter(v => !v.is_approved);
  }
  return vendors.value;
});

const loadVendors = async () => {
  loading.value = true;
  try {
    const response = await api.get('admin/vendors/validation/');
    vendors.value = response.data;
  } catch (err) {
    console.error('Failed to load validation queue', err);
    alert('Network fetch anomaly.');
  } finally {
    loading.value = false;
  }
};

const updateStatus = async (id, is_approved) => {
  try {
    const msg = is_approved ? 'Authorize public broadcast for this node?' : 'Suspend network access for this node?';
    if (!confirm(msg)) return;
    
    await api.patch(`admin/vendors/validation/${id}/`, { is_approved });
    
    // update locally
    const vendorIndex = vendors.value.findIndex(v => v.id === id);
    if (vendorIndex !== -1) {
      vendors.value[vendorIndex].is_approved = is_approved;
    }
  } catch (err) {
    console.error('Validation update failed', err);
    alert('System command aborted due to an error.');
  }
};

onMounted(loadVendors);
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }
</style>
