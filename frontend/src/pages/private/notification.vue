<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden']">
    <!-- Toast Notification -->
    <transition name="fade">
      <div 
        v-if="showToast" 
        :class="[
          'fixed top-4 z-50 p-3 rounded-md shadow-lg text-sm sm:text-base max-w-xs mx-4',
          'left-1/2 transform -translate-x-1/2 sm:left-auto sm:right-4 sm:transform-none',
          toastType === 'success' ? 'bg-green-500/90 text-green-50 animate-pulse-alert' : 'bg-red-500/90 text-red-50 animate-pulse-alert'
        ]"
      >
        {{ toastMessage }}
      </div>
    </transition>

    <!-- Header -->
    <header :class="[themeClasses.bg.card, themeClasses.shadow, 'z-10 bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
      <div class="flex items-center justify-between px-4 py-3">
        <div class="flex items-center space-x-3">
          <h1 :class="[themeClasses.text.primary, 'text-lg sm:text-xl font-semibold']">Notifications</h1>
          <span 
            v-if="unreadCount > 0" 
            :class="[themeClasses.alert.error, 'px-2 py-0.5 text-xs rounded-full animate-pulse-badge']"
          >
            {{ unreadCount }} new
          </span>
        </div>
        <div class="flex items-center space-x-2">
          <button 
            @click="toggleTheme" 
            :class="[themeClasses.text.secondary, themeClasses.text.primary.replace('text-', 'hover:text-'), 'p-2 rounded-lg transition-colors animate-hover-scale']"
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
            @click="markAllAsRead"
            :class="[themeClasses.button.secondary, 'hidden sm:inline-flex items-center px-3 py-2 text-sm font-medium rounded-md animate-hover-glow']"
          >
            Mark all as read
          </button>
          <button 
            @click="showNotificationSettings = true"
            :class="[themeClasses.button.primary, 'inline-flex items-center px-3 py-2 text-sm font-medium rounded-md animate-hover-glow']"
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
    <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <!-- Animated Background -->
      <div class="absolute inset-0 overflow-hidden opacity-10">
        <div class="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-to-br from-blue-400 to-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color"></div>
        <div class="absolute -bottom-1/2 -left-1/2 w-full h-full bg-gradient-to-tr from-cyan-400 to-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color animation-delay-2000"></div>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="flex items-center justify-center p-8">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" :class="[themeClasses.bg.card, themeClasses.shadow, 'p-6 text-center rounded-lg animate-pulse-card']">
        <div :class="[themeClasses.text.error, 'text-sm']">{{ error }}</div>
        <button 
          @click="fetchNotifications" 
          :class="[themeClasses.text.accent, 'mt-2 text-sm hover:underline animate-hover-scale']"
        >
          Retry
        </button>
      </div>

      <!-- Content -->
      <div v-else class="max-w-4xl mx-auto">
        <!-- Filters -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg mb-6 animate-pulse-card']">
          <div class="px-4 py-3">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <div class="relative">
                <div class="flex space-x-2 overflow-x-auto scrollbar-hide pb-2">
                  <button 
                    v-for="filter in filters"
                    :key="filter.value"
                    @click="activeFilter = filter.value"
                    :class="[
                      activeFilter === filter.value ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800 hover:bg-gray-200',
                      'px-3 py-1 text-sm rounded-md whitespace-nowrap flex-shrink-0 transition-colors animate-hover-scale'
                    ]"
                  >
                    {{ filter.label }}
                    <span v-if="filter.count" :class="[
                      activeFilter === filter.value ? 'bg-blue-200 text-blue-800' : 'bg-gray-200 text-gray-800',
                      'ml-1 px-1.5 py-0.5 text-xs rounded-full'
                    ]">
                      {{ filter.count }}
                    </span>
                  </button>
                </div>
                <div class="absolute right-0 top-0 bottom-0 w-8 bg-gradient-to-l from-gray-100 to-transparent pointer-events-none"></div>
              </div>
              <div class="flex items-center">
                <label for="sort" :class="[themeClasses.text.secondary, 'mr-2 text-sm whitespace-nowrap']">Sort by:</label>
                <select 
                  id="sort"
                  v-model="sortBy"
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full sm:w-auto px-3 py-1.5 text-sm rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
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
        <div class="space-y-4">
          <div 
            v-for="notification in filteredNotifications" 
            :key="notification.id" 
            :class="[
              themeClasses.bg.card, 
              themeClasses.shadow, 
              'rounded-lg p-4 hover:bg-gray-50 transition-colors duration-150 animate-pulse-card',
              !notification.is_resolved ? 'border-l-4' : '',
              !notification.is_resolved && notification.severity_level === 'CRITICAL' ? 'border-red-500' : '',
              !notification.is_resolved && notification.severity_level === 'HIGH' ? 'border-yellow-500' : '',
              !notification.is_resolved && notification.severity_level === 'LOW' ? 'border-gray-300' : ''
            ]"
          >
            <div class="flex items-start">
              <div class="flex-shrink-0 pt-1">
                <div :class="[
                  'h-8 w-8 rounded-full flex items-center justify-center',
                  notification.alert_type === 'GAS_LEAK' ? 'bg-red-100 text-red-600' : 
                  notification.alert_type === 'SYSTEM' ? 'bg-blue-100 text-blue-600' : 
                  notification.alert_type === 'GAS_LEVEL_LOW' ? 'bg-green-100 text-green-600' : 
                  'bg-yellow-100 text-yellow-600'
                ]">
                  <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path v-if="notification.alert_type === 'GAS_LEAK'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    <path v-if="notification.alert_type === 'SYSTEM'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                    <path v-if="notification.alert_type === 'GAS_LEVEL_LOW'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    <path v-if="notification.alert_type === 'LOW_BATTERY'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    <path v-if="notification.alert_type === 'PAYMENT_SUCCESS'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                    <path v-if="notification.alert_type === 'PAYMENT_FAILED'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                  </svg>
                </div>
              </div>
              <div class="ml-3 flex-1 min-w-0">
                <div class="flex justify-between">
                  <p :class="[themeClasses.text.primary, 'text-sm font-medium truncate']">
                    {{ notification.alert_message }}
                    <span v-if="!notification.is_resolved" class="ml-1 inline-block h-2 w-2 rounded-full bg-blue-500 animate-pulse-badge"></span>
                  </p>
                  <div class="text-xs text-gray-500 whitespace-nowrap ml-2">
                    {{ formatTime(notification.triggered_at) }}
                  </div>
                </div>
                <p :class="[themeClasses.text.secondary, 'text-sm mt-1 truncate']">
                  {{ notification.sensor_name ? `${notification.sensor_name} at ${notification.house_address}` : notification.house_address }}
                </p>
                <div class="mt-2 flex space-x-3">
                  <button 
                    v-if="!notification.is_resolved"
                    @click="markAsRead(notification)"
                    :class="[themeClasses.text.accent, 'text-xs hover:underline animate-hover-scale']"
                  >
                    Mark as read
                  </button>
                  <button 
                    @click="dismissNotification(notification)"
                    :class="[themeClasses.text.secondary, 'text-xs hover:underline animate-hover-scale ml-auto']"
                  >
                    Dismiss
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Empty State -->
          <div v-if="filteredNotifications.length === 0" :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg p-6 text-center animate-pulse-card']">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
            </svg>
            <h3 :class="[themeClasses.text.primary, 'mt-2 text-sm font-medium']">
              {{ activeFilter === 'all' ? "You're all caught up!" : `No ${activeFilter} notifications` }}
            </h3>
            <button 
              @click="activeFilter = 'all'"
              :class="[themeClasses.button.primary, 'mt-4 px-4 py-2 text-sm font-medium rounded-md animate-hover-glow']"
            >
              View all notifications
            </button>
          </div>
        </div>
      </div>
    </main>

    <!-- Settings Modal -->
    <div v-if="showNotificationSettings" class="fixed inset-0 bg-gray-600/50 flex items-center justify-center z-50 p-4">
      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg max-w-md sm:max-w-lg max-h-[90vh] overflow-y-auto animate-pulse-card']">
        <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
          <h3 :class="[themeClasses.text.primary, 'text-lg font-medium']">Notification Settings</h3>
        </div>
        <div class="p-6 space-y-6">
          <!-- Notification Preferences -->
          <div>
            <h4 :class="[themeClasses.text.primary, 'text-sm font-medium mb-3']">Notification Preferences</h4>
            <div class="space-y-4">
              <label class="flex items-start cursor-pointer">
                <input 
                  v-model="settings.emailEnabled" 
                  type="checkbox" 
                  :class="[themeClasses.text.accent, 'h-4 w-4 rounded focus:ring-blue-500 animate-input-focus']"
                >
                <div class="ml-3 text-sm">
                  <span :class="[themeClasses.text.primary, 'font-medium']">Email Notifications</span>
                  <p :class="[themeClasses.text.secondary, 'text-gray-500']">Receive notifications via email</p>
                </div>
              </label>
              <label class="flex items-start cursor-pointer">
                <input 
                  v-model="settings.pushEnabled" 
                  type="checkbox" 
                  :class="[themeClasses.text.accent, 'h-4 w-4 rounded focus:ring-blue-500 animate-input-focus']"
                >
                <div class="ml-3 text-sm">
                  <span :class="[themeClasses.text.primary, 'font-medium']">Push Notifications</span>
                  <p :class="[themeClasses.text.secondary, 'text-gray-500']">Receive notifications on your devices</p>
                </div>
              </label>
              <label class="flex items-start cursor-pointer">
                <input 
                  v-model="settings.smsEnabled" 
                  type="checkbox" 
                  :class="[themeClasses.text.accent, 'h-4 w-4 rounded focus:ring-blue-500 animate-input-focus']"
                >
                <div class="ml-3 text-sm">
                  <span :class="[themeClasses.text.primary, 'font-medium']">SMS Notifications</span>
                  <p :class="[themeClasses.text.secondary, 'text-gray-500']">Receive critical alerts via text message</p>
                </div>
              </label>
            </div>
          </div>
          <!-- Alert Thresholds -->
          <div>
            <h4 :class="[themeClasses.text.primary, 'text-sm font-medium mb-3']">Alert Thresholds</h4>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label for="critical-alerts" :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Critical Alerts</label>
                <select 
                  id="critical-alerts" 
                  v-model="settings.criticalAlerts" 
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                >
                  <option value="all">All critical alerts</option>
                  <option value="system">System alerts only</option>
                  <option value="none">None</option>
                </select>
              </div>
              <div>
                <label for="warning-alerts" :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Warning Alerts</label>
                <select 
                  id="warning-alerts" 
                  v-model="settings.warningAlerts" 
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                >
                  <option value="all">All warnings</option>
                  <option value="important">Important only</option>
                  <option value="none">None</option>
                </select>
              </div>
              <div>
                <label for="info-alerts" :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Info Alerts</label>
                <select 
                  id="info-alerts" 
                  v-model="settings.infoAlerts" 
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                >
                  <option value="important">Important only</option>
                  <option value="none">None</option>
                </select>
              </div>
            </div>
          </div>
          <!-- Quiet Hours -->
          <div>
            <h4 :class="[themeClasses.text.primary, 'text-sm font-medium mb-3']">Quiet Hours</h4>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label for="quiet-start" :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Start Time</label>
                <select 
                  id="quiet-start" 
                  v-model="settings.quietStart" 
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                >
                  <option v-for="hour in hours" :key="'start-'+hour.value" :value="hour.value">
                    {{ hour.label }}
                  </option>
                </select>
              </div>
              <div>
                <label for="quiet-end" :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">End Time</label>
                <select 
                  id="quiet-end" 
                  v-model="settings.quietEnd" 
                  :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 rounded-md focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                >
                  <option v-for="hour in hours" :key="'end-'+hour.value" :value="hour.value">
                    {{ hour.label }}
                  </option>
                </select>
              </div>
            </div>
          </div>
        </div>
        <div :class="[themeClasses.bg.secondary, 'px-6 py-4 border-t flex justify-end space-x-3']">
          <button 
            @click="showNotificationSettings = false"
            :class="[themeClasses.button.secondary, 'px-4 py-2 text-sm font-medium rounded-md animate-hover-glow']"
          >
            Cancel
          </button>
          <button 
            @click="saveNotificationSettings"
            :class="[themeClasses.button.primary, 'px-4 py-2 text-sm font-medium rounded-md animate-hover-glow']"
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
import api from '../../config/api'

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme()

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
  { value: 'tanks', label: 'Tanks', count: null },
  { value: 'payments', label: 'Payments', count: null }
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
  
  switch (activeFilter.value) {
    case 'unread':
      filtered = filtered.filter(n => !n.is_resolved)
      break
    case 'alerts':
      filtered = filtered.filter(n => n.alert_type !== 'SYSTEM' && n.alert_type !== 'PAYMENT_SUCCESS' && n.alert_type !== 'PAYMENT_FAILED')
      break
    case 'system':
      filtered = filtered.filter(n => n.alert_type === 'SYSTEM')
      break
    case 'tanks':
      filtered = filtered.filter(n => n.sensor_name)
      break
    case 'payments':
      filtered = filtered.filter(n => n.alert_type === 'PAYMENT_SUCCESS' || n.alert_type === 'PAYMENT_FAILED')
      break
  }
  
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
    await api.post('/notifications/mark-all-read/')
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
        count = notifications.value.filter(n => n.alert_type !== 'SYSTEM' && n.alert_type !== 'PAYMENT_SUCCESS' && n.alert_type !== 'PAYMENT_FAILED').length
        break
      case 'system':
        count = notifications.value.filter(n => n.alert_type === 'SYSTEM').length
        break
      case 'tanks':
        count = notifications.value.filter(n => n.sensor_name).length
        break
      case 'payments':
        count = notifications.value.filter(n => n.alert_type === 'PAYMENT_SUCCESS' || n.alert_type === 'PAYMENT_FAILED').length
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
    showToastMessage('Failed to fetch settings', 'error')
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
/* Animations */
@keyframes blob-color {
  0% { background: radial-gradient(circle, rgba(96, 165, 250, 0.7), rgba(147, 51, 234, 0.7)); transform: translate(0, 0) scale(1); }
  50% { background: radial-gradient(circle, rgba(34, 211, 238, 0.7), rgba(219, 39, 119, 0.7)); transform: translate(10%, 10%) scale(1.1); }
  100% { background: radial-gradient(circle, rgba(96, 165, 250, 0.7), rgba(147, 51, 234, 0.7)); transform: translate(0, 0) scale(1); }
}

@keyframes pulse-card {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

@keyframes pulse-badge {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

@keyframes pulse-alert {
  0%, 100% { background-color: rgba(255, 255, 255, 0.1); }
  50% { background-color: rgba(255, 255, 255, 0.2); }
}

@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

@keyframes hover-glow {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  50% { box-shadow: 0 0 15px 5px rgba(59, 130, 246, 0.3); }
  100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
}

@keyframes hover-scale {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

@keyframes input-focus {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  100% { box-shadow: 0 0 8px 2px rgba(59, 130, 246, 0.3); }
}

.animate-blob-color {
  animation: blob-color 12s ease-in-out infinite;
}

.animate-pulse-card {
  animation: pulse-card 4s ease-in-out infinite;
}

.animate-pulse-badge {
  animation: pulse-badge 2s infinite;
}

.animate-pulse-alert {
  animation: pulse-alert 2s ease-in-out infinite;
}

.animate-gradient-shift {
  background-size: 200% 200%;
  animation: gradient-shift 10s ease infinite;
}

.animate-hover-glow:hover {
  animation: hover-glow 1.5s ease-in-out infinite;
}

.animate-hover-scale:hover {
  animation: hover-scale 0.3s ease-in-out;
}

.animate-input-focus:focus {
  animation: input-focus 0.3s ease-in-out forwards;
}

.animation-delay-2000 {
  animation-delay: 2000ms;
}

/* Scrollbar styling */
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

.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Ensure text stays within frame */
.break-words {
  word-break: break-word;
  overflow-wrap: break-word;
  hyphens: auto;
}
</style>