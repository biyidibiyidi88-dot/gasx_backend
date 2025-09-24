<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative']">
    <!-- Animated background elements -->
    <div class="absolute inset-0 overflow-hidden opacity-20">
      <div class="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-to-br from-blue-400 to-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color"></div>
      <div class="absolute -bottom-1/2 -left-1/2 w-full h-full bg-gradient-to-tr from-cyan-400 to-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color animation-delay-2000"></div>
    </div>
    <!-- Top Navigation -->
    <header :class="[themeClasses.bg.secondary, themeClasses.shadow, 'z-10 animate-pulse-header']">
      <div class="flex items-center justify-between px-4 py-3 sm:px-6">
        <!-- Dashboard Title -->
        <h1 :class="[themeClasses.text.heading, 'text-lg sm:text-xl font-semibold truncate flex-1 mx-2 md:mx-0 md:flex-none animate-fade-in']">Home Gas Tank Monitor</h1>
        
        <!-- Theme Toggle & Last Updated -->
        <div class="flex items-center space-x-2 sm:space-x-4">
          <!-- Last Updated -->
          <div :class="[themeClasses.text.caption, 'text-xs sm:text-sm hidden sm:block']">
            Last updated: {{ formatTime(lastUpdated) }}
            <button @click="refreshData" :class="[themeClasses.text.accent, 'ml-2 hover:text-blue-700 animate-hover-glow']">
              <svg class="h-3 w-3 sm:h-4 sm:w-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
            </button>
          </div>
          
          <!-- Mobile refresh button -->
          <button @click="refreshData" :class="[themeClasses.text.accent, 'p-2 rounded-lg hover:text-blue-700 sm:hidden animate-hover-scale']">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Dashboard Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-6">
      <!-- Critical Alert Banner with animation -->
      <transition 
        enter-active-class="transform transition-all duration-300 ease-out"
        enter-from-class="opacity-0 -translate-y-4"
        enter-to-class="opacity-100 translate-y-0"
        leave-active-class="transform transition-all duration-200 ease-in"
        leave-from-class="opacity-100 translate-y-0"
        leave-to-class="opacity-0 -translate-y-4"
      >
        <div v-if="alert" class="mb-6">
          <div :class="[getAlertClasses(alert.type), 'border-l-4 p-4 rounded-r-lg animate-pulse-alert']">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5" :class="getAlertIconClasses(alert.type)" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
              </div>
              <div class="ml-3 flex-1">
                <h3 :class="[getAlertTextClasses(alert.type), 'text-sm font-medium']">{{ alert.title }}</h3>
                <div :class="[getAlertTextClasses(alert.type), 'mt-2 text-sm break-words']">
                  {{ alert.message }}
                  <button v-if="alert.action" @click="alert.action.callback" :class="[getAlertButtonClasses(alert.type), 'ml-2 px-2 py-1 text-xs rounded animate-hover-scale']">
                    {{ alert.action.text }}
                  </button>
                </div>
              </div>
              <button @click="dismissAlert" :class="[themeClasses.text.muted, 'ml-4 flex-shrink-0 hover:text-gray-600 animate-hover-scale']">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </transition>

      <!-- Tank Status Overview -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6 mb-6">
        <!-- Tank Level with pulse animation -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden animate-pulse-card']">
          <div :class="[themeClasses.border.primary, 'px-4 sm:px-6 py-3 sm:py-4 border-b flex justify-between items-center bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
            <h3 :class="[themeClasses.text.heading, 'text-base sm:text-lg font-medium']">Gas Level</h3>
            <span class="text-xs px-2 py-1 rounded-full" :class="levelStatusClass">{{ levelStatusText }}</span>
          </div>
          <div class="px-4 sm:px-6 py-6 sm:py-8 text-center">
            <div class="relative h-32 sm:h-48 mx-auto" style="max-width: 200px">
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
              <p class="text-3xl font-bold animate-pulse-level" :class="levelTextColorClass">{{ tank.level }}%</p>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 bg-gray-50">
            <button @click="showRefillModal = true" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md text-sm font-medium transition-colors animate-hover-glow">Schedule Refill</button>
          </div>
        </div>

        <!-- Usage Statistics with hover effect -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden animate-pulse-card animation-delay-200']">
          <div :class="[themeClasses.border.primary, 'px-4 sm:px-6 py-3 sm:py-4 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
            <h3 :class="[themeClasses.text.heading, 'text-base sm:text-lg font-medium']">Tank Information</h3>
          </div>
          <div class="p-4 sm:p-6">
            <div class="space-y-4">
              <div>
                <p :class="[themeClasses.text.secondary, 'text-sm']">Daily Usage</p>
                <p class="text-xl font-semibold" :class="themeClasses.text.primary">{{ dailyUsage }} kg/day</p>
                <div class="w-full bg-gray-200 rounded-full h-2.5 mt-2">
                  <div class="bg-blue-600 h-2.5 rounded-full transition-all duration-500" :style="`width: ${Math.min(dailyUsage / tank.capacity * 100, 100)}%`"></div>
                </div>
              </div>
              
              <div>
                <p :class="[themeClasses.text.secondary, 'text-sm']">Last Refill</p>
                <p class="text-xl font-semibold" :class="themeClasses.text.primary">{{ daysSinceRefill }} days ago</p>
                <p :class="[themeClasses.text.muted, 'text-xs']">{{ formatDate(tank.lastRefill) }}</p>
              </div>
              
              <div>
                <p :class="[themeClasses.text.secondary, 'text-sm']">Estimated Refill Date</p>
                <p class="text-xl font-semibold" :class="themeClasses.text.primary">{{ estimatedRefillDate }}</p>
                <p class="text-xs" :class="refillUrgencyClass">
                  {{ refillUrgencyText }}
                </p>
              </div>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 bg-gray-50">
            <button @click="showUsageHistory = true" :class="[themeClasses.text.accent, 'text-sm hover:text-blue-500 animate-hover-scale']">
              View Detailed Usage History
            </button>
          </div>
        </div>
      </div>

      <!-- AI Prediction Section with gradient animation -->
      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden mb-6 relative animate-pulse-card']">
        <div class="absolute inset-0 bg-gradient-to-r from-blue-500/5 via-purple-500/5 to-cyan-500/5 animate-gradient-shift"></div>
        <div :class="[themeClasses.border.primary, 'px-4 sm:px-6 py-3 sm:py-4 border-b relative']">
          <h3 :class="[themeClasses.text.heading, 'text-base sm:text-lg font-medium']">AI Consumption Prediction</h3>
        </div>
        <div class="p-4 sm:p-6 relative">
          <div v-if="isPredicting" class="flex flex-col items-center justify-center py-8">
            <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500 mb-4"></div>
            <p :class="[themeClasses.text.secondary, 'text-center']">
              Analyzing usage patterns...<br>
              AI predictions may take some time
            </p>
          </div>
          
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4 relative">
            <div :class="[isDark ? 'bg-blue-900/30' : 'bg-blue-50', 'p-3 sm:p-4 rounded-lg animate-pulse-prediction']">
              <p :class="[isDark ? 'text-blue-300' : 'text-blue-800', 'text-xs sm:text-sm']">Predicted Days Remaining</p>
              <p :class="[isDark ? 'text-blue-400' : 'text-blue-600', 'text-xl sm:text-2xl font-bold']">{{ prediction.days_remaining }}</p>
              <p :class="[isDark ? 'text-blue-400' : 'text-blue-500', 'text-xs mt-1']">Based on current usage</p>
            </div>
            
            <div :class="[isDark ? 'bg-purple-900/30' : 'bg-purple-50', 'p-3 sm:p-4 rounded-lg animate-pulse-prediction']">
              <p :class="[isDark ? 'text-purple-300' : 'text-purple-800', 'text-xs sm:text-sm']">Prediction Confidence</p>
              <p :class="[isDark ? 'text-purple-400' : 'text-purple-600', 'text-xl sm:text-2xl font-bold']">{{ (prediction.confidence * 100).toFixed(0) }}%</p>
              <p :class="[isDark ? 'text-purple-400' : 'text-purple-500', 'text-xs mt-1']">Accuracy of forecast</p>
            </div>
            
            <div :class="[isDark ? 'bg-green-900/30' : 'bg-green-50', 'p-3 sm:p-4 rounded-lg sm:col-span-2 lg:col-span-1 animate-pulse-prediction']">
              <p :class="[isDark ? 'text-green-300' : 'text-green-800', 'text-xs sm:text-sm']">Consumption Trend</p>
              <p :class="[isDark ? 'text-green-400' : 'text-green-600', 'text-xl sm:text-2xl font-bold capitalize']">{{ prediction.trend }}</p>
              <p :class="[isDark ? 'text-green-400' : 'text-green-500', 'text-xs mt-1']">Compared to last week</p>
            </div>
            
            <div :class="[themeClasses.bg.tertiary, 'sm:col-span-2 lg:col-span-3 p-3 sm:p-4 rounded-lg mt-2']">
              <p :class="[themeClasses.text.primary, 'text-xs sm:text-sm font-medium']">AI Recommendation</p>
              <p :class="[themeClasses.text.secondary, 'mt-1 text-xs sm:text-sm break-words']">{{ prediction.recommendation }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Consumption Charts -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-4 sm:gap-6 mb-6">
        <!-- Level Trend Chart -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg p-4 sm:p-6 animate-pulse-card']">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-4 space-y-2 sm:space-y-0">
            <h3 :class="[themeClasses.text.primary, 'text-base sm:text-lg font-medium']">Gas Level Trend</h3>
            <div class="flex space-x-1 sm:space-x-2">
              <button @click="chartRange = 'week'" :class="[chartRange === 'week' ? (isDark ? 'bg-blue-900 text-blue-300' : 'bg-blue-100 text-blue-800') : (isDark ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-800'), 'px-2 sm:px-3 py-1 text-xs sm:text-sm rounded-md animate-hover-scale']">
                Week
              </button>
              <button @click="chartRange = 'month'" :class="[chartRange === 'month' ? (isDark ? 'bg-blue-900 text-blue-300' : 'bg-blue-100 text-blue-800') : (isDark ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-800'), 'px-2 sm:px-3 py-1 text-xs sm:text-sm rounded-md animate-hover-scale']">
                Month
              </button>
              <button @click="chartRange = 'year'" :class="[chartRange === 'year' ? (isDark ? 'bg-blue-900 text-blue-300' : 'bg-blue-100 text-blue-800') : (isDark ? 'bg-gray-700 text-gray-300' : 'bg-gray-100 text-gray-800'), 'px-2 sm:px-3 py-1 text-xs sm:text-sm rounded-md animate-hover-scale']">
                Year
              </button>
            </div>
          </div>
          <div class="h-48 sm:h-64 overflow-hidden">
            <canvas id="levelChart"></canvas>
          </div>
        </div>

        <!-- Daily Consumption Chart -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg p-4 sm:p-6 animate-pulse-card']">
          <div class="flex flex-col sm:flex-row sm:items-center justify-between mb-4 space-y-2 sm:space-y-0">
            <h3 :class="[themeClasses.text.primary, 'text-base sm:text-lg font-medium']">Daily Consumption</h3>
            <div :class="[themeClasses.text.secondary, 'text-xs sm:text-sm']">
              Total: {{ totalConsumption.toFixed(2) }} kg
            </div>
          </div>
          <div class="h-48 sm:h-64 overflow-hidden">
            <canvas id="consumptionChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Quick Actions with hover effects -->
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
        <transition-group
          appear
          @before-enter="beforeEnter"
          @enter="enter"
          :css="false"
        >
          <button 
            v-for="(action, index) in quickActions" 
            :key="action.text"
            :data-index="index"
            @click="action.handler" 
            :class="[themeClasses.bg.card, themeClasses.shadow, 'p-4 rounded-lg flex flex-col items-center transition-colors hover:bg-gray-100 dark:hover:bg-gray-700 animate-hover-scale']"
          >
            <svg class="h-6 w-6 mb-2" :class="getActionIconClass(action.text)" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="action.icon"/>
            </svg>
            <span :class="[themeClasses.text.primary, 'text-sm font-medium']">{{ action.text }}</span>
          </button>
        </transition-group>
      </div>

      <!-- Refill Modal with transition -->
      <transition 
        enter-active-class="transition-opacity duration-300 ease-out"
        leave-active-class="transition-opacity duration-200 ease-in"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showRefillModal" class="fixed inset-0 bg-gray-600/50 dark:bg-gray-900/70 backdrop-blur-sm flex items-center justify-center z-50 p-4" @click.self="showRefillModal = false">
          <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg max-w-md w-full animate-pulse-card']">
            <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
              <h3 :class="[themeClasses.text.primary, 'text-lg font-medium']">Schedule Gas Refill</h3>
            </div>
            <div class="p-6">
              <div class="mb-4">
                <label :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Delivery Date</label>
                <input type="date" v-model="refillDate" :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']">
              </div>
              <div class="mb-4">
                <label :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Delivery Time</label>
                <select v-model="refillTime" :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']">
                  <option>Morning (8am-12pm)</option>
                  <option>Afternoon (12pm-4pm)</option>
                  <option>Evening (4pm-8pm)</option>
                </select>
              </div>
              <div class="mb-4">
                <label :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Quantity (kg)</label>
                <input type="number" v-model="refillQuantity" min="10" max="100" :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']">
              </div>
            </div>
            <div :class="[themeClasses.border.primary, themeClasses.bg.tertiary, 'px-6 py-4 border-t flex justify-end']">
              <button @click="showRefillModal = false" :class="[themeClasses.button.secondary, 'mr-3 px-4 py-2 text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 animate-hover-scale']">
                Cancel
              </button>
              <button @click="scheduleRefill" :class="[themeClasses.button.primary, 'px-4 py-2 text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 animate-hover-glow']">
                Schedule Refill
              </button>
            </div>
          </div>
        </div>
      </transition>
      
      <!-- Settings Modal -->
      <transition
        enter-active-class="ease-out duration-300"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="ease-in duration-200"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showSettingsModal" class="fixed inset-0 bg-gray-600/50 dark:bg-gray-900/70 backdrop-blur-sm flex items-center justify-center z-50">
          <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg max-w-md w-full animate-pulse-card']">
            <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
              <h3 :class="[themeClasses.text.primary, 'text-lg font-medium']">Safety Thresholds</h3>
            </div>
            <div class="p-6">
              <div class="mb-4">
                <label :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Low Level Alert (%)</label>
                <input type="number" v-model="alertThresholds.lowLevel" min="5" max="30" :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']">
              </div>
              <div class="mb-4">
                <label :class="[themeClasses.text.primary, 'block text-sm font-medium mb-1']">Critical Level Alert (%)</label>
                <input type="number" v-model="alertThresholds.criticalLevel" min="1" max="15" :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']">
              </div>
            </div>
            <div :class="[themeClasses.border.primary, themeClasses.bg.tertiary, 'px-6 py-4 border-t flex justify-end']">
              <button @click="showSettingsModal = false" :class="[themeClasses.button.secondary, 'mr-3 px-4 py-2 text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 animate-hover-scale']">
                Cancel
              </button>
              <button @click="saveSettings" :class="[themeClasses.button.primary, 'px-4 py-2 text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 animate-hover-glow']">
                Save Settings
              </button>
            </div>
          </div>
        </div>
      </transition>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'
const router = useRouter()
import {
  Chart,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  LineController,
  BarElement,
  BarController,
  Title,
  Tooltip,
  Legend
} from 'chart.js'

// Register Chart.js components
Chart.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  LineController,
  BarElement,
  BarController,
  Title,
  Tooltip,
  Legend
)

// Theme composable
const { isDark, themeClasses } = useTheme()

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
const backendAlerts = ref([])
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
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300'
  return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
})

const levelStatusText = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'CRITICAL'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'LOW'
  return 'NORMAL'
})

const dailyUsage = computed(() => {
  if (usageHistory.value.length === 0) return 0
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  const totalConsumption = sortedHistory.reduce((sum, day) => sum + day.consumption_kg, 0)
  const totalDays = sortedHistory.length
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
  if (usageHistory.value.length === 0) return 0
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  return sortedHistory.reduce((sum, day) => sum + day.consumption_kg, 0)
})

const dailyConsumptionData = computed(() => {
  if (usageHistory.value.length === 0) return []
  const sortedHistory = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  return sortedHistory
    .filter(day => day.consumption_kg > 0)
    .map(day => ({
      date: day.date,
      consumption: day.consumption_kg.toFixed(2),
      is_weekend: day.is_weekend,
      reading_count: day.reading_count
    }))
})

// Quick actions data
const quickActions = ref([
  {
    text: 'Refill Gas',
    icon: 'M12 6v6m0 0v6m0-6h6m-6 0H6',
    handler: () => showRefillModal.value = true
  },
  {
    text: 'Usage History',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    handler: () => showUsageHistory.value = true
  },
  {
    text: 'Settings',
    icon: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z',
    handler: () => showSettingsModal.value = true
  },
  {
    text: 'AI Assistant',
    icon: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z',
    handler: () => router.push({ name: 'ai-chat' })
  }
])

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
  refreshAlerts()
}

const updateTankData = () => {
  fetchGasReadings()
}

const refreshAlerts = async () => {
  await fetchBackendAlerts()
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

const fetchBackendAlerts = async () => {
  try {
    const response = await api.get('alerts/', {
      headers: { Authorization: `Token ${localStorage.getItem('authToken')}` }
    })
    backendAlerts.value = response.data.filter(alert => !alert.is_resolved)
  } catch (error) {
    console.error('Error fetching backend alerts:', error)
  }
}

const checkForAlerts = () => {
  alert.value = null
  
  const criticalBackendAlert = backendAlerts.value.find(a => 
    a.alert_type === 'GAS_LEAK' && (a.severity_level === 'CRITICAL' || a.severity_level === 'HIGH')
  )
  
  if (criticalBackendAlert) {
    alert.value = {
      type: 'error', // Ensure error type for critical alerts
      title: '🚨 GAS LEAK DETECTED',
      message: `${criticalBackendAlert.alert_message || 'Gas leak detected by ' + criticalBackendAlert.sensor_name}. Take immediate safety action!`,
      action: {
        text: 'View Details',
        callback: () => {
          alert.value = null
        }
      },
      backendAlert: criticalBackendAlert
    }
    return
  }
  
  const otherBackendAlert = backendAlerts.value.find(a => 
    a.alert_type === 'GAS_LEAK' && (a.severity_level === 'MEDIUM' || a.severity_level === 'LOW')
  )
  
  if (otherBackendAlert) {
    alert.value = {
      type: 'warning',
      title: '⚠️ GAS LEAK ALERT',
      message: `${otherBackendAlert.alert_message || 'Gas leak detected by ' + otherBackendAlert.sensor_name}. Please investigate.`,
      action: {
        text: 'View Details',
        callback: () => {
          alert.value = null
        }
      },
      backendAlert: otherBackendAlert
    }
    return
  }
  
  if (tank.value.level < alertThresholds.value.criticalLevel) {
    alert.value = {
      type: 'error', // Ensure error type for critical level
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
      type: 'warning',
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
    const response = await api.get('sensors/', {
      headers: { Authorization: `Token ${localStorage.getItem('authToken')}` }
    })
    const sensors = response.data
    if (sensors.length > 0) {
      const latestReading = sensors[0].current_gas_level
      tank.value.level = (latestReading / tank.value.capacity * 100).toFixed(2)

      await fetchBackendAlerts()

      const endDate = new Date()
      const startDate = new Date()
      startDate.setDate(endDate.getDate() - 30)
      
      const dailyReadingsResponse = await api.get('/gas-readings/daily/', {
        headers: { Authorization: `Token ${localStorage.getItem('authToken')}` },
        params: {
          start_date: startDate.toISOString().split('T')[0],
          end_date: endDate.toISOString().split('T')[0]
        }
      })
      
      if (dailyReadingsResponse.data.status_code === 200) {
        usageHistory.value = dailyReadingsResponse.data.data.map(day => ({
          date: day.date,
          level: day.gas_percentage,
          consumption_kg: day.consumption_kg,
          avg_remaining_kg: day.avg_remaining_kg,
          reading_count: day.reading_count,
          is_weekend: new Date(day.date).getDay() === 0 || new Date(day.date).getDay() === 6
        }))
      } else {
        usageHistory.value = []
      }
      
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

      if (levelChartInstance.value && consumptionChartInstance.value) {
        updateCharts()
      } else {
        initializeCharts()
      }

      checkForAlerts()
    } else {
      alert.value = {
        type: 'error', // Ensure error type for no sensors
        title: 'NO SENSORS',
        message: 'No gas sensors found. Please configure a sensor to monitor gas levels.',
        action: null
      }
    }
  } catch (error) {
    console.error('Error fetching gas readings:', error)
    alert.value = {
      type: 'error', // Ensure error type for fetch error
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
  const levelCtx = document.getElementById('levelChart').getContext('2d')
  levelChartInstance.value = new Chart(levelCtx, {
    type: 'line',
    data: {
      labels: usageHistory.value.map(item => item.date),
      datasets: [{
        label: 'Gas Level (%)',
        data: usageHistory.value.map(item => item.level),
        borderColor: '#3B82F6',
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
          title: { display: true, text: 'Gas Level (%)' },
          grid: { color: isDark.value ? '#4B5563' : '#E5E7EB' }
        },
        x: {
          title: { display: true, text: 'Date' },
          grid: { display: false }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(context) {
              return `Level: ${context.parsed.y.toFixed(2)}%`
            }
          }
        },
        legend: { display: false }
      }
    }
  })

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
          min: 0,
          grid: { color: isDark.value ? '#4B5563' : '#E5E7EB' }
        },
        x: {
          title: { display: true, text: 'Date' },
          grid: { display: false }
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
        legend: { display: false }
      }
    }
  })
}

const updateCharts = () => {
  if (levelChartInstance.value) {
    levelChartInstance.value.data.labels = usageHistory.value.map(item => item.date)
    levelChartInstance.value.data.datasets[0].data = usageHistory.value.map(item => item.level)
    levelChartInstance.value.options.scales.y.grid.color = isDark.value ? '#4B5563' : '#E5E7EB'
    levelChartInstance.value.update()
  }

  if (consumptionChartInstance.value) {
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
    consumptionChartInstance.value.options.scales.y.grid.color = isDark.value ? '#4B5563' : '#E5E7EB'
    consumptionChartInstance.value.update()
  }
}

// Theme helper functions for alerts
function getAlertClasses(type) {
  const alertMap = {
    'success': themeClasses.value.alert.success,
    'warning': themeClasses.value.alert.warning,
    'error': themeClasses.value.alert.error,
    'red': themeClasses.value.alert.error,
    'orange': themeClasses.value.alert.warning,
    'green': themeClasses.value.alert.success
  }
  return alertMap[type] || themeClasses.value.alert.error // Default to error for consistency
}

function getAlertIconClasses(type) {
  const iconMap = {
    'success': themeClasses.value.text.success,
    'warning': themeClasses.value.text.warning,
    'error': themeClasses.value.text.error,
    'red': themeClasses.value.text.error,
    'orange': themeClasses.value.text.warning,
    'green': themeClasses.value.text.success
  }
  return iconMap[type] || themeClasses.value.text.error
}

function getAlertTextClasses(type) {
  return getAlertIconClasses(type)
}

function getAlertButtonClasses(type) {
  const buttonMap = {
    'success': isDark.value ? 'bg-green-800/50 text-green-300 hover:bg-green-800/70' : 'bg-green-100 text-green-800 hover:bg-green-200',
    'warning': isDark.value ? 'bg-orange-800/50 text-orange-300 hover:bg-orange-800/70' : 'bg-orange-100 text-orange-800 hover:bg-orange-200',
    'error': isDark.value ? 'bg-red-800/50 text-red-300 hover:bg-red-800/70' : 'bg-red-100 text-red-800 hover:bg-red-200',
    'red': isDark.value ? 'bg-red-800/50 text-red-300 hover:bg-red-800/70' : 'bg-red-100 text-red-800 hover:bg-red-200',
    'orange': isDark.value ? 'bg-orange-800/50 text-orange-300 hover:bg-orange-800/70' : 'bg-orange-100 text-orange-800 hover:bg-orange-200',
    'green': isDark.value ? 'bg-green-800/50 text-green-300 hover:bg-green-800/70' : 'bg-green-100 text-green-800 hover:bg-green-200'
  }
  return buttonMap[type] || (isDark.value ? 'bg-red-800/50 text-red-300 hover:bg-red-800/70' : 'bg-red-100 text-red-800 hover:bg-red-200')
}

// Helper function for quick action icons
function getActionIconClass(actionText) {
  const iconColorMap = {
    'Refill Gas': 'text-blue-500',
    'Usage History': 'text-green-500',
    'Settings': 'text-purple-500',
    'AI Assistant': 'text-cyan-500'
  }
  return iconColorMap[actionText] || 'text-blue-500'
}

// Animation helpers for quick actions
const beforeEnter = (el) => {
  el.style.opacity = 0
  el.style.transform = 'translateY(20px)'
}

const enter = (el, done) => {
  const delay = el.dataset.index * 100
  setTimeout(() => {
    el.style.transition = 'all 0.5s ease-out'
    el.style.opacity = 1
    el.style.transform = 'translateY(0)'
    done()
  }, delay)
}

// Lifecycle hooks
onMounted(async () => {
  refillDate.value = getNextAvailableDate()
  await fetchGasReadings()
  
  const dataUpdateInterval = setInterval(updateTankData, 3600000)
  
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

// Watch for theme changes to update chart colors
watch(() => isDark.value, () => {
  if (levelChartInstance.value) {
    levelChartInstance.value.options.scales.y.grid.color = isDark.value ? '#4B5563' : '#E5E7EB'
    levelChartInstance.value.update()
  }
  if (consumptionChartInstance.value) {
    consumptionChartInstance.value.options.scales.y.grid.color = isDark.value ? '#4B5563' : '#E5E7EB'
    consumptionChartInstance.value.update()
  }
})
</script>

<style scoped>
/* Background blob animation */
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
  animation: blob-color 12s ease-in-out infinite;
}

/* Enhanced Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes pulse-header {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

@keyframes pulse-alert {
  0%, 100% { background-color: rgba(255, 255, 255, 0.1); }
  50% { background-color: rgba(255, 255, 255, 0.2); }
}

@keyframes pulse-card {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

@keyframes pulse-level {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

@keyframes pulse-prediction {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.02); }
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

.animate-pulse-header {
  animation: pulse-header 4s ease-in-out infinite;
}

.animate-pulse-alert {
  animation: pulse-alert 2s ease-in-out infinite;
}

.animate-pulse-card {
  animation: pulse-card 4s ease-in-out infinite;
}

.animate-pulse-level {
  animation: pulse-level 2s ease-in-out infinite;
}

.animate-pulse-prediction {
  animation: pulse-prediction 3s ease-in-out infinite;
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

/* Animation delays */
.animation-delay-200 {
  animation-delay: 200ms;
}

.animation-delay-2000 {
  animation-delay: 2000ms;
}

/* Scrollbar styling */
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

/* Ensure text stays within frame */
.break-words {
  word-break: break-word;
  overflow-wrap: break-word;
  hyphens: auto;
}

/* Ensure charts stay within frame */
canvas {
  max-width: 100%;
  height: 100% !important;
}
</style>