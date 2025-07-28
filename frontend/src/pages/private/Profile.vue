<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen']">
    <div class="max-w-3xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
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
            <img :src="userStore.userProfile?.profile_image_url" class="max-w-full max-h-screen object-contain" alt="Profile preview">
            <button @click="showImageModal = false" 
                    :class="[themeClasses.bg.secondary, 'absolute top-4 right-4 p-2 rounded-full shadow-md hover:bg-gray-700']">
              <svg xmlns="http://www.w3.org/2000/svg" :class="[themeClasses.text.primary, 'h-6 w-6']" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
            <button v-if="userStore.userProfile?.profile_image_url"
                    @click="removeProfileImage"
                    :class="[themeClasses.button.danger, 'absolute bottom-4 right-4 px-4 py-2 rounded-md']">
              Remove Image
            </button>
          </div>
        </div>
      </transition>

      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden']">
        <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b']">
          <div class="flex items-center justify-between">
            <h2 :class="[themeClasses.text.primary, 'text-xl font-semibold']">Profile Settings</h2>
            <!-- Theme Toggle Button -->
            <button 
              @click="toggleTheme" 
              :class="[themeClasses.text.secondary, 'p-2 rounded-lg transition-colors hover:text-gray-600']"
              :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
            >
              <svg v-if="isDark" class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
              </svg>
              <svg v-else class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
      
      <div class="px-6 py-4">
        <div class="flex items-center space-x-6">
          <div class="relative">
            <!-- Profile Image with Click-to-View -->
            <div v-if="userStore.userProfile?.profile_image_url" 
                 class="w-24 h-24 rounded-full overflow-hidden border-2 border-blue-500 cursor-pointer hover:border-blue-600 transition-all"
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
                 :class="[themeClasses.bg.tertiary, 'w-24 h-24 rounded-full flex items-center justify-center cursor-pointer border-2 border-gray-300']"
                 @click="$refs.fileInput.click()">
              <svg :class="[themeClasses.text.muted, 'w-12 h-12']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
            </div>
          </div>
          <div class="flex-1">
            <div class="flex items-center space-x-4">
              <label class="block">
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
                  :class="[themeClasses.button.secondary, 'px-4 py-2 rounded-md transition-colors']"
                >
                  Add Photo
                </button>
              </label>
              <button
                v-if="userStore.userProfile?.profile_image_url"
                @click="removeProfileImage"
                :class="[themeClasses.button.danger, 'px-4 py-2 rounded-md transition-colors']"
              >
                Remove Photo
              </button>
            </div>
            <p class="mt-2 text-sm text-gray-500">
              JPG, GIF or PNG. Max size of 10MB.
            </p>
          </div>
        </div>
        
        <div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2">
          <div>
            <label for="first_name" class="block text-sm font-medium text-gray-700">First name</label>
            <input 
              type="text" 
              id="first_name" 
              v-model="userStore.userProfile.first_name" 
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            >
          </div>
          
          <div>
            <label for="last_name" class="block text-sm font-medium text-gray-700">Last name</label>
            <input 
              type="text" 
              id="last_name" 
              v-model="userStore.userProfile.last_name" 
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            >
          </div>
          
          <div class="sm:col-span-2">
            <label for="email" class="block text-sm font-medium text-gray-700">Email address</label>
            <input 
              type="email" 
              id="email" 
              v-model="userStore.userProfile.email" 
              disabled
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 bg-gray-100 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            >
          </div>
          
          <div class="sm:col-span-2">
            <label for="phone" class="block text-sm font-medium text-gray-700">Phone number</label>
            <input 
              type="tel" 
              id="phone" 
              v-model="userStore.userProfile.phone_number" 
              class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
            >
          </div>
        </div>
        
        <div class="mt-8 pt-5 border-t border-gray-200">
          <div class="flex justify-end">
            <button
              @click="updateProfile"
              class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
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
const selectedFile = ref(null)
const showImageModal = ref(false)
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')

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
  isSaving.value = true
  
  try {
    await userStore.updateProfile(userStore.userProfile)
    showNotificationMessage('Profile updated successfully')
  } catch (error) {
    showNotificationMessage('Failed to update profile', 'error')
    console.error('Failed to update profile:', error)
  } finally {
    isSaving.value = false
  }
}

// Handle image error
const handleImageError = () => {
  userStore.userProfile.profile_image_url = null
}

onMounted(async () => {

})
</script>

<style scoped>
/* Styles remain exactly the same */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>