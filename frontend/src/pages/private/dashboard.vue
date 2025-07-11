<template>
  <div class="flex-1 flex flex-col overflow-hidden bg-gray-50">
    <!-- Top Navigation -->
    <header class="bg-white shadow-sm z-10">
      <div class="flex items-center justify-between px-4 py-3 sm:px-6">
        <!-- Mobile menu button -->
        <button 
          @click="emit('toggle-sidebar')"
          class="md:hidden text-gray-500 hover:text-gray-600 focus:outline-none"
        >
          <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </button>
        
        <!-- Dashboard Title -->
        <h1 class="text-xl font-semibold text-gray-800">Home Gas Tank Monitor</h1>
        
        <!-- Last Updated -->
        <div class="text-sm text-gray-500">
          Last updated: {{ formatTime(lastUpdated) }}
          <button @click="refreshData" class="ml-2 text-blue-500 hover:text-blue-700">
            <svg class="h-4 w-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Dashboard Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <!-- Critical Alert Banner -->
      <div v-if="alert" class="mb-6">
        <div :class="`bg-${alert.type}-50 border-l-4 border-${alert.type}-500 p-4 rounded-r-lg`">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5" :class="`text-${alert.type}-500`" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
              </svg>
            </div>
            <div class="ml-3">
              <h3 :class="`text-sm font-medium text-${alert.type}-800`">{{ alert.title }}</h3>
              <div :class="`mt-2 text-sm text-${alert.type}-700`">
                {{ alert.message }}
                <button v-if="alert.action" @click="alert.action.callback" class="ml-2 px-2 py-1 text-xs rounded" :class="`bg-${alert.type}-100 text-${alert.type}-800 hover:bg-${alert.type}-200`">
                  {{ alert.action.text }}
                </button>
              </div>
            </div>
            <button @click="dismissAlert" class="ml-auto text-gray-400 hover:text-gray-500">
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Tank Status Overview -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <!-- Tank Level -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h3 class="text-lg font-medium text-gray-900">Gas Level</h3>
            <span class="text-xs px-2 py-1 rounded-full" :class="levelStatusClass">{{ levelStatusText }}</span>
          </div>
          <div class="px-6 py-8 text-center">
            <div class="relative h-48 mx-auto" style="max-width: 200px">
              <!-- Tank visualization -->
              <div class="absolute bottom-0 left-0 right-0 bg-gray-200 rounded-t-lg" style="height: 100%">
                <div 
                  class="absolute bottom-0 left-0 right-0 rounded-t-lg transition-all duration-500"
                  :class="levelColorClass"
                  :style="`height: ${tank.level}%`"
                ></div>
              </div>
              <!-- Measurement markers -->
              <div class="absolute left-0 right-0 border-t border-gray-300" style="top: 25%"></div>
              <div class="absolute left-0 right-0 border-t border-gray-300" style="top: 50%"></div>
              <div class="absolute left-0 right-0 border-t border-gray-300" style="top: 75%"></div>
              <!-- Current level indicator -->
              <div class="absolute left-0 right-0 text-xs font-medium" 
                   :style="`bottom: ${tank.level}%; margin-bottom: -10px`"
                   :class="levelTextColorClass">
                {{ tank.level }}%
              </div>
            </div>
            <div class="mt-4">
              <p class="text-3xl font-bold" :class="levelTextColorClass">{{ tank.level }}%</p>
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
            <button @click="showRefillModal = true" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md text-sm font-medium transition-colors">
              Schedule Refill
            </button>
          </div>
        </div>

        <!-- Usage Statistics -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Usage Statistics</h3>
          </div>
          <div class="p-6">
            <div class="space-y-4">
              <div>
                <p class="text-sm text-gray-500">Daily Usage</p>
                <p class="text-xl font-semibold">{{ dailyUsage }} kg/day</p>
                <div class="w-full bg-gray-200 rounded-full h-2.5 mt-2">
                  <div class="bg-blue-600 h-2.5 rounded-full" :style="`width: ${Math.min(dailyUsage / tank.capacity * 100, 100)}%`"></div>
                </div>
              </div>
              
              <div>
                <p class="text-sm text-gray-500">Last Refill</p>
                <p class="text-xl font-semibold">{{ daysSinceRefill }} days ago</p>
                <p class="text-xs text-gray-400">{{ formatDate(tank.lastRefill) }}</p>
              </div>
              
              <div>
                <p class="text-sm text-gray-500">Estimated Refill Date</p>
                <p class="text-xl font-semibold">{{ estimatedRefillDate }}</p>
                <p class="text-xs" :class="refillUrgencyClass">
                  {{ refillUrgencyText }}
                </p>
              </div>
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50">
            <button @click="showUsageHistory = true" class="text-sm text-blue-600 hover:text-blue-500">
              View Detailed Usage History
            </button>
          </div>
        </div>
      </div>

      <!-- AI Prediction Section -->
      <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
        <div class="px-6 py-4 border-b border-gray-200">
          <h3 class="text-lg font-medium text-gray-900">AI Consumption Prediction</h3>
        </div>
        <div class="p-6">
          <div v-if="isPredicting" class="flex flex-col items-center justify-center py-8">
            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500 mb-4"></div>
            <p class="text-gray-500 text-center">
              Analyzing usage patterns...<br>
              AI predictions may take some time
            </p>
          </div>
          
          <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="bg-blue-50 p-4 rounded-lg">
              <p class="text-sm text-blue-800">Predicted Days Remaining</p>
              <p class="text-2xl font-bold text-blue-600">{{ prediction.days_remaining }}</p>
              <p class="text-xs text-blue-500 mt-1">Based on current usage</p>
            </div>
            
            <div class="bg-purple-50 p-4 rounded-lg">
              <p class="text-sm text-purple-800">Prediction Confidence</p>
              <p class="text-2xl font-bold text-purple-600">{{ (prediction.confidence * 100).toFixed(0) }}%</p>
              <p class="text-xs text-purple-500 mt-1">Accuracy of forecast</p>
            </div>
            
            <div class="bg-green-50 p-4 rounded-lg">
              <p class="text-sm text-green-800">Consumption Trend</p>
              <p class="text-2xl font-bold text-green-600 capitalize">{{ prediction.trend }}</p>
              <p class="text-xs text-green-500 mt-1">Compared to last week</p>
            </div>
            
            <div class="md:col-span-3 bg-gray-50 p-4 rounded-lg mt-2">
              <p class="text-sm text-gray-800 font-medium">AI Recommendation</p>
              <p class="text-gray-700 mt-1">{{ prediction.recommendation }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Consumption Charts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <!-- Level Trend Chart -->
        <div class="bg-white shadow rounded-lg p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Gas Level Trend (Last 7 Days)</h3>
            <div class="flex space-x-2">
              <button @click="chartRange = 'week'" :class="`px-3 py-1 text-sm rounded-md ${chartRange === 'week' ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'}`">
                Week
              </button>
              <button @click="chartRange = 'month'" :class="`px-3 py-1 text-sm rounded-md ${chartRange === 'month' ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'}`">
                Month
              </button>
              <button @click="chartRange = 'year'" :class="`px-3 py-1 text-sm rounded-md ${chartRange === 'year' ? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'}`">
                Year
              </button>
            </div>
          </div>
          <div class="h-64">
            <canvas id="levelChart"></canvas>
          </div>
        </div>

        <!-- Daily Consumption Chart -->
        <div class="bg-white shadow rounded-lg p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">Daily Consumption (Last 7 Days)</h3>
            <div class="text-sm text-gray-500">
              Total: {{ totalConsumption.toFixed(2) }} kg
            </div>
          </div>
          <div class="h-64">
            <canvas id="consumptionChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <button @click="showRefillModal = true" class="p-4 bg-white rounded-lg shadow flex flex-col items-center hover:bg-gray-50 transition-colors">
          <svg class="h-6 w-6 text-blue-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
          </svg>
          <span class="text-sm font-medium">Order Refill</span>
        </button>
        <button @click="showTankDetails = true" class="p-4 bg-white rounded-lg shadow flex flex-col items-center hover:bg-gray-50 transition-colors">
          <svg class="h-6 w-6 text-green-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
          </svg>
          <span class="text-sm font-medium">Tank Details</span>
        </button>
        <button @click="showAlertsSettings = true" class="p-4 bg-white rounded-lg shadow flex flex-col items-center hover:bg-gray-50 transition-colors">
          <svg class="h-6 w-6 text-yellow-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
          </svg>
          <span class="text-sm font-medium">Alert Settings</span>
        </button>
        <button @click="showSettingsModal = true" class="p-4 bg-white rounded-lg shadow flex flex-col items-center hover:bg-gray-50 transition-colors">
          <svg class="h-6 w-6 text-purple-500 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          <span class="text-sm font-medium">Settings</span>
        </button>
      </div>

      <!-- Refill Modal -->
      <div v-if="showRefillModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Schedule Gas Refill</h3>
          </div>
          <div class="p-6">
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Delivery Date</label>
              <input type="date" v-model="refillDate" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Delivery Time</label>
              <select v-model="refillTime" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                <option>Morning (8am-12pm)</option>
                <option>Afternoon (12pm-4pm)</option>
                <option>Evening (4pm-8pm)</option>
              </select>
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Quantity (kg)</label>
              <input type="number" v-model="refillQuantity" min="10" max="100" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
            <button @click="showRefillModal = false" class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
              Cancel
            </button>
            <button @click="scheduleRefill" class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
              Schedule Refill
            </button>
          </div>
        </div>
      </div>

      <!-- Settings Modal -->
      <div v-if="showSettingsModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-medium text-gray-900">Safety Thresholds</h3>
          </div>
          <div class="p-6">
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Low Level Alert (%)</label>
              <input type="number" v-model="alertThresholds.lowLevel" min="5" max="30" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
            </div>
            <div class="mb-4">
              <label class="block text-sm font-medium text-gray-700 mb-1">Critical Level Alert (%)</label>
              <input type="number" v-model="alertThresholds.criticalLevel" min="1" max="15" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
            </div>
          </div>
          <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-end">
            <button @click="showSettingsModal = false" class="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
              Cancel
            </button>
            <button @click="saveSettings" class="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
              Save Settings
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import api from '../public/api'
import Chart from 'chart.js/auto'
import { onUnmounted } from 'vue'

const emit = defineEmits(['toggle-sidebar'])

// Reactive state
const lastUpdated = ref(new Date())
const showRefillModal = ref(false)
const showSettingsModal = ref(false)
const showTankDetails = ref(false)
const showUsageHistory = ref(false)
const showAlertsSettings = ref(false)
const chartRange = ref('week')
const refillDate = ref('')
const refillTime = ref('Morning (8am-12pm)')
const refillQuantity = ref(50)
const alert = ref(null)
const usageHistory = ref([])
const levelChartInstance = ref(null)
const consumptionChartInstance = ref(null)
const isPredicting = ref(false)

// Tank data
const tank = ref({
  level: 0,
  lastRefill: '2025-06-01',
  capacity: 20,
  type: 'Propane',
  serialNumber: 'HTK-2025-0425',
  installationDate: '2025-04-25'
})

// Alert thresholds
const alertThresholds = ref({
  lowLevel: 20,
  criticalLevel: 10
})

// Prediction data
const prediction = ref({
  days_remaining: 0,
  confidence: 0,
  trend: 'stable',
  recommendation: ''
})

// Computed properties
const levelColorClass = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'bg-red-500'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'bg-yellow-500'
  return 'bg-green-500'
})

const levelTextColorClass = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'text-red-500'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'text-yellow-500'
  return 'text-green-500'
})

const levelStatusClass = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'bg-red-100 text-red-800'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'bg-yellow-100 text-yellow-800'
  return 'bg-green-100 text-green-800'
})

const levelStatusText = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'CRITICAL'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'LOW'
  return 'NORMAL'
})

const dailyUsage = computed(() => {
  if (usageHistory.value.length < 2) return 0
  // Sort by date (oldest first)
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  const totalConsumption = sortedHistory[0].consumption_kg - sortedHistory[sortedHistory.length - 1].consumption_kg
  const totalDays = (new Date(sortedHistory[sortedHistory.length - 1].date) - new Date(sortedHistory[0].date)) / (1000 * 60 * 60 * 24)
  return totalDays > 0 ? (totalConsumption / totalDays).toFixed(2) : 0
})

const daysSinceRefill = computed(() => {
  const diff = new Date() - new Date(tank.value.lastRefill)
  return Math.floor(diff / (1000 * 60 * 60 * 24))
})

const estimatedRemaining = computed(() => {
  return Math.floor(prediction.value.days_remaining)
})

const estimatedRefillDate = computed(() => {
  const daysToRefill = Math.floor(prediction.value.days_remaining)
  const date = new Date()
  date.setDate(date.getDate() + daysToRefill)
  return date.toLocaleDateString()
})

const refillUrgencyClass = computed(() => {
  const daysToEmpty = prediction.value.days_remaining
  if (daysToEmpty < 3) return 'text-red-500'
  if (daysToEmpty < 7) return 'text-yellow-500'
  return 'text-green-500'
})

const refillUrgencyText = computed(() => {
  const daysToEmpty = prediction.value.days_remaining
  if (daysToEmpty < 3) return 'Refill urgently needed'
  if (daysToEmpty < 7) return 'Schedule refill soon'
  return 'Adequate supply'
})

const totalConsumption = computed(() => {
  if (usageHistory.value.length < 2) return 0
  // Sort by date (oldest first)
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  let total = 0
  for (let i = 1; i < sortedHistory.length; i++) {
    const diff = sortedHistory[i-1].consumption_kg - sortedHistory[i].consumption_kg
    if (diff > 0) {
      total += diff
    }
  }
  return total
})

const dailyConsumptionData = computed(() => {
  if (usageHistory.value.length < 2) return []
  
  // Sort by date (oldest first)
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  
  const data = []
  for (let i = 1; i < sortedHistory.length; i++) {
    // Calculate positive consumption (previous - current)
    const diff = sortedHistory[i-1].consumption_kg - sortedHistory[i].consumption_kg
    if (diff > 0) { // Only include positive consumption
      data.push({
        date: sortedHistory[i].date,
        consumption: diff.toFixed(2),
        is_weekend: sortedHistory[i].is_weekend
      })
    }
  }
  return data
})

// Methods
const formatTime = (date) => {
  return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const formatDate = (dateStr) => {
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateStr).toLocaleDateString(undefined, options)
}

const getNextAvailableDate = () => {
  const date = new Date()
  date.setDate(date.getDate() + 2)
  return date.toISOString().split('T')[0]
}

const dismissAlert = () => {
  alert.value = null
}

const refreshData = () => {
  lastUpdated.value = new Date()
  fetchGasReadings()
}

const updateTankData = () => {
  lastUpdated.value = new Date()
  fetchGasReadings()
  checkForAlerts()
}

const scheduleRefill = () => {
  alert(`Refill scheduled for ${refillDate.value} (${refillTime.value}) - ${refillQuantity.value} kg`)
  showRefillModal.value = false
  tank.value.lastRefill = new Date().toISOString().split('T')[0]
}

const saveSettings = () => {
  showSettingsModal.value = false
  checkForAlerts()
}

const checkForAlerts = () => {
  alert.value = null
  
  if (tank.value.level < alertThresholds.value.criticalLevel) {
    alert.value = {
      type: 'red',
      title: 'CRITICAL GAS LEVEL',
      message: `Your gas tank is critically low (${tank.value.level}%). Order an emergency refill immediately.`,
      action: {
        text: 'Order Now',
        callback: () => {
          showRefillModal.value = true
          alert.value = null
        }
      }
    }
    return
  }
  
  if (tank.value.level < alertThresholds.value.lowLevel) {
    alert.value = {
      type: 'yellow',
      title: 'LOW GAS LEVEL',
      message: `Your gas tank is getting low (${tank.value.level}%). Consider scheduling a refill soon.`,
      action: {
        text: 'Schedule Refill',
        callback: () => {
          showRefillModal.value = true
          alert.value = null
        }
      }
    }
  }
}

const fetchGasReadings = async () => {
  try {
    // Fetch sensor data
    const response = await api.get('sensors/', {
      headers: { Authorization: `Token ${localStorage.getItem('authToken')}` }
    })
    const sensors = response.data
    if (sensors.length > 0) {
      const latestReading = sensors[0].current_gas_level
      tank.value.level = (latestReading / tank.value.capacity * 100).toFixed(2)

      // Fetch usage history for chart and AI prediction (7 days)
      const endDate = new Date()
      const startDate = new Date()
      startDate.setDate(endDate.getDate() - 7)
      
      const readingsResponse = await api.get('/gas-readings/', {
        headers: { Authorization: `Token ${localStorage.getItem('authToken')}` },
        params: {
          start_date: startDate.toISOString().split('T')[0],
          end_date: endDate.toISOString().split('T')[0]
        }
      })
      
      usageHistory.value = readingsResponse.data.map(reading => ({
        date: reading.reading_timestamp.split('T')[0],
        level: (reading.remaining_gas / tank.value.capacity * 100).toFixed(2),
        consumption_kg: parseFloat(reading.remaining_gas),
        is_weekend: new Date(reading.reading_timestamp).getDay() === 0 || new Date(reading.reading_timestamp).getDay() === 6
      }))
      
      // Fetch AI prediction
      isPredicting.value = true
      const predictionResponse = await api.get('/gas/prediction/', {
        headers: { Authorization: `Token ${localStorage.getItem('authToken')}` }
      })
      
      if (predictionResponse.data.status_code === 200) {
        prediction.value = {
          days_remaining: predictionResponse.data.projected_days,
          confidence: predictionResponse.data.confidence,
          trend: predictionResponse.data.trend,
          recommendation: predictionResponse.data.recommendation
        }
      } else {
        prediction.value = {
          days_remaining: 0,
          confidence: 0,
          trend: 'unknown',
          recommendation: 'Prediction unavailable'
        }
      }

      // Update charts if they exist
      if (levelChartInstance.value && consumptionChartInstance.value) {
        updateCharts()
      } else {
        initializeCharts()
      }

      checkForAlerts()
    } else {
      alert.value = {
        type: 'red',
        title: 'NO SENSORS',
        message: 'No gas sensors found. Please configure a sensor to monitor gas levels.',
        action: null
      }
    }
  } catch (error) {
    console.error('Error fetching gas readings:', error)
    alert.value = {
      type: 'red',
      title: 'DATA FETCH ERROR',
      message: 'Failed to fetch gas readings. Please try again later.',
      action: {
        text: 'Retry',
        callback: () => fetchGasReadings()
      }
    }
  } finally {
    isPredicting.value = false
  }
}

const initializeCharts = () => {
  // Initialize Level Chart (Line Chart)
  const levelCtx = document.getElementById('levelChart').getContext('2d')
  levelChartInstance.value = new Chart(levelCtx, {
    type: 'line',
    data: {
      labels: usageHistory.value.map(item => item.date),
      datasets: [{
        label: 'Gas Level (%)',
        data: usageHistory.value.map(item => item.level),
        borderColor: 'rgb(59, 130, 246)',
        backgroundColor: 'rgba(59, 130, 246, 0.1)',
        tension: 0.3,
        fill: true,
        borderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          max: 100,
          title: { display: true, text: 'Gas Level (%)' }
        },
        x: {
          title: { display: true, text: 'Date' }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(context) {
              return `Level: ${context.parsed.y.toFixed(2)}%`
            }
          }
        }
      }
    }
  })

  // Initialize Consumption Chart (Bar Chart)
  const consumptionCtx = document.getElementById('consumptionChart').getContext('2d')
  consumptionChartInstance.value = new Chart(consumptionCtx, {
    type: 'bar',
    data: {
      labels: dailyConsumptionData.value.map(item => item.date),
      datasets: [{
        label: 'Daily Consumption (kg)',
        data: dailyConsumptionData.value.map(item => item.consumption),
        backgroundColor: dailyConsumptionData.value.map(item => 
          item.is_weekend ? 'rgba(234, 88, 12, 0.7)' : 'rgba(59, 130, 246, 0.7)'
        ),
        borderColor: dailyConsumptionData.value.map(item => 
          item.is_weekend ? 'rgba(234, 88, 12, 1)' : 'rgba(59, 130, 246, 1)'
        ),
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          title: { display: true, text: 'Consumption (kg)' },
          min: 0 // Ensure y-axis starts at 0
        },
        x: {
          title: { display: true, text: 'Date' }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(context) {
              return `Consumed: ${context.parsed.y} kg`
            },
            afterLabel: function(context) {
              const data = dailyConsumptionData.value[context.dataIndex]
              return data.is_weekend ? 'Weekend' : 'Weekday'
            }
          }
        },
        legend: {
          display: false
        }
      }
    }
  })
}

const updateCharts = () => {
  if (levelChartInstance.value) {
    levelChartInstance.value.data.labels = usageHistory.value.map(item => item.date)
    levelChartInstance.value.data.datasets[0].data = usageHistory.value.map(item => item.level)
    levelChartInstance.value.update()
  }

  if (consumptionChartInstance.value) {
    // Sort consumption data by date
    const sortedData = [...dailyConsumptionData.value].sort((a, b) => 
      new Date(a.date) - new Date(b.date))
    
    consumptionChartInstance.value.data.labels = sortedData.map(item => item.date)
    consumptionChartInstance.value.data.datasets[0].data = sortedData.map(item => item.consumption)
    consumptionChartInstance.value.data.datasets[0].backgroundColor = sortedData.map(item => 
      item.is_weekend ? 'rgba(234, 88, 12, 0.7)' : 'rgba(59, 130, 246, 0.7)'
    )
    consumptionChartInstance.value.data.datasets[0].borderColor = sortedData.map(item => 
      item.is_weekend ? 'rgba(234, 88, 12, 1)' : 'rgba(59, 130, 246, 1)'
    )
    consumptionChartInstance.value.update()
  }
}

// Lifecycle hooks
onMounted(async () => {
  refillDate.value = getNextAvailableDate()
  await fetchGasReadings()
  
  // Set up periodic data refresh (every 1 hour)
  const dataUpdateInterval = setInterval(updateTankData, 3600000)
  
  // Clean up interval when component is unmounted
  onUnmounted(() => {
    clearInterval(dataUpdateInterval)
    if (levelChartInstance.value) {
      levelChartInstance.value.destroy()
    }
    if (consumptionChartInstance.value) {
      consumptionChartInstance.value.destroy()
    }
  })
})

// Watch for chart range changes
watch(chartRange, (newRange) => {
  fetchGasReadings()
})
</script>

<style scoped>
.dropdown-enter-active, .dropdown-leave-active {
  transition: all 0.2s ease;
}
.dropdown-enter, .dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
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
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter, .modal-leave-to {
  opacity: 0;
}

/* Animation for the loading spinner */
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.animate-spin {
  animation: spin 1s linear infinite;
}
</style>