<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    <!-- Background accents -->
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-orange-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay:2s"></div>

    <!-- Header -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-orange-400 shadow-[0_0_10px_rgba(251,146,60,0.5)] animate-pulse"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Logistics / <span class="text-white/80">Delivery Control</span></h1>
        </div>
        <div class="flex items-center gap-3">
          <div class="px-4 py-1.5 rounded-full bg-orange-400/5 border border-orange-400/20 text-[9px] font-black text-orange-400 uppercase tracking-widest italic">
            {{ pendingCount }} PENDING
          </div>
          <div class="px-4 py-1.5 rounded-full bg-teal-400/5 border border-teal-400/20 text-[9px] font-black text-teal-400 uppercase tracking-widest italic">
            {{ myDeliveries.length }} MY ROUTES
          </div>
        </div>
      </div>
    </header>

    <!-- Tab Bar -->
    <div class="border-b border-white/5 px-8">
      <div class="flex space-x-8">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          @click="activeTab = tab.key"
          :class="[
            'py-4 text-[10px] font-black uppercase tracking-[0.2em] border-b-2 transition-all duration-300',
            activeTab === tab.key
              ? 'border-orange-400 text-orange-400'
              : 'border-transparent text-white/30 hover:text-white/60'
          ]"
        >{{ tab.label }}</button>
      </div>
    </div>

    <main class="flex-1 overflow-y-auto p-8 custom-scrollbar">
      <!-- Loading -->
      <div v-if="loading" class="flex items-center justify-center h-48">
        <div class="w-8 h-8 border-2 border-orange-400/20 border-t-orange-400 rounded-full animate-spin"></div>
      </div>

      <!-- Empty state -->
      <div v-else-if="displayedDeliveries.length === 0" class="flex flex-col items-center justify-center py-20">
        <div class="w-16 h-16 rounded-full bg-white/5 border border-white/10 flex items-center justify-center mb-4">
          <svg class="w-8 h-8 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
          </svg>
        </div>
        <p class="text-sm font-bold text-white/40 uppercase tracking-widest italic">No deliveries in this queue</p>
      </div>

      <!-- Delivery Cards Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <div
          v-for="delivery in displayedDeliveries"
          :key="delivery.id"
          class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] p-6 flex flex-col gap-4 hover:border-orange-400/30 transition-all duration-500 group"
        >
          <!-- Status badge -->
          <div class="flex justify-between items-center">
            <span class="text-[9px] font-black uppercase tracking-widest px-3 py-1 rounded-full border"
              :class="statusStyle(delivery.status)">
              {{ delivery.status_display }}
            </span>
            <span class="text-[10px] font-bold text-white/30 italic">#{{ delivery.id }}</span>
          </div>

          <!-- Bottle info -->
          <div>
            <p class="text-xs font-black text-white/30 uppercase tracking-widest mb-1">Cylinder</p>
            <p class="text-lg font-black text-white italic tracking-tighter">{{ delivery.bottle_detail }}</p>
          </div>

          <!-- Addresses -->
          <div class="space-y-2 border-t border-white/5 pt-3">
            <div class="flex items-start gap-2">
              <div class="w-1.5 h-1.5 rounded-full bg-teal-400 mt-1.5 shrink-0"></div>
              <div>
                <p class="text-[8px] text-white/20 uppercase tracking-widest">From (Supplier)</p>
                <p class="text-xs font-bold text-white/70">{{ delivery.vendor_name }}</p>
              </div>
            </div>
            <div class="flex items-start gap-2">
              <div class="w-1.5 h-1.5 rounded-full bg-orange-400 mt-1.5 shrink-0"></div>
              <div>
                <p class="text-[8px] text-white/20 uppercase tracking-widest">To (Client)</p>
                <p class="text-xs font-bold text-white/70">{{ delivery.delivery_address }}</p>
              </div>
            </div>
          </div>

          <!-- Driver -->
          <div v-if="delivery.delivery_person_name" class="text-[9px] font-bold text-white/30 uppercase tracking-widest">
            Driver: <span class="text-white/60">{{ delivery.delivery_person_name }}</span>
          </div>

          <!-- Actions -->
          <div class="flex flex-wrap gap-2 pt-2 border-t border-white/5">
            <!-- Claim -->
            <button
              v-if="delivery.status === 'PENDING' && !delivery.delivery_person"
              @click="updateStatus(delivery.id, 'ASSIGNED')"
              class="flex-1 py-2.5 px-3 rounded-xl bg-orange-400/10 border border-orange-400/30 text-[9px] font-black uppercase tracking-widest text-orange-400 hover:bg-orange-400 hover:text-gray-950 transition-all"
            >Claim</button>

            <!-- Out for Delivery -->
            <button
              v-if="delivery.status === 'ASSIGNED' && delivery.delivery_person === myUserId"
              @click="updateStatus(delivery.id, 'OUT_FOR_DELIVERY')"
              class="flex-1 py-2.5 px-3 rounded-xl bg-blue-400/10 border border-blue-400/30 text-[9px] font-black uppercase tracking-widest text-blue-400 hover:bg-blue-400 hover:text-gray-950 transition-all"
            >Out for Delivery</button>

            <!-- Mark Delivered -->
            <button
              v-if="delivery.status === 'OUT_FOR_DELIVERY' && delivery.delivery_person === myUserId"
              @click="updateStatus(delivery.id, 'DELIVERED')"
              class="flex-1 py-2.5 px-3 rounded-xl bg-teal-400/10 border border-teal-400/30 text-[9px] font-black uppercase tracking-widest text-teal-400 hover:bg-teal-400 hover:text-gray-950 transition-all"
            >Mark Delivered</button>

            <!-- View Route -->
            <router-link
              v-if="delivery.status !== 'DELIVERED' && delivery.status !== 'CANCELLED' && delivery.vendor_latitude"
              :to="{ name: 'delivery-route', params: { id: delivery.id } }"
              class="flex-1 py-2.5 px-3 rounded-xl bg-white/5 border border-white/10 text-[9px] font-black uppercase tracking-widest text-white/40 hover:border-white/20 hover:text-white transition-all text-center"
            >View Route</router-link>

            <!-- Cancel -->
            <button
              v-if="delivery.status === 'PENDING' || delivery.status === 'ASSIGNED'"
              @click="updateStatus(delivery.id, 'CANCELLED')"
              class="py-2.5 px-3 rounded-xl bg-red-400/5 border border-red-400/20 text-[9px] font-black uppercase tracking-widest text-red-400/60 hover:bg-red-500 hover:text-white transition-all"
            >Cancel</button>
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
import { useUserStore } from '../../../stores/user';

const { themeClasses } = useTheme();
const userStore = useUserStore();
const deliveries = ref([]);
const loading = ref(true);
const activeTab = ref('pending');

const myUserId = computed(() => userStore.userProfile?.id);

const tabs = [
  { key: 'pending', label: 'Available Jobs (Pending)' },
  { key: 'mine', label: 'My Route Assignments' },
  { key: 'all', label: 'All' },
];

const pendingCount = computed(() =>
  deliveries.value.filter(d => d.status === 'PENDING' && !d.delivery_person).length
);

const myDeliveries = computed(() =>
  deliveries.value.filter(d => d.delivery_person === myUserId.value)
);

const displayedDeliveries = computed(() => {
  if (activeTab.value === 'pending') return deliveries.value.filter(d => d.status === 'PENDING' && !d.delivery_person);
  if (activeTab.value === 'mine') return myDeliveries.value;
  return deliveries.value;
});

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

const loadDeliveries = async () => {
  loading.value = true;
  try {
    const res = await api.get('deliveries/');
    deliveries.value = res.data;
  } catch (e) {
    console.error('Failed to load deliveries', e);
  } finally {
    loading.value = false;
  }
};

const updateStatus = async (id, status) => {
  try {
    const res = await api.patch(`deliveries/${id}/`, { status });
    const idx = deliveries.value.findIndex(d => d.id === id);
    if (idx !== -1) deliveries.value[idx] = res.data;
  } catch (e) {
    console.error('Failed to update delivery', e);
  }
};

onMounted(loadDeliveries);
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
</style>
