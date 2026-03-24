<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Background Accents -->
    <div class="absolute top-0 left-1/3 w-[500px] h-[500px] bg-teal-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Notification Toast -->
    <transition name="toast">
      <div v-if="showNotification" 
           :class="['fixed top-6 right-6 z-[100] px-6 py-4 rounded-2xl shadow-2xl backdrop-blur-xl border flex items-center gap-4', 
                   notificationType === 'success' ? 'bg-teal-500/10 border-teal-500/20 text-teal-400' : 'bg-red-500/10 border-red-500/20 text-red-400']">
        <div class="w-2 h-2 rounded-full bg-current animate-pulse"></div>
        <span class="text-[10px] font-black uppercase tracking-[0.2em] italic">{{ notificationMessage }}</span>
      </div>
    </transition>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between px-6 sm:px-8 py-4 sm:py-5 gap-4">
        <div class="flex items-center space-x-4">
          <div class="w-1.5 h-1.5 sm:w-2 h-2 rounded-full bg-blue-400 shadow-[0_0_10px_rgba(96,165,250,0.5)]"></div>
          <h1 class="text-[10px] sm:text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Registry / <span class="text-white/80">User Management</span></h1>
        </div>
        
        <button 
          @click="showInviteModal = true"
          class="w-full sm:w-auto group flex items-center justify-center px-6 py-2.5 bg-teal-400 hover:bg-teal-300 rounded-xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 transition-all hover:shadow-[0_0_20px_rgba(45,212,191,0.4)]"
        >
          <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
          </svg>
          Establish Node
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-8 space-y-6 sm:space-y-8 custom-scrollbar">
      
      <!-- Search and Filtering Layer -->
      <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[2.5rem] p-5 sm:p-6 hover:border-white/10 transition-all duration-500">
        <div class="flex flex-col md:flex-row gap-5 sm:gap-6">
          <!-- Search Protocol -->
          <div class="relative flex-1 group">
            <div class="absolute inset-y-0 left-5 flex items-center pointer-events-none">
              <svg class="h-4 w-4 text-white/20 group-focus-within:text-teal-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
              </svg>
            </div>
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="IDENTIFY NODE BY NAME OR ALIAS..."
              class="w-full pl-14 pr-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.08] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 text-[10px] font-black tracking-[0.2em] uppercase italic"
            >
          </div>
          
          <!-- Filter Protocol -->
          <div class="flex items-center gap-4">
            <div class="relative min-w-[180px]">
              <select 
                v-model="roleFilter"
                class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-[10px] font-black tracking-[0.2em] uppercase appearance-none cursor-pointer italic"
              >
                <option value="">All Roles</option>
                <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
              </select>
              <div class="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-white/20">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" /></svg>
              </div>
            </div>
            
            <div class="relative min-w-[180px]">
              <select 
                v-model="statusFilter"
                class="w-full px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white text-[10px] font-black tracking-[0.2em] uppercase appearance-none cursor-pointer italic"
              >
                <option value="">All Statuses</option>
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="suspended">Suspended</option>
              </select>
              <div class="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-white/20">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" /></svg>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Registry Table Layer -->
      <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] overflow-hidden hover:border-white/10 transition-all duration-500">
        <div class="overflow-x-auto custom-scrollbar">
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-white/[0.01] border-b border-white/5">
                <th class="px-5 sm:px-8 py-4 sm:py-6 text-left text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic">Identity</th>
                <th class="px-5 sm:px-8 py-4 sm:py-6 text-left text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic">Privilege Level</th>
                <th class="px-5 sm:px-8 py-4 sm:py-6 text-left text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic">Logic Status</th>
                <th class="px-5 sm:px-8 py-4 sm:py-6 text-left text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic">Last Uplink</th>
                <th class="px-5 sm:px-8 py-4 sm:py-6 text-right text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic">Commands</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr 
                v-for="user in paginatedUsers" 
                :key="user.id" 
                class="group hover:bg-white/[0.03] transition-colors"
                @dblclick="editUser(user)"
              >
                <td class="px-5 sm:px-8 py-4 sm:py-6 whitespace-nowrap">
                  <div class="flex items-center gap-5">
                    <div @click="viewProfileImage(user)" class="relative cursor-pointer group/avatar">
                      <div class="absolute inset-0 bg-teal-400/20 blur-md rounded-full opacity-0 group-hover/avatar:opacity-100 transition-opacity"></div>
                      <img class="h-10 w-10 rounded-2xl object-cover border border-white/10 relative z-10" :src="user.avatar" :alt="user.name" @error="handleImageError(user)">
                    </div>
                    <div>
                      <div class="text-sm font-black text-white italic tracking-tighter">{{ user.name }}</div>
                      <div class="text-[9px] font-bold text-white/20 uppercase tracking-widest">{{ user.email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 whitespace-nowrap">
                  <div class="text-[10px] font-black text-white/60 uppercase tracking-widest">{{ formatRole(user.role) }}</div>
                </td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 whitespace-nowrap">
                  <span :class="statusClass(user.status)" class="px-3 py-1 rounded-full text-[8px] font-black uppercase tracking-[0.2em] border border-current opacity-80 backdrop-blur-md">
                    {{ formatStatus(user.status) }}
                  </span>
                </td>
                <td class="px-8 py-6 whitespace-nowrap text-[10px] font-bold text-white/30 italic uppercase tracking-tighter">
                  {{ formatLastActive(user.lastActive) }}
                </td>
                <td class="px-8 py-6 whitespace-nowrap text-right">
                  <div class="flex items-center justify-end gap-3 translate-x-2 group-hover:translate-x-0 transition-transform">
                    <button @click="editUser(user)" class="p-2 text-white/20 hover:text-teal-400 hover:bg-teal-400/10 rounded-xl transition-all" title="Edit Logic">
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                    </button>
                    <button 
                      @click="confirmUserAction(user, user.status === 'active' ? 'suspend' : 'activate')"
                      class="p-2 text-white/20 hover:text-yellow-400 hover:bg-yellow-400/10 rounded-xl transition-all"
                      :title="user.status === 'active' ? 'Suspend Node' : 'Initialize Node'"
                    >
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path v-if="user.status === 'active'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </button>
                    <button @click="confirmUserAction(user, 'delete')" class="p-2 text-white/20 hover:text-red-400 hover:bg-red-400/10 rounded-xl transition-all" title="Purge Node">
                      <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="filteredUsers.length === 0">
                <td colspan="5" class="px-8 py-20 text-center">
                  <div class="text-[10px] font-black uppercase tracking-[0.4em] text-white/10 italic animate-pulse">ZERO_NODES_IDENTIFIED_IN_SEARCH_PROTOCOL</div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Pagination Command -->
        <div class="px-8 py-6 bg-white/[0.01] border-t border-white/5 flex items-center justify-between">
          <div class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">
            Visualizing <span class="text-white/60">{{ (currentPage - 1) * pageSize + 1 }}-{{ Math.min(currentPage * pageSize, filteredUsers.length) }}</span> // Aggregate <span class="text-white/60">{{ filteredUsers.length }}</span> Nodes
          </div>
          
          <div class="flex items-center gap-1.5">
            <button 
              @click="currentPage-- "
              :disabled="currentPage === 1"
              class="p-2.5 rounded-xl bg-white/5 border border-white/5 text-white/40 hover:text-white hover:border-teal-400/30 disabled:opacity-20 transition-all"
            >
              <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M15 19l-7-7 7-7"/></svg>
            </button>
            
            <div class="flex gap-1.5 h-9">
              <button 
                v-for="page in visiblePages"
                :key="page"
                @click="currentPage = page"
                :class="[currentPage === page ? 'bg-teal-400 text-gray-950 border-teal-400' : 'bg-white/5 text-white/40 border-white/5 hover:text-white', 'w-9 text-[10px] font-black rounded-xl border transition-all']"
              >
                {{ page }}
              </button>
            </div>
            
            <button 
              @click="currentPage++"
              :disabled="currentPage === totalPages"
              class="p-2.5 rounded-xl bg-white/5 border border-white/5 text-white/40 hover:text-white hover:border-teal-400/30 disabled:opacity-20 transition-all"
            >
              <svg class="h-3 w-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7"/></svg>
            </button>
          </div>
        </div>
      </div>

    </main>

    <!-- Modal Layers -->
    <transition name="modal">
      <div v-if="showInviteModal || showEditModal || showConfirmModal || showImageModal" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-gray-950/80 backdrop-blur-xl" @click="closeAllModals">
        
        <!-- Invite Modal -->
        <div v-if="showInviteModal" @click.stop class="bg-gray-900 border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-10 max-w-md w-full relative group/modal overflow-hidden">
          <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-500/5 to-transparent pointer-events-none"></div>
          <div class="relative z-10 space-y-8">
            <h2 class="text-2xl sm:text-3xl font-black text-white italic uppercase tracking-tighter">Initialize Node</h2>
            <div class="space-y-6">
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Node Uplink Identifier / Email</label>
                <input v-model="inviteEmail" type="email" placeholder="node@protocol.ai" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic placeholder:text-white/10">
              </div>
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Privilege Profile</label>
                <select v-model="inviteRole" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic appearance-none cursor-pointer">
                  <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
                </select>
              </div>
              <div class="pt-6 flex gap-4">
                <button @click="showInviteModal = false" class="flex-1 py-5 border border-white/5 text-[10px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-2xl transition-all">Abort</button>
                <button @click="sendInvite" class="flex-1 py-5 bg-teal-400 text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 rounded-2xl hover:shadow-[0_0_30px_rgba(45,212,191,0.4)] transition-all">Transmit Invite</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Edit Modal -->
        <div v-if="showEditModal" @click.stop class="bg-gray-900 border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-10 max-w-md w-full relative group/modal overflow-hidden">
          <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-blue-500/5 to-transparent pointer-events-none"></div>
          <div class="relative z-10 space-y-8">
            <h2 class="text-2xl sm:text-3xl font-black text-white italic uppercase tracking-tighter">Modify Node Logic</h2>
            <div class="space-y-6">
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Identity Alias</label>
                <input v-model="editingUser.name" type="text" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white font-bold italic">
              </div>
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Digital Identifier</label>
                <input v-model="editingUser.email" type="email" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white font-bold italic">
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Privilege Profile</label>
                  <select v-model="editingUser.role" class="w-full px-4 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white text-[10px] font-black uppercase appearance-none cursor-pointer italic">
                    <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
                  </select>
                </div>
                <div class="space-y-2">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Operational Status</label>
                  <select v-model="editingUser.status" class="w-full px-4 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-blue-400/50 focus:outline-none text-white text-[10px] font-black uppercase appearance-none cursor-pointer italic">
                    <option value="active">Active</option>
                    <option value="pending">Pending</option>
                    <option value="suspended">Suspended</option>
                  </select>
                </div>
              </div>
              <div class="pt-6 flex gap-4">
                <button @click="showEditModal = false" class="flex-1 py-5 border border-white/5 text-[10px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-2xl transition-all">Abort</button>
                <button @click="saveUser" class="flex-1 py-5 bg-gradient-to-r from-teal-400 to-blue-500 text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 rounded-2xl hover:shadow-[0_0_30px_rgba(45,212,191,0.4)] transition-all">Commit Logic</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Confirmation Modal -->
        <div v-if="showConfirmModal" @click.stop class="bg-gray-900 border border-white/10 rounded-[2.5rem] p-10 max-w-sm w-full relative group/modal overflow-hidden">
          <div class="relative z-10 text-center space-y-6">
            <div class="w-16 h-16 mx-auto rounded-3xl bg-red-500/10 border border-red-500/20 flex items-center justify-center animate-pulse">
              <svg class="h-8 w-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
            </div>
            <div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.4em] text-red-400 mb-2 italic">Security Protocol</h3>
              <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">{{ confirmTitle }}</h2>
            </div>
            <p class="text-sm font-bold text-white/40 uppercase tracking-widest italic leading-relaxed">{{ confirmMessage }}</p>
            <div class="pt-6 flex gap-4">
              <button @click="showConfirmModal = false" class="flex-1 py-4 border border-white/5 text-[9px] font-black uppercase tracking-widest text-white/40 hover:bg-white/5 rounded-xl transition-all">Cancel</button>
              <button 
                @click="executeUserAction"
                :class="[
                  confirmAction === 'delete' ? 'bg-red-500 hover:shadow-red-500/30' : 
                  confirmAction === 'suspend' ? 'bg-yellow-500 hover:shadow-yellow-500/30' : 'bg-teal-500 hover:shadow-teal-500/30',
                  'flex-1 py-4 text-[10px] font-black uppercase tracking-widest text-gray-950 rounded-xl transition-all shadow-lg'
                ]"
              >
                Confirm {{ confirmButtonText }}
              </button>
            </div>
          </div>
        </div>

        <!-- Image Preview Modal -->
        <div v-if="showImageModal" @click.stop class="relative group/img max-w-3xl max-h-[80vh]">
          <div class="absolute inset-x-0 -bottom-10 h-20 bg-teal-400/20 blur-[60px] opacity-50"></div>
          <img :src="selectedUserImage" class="max-w-full max-h-[80vh] object-contain rounded-[2rem] border-2 border-white/10 shadow-2xl relative z-10" alt="Identity Preview">
          <button @click="showImageModal = false" class="absolute -top-12 -right-12 p-4 text-white hover:text-teal-400 transition-colors">
            <svg class="h-8 w-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" /></svg>
          </button>
        </div>

      </div>
    </transition>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'

const { themeClasses } = useTheme()

// Registry State
const users = ref([])
const searchQuery = ref('')
const roleFilter = ref('')
const statusFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const isLoading = ref(false)

// Modals State
const showInviteModal = ref(false)
const showEditModal = ref(false)
const showConfirmModal = ref(false)
const showImageModal = ref(false)

// Interaction State
const inviteEmail = ref('')
const inviteRole = ref('user')
const selectedUserImage = ref('')
const editingUser = ref({ id: null, name: '', email: '', role: '', status: '' })
const confirmUser = ref(null)
const confirmAction = ref('')
const confirmTitle = ref('')
const confirmMessage = ref('')
const confirmButtonText = ref('')

// Notifications
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')

const availableRoles = [
  { value: 'admin', label: 'Administrator' },
  { value: 'user', label: 'Standard Node' },
  { value: 'manager', label: 'Controller' }
]

// Logic Functions
const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => showNotification.value = false, 3000)
}

const closeAllModals = () => {
  showInviteModal.value = false
  showEditModal.value = false
  showConfirmModal.value = false
  showImageModal.value = false
}

const viewProfileImage = (user) => { if (user.avatar) { selectedUserImage.value = user.avatar; showImageModal.value = true } }
const handleImageError = (user) => user.avatar = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.name)}&background=random`

const filteredUsers = computed(() => {
  return users.value.filter(u => {
    const search = searchQuery.value.toLowerCase()
    const matchesSearch = u.name.toLowerCase().includes(search) || u.email.toLowerCase().includes(search)
    const matchesRole = !roleFilter.value || u.role === roleFilter.value
    const matchesStatus = !statusFilter.value || u.status === statusFilter.value
    return matchesSearch && matchesRole && matchesStatus
  })
})

const totalPages = computed(() => Math.ceil(filteredUsers.value.length / pageSize.value))
const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return filteredUsers.value.slice(start, start + pageSize.value)
})

const visiblePages = computed(() => {
  const pages = []
  const max = 5
  let start = Math.max(1, currentPage.value - 2)
  let end = Math.min(totalPages.value, start + max - 1)
  if (end - start + 1 < max) start = Math.max(1, end - max + 1)
  for (let i = start; i <= end; i++) pages.push(i)
  return pages
})

const formatRole = (role) => availableRoles.find(r => r.value === role)?.label || role
const formatStatus = (status) => ({ active: 'Active Pulse', pending: 'Awaiting Logic', suspended: 'Purged' }[status] || status)
const statusClass = (status) => ({
  active: 'text-teal-400 border-teal-400/30 bg-teal-400/5',
  pending: 'text-yellow-400 border-yellow-400/30 bg-yellow-400/5',
  suspended: 'text-red-400 border-red-400/30 bg-red-400/5'
}[status] || 'text-white/20 border-white/10 bg-white/5')

const formatLastActive = (date) => date ? new Date(date).toLocaleString([], { dateStyle: 'short', timeStyle: 'short' }) : 'ZERO_IDLE_CYCLE'

const editUser = (user) => { editingUser.value = { ...user }; showEditModal.value = true }

const confirmUserAction = (user, action) => {
  confirmUser.value = user
  confirmAction.value = action
  const map = {
    delete: { t: 'Purge Identity', m: `Permanently erase Node ${user.name} from the encrypted grid?`, b: 'Confirm Purge' },
    suspend: { t: 'De-initialize Node', m: `Restrict all logic access for ${user.name}?`, b: 'Suspend' },
    activate: { t: 'Initialize Node', m: `Re-establish neural link for ${user.name}?`, b: 'Activate' }
  }[action]
  confirmTitle.value = map.t; confirmMessage.value = map.m; confirmButtonText.value = map.b
  showConfirmModal.value = true
}

// API Interactions
const fetchUsers = async () => {
  isLoading.value = true
  try {
    const res = await api.get('/users/')
    users.value = res.data.map(u => ({
      id: u.id,
      name: `${u.first_name} ${u.last_name}`,
      email: u.email,
      avatar: u.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(u.first_name + ' ' + u.last_name)}&background=random`,
      role: u.role,
      status: u.status,
      lastActive: u.last_active
    }))
  } catch (e) { showNotificationMessage('Uplink failed: Access denied', 'error') }
  finally { isLoading.value = false }
}

const sendInvite = async () => {
  try {
    const res = await api.post('/users/invite/', { email: inviteEmail.value, first_name: inviteEmail.value.split('@')[0], is_admin: inviteRole.value === 'admin' })
    users.value.push({ id: res.data.id, name: inviteEmail.value.split('@')[0], email: inviteEmail.value, avatar: handleImageError({ name: inviteEmail.value }), role: inviteRole.value, status: 'pending', lastActive: null })
    showNotificationMessage('Transmission binary sent')
    showInviteModal.value = false
    inviteEmail.value = ''
  } catch (e) { showNotificationMessage('Signal interference', 'error') }
}

const saveUser = async () => {
  try {
    const res = await api.patch(`/users/${editingUser.value.id}/`, { first_name: editingUser.value.name.split(' ')[0], last_name: editingUser.value.name.split(' ')[1] || '', email: editingUser.value.email, is_admin: editingUser.value.role === 'admin' })
    const idx = users.value.findIndex(u => u.id === editingUser.value.id)
    if (idx !== -1) users.value[idx] = { ...users.value[idx], name: `${res.data.first_name} ${res.data.last_name}`, email: res.data.email, role: res.data.role, status: res.data.status }
    showNotificationMessage('Node logic re-written')
    showEditModal.value = false
  } catch (e) { showNotificationMessage('Write error: Permission denied', 'error') }
}

const executeUserAction = async () => {
  try {
    if (confirmAction.value === 'delete') {
      await api.delete(`/users/${confirmUser.value.id}/`)
      users.value = users.value.filter(u => u.id !== confirmUser.value.id)
      showNotificationMessage('Identity purged')
    } else {
      const active = confirmAction.value === 'activate'
      await api.patch(`/users/${confirmUser.value.id}/status/`, { is_active: active })
      const idx = users.value.findIndex(u => u.id === confirmUser.value.id)
      if (idx !== -1) { users.value[idx].status = active ? 'active' : 'suspended'; if (active) users.value[idx].lastActive = new Date().toISOString() }
      showNotificationMessage(`Status: ${active ? 'Pulse Active' : 'Offline'}`)
    }
  } catch (e) { showNotificationMessage('Security override failed', 'error') }
  finally { showConfirmModal.value = false }
}

onMounted(fetchUsers)
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; height: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

/* Table specific transitions */
tbody tr { cursor: pointer; transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1); }

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