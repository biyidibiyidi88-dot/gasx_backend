<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden']">
    <!-- Notification Toast - Centered on mobile -->
    <transition name="fade">
      <div v-if="showToast" 
           :class="['fixed top-4 z-50 p-3 rounded-md shadow-lg text-white text-sm sm:text-base max-w-xs mx-4 sm:mx-0',
                   'left-1/2 transform -translate-x-1/2 sm:left-auto sm:right-4 sm:transform-none',
                   toastType === 'success' ? 'bg-green-500' : 'bg-red-500']">
        {{ toastMessage }}
      </div>
    </transition>

    <!-- Top Navigation - Stacked on mobile -->
    <header :class="[themeClasses.bg.secondary, themeClasses.shadow, 'z-10']">
      <div class="flex items-center justify-between px-4 py-3">
        <div class="flex items-center">
          <!-- Mobile menu button -->
         
          
          <!-- Page Title -->
          <div class="flex items-center">
            <h1 :class="[themeClasses.text.primary, 'text-lg sm:text-xl font-semibold']">Notifications</h1>
            <span v-if="unreadCount > 0" class="ml-2 px-2 py-0.5 text-xs rounded-full bg-red-500 text-white">
              {{ unreadCount }} new
            </span>
          </div>
        </div>
        
        <!-- Theme Toggle & Actions -->
        <div class="flex items-center space-x-2">
          <!-- Theme Toggle Button -->
          
          
          <button 
            @click="markAllAsRead"
            :class="[themeClasses.button.secondary, 'hidden sm:inline-flex items-center px-3 py-2 text-sm leading-4 font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500']"
          >
            Mark all as read
          </button>
          <button 
            @click="showNotificationSettings = true"
            :class="[themeClasses.button.primary, 'inline-flex items-center px-3 py-2 text-sm leading-4 font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500']"
          >
            <svg class="-ml-0.5 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            <span class="hidden sm:inline">Settings</span>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto">
      <!-- Loading State -->
      <div v-if="isLoading" class="flex items-center justify-center p-8">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="p-8 text-center text-red-500">
        {{ error }}
        <button @click="fetchNotifications" class="mt-2 text-blue-600 hover:text-blue-800">
          Retry
        </button>
      </div>

      <!-- Content -->
      <div v-else>
        <!-- Notification Filters with scrollable area -->
        <div :class="[themeClasses.bg.secondary, themeClasses.shadow, themeClasses.border, 'border-b']">
          <div class="px-4 sm:px-6">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-2 py-3">
              <div class="relative">
                <div class="flex space-x-2 overflow-x-auto pb-2 scrollbar-hide">
                  <button 
                    v-for="filter in filters"
                    :key="filter.value"
                    @click="activeFilter = filter.value"
                    class="px-3 py-1 text-sm rounded-md whitespace-nowrap flex-shrink-0"
                    :class="{
                      'bg-blue-100 text-blue-800': activeFilter === filter.value,
                      'bg-gray-100 text-gray-800 hover:bg-gray-200': activeFilter !== filter.value
                    }"
                  >
                    {{ filter.label }}
                    <span v-if="filter.count" class="ml-1 px-1.5 py-0.5 text-xs rounded-full" 
                      :class="{
                        'bg-blue-200 text-blue-800': activeFilter === filter.value,
                        'bg-gray-200 text-gray-800': activeFilter !== filter.value
                      }">
                      {{ filter.count }}
                    </span>
                  </button>
                </div>
                <div class="absolute right-0 top-0 bottom-0 w-8 bg-gradient-to-l from-gray-100 to-transparent pointer-events-none"></div>
              </div>
              
              <div class="flex items-center mt-2 md:mt-0">
                <label for="sort" class="mr-2 text-sm text-gray-600 whitespace-nowrap">Sort by:</label>
                <select 
                  id="sort"
                  v-model="sortBy"
                  class="block w-full pl-3 pr-10 py-1.5 text-sm border border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 rounded-md"
                >
                  <option value="newest">Newest first</option>
                  <option value="oldest">Oldest first</option>
                  <option value="priority">Priority</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <!-- Notifications List -->
        <div class="divide-y divide-gray-200">
          <div v-for="notification in filteredNotifications" :key="notification.id" 
            class="px-4 py-4 sm:px-6 hover:bg-gray-50 transition-colors duration-150"
            :class="{
              'bg-blue-50': !notification.is_resolved,
              'border-l-4 border-blue-500': !notification.is_resolved && notification.severity_level === 'CRITICAL',
              'border-l-4 border-yellow-500': !notification.is_resolved && notification.severity_level === 'HIGH',
              'border-l-4 border-gray-300': !notification.is_resolved && notification.severity_level === 'LOW'
            }">
            <div class="flex items-start">
              <!-- Notification Icon -->
              <div class="flex-shrink-0 pt-1">
                <div class="h-8 w-8 rounded-full flex items-center justify-center"
                  :class="{
                    'bg-red-100 text-red-600': notification.alert_type === 'GAS_LEAK',
                    'bg-blue-100 text-blue-600': notification.alert_type === 'SYSTEM',
                    'bg-green-100 text-green-600': notification.alert_type === 'GAS_LEVEL_LOW',
                    'bg-yellow-100 text-yellow-600': notification.alert_type === 'LOW_BATTERY'
                  }">
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path v-if="notification.alert_type === 'GAS_LEAK'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    <path v-if="notification.alert_type === 'SYSTEM'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                    <path v-if="notification.alert_type === 'GAS_LEVEL_LOW'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    <path v-if="notification.alert_type === 'LOW_BATTERY'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                </div>
              </div>
              
              <!-- Notification Content -->
              <div class="ml-3 flex-1 min-w-0">
                <div class="flex justify-between">
                  <p class="text-sm font-medium text-gray-900 truncate">
                    {{ notification.alert_message }}
                    <span v-if="!notification.is_resolved" class="ml-1 inline-block h-2 w-2 rounded-full bg-blue-500"></span>
                  </p>
                  <div class="text-xs text-gray-500 whitespace-nowrap ml-2">
                    {{ formatTime(notification.triggered_at) }}
                  </div>
                </div>
                <p class="text-sm text-gray-600 mt-1 truncate">
                  {{ notification.sensor_name }} at {{ notification.house_address }}
                </p>
                
                <!-- Notification Actions -->
                <div class="mt-2 flex space-x-3">
                  <button 
                    v-if="!notification.is_resolved"
                    @click="markAsRead(notification)"
                    class="text-xs text-blue-600 hover:text-blue-800"
                  >
                    Mark as read
                  </button>
                  <button 
                    @click="dismissNotification(notification)"
                    class="text-xs text-gray-500 hover:text-gray-700 ml-auto"
                  >
                    Dismiss
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Empty State -->
          <div v-if="filteredNotifications.length === 0" class="px-4 py-12 sm:px-6 text-center">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No notifications</h3>
            <p class="mt-1 text-sm text-gray-500">
              {{ activeFilter === 'all' ? "You're all caught up!" : `No ${activeFilter} notifications` }}
            </p>
            <div class="mt-6">
              <button 
                @click="activeFilter = 'all'"
                type="button"
                class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                View all notifications
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Notification Settings Modal - Responsive -->
    <div v-if="showNotificationSettings" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-md sm:max-w-xl md:max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-medium text-gray-900">Notification Settings</h3>
        </div>
        <div class="p-6">
          <div class="space-y-6">
            <!-- Notification Preferences -->
            <div>
              <h4 class="text-sm font-medium text-gray-900 mb-3">Notification Preferences</h4>
              <div class="space-y-4">
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <input 
                      id="email-notifications" 
                      v-model="settings.emailEnabled" 
                      type="checkbox" 
                      class="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    >
                  </div>
                  <div class="ml-3 text-sm">
                    <label for="email-notifications" class="font-medium text-gray-700">Email Notifications</label>
                    <p class="text-gray-500">Receive notifications via email</p>
                  </div>
                </div>
                
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <input 
                      id="push-notifications" 
                      v-model="settings.pushEnabled" 
                      type="checkbox" 
                      class="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    >
                  </div>
                  <div class="ml-3 text-sm">
                    <label for="push-notifications" class="font-medium text-gray-700">Push Notifications</label>
                    <p class="text-gray-500">Receive notifications on your devices</p>
                  </div>
                </div>
                
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <input 
                      id="sms-notifications" 
                      v-model="settings.smsEnabled" 
                      type="checkbox" 
                      class="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    >
                  </div>
                  <div class="ml-3 text-sm">
                    <label for="sms-notifications" class="font-medium text-gray-700">SMS Notifications</label>
                    <p class="text-gray-500">Receive critical alerts via text message</p>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Alert Thresholds - Responsive grid -->
            <div>
              <h4 class="text-sm font-medium text-gray-900 mb-3">Alert Thresholds</h4>
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label for="critical-alerts" class="block text-sm font-medium text-gray-700 mb-1">Critical Alerts</label>
                  <select 
                    id="critical-alerts" 
                    v-model="settings.criticalAlerts" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="all">All critical alerts</option>
                    <option value="system">System alerts only</option>
                    <option value="none">None</option>
                  </select>
                </div>
                <div>
                  <label for="warning-alerts" class="block text-sm font-medium text-gray-700 mb-1">Warning Alerts</label>
                  <select 
                    id="warning-alerts" 
                    v-model="settings.warningAlerts" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="all">All warnings</option>
                    <option value="important">Important only</option>
                    <option value="none">None</option>
                  </select>
                </div>
                <div>
                  <label for="info-alerts" class="block text-sm font-medium text-gray-700 mb-1">Info Alerts</label>
                  <select 
                    id="info-alerts" 
                    v-model="settings.infoAlerts" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="important">Important only</option>
                    <option value="none">None</option>
                  </select>
                </div>
              </div>
            </div>
            
            <!-- Quiet Hours - Responsive grid -->
            <div>
              <h4 class="text-sm font-medium text-gray-900 mb-3">Quiet Hours</h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label for="quiet-start" class="block text-sm font-medium text-gray-700 mb-1">Start Time</label>
                  <select 
                    id="quiet-start" 
                    v-model="settings.quietStart" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option v-for="hour in hours" :key="'start-'+hour.value" :value="hour.value">
                      {{ hour.label }}
                    </option>
                  </select>
                </div>
                <div>
                  <label for="quiet-end" class="block text-sm font-medium text-gray-700 mb-1">End Time</label>
                  <select 
                    id="quiet-end" 
                    v-model="settings.quietEnd" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option v-for="hour in hours" :key="'end-'+hour.value" :value="hour.value">
                      {{ hour.label }}
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
          <button 
            @click="showNotificationSettings = false"
            class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Cancel
          </button>
          <button 
            @click="saveNotificationSettings"
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Save Settings
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useTheme } from '../../composables/useTheme'

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme()

import api from "../../config/api"

// State
const activeFilter = ref('unread')
const sortBy = ref('newest')
const showNotificationSettings = ref(false)
const notifications = ref([])
const isLoading = ref(false)
const error = ref(null)
const showToast = ref(false)
const toastMessage = ref('')
const toastType = ref('success')

const hours = [
  { value: 22, label: '10:00 PM' },
  { value: 23, label: '11:00 PM' },
  { value: 0, label: '12:00 AM' },
  { value: 1, label: '1:00 AM' },
  { value: 2, label: '2:00 AM' },
  { value: 3, label: '3:00 AM' },
  { value: 4, label: '4:00 AM' },
  { value: 5, label: '5:00 AM' },
  { value: 6, label: '6:00 AM' }
]

const filters = ref([
  { value: 'all', label: 'All', count: null },
  { value: 'unread', label: 'Unread', count: null },
  { value: 'alerts', label: 'Alerts', count: null },
  { value: 'system', label: 'System', count: null },
  { value: 'tanks', label: 'Tanks', count: null }
])

const settings = ref({
  emailEnabled: true,
  pushEnabled: true,
  smsEnabled: false,
  criticalAlerts: 'all',
  warningAlerts: 'all',
  infoAlerts: 'important',
  quietStart: 22,
  quietEnd: 6
})

// Computed properties
const filteredNotifications = computed(() => {
  let filtered = [...notifications.value]
  
  // Apply filter
  switch (activeFilter.value) {
    case 'unread':
      filtered = filtered.filter(n => !n.is_resolved)
      break
    case 'alerts':
      filtered = filtered.filter(n => n.alert_type !== 'SYSTEM')
      break
    case 'system':
      filtered = filtered.filter(n => n.alert_type === 'SYSTEM')
      break
    case 'tanks':
      filtered = filtered.filter(n => n.sensor_name)
      break
    // 'all' shows everything
  }
  
  // Apply sorting
  switch (sortBy.value) {
    case 'newest':
      filtered.sort((a, b) => new Date(b.triggered_at) - new Date(a.triggered_at))
      break
    case 'oldest':
      filtered.sort((a, b) => new Date(a.triggered_at) - new Date(b.triggered_at))
      break
    case 'priority':
      const priorityOrder = { 'CRITICAL': 1, 'HIGH': 2, 'MEDIUM': 3, 'LOW': 4 }
      filtered.sort((a, b) => {
        if (priorityOrder[a.severity_level] === priorityOrder[b.severity_level]) {
          return new Date(b.triggered_at) - new Date(a.triggered_at)
        }
        return priorityOrder[a.severity_level] - priorityOrder[b.severity_level]
      })
      break
  }
  
  return filtered
})

const unreadCount = computed(() => {
  return notifications.value.filter(n => !n.is_resolved).length
})

// Methods
const showToastMessage = (message, type = 'success') => {
  toastMessage.value = message
  toastType.value = type
  showToast.value = true
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

const formatTime = (timestamp) => {
  const now = new Date()
  const date = new Date(timestamp)
  const diffHours = Math.floor((now - date) / (1000 * 60 * 60))
  
  if (diffHours < 1) {
    const diffMinutes = Math.floor((now - date) / (1000 * 60))
    return `${diffMinutes} minute${diffMinutes !== 1 ? 's' : ''} ago`
  }
  if (diffHours < 24) {
    return `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`
  }
  
  return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const fetchNotifications = async () => {
  isLoading.value = true
  error.value = null
  try {
    const response = await api.get('/notifications/')
    notifications.value = response.data
    updateFilterCounts()
  } catch (err) {
    error.value = 'Failed to load notifications'
    console.error('Error fetching notifications:', err)
    showToastMessage('Failed to load notifications', 'error')
  } finally {
    isLoading.value = false
  }
}

const markAsRead = async (notification) => {
  try {
    await api.post(`/notifications/${notification.id}/read/`)
    notification.is_resolved = true
    updateFilterCounts()
    showToastMessage('Notification marked as read')
  } catch (err) {
    console.error('Error marking notification as read:', err)
    showToastMessage('Failed to mark as read', 'error')
  }
}

const markAllAsRead = async () => {
  try {
    await api.post('notifications/mark-all-read/')
    notifications.value.forEach(n => n.is_resolved = true)
    updateFilterCounts()
    showToastMessage('All notifications marked as read')
  } catch (err) {
    console.error('Error marking all notifications as read:', err)
    showToastMessage('Failed to mark all as read', 'error')
  }
}

const dismissNotification = async (notification) => {
  try {
    await api.delete(`/notifications/${notification.id}/`)
    notifications.value = notifications.value.filter(n => n.id !== notification.id)
    updateFilterCounts()
    showToastMessage('Notification dismissed')
  } catch (err) {
    console.error('Error dismissing notification:', err)
    showToastMessage('Failed to dismiss notification', 'error')
  }
}

const updateFilterCounts = () => {
  filters.value = filters.value.map(filter => {
    let count
    switch (filter.value) {
      case 'unread':
        count = notifications.value.filter(n => !n.is_resolved).length
        break
      case 'alerts':
        count = notifications.value.filter(n => n.alert_type !== 'SYSTEM').length
        break
      case 'system':
        count = notifications.value.filter(n => n.alert_type === 'SYSTEM').length
        break
      case 'tanks':
        count = notifications.value.filter(n => n.sensor_name).length
        break
      default:
        count = null
    }
    return { ...filter, count }
  })
}

const fetchSettings = async () => {
  try {
    const response = await api.get('/notifications/settings/')
    settings.value = response.data
  } catch (err) {
    console.error('Error fetching notification settings:', err)
  }
}

const saveNotificationSettings = async () => {
  try {
    await api.post('/notifications/settings/', settings.value)
    showNotificationSettings.value = false
    showToastMessage('Notification settings saved')
  } catch (err) {
    console.error('Error saving notification settings:', err)
    showToastMessage('Failed to save settings', 'error')
  }
}

// Lifecycle
onMounted(() => {
  fetchNotifications()
  fetchSettings()
})
</script>

<style scoped>
/* Custom scrollbar for main content */
main::-webkit-scrollbar {
  width: 6px;
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

/* Hide scrollbar for filter buttons but allow scrolling */
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Modal transitions */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter, .modal-leave-to {
  opacity: 0;
}

/* Notification priority indicators */
.border-l-4 {
  transition: border-color 0.2s ease;
}

/* Button transitions */
button {
  transition: all 0.2s ease;
}

/* Toast notification */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .text-truncate {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}
</style>