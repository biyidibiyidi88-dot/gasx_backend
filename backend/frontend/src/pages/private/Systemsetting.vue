<template>
    <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden']">
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
          <h1 :class="[themeClasses.text.primary, 'text-xl font-semibold']">System Settings</h1>
          
          <!-- Theme Toggle & Save Status -->
          <div class="flex items-center space-x-4">
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
            
            <!-- Save Status -->
            <div :class="[themeClasses.text.secondary, 'text-sm']">
              <span v-if="saved" :class="[themeClasses.text.success, 'flex items-center']">
                <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                Changes saved
              </span>
              <span v-else :class="themeClasses.text.secondary">Unsaved changes</span>
            </div>
          </div>
        </div>
      </header>
  
      <!-- Main Content -->
      <main class="flex-1 overflow-y-auto p-4 sm:p-6">
        <div class="max-w-4xl mx-auto">
          <!-- Alert Notification Settings -->
          <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden mb-6']">
            <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b']">
              <h2 :class="[themeClasses.text.primary, 'text-lg font-medium flex items-center']">
                <svg :class="[themeClasses.text.warning, 'h-5 w-5 mr-2']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
                Alert Notifications
              </h2>
            </div>
            <div class="p-6">
              <div class="space-y-6">
                <!-- Email Notifications -->
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <input 
                      id="email-notifications" 
                      v-model="settings.emailNotifications" 
                      type="checkbox" 
                      class="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    >
                  </div>
                  <div class="ml-3 text-sm">
                    <label for="email-notifications" class="font-medium text-gray-700">Email Notifications</label>
                    <p class="text-gray-500">Receive alerts via email</p>
                  </div>
                </div>
                
                <!-- SMS Notifications -->
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <input 
                      id="sms-notifications" 
                      v-model="settings.smsNotifications" 
                      type="checkbox" 
                      class="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                    >
                  </div>
                  <div class="ml-3 text-sm">
                    <label for="sms-notifications" class="font-medium text-gray-700">SMS Notifications</label>
                    <p class="text-gray-500">Receive critical alerts via text message</p>
                  </div>
                </div>
                
                <!-- Notification Thresholds -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label for="low-level" class="block text-sm font-medium text-gray-700 mb-1">Low Level Alert (%)</label>
                    <input 
                      type="number" 
                      id="low-level" 
                      v-model="settings.lowLevelThreshold" 
                      min="5" 
                      max="30" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                  <div>
                    <label for="critical-level" class="block text-sm font-medium text-gray-700 mb-1">Critical Level Alert (%)</label>
                    <input 
                      type="number" 
                      id="critical-level" 
                      v-model="settings.criticalLevelThreshold" 
                      min="1" 
                      max="15" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                  <div>
                    <label for="alert-delay" class="block text-sm font-medium text-gray-700 mb-1">Alert Delay (minutes)</label>
                    <input 
                      type="number" 
                      id="alert-delay" 
                      v-model="settings.alertDelay" 
                      min="0" 
                      max="60" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                </div>
                
                <!-- Notification Schedule -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Notification Hours</label>
                  <div class="flex flex-wrap gap-2">
                    <button 
                      v-for="hour in hours" 
                      :key="hour.value" 
                      @click="toggleNotificationHour(hour.value)"
                      class="px-3 py-1 text-sm rounded-md"
                      :class="{
                        'bg-blue-100 text-blue-800': settings.notificationHours.includes(hour.value),
                        'bg-gray-100 text-gray-800': !settings.notificationHours.includes(hour.value)
                      }"
                    >
                      {{ hour.label }}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Tank Configuration -->
          <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
            <div class="px-6 py-4 border-b border-gray-200">
              <h2 class="text-lg font-medium text-gray-900 flex items-center">
                <svg class="h-5 w-5 text-blue-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                </svg>
                Tank Configuration
              </h2>
            </div>
            <div class="p-6">
              <div class="space-y-6">
                <!-- Tank Details -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label for="tank-type" class="block text-sm font-medium text-gray-700 mb-1">Tank Type</label>
                    <select 
                      id="tank-type" 
                      v-model="settings.tankType" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option>Propane</option>
                      <option>Butane</option>
                      <option>Natural Gas</option>
                      <option>Other</option>
                    </select>
                  </div>
                  <div>
                    <label for="tank-capacity" class="block text-sm font-medium text-gray-700 mb-1">Tank Capacity (liters)</label>
                    <input 
                      type="number" 
                      id="tank-capacity" 
                      v-model="settings.tankCapacity" 
                      min="10" 
                      max="1000" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                </div>
                
                <!-- Safety Thresholds -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label for="min-pressure" class="block text-sm font-medium text-gray-700 mb-1">Minimum Pressure (psi)</label>
                    <input 
                      type="number" 
                      id="min-pressure" 
                      v-model="settings.minPressure" 
                      min="50" 
                      max="120" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                  <div>
                    <label for="max-pressure" class="block text-sm font-medium text-gray-700 mb-1">Maximum Pressure (psi)</label>
                    <input 
                      type="number" 
                      id="max-pressure" 
                      v-model="settings.maxPressure" 
                      min="130" 
                      max="200" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                  <div>
                    <label for="min-temp" class="block text-sm font-medium text-gray-700 mb-1">Minimum Temperature (°C)</label>
                    <input 
                      type="number" 
                      id="min-temp" 
                      v-model="settings.minTemperature" 
                      min="-20" 
                      max="10" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                  <div>
                    <label for="max-temp" class="block text-sm font-medium text-gray-700 mb-1">Maximum Temperature (°C)</label>
                    <input 
                      type="number" 
                      id="max-temp" 
                      v-model="settings.maxTemperature" 
                      min="30" 
                      max="60" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                    >
                  </div>
                </div>
                
                <!-- Tank Location -->
                <div>
                  <label for="tank-location" class="block text-sm font-medium text-gray-700 mb-1">Tank Location</label>
                  <textarea 
                    id="tank-location" 
                    v-model="settings.tankLocation" 
                    rows="2" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  ></textarea>
                </div>
              </div>
            </div>
          </div>
  
          <!-- User Preferences -->
          <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
            <div class="px-6 py-4 border-b border-gray-200">
              <h2 class="text-lg font-medium text-gray-900 flex items-center">
                <svg class="h-5 w-5 text-purple-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
                User Preferences
              </h2>
            </div>
            <div class="p-6">
              <div class="space-y-6">
                <!-- Theme Preference -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Theme Preference</label>
                  <div class="flex space-x-4">
                    <button 
                      @click="settings.theme = 'light'"
                      class="px-4 py-2 border rounded-md flex items-center"
                      :class="{
                        'border-blue-500 bg-blue-50': settings.theme === 'light',
                        'border-gray-300': settings.theme !== 'light'
                      }"
                    >
                      <svg class="h-5 w-5 mr-2 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
                      </svg>
                      Light
                    </button>
                    <button 
                      @click="settings.theme = 'dark'"
                      class="px-4 py-2 border rounded-md flex items-center"
                      :class="{
                        'border-blue-500 bg-blue-50': settings.theme === 'dark',
                        'border-gray-300': settings.theme !== 'dark'
                      }"
                    >
                      <svg class="h-5 w-5 mr-2 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
                      </svg>
                      Dark
                    </button>
                    <button 
                      @click="settings.theme = 'system'"
                      class="px-4 py-2 border rounded-md flex items-center"
                      :class="{
                        'border-blue-500 bg-blue-50': settings.theme === 'system',
                        'border-gray-300': settings.theme !== 'system'
                      }"
                    >
                      <svg class="h-5 w-5 mr-2 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                      </svg>
                      System
                    </button>
                  </div>
                </div>
                
                <!-- Data Refresh Rate -->
                <div>
                  <label for="refresh-rate" class="block text-sm font-medium text-gray-700 mb-1">Data Refresh Rate</label>
                  <select 
                    id="refresh-rate" 
                    v-model="settings.refreshRate" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="30">30 seconds</option>
                    <option value="60">1 minute</option>
                    <option value="300">5 minutes</option>
                    <option value="600">10 minutes</option>
                  </select>
                </div>
                
                <!-- Default Dashboard View -->
                <div>
                  <label for="default-view" class="block text-sm font-medium text-gray-700 mb-1">Default Dashboard View</label>
                  <select 
                    id="default-view" 
                    v-model="settings.defaultView" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="overview">Overview</option>
                    <option value="detailed">Detailed</option>
                    <option value="analytics">Analytics</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Danger Zone -->
          <div class="bg-white shadow rounded-lg overflow-hidden border border-red-200">
            <div class="px-6 py-4 border-b border-red-200 bg-red-50">
              <h2 class="text-lg font-medium text-red-800 flex items-center">
                <svg class="h-5 w-5 text-red-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                Danger Zone
              </h2>
            </div>
            <div class="p-6">
              <div class="space-y-4">
                <!-- Reset Settings -->
                <div class="flex items-center justify-between">
                  <div>
                    <h3 class="text-sm font-medium text-gray-900">Reset to Default Settings</h3>
                    <p class="text-sm text-gray-500">Reset all settings to their original default values</p>
                  </div>
                  <button 
                    @click="confirmReset = true"
                    class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                  >
                    Reset
                  </button>
                </div>
                
                <!-- Delete Account -->
                <div class="flex items-center justify-between">
                  <div>
                    <h3 class="text-sm font-medium text-gray-900">Delete Account</h3>
                    <p class="text-sm text-gray-500">Permanently delete your account and all associated data</p>
                  </div>
                  <button 
                    @click="confirmDelete = true"
                    class="px-4 py-2 border border-transparent rounded-md text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
  
          <!-- Save Button -->
          <div class="mt-6 flex justify-end">
            <button 
              @click="saveSettings"
              class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Save Changes
            </button>
          </div>
        </div>
  
        <!-- Reset Confirmation Modal -->
        <div v-if="confirmReset" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Reset Settings</h3>
            </div>
            <div class="p-6">
              <p class="text-gray-700 mb-4">Are you sure you want to reset all settings to their default values? This action cannot be undone.</p>
              <div class="flex justify-end space-x-3">
                <button 
                  @click="confirmReset = false"
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Cancel
                </button>
                <button 
                  @click="resetSettings"
                  class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Reset Settings
                </button>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Delete Confirmation Modal -->
        <div v-if="confirmDelete" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Delete Account</h3>
            </div>
            <div class="p-6">
              <p class="text-gray-700 mb-4">This will permanently delete your account and all associated data. This action cannot be undone.</p>
              <div class="mb-4">
                <label for="confirm-delete" class="block text-sm font-medium text-gray-700 mb-1">Type "DELETE" to confirm</label>
                <input 
                  type="text" 
                  id="confirm-delete" 
                  v-model="deleteConfirmation" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-red-500 focus:border-red-500"
                >
              </div>
              <div class="flex justify-end space-x-3">
                <button 
                  @click="confirmDelete = false"
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Cancel
                </button>
                <button 
                  @click="deleteAccount"
                  :disabled="deleteConfirmation !== 'DELETE'"
                  :class="{
                    'bg-red-600 hover:bg-red-700': deleteConfirmation === 'DELETE',
                    'bg-red-400 cursor-not-allowed': deleteConfirmation !== 'DELETE'
                  }"
                  class="px-4 py-2 text-sm font-medium text-white border border-transparent rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Delete Account
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  </template>
  
  <script>
  import { useTheme } from '../../composables/useTheme';
  
  export default {
    setup() {
      // Theme composable
      const { isDark, toggleTheme, themeClasses } = useTheme();
      
      return {
        isDark,
        toggleTheme,
        themeClasses
      };
    },
    name: 'SettingsView',
    emits: ['toggle-sidebar'],
    data() {
      return {
        saved: false,
        confirmReset: false,
        confirmDelete: false,
        deleteConfirmation: '',
        hours: [
          { value: 0, label: '12 AM' },
          { value: 1, label: '1 AM' },
          { value: 2, label: '2 AM' },
          { value: 3, label: '3 AM' },
          { value: 4, label: '4 AM' },
          { value: 5, label: '5 AM' },
          { value: 6, label: '6 AM' },
          { value: 7, label: '7 AM' },
          { value: 8, label: '8 AM' },
          { value: 9, label: '9 AM' },
          { value: 10, label: '10 AM' },
          { value: 11, label: '11 AM' },
          { value: 12, label: '12 PM' },
          { value: 13, label: '1 PM' },
          { value: 14, label: '2 PM' },
          { value: 15, label: '3 PM' },
          { value: 16, label: '4 PM' },
          { value: 17, label: '5 PM' },
          { value: 18, label: '6 PM' },
          { value: 19, label: '7 PM' },
          { value: 20, label: '8 PM' },
          { value: 21, label: '9 PM' },
          { value: 22, label: '10 PM' },
          { value: 23, label: '11 PM' }
        ],
        settings: {
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
          tankLocation: 'Backyard, near the patio',
          theme: 'system',
          refreshRate: '60',
          defaultView: 'overview'
        }
      }
    },
    methods: {
      toggleNotificationHour(hour) {
        const index = this.settings.notificationHours.indexOf(hour);
        if (index === -1) {
          this.settings.notificationHours.push(hour);
        } else {
          this.settings.notificationHours.splice(index, 1);
        }
        // Sort the hours for display
        this.settings.notificationHours.sort((a, b) => a - b);
      },
      saveSettings() {
        // In a real app, this would save to your backend
        console.log('Settings saved:', this.settings);
        this.saved = true;
        setTimeout(() => {
          this.saved = false;
        }, 3000);
      },
      resetSettings() {
        // Reset to default values
        this.settings = {
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
          tankLocation: 'Backyard, near the patio',
          theme: 'system',
          refreshRate: '60',
          defaultView: 'overview'
        };
        this.confirmReset = false;
        this.saved = true;
        setTimeout(() => {
          this.saved = false;
        }, 3000);
      },
      deleteAccount() {
        if (this.deleteConfirmation === 'DELETE') {
          // In a real app, this would delete the account
          console.log('Account deleted');
          this.confirmDelete = false;
          this.$router.push('/login');
        }
      }
    }
  }
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
  
  /* Smooth transitions for buttons */
  button {
    transition: all 0.2s ease;
  }
  
  /* Checkbox styling */
  input[type="checkbox"]:checked {
    background-image: url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M5.707 7.293a1 1 0 0 0-1.414 1.414l2 2a1 1 0 0 0 1.414 0l4-4a1 1 0 0 0-1.414-1.414L7 8.586 5.707 7.293z'/%3e%3c/svg%3e");
    background-color: currentColor;
    background-size: 100% 100%;
    background-position: center;
    background-repeat: no-repeat;
  }
  </style>