<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen transition-colors duration-200 relative']">
    <!-- Animated background elements with color transitions -->
    <div class="absolute inset-0 overflow-hidden opacity-20">
      <div class="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-to-br from-blue-400 to-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color"></div>
      <div class="absolute -bottom-1/2 -left-1/2 w-full h-full bg-gradient-to-tr from-cyan-400 to-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color animation-delay-2000"></div>
    </div>
    
    <div class="relative max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <!-- Notification Toast -->
      <transition 
        enter-active-class="transform ease-out duration-300 transition"
        enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
        enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
        leave-active-class="transition ease-in duration-100"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showNotification" 
             :class="['fixed top-4 right-4 z-50 p-4 rounded-lg shadow-xl text-white transform transition-all duration-300', 
                     notificationType === 'success' ? 'bg-green-500/95 backdrop-blur-sm animate-pulse-success' : 'bg-red-500/95 backdrop-blur-sm animate-pulse-error',
                     'border border-white/10']">
          <div class="flex items-center">
            <svg v-if="notificationType === 'success'" class="h-6 w-6 mr-2 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <svg v-else class="h-6 w-6 mr-2 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
            <span class="font-medium">{{ notificationMessage }}</span>
          </div>
        </div>
      </transition>

      <!-- Image Preview Modal -->
      <transition 
        enter-active-class="ease-out duration-300"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="ease-in duration-200"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showImageModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
          <div class="flex min-h-screen items-center justify-center p-4 text-center sm:block sm:p-0">
            <div class="fixed inset-0 bg-gray-900/80 backdrop-blur-sm transition-opacity" aria-hidden="true" @click="showImageModal = false"></div>
            <span class="hidden sm:inline-block sm:h-screen sm:align-middle" aria-hidden="true">&#8203;</span>
            
            <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
              <div class="relative">
                <img :src="userStore.userProfile?.profile_image_url" class="w-full max-h-[80vh] object-contain" alt="Profile preview">
                
                <div class="absolute top-4 right-4 flex space-x-2">
                  <button 
                    @click="showImageModal = false"
                    class="p-2 rounded-full bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm shadow-lg hover:bg-white dark:hover:bg-gray-800 transition-colors duration-200 text-gray-700 dark:text-gray-200 hover:text-gray-900 dark:hover:text-white animate-hover-scale"
                    aria-label="Close"
                  >
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                  
                  <button 
                    v-if="userStore.userProfile?.profile_image_url"
                    @click="removeProfileImage"
                    class="flex items-center px-4 py-2 rounded-full bg-red-500/90 hover:bg-red-600 text-white transition-colors duration-200 shadow-lg animate-hover-scale"
                  >
                    <svg class="h-5 w-5 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Remove
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </transition>

      <!-- Profile Card with pulse animation -->
      <div :class="[themeClasses.bg.card, 'relative rounded-2xl overflow-hidden transition-all duration-300 transform hover:shadow-2xl border border-white/10 bg-opacity-80 dark:bg-opacity-80 backdrop-blur-sm animate-pulse-card']">
        <!-- Decorative elements with color animation -->
        <div class="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-purple-500/10 dark:from-blue-500/5 dark:to-purple-500/5 animate-gradient-shift"></div>
        
        <div class="relative">
          <!-- Header -->
          <div class="px-6 py-5 sm:px-8 sm:py-6">
            <div class="flex items-center justify-between">
              <div>
                <h2 :class="[themeClasses.text.primary, 'text-2xl font-bold tracking-tight']">
                  Profile Settings
                </h2>
                <p :class="[themeClasses.text.secondary, 'mt-1 text-sm']">
                  Manage your personal information and preferences
                </p>
              </div>
              <div class="flex-shrink-0">
                <button 
                  @click="updateProfile"
                  :disabled="isUpdating"
                  :class="[
                    'inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-full shadow-sm text-white',
                    'bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500',
                    'transition-colors duration-200 animate-hover-glow',
                    isUpdating ? 'opacity-70 cursor-not-allowed' : ''
                  ]"
                >
                  <svg v-if="isUpdating" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  {{ isUpdating ? 'Saving...' : 'Save Changes' }}
                </button>
              </div>
            </div>
          </div>
          
          <!-- Divider -->
          <div :class="[themeClasses.border.primary, 'border-t border-opacity-20']"></div>
        </div>
        
        <div class="px-6 py-4">
          <div class="flex flex-col sm:flex-row items-center sm:items-start space-y-4 sm:space-y-0 sm:space-x-6">
            <div class="relative">
              <!-- Profile Image with Click-to-View -->
              <div v-if="userStore.userProfile?.profile_image_url" 
                   class="w-24 h-24 rounded-full overflow-hidden border-2 border-blue-500 cursor-pointer hover:border-blue-600 transition-all animate-border-pulse"
                   @click="showImageModal = true">
                <img 
                  class="w-full h-full object-cover" 
                  :src="userStore.userProfile.profile_image_url" 
                  alt="User profile"
                  @error="handleImageError"
                >
              </div>
              <!-- Fallback Avatar -->
              <div v-else 
                   :class="[themeClasses.bg.tertiary, 'w-24 h-24 rounded-full flex items-center justify-center cursor-pointer border-2 animate-border-pulse', themeClasses.border.secondary]"
                   @click="$refs.fileInput.click()">
                <svg :class="[themeClasses.text.muted, 'w-12 h-12']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
              </div>
            </div>
            <div class="flex-1 w-full">
              <div class="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-4">
                <label class="block w-full sm:w-auto">
                  <span class="sr-only">Choose profile photo</span>
                  <input 
                    ref="fileInput"
                    type="file" 
                    accept="image/*" 
                    @change="onFileChange" 
                    class="hidden"
                  >
                  <button
                    @click="$refs.fileInput.click()"
                    :class="[themeClasses.button.secondary, 'w-full sm:w-auto px-4 py-2 rounded-md transition-colors animate-hover-glow']"
                  >
                    Add Photo
                  </button>
                </label>
                <button
                  v-if="userStore.userProfile?.profile_image_url"
                  @click="removeProfileImage"
                  :class="[themeClasses.button.danger, 'w-full sm:w-auto px-4 py-2 rounded-md transition-colors animate-hover-glow']"
                >
                  Remove Photo
                </button>
              </div>
              <p :class="['mt-2 text-sm', themeClasses.text.muted]">
                JPG, GIF or PNG. Max size of 10MB.
              </p>
            </div>
          </div>
          
          <div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2">
            <div>
              <label for="first_name" :class="['block text-sm font-medium', themeClasses.text.primary]">First name</label>
              <input 
                type="text" 
                id="first_name" 
                v-model="userStore.userProfile.first_name" 
                :class="['mt-1 block w-full rounded-md shadow-sm py-2 px-3 focus:outline-none sm:text-sm transition-colors duration-200 animate-input-focus',
                         themeClasses.bg.input, themeClasses.text.primary, themeClasses.border.input, 'focus:ring-2 focus:ring-blue-500 focus:border-blue-500']"
              >
            </div>
            
            <div>
              <label for="last_name" :class="['block text-sm font-medium', themeClasses.text.primary]">Last name</label>
              <input 
                type="text" 
                id="last_name" 
                v-model="userStore.userProfile.last_name" 
                :class="['mt-1 block w-full rounded-md shadow-sm py-2 px-3 focus:outline-none sm:text-sm transition-colors duration-200 animate-input-focus',
                         themeClasses.bg.input, themeClasses.text.primary, themeClasses.border.input, 'focus:ring-2 focus:ring-blue-500 focus:border-blue-500']"
              >
            </div>
            
            <div class="sm:col-span-2">
              <label for="email" :class="['block text-sm font-medium', themeClasses.text.primary]">Email address</label>
              <input 
                type="email" 
                id="email" 
                v-model="userStore.userProfile.email" 
                disabled
                :class="['mt-1 block w-full rounded-md shadow-sm py-2 px-3 focus:outline-none sm:text-sm transition-colors duration-200',
                         themeClasses.bg.disabled, themeClasses.text.primary, themeClasses.border.input]"
              >
            </div>
            
            <div class="sm:col-span-2">
              <label for="phone" :class="['block text-sm font-medium', themeClasses.text.primary]">Phone number</label>
              <input 
                type="tel" 
                id="phone" 
                v-model="userStore.userProfile.phone_number" 
                :class="['mt-1 block w-full rounded-md shadow-sm py-2 px-3 focus:outline-none sm:text-sm transition-colors duration-200 animate-input-focus',
                         themeClasses.bg.input, themeClasses.text.primary, themeClasses.border.input, 'focus:ring-2 focus:ring-blue-500 focus:border-blue-500']"
              >
            </div>
          </div>
          
          <div :class="['mt-8 pt-5', themeClasses.border.primary]">
            <div class="flex justify-end">
              <button
                @click="updateProfile"
                class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 animate-hover-glow"
                :disabled="isSaving"
              >
                <span v-if="!isSaving">Save</span>
                <span v-else class="flex items-center">
                  <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Saving...
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Delete Account Confirmation Modal -->
      <transition 
        enter-active-class="ease-out duration-300"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="ease-in duration-200"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="confirmDeleteAccount" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
          <div class="flex min-h-screen items-center justify-center p-4 text-center sm:block sm:p-0">
            <div class="fixed inset-0 bg-gray-900/80 backdrop-blur-sm transition-opacity" aria-hidden="true"></div>
            <span class="hidden sm:inline-block sm:h-screen sm:align-middle" aria-hidden="true">&#8203;</span>
            
            <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div class="px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="sm:flex sm:items-start">
                  <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 dark:bg-red-900/30 sm:mx-0 sm:h-10 sm:w-10">
                    <svg class="h-6 w-6 text-red-600 dark:text-red-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                  </div>
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                    <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-white" id="modal-title">
                      Delete account
                    </h3>
                    <div class="mt-2">
                      <p class="text-sm text-gray-500 dark:text-gray-300">
                        Are you sure you want to delete your account? All of your data will be permanently removed. This action cannot be undone.
                      </p>
                    </div>
                    <div class="mt-4">
                      <p class="text-sm text-gray-500 dark:text-gray-400">
                        To confirm, type <span class="font-mono bg-red-100 dark:bg-red-900/50 text-red-800 dark:text-red-200 px-2 py-0.5 rounded">delete my account</span> below:
                      </p>
                      <input
                        v-model="deleteConfirmationText"
                        type="text"
                        class="mt-2 block w-full rounded-md shadow-sm border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-red-500 focus:border-red-500 sm:text-sm animate-input-focus"
                        placeholder="Type to confirm..."
                      />
                    </div>
                  </div>
                </div>
              </div>
              <div class="px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <button
                  type="button"
                  @click="deleteAccount"
                  :disabled="deleteConfirmationText.toLowerCase() !== 'delete my account'"
                  :class="[
                    'w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 text-base font-medium text-white sm:ml-3 sm:w-auto sm:text-sm animate-hover-glow',
                    deleteConfirmationText.toLowerCase() === 'delete my account' 
                      ? 'bg-red-600 hover:bg-red-700 focus:ring-2 focus:ring-offset-2 focus:ring-red-500' 
                      : 'bg-red-400 cursor-not-allowed',
                    'transition-colors duration-200'
                  ]"
                >
                  {{ isDeleting ? 'Deleting...' : 'Delete account' }}
                </button>
                <button
                  type="button"
                  @click="confirmDeleteAccount = false"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 dark:border-gray-600 shadow-sm px-4 py-2 bg-white dark:bg-gray-700 text-base font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm transition-colors duration-200 animate-hover-glow"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useTheme } from '../../composables/useTheme'

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme()
import { useUserStore } from '../../stores/user'

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

// Show notification
const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
}

// Handle file change
const onFileChange = (e) => {
  const file = e.target.files[0]
  if (!file) return
  
  if (file.size > 10 * 1024 * 1024) {
    showNotificationMessage('File size should be less than 10MB', 'error')
    return
  }
  
  if (!file.type.match('image.*')) {
    showNotificationMessage('Only image files are allowed', 'error')
    return
  }
  
  selectedFile.value = file
  
  const reader = new FileReader()
  reader.onload = (e) => {
    // Temporarily set the image URL for preview
    userStore.userProfile.profile_image_url = e.target.result
  }
  reader.readAsDataURL(file)
  
  uploadProfileImage()
}

// Upload profile image
const uploadProfileImage = async () => {
  if (!selectedFile.value) return
  
  const formData = new FormData()
  formData.append('profile_image', selectedFile.value)
  
  isSaving.value = true
  
  try {
    await userStore.uploadProfileImage(formData)
    showNotificationMessage('Profile image updated successfully')
  } catch (error) {
    showNotificationMessage('Failed to update profile image', 'error')
    console.error('Failed to upload profile image:', error)
  } finally {
    isSaving.value = false
    selectedFile.value = null
  }
}

// Remove profile image
const removeProfileImage = async () => {
  isSaving.value = true
  
  try {
    await userStore.removeProfileImage()
    showImageModal.value = false
    showNotificationMessage('Profile image removed successfully')
  } catch (error) {
    showNotificationMessage('Failed to remove profile image', 'error')
    console.error('Failed to remove profile image:', error)
  } finally {
    isSaving.value = false
  }
}

// Update profile
const updateProfile = async () => {
  isUpdating.value = true
  
  try {
    await userStore.updateProfile(userStore.userProfile)
    showNotificationMessage('Profile updated successfully')
  } catch (error) {
    showNotificationMessage('Failed to update profile', 'error')
    console.error('Failed to update profile:', error)
  } finally {
    isUpdating.value = false
  }
}

// Delete account
const deleteAccount = async () => {
  if (deleteConfirmationText.value.toLowerCase() !== 'delete my account') return
  
  isDeleting.value = true
  try {
    await userStore.deleteAccount()
    showNotificationMessage('Account deleted successfully')
    confirmDeleteAccount.value = false
  } catch (error) {
    showNotificationMessage('Failed to delete account', 'error')
    console.error('Failed to delete account:', error)
  } finally {
    isDeleting.value = false
  }
}

// Handle image error
const handleImageError = () => {
  userStore.userProfile.profile_image_url = null
}

onMounted(async () => {
  // Load user preferences from localStorage or API
  const savedDarkMode = localStorage.getItem('darkMode')
  if (savedDarkMode !== null) {
    if (savedDarkMode === 'true' && !isDark.value) {
      toggleTheme()
    } else if (savedDarkMode === 'false' && isDark.value) {
      toggleTheme()
    }
  }
  
  // Load user profile if not already loaded
  if (!userStore.userProfile) {
    try {
      await userStore.fetchUserProfile()
    } catch (error) {
      console.error('Error loading user profile:', error)
      showNotificationMessage('Failed to load user profile', 'error')
    }
  }
})
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Animation for background blobs with color transitions */
@keyframes blob-color {
  0% {
    background: radial-gradient(circle, rgba(96, 165, 250, 0.7), rgba(147, 51, 234, 0.7));
    transform: translate(0, 0) scale(1);
  }
  50% {
    background: radial-gradient(circle, rgba(34, 211, 238, 0.7), rgba(219, 39, 119, 0.7));
    transform: translate(10%, 10%) scale(1.1);
  }
  100% {
    background: radial-gradient(circle, rgba(96, 165, 250, 0.7), rgba(147, 51, 234, 0.7));
    transform: translate(0, 0) scale(1);
  }
}

.animate-blob-color {
  animation: blob-color 8s ease-in-out infinite;
}

/* Pulse animation for success notification */
@keyframes pulse-success {
  0%, 100% { background-color: rgba(34, 197, 94, 0.95); }
  50% { background-color: rgba(22, 163, 74, 0.95); }
}

.animate-pulse-success {
  animation: pulse-success 2s ease-in-out infinite;
}

/* Pulse animation for error notification */
@keyframes pulse-error {
  0%, 100% { background-color: rgba(239, 68, 68, 0.95); }
  50% { background-color: rgba(220, 38, 38, 0.95); }
}

.animate-pulse-error {
  animation: pulse-error 2s ease-in-out infinite;
}

/* Gradient shift for card background */
@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.animate-gradient-shift {
  background-size: 200% 200%;
  animation: gradient-shift 10s ease infinite;
}

/* Pulse animation for profile card */
@keyframes pulse-card {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

.animate-pulse-card {
  animation: pulse-card 4s ease-in-out infinite;
}

/* Border pulse for profile image */
@keyframes border-pulse {
  0%, 100% { border-color: rgba(59, 130, 246, 0.5); }
  50% { border-color: rgba(59, 130, 246, 0.8); }
}

.animate-border-pulse {
  animation: border-pulse 3s ease-in-out infinite;
}

/* Hover glow effect for buttons */
@keyframes hover-glow {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  50% { box-shadow: 0 0 15px 5px rgba(59, 130, 246, 0.3); }
  100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
}

.animate-hover-glow:hover {
  animation: hover-glow 1.5s ease-in-out infinite;
}

/* Scale effect for buttons on hover */
@keyframes hover-scale {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.animate-hover-scale:hover {
  animation: hover-scale 0.3s ease-in-out;
}

/* Input focus animation */
@keyframes input-focus {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  100% { box-shadow: 0 0 8px 2px rgba(59, 130, 246, 0.3); }
}

.animate-input-focus:focus {
  animation: input-focus 0.3s ease-in-out forwards;
}

/* Smooth transitions for theme changes */
.transition-colors {
  transition-property: background-color, border-color, color, fill, stroke;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .max-w-4xl {
    padding-left: 1rem;
    padding-right: 1rem;
  }
  
  .px-6 {
    padding-left: 1rem;
    padding-right: 1rem;
  }
}
</style>