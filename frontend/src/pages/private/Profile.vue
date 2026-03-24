<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Notification Toast -->
    <transition name="toast">
      <div v-if="showNotification" 
           :class="['fixed top-6 right-6 z-[100] px-6 py-4 rounded-2xl shadow-2xl backdrop-blur-xl border flex items-center gap-4', 
                   notificationType === 'success' ? 'bg-teal-500/10 border-teal-400/20 text-teal-400' : 'bg-red-500/10 border-red-500/20 text-red-400']">
        <div class="w-2 h-2 rounded-full bg-current animate-pulse"></div>
        <span class="text-[10px] font-black uppercase tracking-[0.2em] italic">{{ notificationMessage }}</span>
      </div>
    </transition>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Identity / <span class="text-white/80">Node Configuration</span></h1>
        </div>
        
        <button 
          @click="updateProfile"
          :disabled="isUpdating"
          class="group flex items-center px-6 py-2.5 bg-teal-400 hover:bg-teal-300 disabled:opacity-50 disabled:cursor-not-allowed rounded-xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 transition-all hover:shadow-[0_0_20px_rgba(45,212,191,0.4)]"
        >
          <svg v-if="isUpdating" class="animate-spin -ml-1 mr-2 h-3.5 w-3.5" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
          {{ isUpdating ? 'Processing...' : 'Commit Changes' }}
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar max-w-5xl mx-auto w-full">
      
      <!-- Identity Overview Section -->
      <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem] p-10 hover:border-white/10 transition-all duration-500 relative overflow-hidden group/card">
        <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-400/[0.02] to-transparent pointer-events-none"></div>
        
        <div class="flex flex-col md:flex-row items-center gap-10 relative z-10">
          <!-- Avatar Interaction -->
          <div class="relative group/avatar">
            <div class="absolute inset-0 bg-teal-400/20 blur-2xl rounded-full opacity-0 group-hover/avatar:opacity-100 transition-opacity duration-700"></div>
            <div @click="showImageModal = true" class="w-32 h-32 rounded-3xl overflow-hidden border-2 border-white/5 relative z-10 cursor-pointer hover:border-teal-400/50 transition-all duration-500 shadow-2xl">
              <img v-if="userStore.userProfile?.profile_image_url" :src="userStore.userProfile.profile_image_url" class="w-full h-full object-cover" @error="handleImageError">
              <div v-else class="w-full h-full bg-white/5 flex items-center justify-center">
                <svg class="h-12 w-12 text-white/10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
              </div>
            </div>
            
            <!-- Floating Controls -->
            <div class="absolute -bottom-2 -right-2 flex gap-1 z-20">
               <button @click="$refs.fileInput.click()" class="p-2.5 bg-gray-900 border border-white/10 rounded-xl text-teal-400 hover:text-teal-300 hover:border-teal-400/40 shadow-xl transition-all">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4"/></svg>
              </button>
              <input ref="fileInput" type="file" accept="image/*" @change="onFileChange" class="hidden">
            </div>
          </div>

          <!-- Quick Stats -->
          <div class="flex-1 space-y-6">
            <div>
              <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">{{ userStore.userProfile?.first_name }} {{ userStore.userProfile?.last_name }}</h2>
              <p class="text-[10px] font-black text-teal-400/60 uppercase tracking-[0.3em] italic">Authorized Node Member</p>
            </div>
            
            <div class="grid grid-cols-2 gap-4 max-w-sm">
              <div class="bg-white/5 rounded-2xl p-4 border border-white/5 group/stat">
                <div class="text-[9px] font-black text-white/20 uppercase tracking-widest mb-1 italic">Identity Uplink</div>
                <div class="text-[11px] font-bold text-white/60 uppercase truncate italic">{{ userStore.userProfile?.email }}</div>
              </div>
              <div class="bg-white/5 rounded-2xl p-4 border border-white/5 group/stat">
                <div class="text-[9px] font-black text-white/20 uppercase tracking-widest mb-1 italic">Registry Date</div>
                <div class="text-[11px] font-bold text-white/60 uppercase italic">CYCLE_JAN_2026</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Logic Modification Section -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Left: Basic Attributes -->
        <div class="lg:col-span-2 space-y-8 p-10 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem]">
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Attribute Modification</h3>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="space-y-4">
               <div class="space-y-2 group/input">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Forename Identifier</label>
                <input v-model="userStore.userProfile.first_name" type="text" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.08] focus:outline-none text-white text-sm font-black italic tracking-tight transition-all duration-500">
              </div>
              <div class="space-y-2 group/input">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Surname Extension</label>
                <input v-model="userStore.userProfile.last_name" type="text" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.08] focus:outline-none text-white text-sm font-black italic tracking-tight transition-all duration-500">
              </div>
            </div>

            <div class="space-y-4">
              <div class="space-y-2 opacity-50 cursor-not-allowed">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Encrypted Uplink (Read-Only)</label>
                <input :value="userStore.userProfile.email" type="email" disabled class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl text-white/40 text-sm font-black italic tracking-tight">
              </div>
              <div class="space-y-2 group/input">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Communication Link / Phone</label>
                <input v-model="userStore.userProfile.phone_number" type="tel" class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.08] focus:outline-none text-white text-sm font-black italic tracking-tight transition-all duration-500">
              </div>
            </div>
          </div>
        </div>

        <!-- Right: Destructive Logic -->
        <div class="bg-red-500/[0.02] border border-red-500/10 rounded-[3rem] p-10 flex flex-col justify-between group/danger">
          <div class="space-y-4">
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-red-400/40 italic">Terminal Commands</h3>
            <p class="text-[11px] font-bold text-white/30 uppercase tracking-widest leading-loose italic">Attention: Node termination will permanently erase all registry data, historical telemetry, and authorized access. This logic cannot be reversed.</p>
          </div>
          
          <button @click="confirmDeleteAccount = true" class="w-full py-5 border border-red-500/20 rounded-2xl text-red-400 hover:bg-red-500 hover:text-white transition-all duration-500 text-[10px] font-black uppercase tracking-[0.3em] italic">
            PURGE_IDENTITY_NODE
          </button>
        </div>
      </div>

    </main>

    <!-- Modal Layers -->
    <transition name="modal">
      <div v-if="showImageModal || confirmDeleteAccount" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-gray-950/80 backdrop-blur-xl" @click="closeAllModals">
        
        <!-- Image Preview Modal -->
        <div v-if="showImageModal" @click.stop class="relative group/img max-w-2xl max-h-[80vh]">
          <div class="absolute inset-x-0 -bottom-10 h-20 bg-teal-400/20 blur-[60px] opacity-30"></div>
          <img :src="userStore.userProfile?.profile_image_url" class="max-w-full max-h-[70vh] object-contain rounded-[2rem] border-2 border-white/10 shadow-2xl relative z-10" alt="Identity Preview">
          
          <div class="absolute -top-16 inset-x-0 flex justify-center gap-4">
             <button @click="removeProfileImage" class="px-6 py-3 bg-red-500 rounded-xl text-[10px] font-black uppercase tracking-widest text-white shadow-xl hover:bg-red-600 transition-all">Detach Image</button>
             <button @click="showImageModal = false" class="px-6 py-3 bg-white/10 border border-white/10 rounded-xl text-[10px] font-black uppercase tracking-widest text-white shadow-xl hover:bg-white/20 transition-all">Close</button>
          </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div v-if="confirmDeleteAccount" @click.stop class="bg-gray-900 border border-white/10 rounded-[3rem] p-10 max-w-sm w-full relative group/modal overflow-hidden">
          <div class="relative z-10 text-center space-y-8">
            <div class="w-16 h-16 mx-auto rounded-3xl bg-red-500/10 border border-red-500/20 flex items-center justify-center animate-pulse">
              <svg class="h-8 w-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
            </div>
            
            <div>
              <h3 class="text-[11px] font-black uppercase tracking-[0.4em] text-red-500/60 mb-2 italic">DANGER_PROTOCOL</h3>
              <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Terminate Node?</h2>
            </div>
            
            <div class="space-y-4">
              <p class="text-[10px] font-bold text-white/30 uppercase tracking-widest italic text-center">Type "<span class="text-white/60">delete my account</span>" to confirm logic purge.</p>
              <input v-model="deleteConfirmationText" type="text" class="w-full px-6 py-4 bg-white/5 border border-red-500/10 rounded-xl focus:border-red-500 focus:outline-none text-white text-center font-black italic">
            </div>

            <div class="flex gap-4">
              <button @click="confirmDeleteAccount = false; deleteConfirmationText = ''" class="flex-1 py-4 border border-white/5 text-[9px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-xl transition-all">Abort</button>
              <button @click="deleteAccount" :disabled="deleteConfirmationText.toLowerCase() !== 'delete my account'" class="flex-1 py-4 bg-red-500 text-[10px] font-black uppercase tracking-widest text-white disabled:opacity-20 rounded-xl hover:shadow-[0_0_30px_rgba(239,68,68,0.4)] transition-all">Confirm Purge</button>
            </div>
          </div>
        </div>

      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useTheme } from '../../composables/useTheme'
import { useUserStore } from '../../stores/user'

const { isDark, toggleTheme, themeClasses } = useTheme()
const userStore = useUserStore()

const isSaving = ref(false)
const isUpdating = ref(false)
const selectedFile = ref(null)
const showImageModal = ref(false)
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')
const confirmDeleteAccount = ref(false)
const deleteConfirmationText = ref('')
const isDeleting = ref(false)

const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => showNotification.value = false, 3000)
}

const closeAllModals = () => {
  showImageModal.value = false
  confirmDeleteAccount.value = false
}

const onFileChange = (e) => {
  const file = e.target.files[0]
  if (!file) return
  if (file.size > 10 * 1024 * 1024) return showNotificationMessage('Logic error: Signal too large (Max 10MB)', 'error')
  
  selectedFile.value = file
  const reader = new FileReader()
  reader.onload = (e) => userStore.userProfile.profile_image_url = e.target.result
  reader.readAsDataURL(file)
  uploadProfileImage()
}

const uploadProfileImage = async () => {
  if (!selectedFile.value) return
  const formData = new FormData()
  formData.append('profile_image', selectedFile.value)
  isSaving.value = true
  try {
    await userStore.uploadProfileImage(formData)
    showNotificationMessage('Cortex image written')
  } catch (e) { showNotificationMessage('Write failure', 'error') }
  finally { isSaving.value = false; selectedFile.value = null }
}

const removeProfileImage = async () => {
  isSaving.value = true
  try {
    await userStore.removeProfileImage()
    showImageModal.value = false
    showNotificationMessage('Cortex image detached')
  } catch (e) { showNotificationMessage('Detach failure', 'error') }
  finally { isSaving.value = false }
}

const updateProfile = async () => {
  isUpdating.value = true
  try {
    await userStore.updateProfile(userStore.userProfile)
    showNotificationMessage('Node logic updated')
  } catch (e) { showNotificationMessage('Logic write failure', 'error') }
  finally { isUpdating.value = false }
}

const deleteAccount = async () => {
  if (deleteConfirmationText.value.toLowerCase() !== 'delete my account') return
  isDeleting.value = true
  try {
    await userStore.deleteAccount()
    showNotificationMessage('Identity purged')
    confirmDeleteAccount.value = false
  } catch (e) { showNotificationMessage('Purge override failed', 'error') }
  finally { isDeleting.value = false }
}

const handleImageError = () => userStore.userProfile.profile_image_url = null

onMounted(async () => {
  if (!userStore.userProfile) await userStore.fetchUserProfile()
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }

/* Animation Keyframes */
@keyframes toast-in {
  from { opacity: 0; transform: translateX(20px); }
  to { opacity: 1; transform: translateX(0); }
}
.toast-enter-active { animation: toast-in 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.toast-leave-active { transition: opacity 0.3s ease; }
.toast-leave-to { opacity: 0; }

.modal-enter-active, .modal-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.98); }
</style>