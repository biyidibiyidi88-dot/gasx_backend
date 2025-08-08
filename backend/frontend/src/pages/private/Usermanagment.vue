<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden']">
    <!-- Notification Toast -->
    <transition name="fade">
      <div v-if="showNotification" 
           :class="['fixed top-4 right-4 z-50 p-4 rounded-md shadow-lg text-white', 
                   notificationType === 'success' ? 'bg-green-500' : 'bg-red-500']">
        {{ notificationMessage }}
      </div>
    </transition>

     <!-- Image Preview Modal -->
     <transition name="fade">
      <div v-if="showImageModal" class="fixed inset-0 bg-black bg-opacity-75 z-50 flex items-center justify-center p-4">
        <div class="relative max-w-3xl max-h-screen">
          <img :src="selectedUserImage" class="max-w-full max-h-screen object-contain" alt="Profile preview">
          <button @click="showImageModal = false" 
                  :class="[themeClasses.bg.secondary, themeClasses.bg.tertiary.replace('bg-', 'hover:bg-'), 'absolute top-4 right-4 p-2 rounded-full shadow-md']">
            <svg xmlns="http://www.w3.org/2000/svg" :class="[themeClasses.text.primary, 'h-6 w-6']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </transition>

    <!-- Top Navigation -->
    <header :class="[themeClasses.bg.secondary, themeClasses.shadow, 'z-10']">
      <div class="flex items-center justify-between px-4 py-3 sm:px-6">
        <!-- Mobile menu button -->
        <button 
          @click="$emit('toggle-sidebar')"
          :class="[themeClasses.text.secondary, themeClasses.text.primary.replace('text-', 'hover:text-'), 'md:hidden focus:outline-none']"
        >
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
        
        <!-- Page Title -->
        <h1 :class="[themeClasses.text.primary, 'text-xl font-semibold']">User Management</h1>
        
        <!-- Theme Toggle & Actions -->
        <div class="flex items-center space-x-2">
          <!-- Theme Toggle Button -->
          <button 
            @click="toggleTheme" 
            :class="[themeClasses.text.secondary, themeClasses.text.primary.replace('text-', 'hover:text-'), 'p-2 rounded-lg transition-colors']"
            :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
          >
            <svg v-if="isDark" class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
            </svg>
            <svg v-else class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
            </svg>
          </button>
          
          <button 
            @click="showInviteModal = true"
            :class="[themeClasses.button.primary, 'inline-flex items-center px-3 py-2 text-sm leading-4 font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500']"
          >
            <svg class="-ml-0.5 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
            </svg>
            Invite User
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <!-- User Search and Filters -->
      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'mb-6 rounded-lg p-4']">
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <!-- Search -->
          <div class="relative flex-1">
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
              </svg>
            </div>
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="Search users by name or email"
              class="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            >
          </div>
          
          <!-- Filters -->
          <div class="flex items-center space-x-2">
            <select 
              v-model="roleFilter"
              class="block w-full pl-3 pr-10 py-2 text-base border border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
            >
              <option value="">All Roles</option>
              <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
            </select>
            
            <select 
              v-model="statusFilter"
              class="block w-full pl-3 pr-10 py-2 text-base border border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
            >
              <option value="">All Statuses</option>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="suspended">Suspended</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Users Table -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Role
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Last Active
                </th>
                <th scope="col" class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in paginatedUsers" :key="user.id">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="flex items-center">
                    <div @click="viewProfileImage(user)" class="flex-shrink-0 h-10 w-10">
                      <img class="h-10 w-10 rounded-full" :src="user.avatar" :alt="user.name">
                    </div>
                    <div class="ml-4">
                      <div class="text-sm font-medium text-gray-900">{{ user.name }}</div>
                      <div class="text-sm text-gray-500">{{ user.email }}</div>
                    </div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ formatRole(user.role) }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full" :class="statusClass(user.status)">
                    {{ formatStatus(user.status) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatLastActive(user.lastActive) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button 
                    @click="editUser(user)"
                    class="text-blue-600 hover:text-blue-900 mr-3"
                  >
                    Edit
                  </button>
                  <button 
                    @click="confirmUserAction(user, user.status === 'active' ? 'suspend' : 'activate')"
                    class="text-yellow-600 hover:text-yellow-900 mr-3"
                  >
                    {{ user.status === 'active' ? 'Suspend' : 'Activate' }}
                  </button>
                  <button 
                    @click="confirmUserAction(user, 'delete')"
                    class="text-red-600 hover:text-red-900"
                  >
                    Delete
                  </button>
                </td>
              </tr>
              <tr v-if="filteredUsers.length === 0">
                <td colspan="5" class="px-6 py-4 text-center text-sm text-gray-500">
                  No users found matching your criteria
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        
        <!-- Pagination -->
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
          <div class="flex-1 flex justify-between sm:hidden">
            <button 
              @click="currentPage = Math.max(1, currentPage - 1)"
              :disabled="currentPage === 1"
              class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Previous
            </button>
            <button 
              @click="currentPage = Math.min(totalPages, currentPage + 1)"
              :disabled="currentPage === totalPages"
              class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Next
            </button>
          </div>
          <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
            <div>
              <p class="text-sm text-gray-700">
                Showing <span class="font-medium">{{ (currentPage - 1) * pageSize + 1 }}</span> to <span class="font-medium">{{ Math.min(currentPage * pageSize, filteredUsers.length) }}</span> of <span class="font-medium">{{ filteredUsers.length }}</span> users
              </p>
            </div>
            <div>
              <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                <button 
                  @click="currentPage = Math.max(1, currentPage - 1)"
                  :disabled="currentPage === 1"
                  class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                >
                  <span class="sr-only">Previous</span>
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                  </svg>
                </button>
                <button 
                  v-for="page in visiblePages"
                  :key="page"
                  @click="currentPage = page"
                  :class="{
                    'z-10 bg-blue-50 border-blue-500 text-blue-600': currentPage === page,
                    'bg-white border-gray-300 text-gray-500 hover:bg-gray-50': currentPage !== page
                  }"
                  class="relative inline-flex items-center px-4 py-2 border text-sm font-medium"
                >
                  {{ page }}
                </button>
                <button 
                  @click="currentPage = Math.min(totalPages, currentPage + 1)"
                  :disabled="currentPage === totalPages"
                  class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                >
                  <span class="sr-only">Next</span>
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                  </svg>
                </button>
              </nav>
            </div>
          </div>
        </div>
      </div>

      <!-- Invite User Modal -->
      <div v-if="showInviteModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Invite New User</h3>
          </div>
          <div class="p-6">
            <div class="mb-4">
              <label for="invite-email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
              <input 
                type="email" 
                id="invite-email" 
                v-model="inviteEmail"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                placeholder="user@example.com"
              >
            </div>
            <div class="mb-4">
              <label for="invite-role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select 
                id="invite-role" 
                v-model="inviteRole"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
              </select>
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
            <button 
              @click="showInviteModal = false"
              class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <button 
              @click="sendInvite"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Send Invitation
            </button>
          </div>
        </div>
      </div>

      <!-- Edit User Modal -->
      <div v-if="showEditModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Edit User</h3>
          </div>
          <div class="p-6">
            <div class="mb-4">
              <label for="edit-name" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
              <input 
                type="text" 
                id="edit-name" 
                v-model="editingUser.name"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
            </div>
            <div class="mb-4">
              <label for="edit-email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
              <input 
                type="email" 
                id="edit-email" 
                v-model="editingUser.email"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
            </div>
            <div class="mb-4">
              <label for="edit-role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select 
                id="edit-role" 
                v-model="editingUser.role"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option v-for="role in availableRoles" :key="role.value" :value="role.value">{{ role.label }}</option>
              </select>
            </div>
            <div class="mb-4">
              <label for="edit-status" class="block text-sm font-medium text-gray-700 mb-1">Status</label>
              <select 
                id="edit-status" 
                v-model="editingUser.status"
                class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="suspended">Suspended</option>
              </select>
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
            <button 
              @click="showEditModal = false"
              class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <button 
              @click="saveUser"
              class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Save Changes
            </button>
          </div>
        </div>
      </div>

      <!-- Confirmation Modal -->
      <div v-if="showConfirmModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">{{ confirmTitle }}</h3>
          </div>
          <div class="p-6">
            <p class="text-gray-700">{{ confirmMessage }}</p>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
            <button 
              @click="showConfirmModal = false"
              class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Cancel
            </button>
            <button 
              @click="executeUserAction"
              :class="{
                'bg-red-600 hover:bg-red-700': confirmAction === 'delete',
                'bg-yellow-600 hover:bg-yellow-700': confirmAction === 'suspend',
                'bg-green-600 hover:bg-green-700': confirmAction === 'activate'
              }"
              class="px-4 py-2 text-sm font-medium text-white border border-transparent rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              {{ confirmButtonText }}
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '../../config/api' // Smart API client with auto-detection
import { useTheme } from '../../composables/useTheme'

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme()

// State
const searchQuery = ref('')
const roleFilter = ref('')
const statusFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const showInviteModal = ref(false)
const showEditModal = ref(false)
const showConfirmModal = ref(false)
const inviteEmail = ref('')
const inviteRole = ref('user')
const showImageModal = ref(false)
const selectedUserImage = ref('')
const editingUser = ref({
  id: null,
  name: '',
  email: '',
  role: '',
  status: ''
})
const confirmUser = ref(null)
const confirmAction = ref('')
const confirmTitle = ref('')
const confirmMessage = ref('')
const confirmButtonText = ref('')
const users = ref([])
const isLoading = ref(false)

// Notification state
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')

const availableRoles = [
  { value: 'admin', label: 'Administrator' },
  { value: 'user', label: 'Standard User' },
  { value: 'manager', label: 'Manager' }
]


const viewProfileImage = (user) => {
  if (user.avatar) {
    selectedUserImage.value = user.avatar
    showImageModal.value = true
  }
}
const handleImageError = (user) => {
  // Fallback to initials avatar if image fails to load
  user.avatar = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.name)}&background=random`
}
// Show notification
const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
}

// Computed properties
const filteredUsers = computed(() => {
  return users.value.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchQuery.value.toLowerCase()) || 
                         user.email.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesRole = !roleFilter.value || user.role === roleFilter.value
    const matchesStatus = !statusFilter.value || user.status === statusFilter.value
    
    return matchesSearch && matchesRole && matchesStatus
  })
})

const totalPages = computed(() => {
  return Math.ceil(filteredUsers.value.length / pageSize.value)
})

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredUsers.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)
  
  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1)
  }
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  
  return pages
})

// Methods
const formatRole = (role) => {
  const found = availableRoles.find(r => r.value === role)
  return found ? found.label : role
}

const formatStatus = (status) => {
  const statusMap = {
    active: 'Active',
    pending: 'Pending',
    suspended: 'Suspended'
  }
  return statusMap[status] || status
}

const statusClass = (status) => {
  const classes = {
    active: 'bg-green-100 text-green-800',
    pending: 'bg-yellow-100 text-yellow-800',
    suspended: 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const formatLastActive = (date) => {
  if (!date) return 'Never'
  return new Date(date).toLocaleString()
}

const editUser = (user) => {
  editingUser.value = { ...user }
  showEditModal.value = true
}

const confirmUserAction = (user, action) => {
  confirmUser.value = user
  confirmAction.value = action
  
  if (action === 'delete') {
    confirmTitle.value = 'Delete User'
    confirmMessage.value = `Are you sure you want to delete ${user.name}? This action cannot be undone.`
    confirmButtonText.value = 'Delete'
  } else if (action === 'suspend') {
    confirmTitle.value = 'Suspend User'
    confirmMessage.value = `Are you sure you want to suspend ${user.name}? They will no longer be able to access the system.`
    confirmButtonText.value = 'Suspend'
  } else if (action === 'activate') {
    confirmTitle.value = 'Activate User'
    confirmMessage.value = `Are you sure you want to activate ${user.name}? They will regain access to the system.`
    confirmButtonText.value = 'Activate'
  }
  
  showConfirmModal.value = true
}

// API methods
const fetchUsers = async () => {
  isLoading.value = true
  try {
    const response = await api.get('/users/')
    users.value = response.data.map(user => ({
      id: user.id,
      name: `${user.first_name} ${user.last_name}`,
      email: user.email,
      avatar: user.profile_image_url || `https://ui-avatars.com/api/?name=${encodeURIComponent(user.first_name + ' ' + user.last_name)}&background=random`,
      role: user.role,
      status: user.status,
      lastActive: user.last_active
    }))
    showNotificationMessage('Users loaded successfully')
  } catch (error) {
    console.error('Error fetching users:', error)
    showNotificationMessage('Failed to load users', 'error')
  } finally {
    isLoading.value = false
  }
}

const sendInvite = async () => {
  try {
    const response = await api.post('/users/invite/', {
      email: inviteEmail.value,
      first_name: inviteEmail.value.split('@')[0],
      last_name: '',
      is_admin: inviteRole.value === 'admin'
    })
    
    // Add the new user to our local list
    const newUser = {
      id: response.data.id,
      name: inviteEmail.value.split('@')[0],
      email: inviteEmail.value,
      avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(inviteEmail.value.split('@')[0])}&background=random`,
      role: inviteRole.value,
      status: 'pending',
      lastActive: null
    }
    
    users.value.push(newUser)
    showNotificationMessage(`Invitation sent to ${inviteEmail.value}`)
    showInviteModal.value = false
    inviteEmail.value = ''
    inviteRole.value = 'user'
  } catch (error) {
    console.error('Error sending invitation:', error)
    showNotificationMessage('Failed to send invitation', 'error')
  }
}

const saveUser = async () => {
  try {
    const response = await api.patch(`/users/${editingUser.value.id}/`, {
      first_name: editingUser.value.name.split(' ')[0],
      last_name: editingUser.value.name.split(' ')[1] || '',
      email: editingUser.value.email,
      is_admin: editingUser.value.role === 'admin'
    })
    
    // Update the user in our local list
    const index = users.value.findIndex(u => u.id === editingUser.value.id)
    if (index !== -1) {
      users.value[index] = { 
        ...users.value[index],
        name: `${response.data.first_name} ${response.data.last_name}`,
        email: response.data.email,
        role: response.data.role,
        status: response.data.status
      }
    }
    
    showNotificationMessage('User updated successfully')
    showEditModal.value = false
  } catch (error) {
    console.error('Error updating user:', error)
    showNotificationMessage('Failed to update user', 'error')
  }
}

const executeUserAction = async () => {
  try {
    if (confirmAction.value === 'delete') {
      await api.delete(`/users/${confirmUser.value.id}/`)
      // Remove from local list
      users.value = users.value.filter(u => u.id !== confirmUser.value.id)
      showNotificationMessage('User deleted successfully')
    } else {
      const isActive = confirmAction.value === 'activate'
      await api.patch(`/users/${confirmUser.value.id}/status/`, {
        is_active: isActive
      })
      
      // Update status in local list
      const index = users.value.findIndex(u => u.id === confirmUser.value.id)
      if (index !== -1) {
        users.value[index].status = isActive ? 'active' : 'suspended'
        if (isActive) {
          users.value[index].lastActive = new Date().toISOString()
        }
      }
      
      const action = isActive ? 'activated' : 'suspended'
      showNotificationMessage(`User ${action} successfully`)
    }
    
    showConfirmModal.value = false
  } catch (error) {
    console.error('Error performing user action:', error)
    const action = confirmAction.value === 'delete' ? 'delete' : 
                 confirmAction.value === 'activate' ? 'activate' : 'suspend'
    showNotificationMessage(`Failed to ${action} user`, 'error')
  }
}

// Lifecycle hooks
onMounted(() => {
  fetchUsers()
})
</script>

<style scoped>
/* Custom scrollbar for main content */
main::-webkit-scrollbar {
  width: 8px;
}
main::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
}
main::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
}
main::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}

/* Modal transitions */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter, .modal-leave-to {
  opacity: 0;
}

/* Notification transition */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Table row hover effect */
tbody tr {
  transition: background-color 0.2s ease;
}
tbody tr:hover {
  background-color: rgba(243, 244, 246, 0.5);
}

/* Button transitions */
button {
  transition: all 0.2s ease;
}
fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>