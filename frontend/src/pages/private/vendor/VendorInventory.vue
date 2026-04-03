<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-y-auto relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif] min-h-screen']">
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-teal-500/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/5 blur-[180px] -z-0 pointer-events-none animate-pulse" style="animation-delay: 2s"></div>

    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5 relative">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
           <div class="w-2 h-2 rounded-full bg-teal-400 animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
           <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Vendor Module / <span class="text-white/80">Inventory Management</span></h1>
        </div>
      </div>
    </header>

    <main class="flex-1 p-4 sm:p-6 lg:p-8 space-y-6 relative z-10 custom-scrollbar">
       <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
         <div>
           <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Gas Bottle Stock</h2>
           <p class="text-[10px] font-black uppercase tracking-widest text-white/40 mt-1 italic">Manage your available inventory and pricing.</p>
         </div>
         <button @click="showAddModal = true" class="px-6 py-3 bg-gradient-to-r from-teal-400 to-blue-500 rounded-2xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_30px_rgba(45,212,191,0.4)] transition-all">
           + Add New Stock
         </button>
       </div>

       <div v-if="inventory.length === 0" class="flex flex-col items-center justify-center p-12 bg-white/[0.02] border border-white/5 rounded-[2rem]">
         <div class="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center border border-white/10 mb-6">
           <svg class="w-8 h-8 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
         </div>
         <p class="text-sm font-bold text-white/40 uppercase tracking-widest italic mb-2">No Gas Bottles In Stock</p>
         <p class="text-[10px] text-white/20 uppercase tracking-[0.2em] max-w-sm text-center">Add new gas bottles to your inventory to start selling to users.</p>
       </div>

       <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
         <!-- Bottle Cards -->
         <div v-for="bottle in inventory" :key="bottle.id" class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] p-6 sm:p-8 flex flex-col justify-between group hover:border-teal-400/50 hover:bg-white/[0.04] transition-all duration-500 relative overflow-hidden">
           <div class="absolute inset-0 bg-gradient-to-b from-teal-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
           
           <div class="relative z-10 flex justify-between items-center mb-6">
             <div class="flex items-center space-x-3">
               <div class="w-8 h-8 rounded-full bg-teal-400/10 border border-teal-400/20 flex items-center justify-center">
                 <svg class="w-4 h-4 text-teal-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
               </div>
               <div class="text-lg font-black uppercase tracking-widest text-white italic">{{ bottle.brand_display || bottle.brand }}</div>
             </div>
             <button @click="deleteBottle(bottle.id)" class="text-white/20 hover:text-red-400 transition-colors bg-white/5 hover:bg-red-400/10 p-2 rounded-xl">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
             </button>
           </div>
           
           <div class="relative z-10 space-y-4">
             <div class="flex justify-between items-end border-b border-white/5 pb-2 border-dashed">
               <span class="text-[9px] font-black uppercase tracking-widest text-white/30">Size Category</span>
               <span class="text-sm font-bold text-white/90 italic tracking-tight">{{ bottle.size_display || bottle.size }}</span>
             </div>
             <div class="flex justify-between items-end border-b border-white/5 pb-2 border-dashed">
               <span class="text-[9px] font-black uppercase tracking-widest text-white/30">Fixed Price (FCFA)</span>
               <span class="text-base font-black text-teal-400 italic tracking-tight tabular-nums">{{ bottle.price }} FCFA</span>
             </div>
             <div class="flex justify-between items-end pt-2">
               <span class="text-[9px] font-black uppercase tracking-widest text-white/30">Stock Availability</span>
               <div class="flex items-center space-x-2">
                 <span class="w-1.5 h-1.5 rounded-full" :class="bottle.stock_quantity > 0 ? 'bg-teal-400 animate-pulse' : 'bg-red-500'"></span>
                 <span class="text-lg font-black text-white italic tracking-tight tabular-nums" :class="bottle.stock_quantity > 0 ? 'text-white' : 'text-red-400'">{{ bottle.stock_quantity }} Unit(s)</span>
               </div>
             </div>
           </div>
         </div>
       </div>
    </main>

    <!-- Modal for adding stock -->
    <transition name="modal-fade">
      <div v-if="showAddModal" @click.self="showAddModal = false" class="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 bg-gray-950/80 backdrop-blur-xl">
        <div class="bg-gray-900 border border-white/10 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-10 max-w-md w-full relative group/modal overflow-hidden">
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] rounded-full opacity-50"></div>
          <div class="relative z-10">
            <div class="flex justify-between items-center mb-8">
              <div>
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 mb-1 italic">Stock Registration</h3>
                <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Add New Bottle</h2>
              </div>
              <button @click="showAddModal = false" class="p-2 text-white/20 hover:text-white transition-colors bg-white/5 rounded-full">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>

            <form @submit.prevent="addBottle" class="space-y-6">
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Gas Brand Partner</label>
                <select v-model="newBottle.brand" required class="w-full px-5 py-3.5 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white/80 font-bold italic appearance-none cursor-pointer">
                  <option value="" disabled class="bg-gray-900 text-white/50">Select a brand</option>
                  <option v-for="b in brands" :key="b.value" :value="b.value" class="bg-gray-900 text-white">{{ b.label }}</option>
                </select>
              </div>

              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Bottle Size / Capacity</label>
                <select v-model="newBottle.size" required class="w-full px-5 py-3.5 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white/80 font-bold italic appearance-none cursor-pointer">
                  <option value="" disabled class="bg-gray-900 text-white/50">Select a size</option>
                  <option v-for="s in sizes" :key="s.value" :value="s.value" class="bg-gray-900 text-white">{{ s.label }}</option>
                </select>
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Unit Price (FCFA)</label>
                  <input type="number" v-model="newBottle.price" required min="1000" class="w-full px-5 py-3.5 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold tabular-nums italic placeholder-white/20" placeholder="0.00">
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/30 ml-2 italic">Stock Volume</label>
                  <input type="number" v-model="newBottle.stock_quantity" required min="0" class="w-full px-5 py-3.5 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold tabular-nums italic placeholder-white/20" placeholder="0">
                </div>
              </div>

              <div class="pt-4">
                <button type="submit" class="w-full py-4 bg-gradient-to-r from-teal-400 to-blue-500 rounded-2xl text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_40px_rgba(45,212,191,0.5)] transition-all flex items-center justify-center">
                  <span v-if="loading">Processing...</span>
                  <span v-else>Commit Record</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '../../../config/api';
import { useTheme } from '../../../composables/';

const { themeClasses } = useTheme();
const inventory = ref([]);
const showAddModal = ref(false);
const loading = ref(false);

const newBottle = ref({ brand: '', size: '', price: null, stock_quantity: null });
const brands = [
  { value: 'BOCOM', label: 'Bocom' },
  { value: 'TOTAL', label: 'Total' },
  { value: 'GREEN_OIL', label: 'Green Oil' },
  { value: 'SCTM', label: 'SCTM' },
  { value: 'CAMGAZ', label: 'Camgaz' },
  { value: 'TRADEX', label: 'Tradex' },
  { value: 'MRS', label: 'MRS' },
  { value: 'AFT', label: 'AFT' },
  { value: 'OTHER', label: 'Other' }
];
const sizes = [
  { value: 'SMALL_6KG', label: 'Small (6kg)' },
  { value: 'MEDIUM_12_5KG', label: 'Medium (12.5kg)' },
  { value: 'BIG_50KG', label: 'Big (50kg)' }
];

const loadInventory = async () => {
  try {
    const response = await api.get('vendor/gas-bottles/');
    inventory.value = response.data;
  } catch (err) {
    console.error('Failed to load inventory', err);
  }
};

const addBottle = async () => {
  loading.value = true;
  try {
    const response = await api.post('vendor/gas-bottles/', newBottle.value);
    inventory.value.push(response.data);
    showAddModal.value = false;
    newBottle.value = { brand: '', size: '', price: null, stock_quantity: null };
  } catch (err) {
    console.error('Failed to add bottle', err);
    alert('Failed to register stock. ' + JSON.stringify(err.response?.data || 'Server error.'));
  } finally {
    loading.value = false;
  }
};

const deleteBottle = async (id) => {
  if (!confirm('Are you sure you want to permanently erase this record?')) return;
  try {
    await api.delete(`vendor/gas-bottles/${id}/`);
    inventory.value = inventory.value.filter(b => b.id !== id);
  } catch (err) {
    console.error('Failed to delete', err);
  }
};

onMounted(loadInventory);
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

.modal-fade-enter-active, .modal-fade-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-fade-enter-from, .modal-fade-leave-to { opacity: 0; transform: scale(0.95); }
</style>
