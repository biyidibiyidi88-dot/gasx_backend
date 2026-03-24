<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Notification Toast -->
    <transition name="toast">
      <div v-if="showToast" 
           :class="['fixed top-6 right-6 z-[100] px-6 py-4 rounded-2xl shadow-2xl backdrop-blur-xl border flex items-center gap-4', 
                   toastType === 'success' ? 'bg-teal-500/10 border-teal-400/20 text-teal-400' : 'bg-red-500/10 border-red-500/20 text-red-400']">
        <div class="w-2 h-2 rounded-full bg-current animate-pulse"></div>
        <span class="text-[10px] font-black uppercase tracking-[0.2em] italic">{{ toastMessage }}</span>
      </div>
    </transition>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-blue-400 shadow-[0_0_10px_rgba(96,165,250,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Communication / <span class="text-white/80">Node Intelligence</span></h1>
          <span v-if="unreadCount > 0" class="px-3 py-1 bg-red-500/10 border border-red-500/20 rounded-full text-[9px] font-black text-red-400 uppercase tracking-widest animate-pulse italic">
            {{ unreadCount }} New Logs
          </span>
        </div>
        
        <div class="flex items-center gap-4">
          <button @click="markAllAsRead" class="px-5 py-2.5 bg-white/5 border border-white/10 rounded-xl text-[9px] font-black uppercase tracking-[0.2em] text-white/40 hover:text-white hover:border-white/20 transition-all italic">Mark All Resolved</button>
          <button @click="showNotificationSettings = true" class="p-2.5 bg-teal-400 hover:bg-teal-300 rounded-xl text-gray-950 transition-all hover:shadow-[0_0_20px_rgba(45,212,191,0.4)]">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar max-w-5xl mx-auto w-full">
      
      <!-- Intelligence Filters -->
      <div class="flex flex-wrap items-center justify-between gap-6 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-6 group/filters">
        <div class="flex items-center gap-3 overflow-x-auto scrollbar-hide">
          <button 
            v-for="filter in filters" 
            :key="filter.value" 
            @click="activeFilter = filter.value"
            class="px-5 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-widest border transition-all duration-300 relative overflow-hidden italic"
            :class="activeFilter === filter.value ? 'bg-teal-400 text-gray-950 border-teal-400 shadow-[0_0_20px_rgba(45,212,191,0.3)]' : 'bg-white/5 text-white/30 border-white/5 hover:text-white'"
          >
            {{ filter.label }}
            <span v-if="filter.count" class="ml-2 opacity-50">{{ filter.count }}</span>
          </button>
        </div>

        <div class="flex items-center gap-4">
          <span class="text-[9px] font-black text-white/20 uppercase tracking-widest italic">Sequence Buffer:</span>
          <select v-model="sortBy" class="bg-white/5 border border-white/5 rounded-xl px-4 py-2 text-[10px] font-black text-white uppercase tracking-widest outline-none focus:border-teal-400/30 transition-all cursor-pointer italic">
            <option value="newest">Recent_First</option>
            <option value="oldest">Historical_First</option>
            <option value="priority">Priority_First</option>
          </select>
        </div>
      </div>

      <!-- Feed Content -->
      <div v-if="isLoading" class="flex flex-col items-center justify-center py-20 animate-pulse">
        <div class="w-12 h-12 rounded-2xl border-2 border-teal-400/20 border-t-teal-400 animate-spin mb-4"></div>
        <div class="text-[10px] font-black text-white/20 uppercase tracking-[0.4em] italic">Synthesizing_Logs...</div>
      </div>

      <div v-else-if="filteredNotifications.length === 0" class="flex flex-col items-center justify-center py-20 group/empty">
        <div class="w-20 h-20 rounded-[2.5rem] bg-white/5 border border-white/10 flex items-center justify-center text-white/10 mb-8 group-hover/empty:scale-110 transition-transform duration-700">
          <svg class="h-10 w-10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
        </div>
        <h3 class="text-xl font-black text-white italic uppercase tracking-tighter mb-2">Zero Deviations Detected</h3>
        <p class="text-[10px] font-bold text-white/20 uppercase tracking-widest italic">All nodes operating within specified logic thresholds.</p>
      </div>

      <div v-else class="space-y-4">
        <transition-group name="list">
          <div 
            v-for="n in filteredNotifications" 
            :key="n.id" 
            class="group/log relative bg-white/[0.02] backdrop-blur-3xl border rounded-[2rem] p-6 hover:bg-white/[0.04] transition-all duration-500 overflow-hidden"
            :class="[
              !n.is_resolved ? 'border-teal-400/20' : 'border-white/5',
              n.severity_level === 'CRITICAL' && !n.is_resolved ? 'border-red-500/20' : '',
              n.severity_level === 'HIGH' && !n.is_resolved ? 'border-yellow-500/20' : ''
            ]"
          >
            <!-- Severity Side Indicator -->
            <div class="absolute left-0 top-0 bottom-0 w-1" :class="[
              n.severity_level === 'CRITICAL' ? 'bg-red-500 shadow-[2px_0_10px_rgba(239,68,68,0.5)]' : 
              n.severity_level === 'HIGH' ? 'bg-yellow-400 shadow-[2px_0_10px_rgba(250,204,21,0.5)]' : 
              'bg-teal-400 shadow-[2px_0_10px_rgba(45,212,191,0.5)]'
            ]"></div>

            <div class="flex items-start gap-6">
              <!-- Type Icon -->
              <div class="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 border border-white/5" :class="[
                n.alert_type === 'GAS_LEAK' ? 'bg-red-500/10 text-red-400' : 
                n.alert_type === 'SYSTEM' ? 'bg-blue-400/10 text-blue-400' : 
                'bg-teal-400/10 text-teal-400'
              ]">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path v-if="n.alert_type === 'GAS_LEAK'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                  <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
              </div>

              <!-- Content Area -->
              <div class="flex-1 space-y-1">
                <div class="flex justify-between items-start gap-4">
                   <h3 class="text-lg font-black text-white italic uppercase tracking-tighter leading-tight">{{ n.alert_message }}</h3>
                   <span class="text-[9px] font-black text-white/20 uppercase tracking-widest italic tabular-nums whitespace-nowrap">{{ formatTime(n.triggered_at) }}</span>
                </div>
                
                <div class="flex items-center gap-4">
                  <span class="text-[10px] font-black text-teal-400/60 uppercase tracking-widest italic">{{ n.sensor_name || 'System Grid' }}</span>
                  <div class="w-1 h-1 rounded-full bg-white/10"></div>
                  <span class="text-[10px] font-bold text-white/20 uppercase tracking-widest italic truncate max-w-xs">{{ n.house_address }}</span>
                </div>

                <div class="flex gap-4 pt-4">
                  <button v-if="!n.is_resolved" @click="markAsRead(n)" class="text-[9px] font-black text-teal-400 uppercase tracking-widest italic hover:text-teal-300 transition-colors">RESOLVE_LOG</button>
                  <button @click="dismissNotification(n)" class="text-[9px] font-black text-white/20 uppercase tracking-widest italic hover:text-white/40 transition-colors">PURGE_SEQ</button>
                </div>
              </div>
            </div>
          </div>
        </transition-group>
      </div>

    </main>

    <!-- Settings Modal Layer -->
    <transition name="modal">
      <div v-if="showNotificationSettings" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-gray-950/80 backdrop-blur-xl" @click="showNotificationSettings = false">
        
        <div @click.stop class="bg-gray-900 border border-white/10 rounded-[3.5rem] p-10 max-w-2xl w-full relative overflow-hidden group/modal">
          <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-400/[0.02] to-transparent pointer-events-none"></div>
          
          <div class="relative z-10 space-y-10">
            <div class="flex items-center gap-6 border-b border-white/5 pb-8">
              <div class="w-16 h-16 rounded-3xl bg-teal-400/10 border border-teal-400/20 flex items-center justify-center text-teal-400 shadow-xl shadow-teal-400/5 transition-transform duration-700 group-hover/modal:rotate-12">
                <svg class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
              </div>
              <div>
                <h3 class="text-[11px] font-black uppercase tracking-[0.4em] text-teal-400/60 mb-2 italic">Intelligence Bias</h3>
                <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Transmission Rules</h2>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
              <!-- Channel Logic -->
              <div class="space-y-6">
                <h4 class="text-[10px] font-black text-white/20 uppercase tracking-[0.3em] italic ml-4">Communication Uplinks</h4>
                <div v-for="(val, key) in { emailEnabled: 'SMTP_Link', pushEnabled: 'Direct_Notify', smsEnabled: 'Binary_SMS' }" :key="key" class="flex items-center justify-between p-4 rounded-2xl hover:bg-white/5 transition-all cursor-pointer group/toggle" @click="settings[key] = !settings[key]">
                  <span class="text-[10px] font-black uppercase tracking-widest italic" :class="settings[key] ? 'text-teal-400' : 'text-white/40'">{{ val }}</span>
                  <div class="w-12 h-6 rounded-full relative transition-colors duration-500" :class="settings[key] ? 'bg-teal-400' : 'bg-white/10'">
                    <div class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-all duration-500" :class="settings[key] ? 'translate-x-6' : 'translate-x-0'"></div>
                  </div>
                </div>
              </div>

              <!-- Sensitivity Logic -->
              <div class="space-y-6">
                <h4 class="text-[10px] font-black text-white/20 uppercase tracking-[0.3em] italic ml-4">Alert Sensitivity</h4>
                <div class="space-y-4">
                  <div v-for="(label, key) in { criticalAlerts: 'Criticals', warningAlerts: 'Warnings' }" :key="key" class="space-y-2 group/input">
                    <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">{{ label }} Protocol</label>
                    <select v-model="settings[key]" class="w-full bg-white/5 border border-white/5 rounded-xl px-4 py-3 text-[10px] font-black text-white uppercase tracking-widest outline-none focus:border-teal-400/30 transition-all cursor-pointer italic appearance-none">
                      <option value="all">Analyze All</option>
                      <option value="important">Important Only</option>
                      <option value="none">Ignore Seq</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            <!-- Modal Footer -->
            <div class="flex gap-4 pt-8 border-t border-white/5">
              <button @click="showNotificationSettings = false" class="flex-1 py-5 border border-white/5 text-[10px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-2xl transition-all">Abort Sync</button>
              <button @click="saveNotificationSettings" class="flex-1 py-5 bg-teal-400 text-gray-950 text-[10px] font-black uppercase tracking-widest rounded-2xl hover:shadow-[0_0_30px_rgba(45,212,191,0.4)] transition-all">Apply Modification</button>
            </div>
          </div>
        </div>

      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useTheme } from '../../composables/useTheme'
import api from '../../config/api'

const { isDark, toggleTheme, themeClasses } = useTheme()

const activeFilter = ref('unread')
const sortBy = ref('newest')
const showNotificationSettings = ref(false)
const notifications = ref([])
const isLoading = ref(false)
const showToast = ref(false)
const toastMessage = ref('')
const toastType = ref('success')

const hours = Array.from({ length: 24 }, (_, i) => ({
  value: i,
  label: `${i === 0 ? 12 : i > 12 ? i - 12 : i}:00 ${i >= 12 ? 'PM' : 'AM'}`
}))

const filters = [
  { value: 'all', label: 'Matrix' },
  { value: 'unread', label: 'Unresolved' },
  { value: 'alerts', label: 'Anomalies' },
  { value: 'system', label: 'Core Log' },
  { value: 'tanks', label: 'Hardware' },
  { value: 'payments', label: 'Credit' }
]

const settings = ref({
  emailEnabled: true, pushEnabled: true, smsEnabled: false,
  criticalAlerts: 'all', warningAlerts: 'all', infoAlerts: 'important',
  quietStart: 22, quietEnd: 6
})

const filteredNotifications = computed(() => {
  let filtered = [...notifications.value]
  if (activeFilter.value === 'unread') filtered = filtered.filter(n => !n.is_resolved)
  else if (activeFilter.value === 'alerts') filtered = filtered.filter(n => n.alert_type !== 'SYSTEM' && !n.alert_type.includes('PAYMENT'))
  else if (activeFilter.value === 'system') filtered = filtered.filter(n => n.alert_type === 'SYSTEM')
  else if (activeFilter.value === 'tanks') filtered = filtered.filter(n => n.sensor_name)
  else if (activeFilter.value === 'payments') filtered = filtered.filter(n => n.alert_type.includes('PAYMENT'))

  if (sortBy.value === 'newest') filtered.sort((a,b) => new Date(b.triggered_at) - new Date(a.triggered_at))
  else if (sortBy.value === 'oldest') filtered.sort((a,b) => new Date(a.triggered_at) - new Date(b.triggered_at))
  else if (sortBy.value === 'priority') {
    const p = { CRITICAL: 1, HIGH: 2, MEDIUM: 3, LOW: 4 }
    filtered.sort((a,b) => (p[a.severity_level] || 5) - (p[b.severity_level] || 5))
  }
  return filtered
})

const unreadCount = computed(() => notifications.value.filter(n => !n.is_resolved).length)

const showToastMessage = (msg, type = 'success') => {
  toastMessage.value = msg; toastType.value = type; showToast.value = true;
  setTimeout(() => showToast.value = false, 3000)
}

const formatTime = (ts) => {
  const d = new Date(ts)
  return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const fetchNotifications = async () => {
  isLoading.value = true
  try {
    const res = await api.get('/notifications/')
    notifications.value = res.data
  } catch (e) { showToastMessage('Fetch failure', 'error') }
  finally { isLoading.value = false }
}

const markAsRead = async (n) => {
  try {
    await api.post(`/notifications/${n.id}/read/`)
    n.is_resolved = true
    showToastMessage('Log resolved')
  } catch (e) { showToastMessage('State override failure', 'error') }
}

const markAllAsRead = async () => {
  try {
    await api.post('/notifications/mark-all-read/')
    notifications.value.forEach(n => n.is_resolved = true)
    showToastMessage('All sequences resolved')
  } catch (e) { showToastMessage('Global override failure', 'error') }
}

const dismissNotification = async (n) => {
  try {
    await api.delete(`/notifications/${n.id}/`)
    notifications.value = notifications.value.filter(item => item.id !== n.id)
    showToastMessage('Log purged')
  } catch (e) { showToastMessage('Purge failure', 'error') }
}

const saveNotificationSettings = async () => {
  try {
    await api.post('/notifications/settings/', settings.value)
    showNotificationSettings.value = false
    showToastMessage('Rules updated')
  } catch (e) { showToastMessage('Write failure', 'error') }
}

onMounted(() => {
  fetchNotifications()
  api.get('/notifications/settings/').then(res => settings.value = res.data).catch(() => {})
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.scrollbar-hide::-webkit-scrollbar { display: none; }

.list-enter-active, .list-leave-active { transition: all 0.5s ease; }
.list-enter-from, .list-leave-to { opacity: 0; transform: translateX(30px); }

.modal-enter-active, .modal-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.98); }
</style>