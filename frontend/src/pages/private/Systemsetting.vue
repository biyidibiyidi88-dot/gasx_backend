<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-blue-400 shadow-[0_0_10px_rgba(96,165,250,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Command / <span class="text-white/80">System Configuration</span></h1>
        </div>
        
        <div class="flex items-center gap-6">
          <div class="text-[9px] font-black uppercase tracking-widest italic transition-all duration-500" :class="saved ? 'text-teal-400' : 'text-white/20'">
            <span v-if="saved" class="flex items-center gap-2">
              <div class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></div>
              LOG_COMMITTED
            </span>
            <span v-else>MODIFICATION_DETECTED</span>
          </div>

          <button 
            @click="saveSettings"
            class="group flex items-center px-6 py-2.5 bg-teal-400 hover:bg-teal-300 rounded-xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 transition-all hover:shadow-[0_0_20px_rgba(45,212,191,0.4)]"
          >
            Execute Sync
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar max-w-5xl mx-auto w-full">
      
      <!-- Alert Protocol Settings -->
      <section class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem] p-10 hover:border-white/10 transition-all duration-500">
        <div class="flex items-center gap-4 mb-10 border-b border-white/5 pb-6">
          <div class="w-10 h-10 rounded-2xl bg-yellow-400/10 flex items-center justify-center text-yellow-400 border border-yellow-400/20 shadow-lg shadow-yellow-400/5">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
          </div>
          <div>
            <h2 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Alert Logic</h2>
            <h3 class="text-xl font-black text-white italic tracking-tighter uppercase">Notification Protocols</h3>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
          <!-- Transmissions -->
          <div class="space-y-6">
            <div @click="settings.emailNotifications = !settings.emailNotifications" class="flex items-center justify-between group cursor-pointer p-4 rounded-2xl hover:bg-white/5 transition-all">
              <div class="space-y-1">
                <div class="text-[10px] font-black text-white/80 uppercase tracking-widest italic transition-colors" :class="settings.emailNotifications ? 'text-teal-400' : ''">Uplink Email</div>
                <div class="text-[9px] font-bold text-white/20 uppercase tracking-widest italic">Receive telemetry via SMTP link</div>
              </div>
              <div class="w-12 h-6 rounded-full relative transition-colors duration-500" :class="settings.emailNotifications ? 'bg-teal-400' : 'bg-white/10'">
                <div class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-all duration-500" :class="settings.emailNotifications ? 'translate-x-6' : 'translate-x-0'"></div>
              </div>
            </div>

            <div @click="settings.smsNotifications = !settings.smsNotifications" class="flex items-center justify-between group cursor-pointer p-4 rounded-2xl hover:bg-white/5 transition-all">
              <div class="space-y-1">
                <div class="text-[10px] font-black text-white/80 uppercase tracking-widest italic transition-colors" :class="settings.smsNotifications ? 'text-teal-400' : ''">Uplink SMS</div>
                <div class="text-[9px] font-bold text-white/20 uppercase tracking-widest italic">Critical logic alerts via binary text</div>
              </div>
              <div class="w-12 h-6 rounded-full relative transition-colors duration-500" :class="settings.smsNotifications ? 'bg-teal-400' : 'bg-white/10'">
                <div class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-all duration-500" :class="settings.smsNotifications ? 'translate-x-6' : 'translate-x-0'"></div>
              </div>
            </div>
          </div>

          <!-- Thresholds -->
          <div class="space-y-6">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2 group/input">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Low Reserve (%)</label>
                <input v-model="settings.lowLevelThreshold" type="number" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
              </div>
              <div class="space-y-2 group/input">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-red-400 transition-colors">Critical Drain (%)</label>
                <input v-model="settings.criticalLevelThreshold" type="number" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-red-500/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
              </div>
            </div>
            <div class="space-y-2 group/input">
              <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-blue-400 transition-colors">Transmission Delay (Minutes)</label>
              <input v-model="settings.alertDelay" type="number" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
            </div>
          </div>
        </div>

        <!-- Schedule Grid -->
        <div class="mt-12 space-y-4 pt-8 border-t border-white/5">
          <h3 class="text-[9px] font-black uppercase tracking-[0.4em] text-white/20 italic ml-4">Authorized Transmission Cycles</h3>
          <div class="flex flex-wrap gap-2">
            <button 
              v-for="hour in hours" 
              :key="hour.value" 
              @click="toggleNotificationHour(hour.value)"
              :class="[
                settings.notificationHours.includes(hour.value) ? 'bg-teal-400 text-gray-950 border-teal-400 shadow-[0_0_15px_rgba(45,212,191,0.3)]' : 'bg-white/5 text-white/30 border-white/5 hover:text-white',
                'px-4 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest border transition-all duration-300'
              ]"
            >
              {{ hour.label }}
            </button>
          </div>
        </div>
      </section>

      <!-- Hardware Constraints Section -->
      <section class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem] p-10 hover:border-white/10 transition-all duration-500">
        <div class="flex items-center gap-4 mb-10 border-b border-white/5 pb-6">
          <div class="w-10 h-10 rounded-2xl bg-blue-400/10 flex items-center justify-center text-blue-400 border border-blue-400/20 shadow-lg shadow-blue-400/5">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/></svg>
          </div>
          <div>
            <h2 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Module Constraints</h2>
            <h3 class="text-xl font-black text-white italic tracking-tighter uppercase">Hardware Configuration</h3>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
           <div class="space-y-2 group/input">
            <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Fuel Matrix Type</label>
            <select v-model="settings.tankType" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight appearance-none cursor-pointer uppercase">
              <option>Propane</option>
              <option>Butane</option>
              <option>Natural Gas</option>
              <option>Other</option>
            </select>
          </div>
          <div class="space-y-2 group/input">
            <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Volumetric Capacity (L)</label>
            <input v-model="settings.tankCapacity" type="number" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
          </div>
          <div class="space-y-2 group/input">
            <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Deployment Zone</label>
            <input v-model="settings.tankLocation" type="text" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mt-12 pt-8 border-t border-white/5">
          <div v-for="(val, key) in { minPressure: 'Min PSI', maxPressure: 'Max PSI', minTemperature: 'Min °C', maxTemperature: 'Max °C' }" :key="key" class="space-y-2 group/input">
            <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-blue-400 transition-colors">{{ val }} Threshold</label>
            <input v-model="settings[key]" type="number" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
          </div>
        </div>
      </section>

      <!-- Terminal Destruction Layer -->
      <section class="bg-red-500/[0.02] border border-red-500/10 rounded-[3rem] p-10 hover:bg-red-500/[0.03] transition-all duration-700 group/danger">
        <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-red-400/40 italic mb-8">Danger Protocol Grid</h3>
        
        <div class="grid grid-cols-2 gap-8">
           <div class="p-8 bg-white/5 rounded-[2rem] border border-white/5 space-y-4 hover:border-red-500/30 transition-all">
             <div class="text-[10px] font-black text-white/60 uppercase tracking-widest italic">Logic Factory Reset</div>
             <p class="text-[9px] font-bold text-white/20 uppercase tracking-widest leading-loose italic">Wipe all custom threshold logic and return the system to its initial baseline state.</p>
             <button @click="confirmReset = true" class="px-6 py-3 border border-red-500/20 text-red-500 rounded-xl text-[9px] font-black uppercase tracking-widest hover:bg-red-500 hover:text-white transition-all">Reset Matrix</button>
           </div>

           <div class="p-8 bg-white/5 rounded-[2rem] border border-white/5 space-y-4 hover:border-red-500/30 transition-all">
             <div class="text-[10px] font-black text-white/60 uppercase tracking-widest italic">Permanent Node Purge</div>
             <p class="text-[9px] font-bold text-white/20 uppercase tracking-widest leading-loose italic">Erase all associated account data, telemetry logs, and authorized credentials permanently.</p>
             <button @click="confirmDelete = true" class="px-6 py-3 bg-red-500 text-white rounded-xl text-[9px] font-black uppercase tracking-widest hover:bg-red-600 shadow-xl transition-all">Purge Account</button>
           </div>
        </div>
      </section>

    </main>

    <!-- Modal Layers -->
    <transition name="modal">
      <div v-if="confirmReset || confirmDelete" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-gray-950/80 backdrop-blur-xl" @click="confirmReset = false; confirmDelete = false">
        
        <!-- Reset Modal -->
        <div v-if="confirmReset" @click.stop class="bg-gray-900 border border-white/10 rounded-[3rem] p-10 max-w-sm w-full text-center space-y-8 overflow-hidden group/modal relative">
          <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-red-500/5 to-transparent pointer-events-none"></div>
          <div class="w-16 h-16 mx-auto rounded-3xl bg-red-500/10 border border-red-500/20 flex items-center justify-center animate-pulse">
            <svg class="h-8 w-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
          </div>
          <div>
            <h3 class="text-[11px] font-black uppercase tracking-[0.4em] text-red-500/60 mb-2 italic">LOGIC_FAULT_DETECTED</h3>
            <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Reset All Logic?</h2>
            <p class="text-[10px] font-bold text-white/30 uppercase tracking-widest italic mt-4 leading-relaxed">This will override all custom thresholds and return node to baseline parameters.</p>
          </div>
          <div class="flex gap-4">
            <button @click="confirmReset = false" class="flex-1 py-4 border border-white/5 text-[9px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-xl transition-all">Abort</button>
            <button @click="resetSettings" class="flex-1 py-4 bg-red-500 text-[10px] font-black uppercase tracking-widest text-white rounded-xl hover:shadow-[0_0_30px_rgba(239,68,68,0.4)] transition-all">Execute Wipe</button>
          </div>
        </div>

        <!-- Delete Modal -->
         <div v-if="confirmDelete" @click.stop class="bg-gray-900 border border-white/10 rounded-[3rem] p-10 max-w-sm w-full text-center space-y-8 relative overflow-hidden group/modal">
          <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-red-500/5 to-transparent pointer-events-none"></div>
          <div class="w-16 h-16 mx-auto rounded-3xl bg-red-500/10 border border-red-500/20 flex items-center justify-center animate-pulse">
            <svg class="h-8 w-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
          </div>
          <div>
            <h3 class="text-[11px] font-black uppercase tracking-[0.4em] text-red-500/60 mb-2 italic">DANGER_PROTOCOL</h3>
            <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Purge Account?</h2>
            <p class="text-[10px] font-bold text-white/30 uppercase tracking-widest italic mt-4 leading-relaxed text-center">Type "DELETE" to confirm terminal node erasure.</p>
          </div>
          <div class="space-y-4">
            <input v-model="deleteConfirmation" type="text" class="w-full px-6 py-4 bg-white/5 border border-red-500/10 rounded-xl focus:border-red-500 focus:outline-none text-white text-center font-black italic uppercase">
          </div>
          <div class="flex gap-4">
            <button @click="confirmDelete = false; deleteConfirmation = ''" class="flex-1 py-4 border border-white/5 text-[9px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-xl transition-all">Abort</button>
            <button @click="deleteAccount" :disabled="deleteConfirmation !== 'DELETE'" class="flex-1 py-4 bg-red-500 text-[10px] font-black uppercase tracking-widest text-white disabled:opacity-20 rounded-xl hover:shadow-[0_0_30px_rgba(239,68,68,0.4)] transition-all">Confirm Purge</button>
          </div>
        </div>

      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useTheme } from '../../composables/useTheme';

const { isDark, toggleTheme, themeClasses } = useTheme();

// Logic State
const saved = ref(false);
const confirmReset = ref(false);
const confirmDelete = ref(false);
const deleteConfirmation = ref('');

const hours = [
  { value: 0, label: '12 AM' }, { value: 1, label: '01 AM' }, { value: 2, label: '02 AM' }, { value: 3, label: '03 AM' },
  { value: 4, label: '04 AM' }, { value: 5, label: '05 AM' }, { value: 6, label: '06 AM' }, { value: 7, label: '07 AM' },
  { value: 8, label: '08 AM' }, { value: 9, label: '09 AM' }, { value: 10, label: '10 AM' }, { value: 11, label: '11 AM' },
  { value: 12, label: '12 PM' }, { value: 13, label: '01 PM' }, { value: 14, label: '02 PM' }, { value: 15, label: '03 PM' },
  { value: 16, label: '04 PM' }, { value: 17, label: '05 PM' }, { value: 18, label: '06 PM' }, { value: 19, label: '07 PM' },
  { value: 20, label: '08 PM' }, { value: 21, label: '09 PM' }, { value: 22, label: '10 PM' }, { value: 23, label: '11 PM' }
];

const settings = ref({
  emailNotifications: true,
  smsNotifications: false,
  lowLevelThreshold: 20,
  criticalLevelThreshold: 10,
  alertDelay: 5,
  notificationHours: [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
  tankType: 'Propane',
  tankCapacity: 100,
  minPressure: 100,
  maxPressure: 150,
  minTemperature: 15,
  maxTemperature: 30,
  tankLocation: 'BACKYARD_ALPHA_STORAGE',
  theme: 'system',
  refreshRate: '60',
  defaultView: 'overview'
});

const toggleNotificationHour = (hour) => {
  const idx = settings.value.notificationHours.indexOf(hour);
  if (idx === -1) settings.value.notificationHours.push(hour);
  else settings.value.notificationHours.splice(idx, 1);
  settings.value.notificationHours.sort((a, b) => a - b);
};

const saveSettings = () => {
  console.log('SYNC_COMMITTED:', settings.value);
  saved.value = true;
  setTimeout(() => saved.value = false, 3000);
};

const resetSettings = () => {
  settings.value = {
    emailNotifications: true, smsNotifications: false, lowLevelThreshold: 20,
    criticalLevelThreshold: 10, alertDelay: 5,
    notificationHours: [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
    tankType: 'Propane', tankCapacity: 100, minPressure: 100, maxPressure: 150,
    minTemperature: 15, maxTemperature: 30, tankLocation: 'BACKYARD_ALPHA_STORAGE',
    theme: 'system', refreshRate: '60', defaultView: 'overview'
  };
  confirmReset.value = false;
  saveSettings();
};

const deleteAccount = () => {
  if (deleteConfirmation.value === 'DELETE') {
    console.log('ACCOUNT_PURGED');
    confirmDelete.value = false;
    // router.push('/login') would go here
  }
};
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }

/* Modal transitions */
.modal-enter-active, .modal-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.98); }

input[type="number"]::-webkit-inner-spin-button, 
input[type="number"]::-webkit-outer-spin-button { 
  -webkit-appearance: none; 
  margin: 0; 
}
</style>