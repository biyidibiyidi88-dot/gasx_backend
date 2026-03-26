<template>
  <div :class="[themeClasses.bg.primary, 'bg-transparent flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]'] ">
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-teal-500/5 blur-[150px] -z-0 pointer-events-none animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/5 blur-[180px] -z-0 pointer-events-none animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Status Bar -->
    <header class="z-10 bg-transparent backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-6 py-4">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-teal-400 animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">System Command / <span class="text-white/80">Dashboard</span></h1>
        </div>
        
        <div class="flex items-center space-x-6">
          <div class="hidden sm:flex items-center space-x-2">
            <span class="text-[10px] font-black uppercase tracking-[0.2em] text-white/20">Last Sync:</span>
            <span class="text-[10px] font-black uppercase tracking-[0.2em] text-teal-400/60">{{ formatTime(lastUpdated) }}</span>
          </div>
          <button @click="refreshData" class="group p-2 rounded-xl bg-white/5 border border-white/5 hover:border-teal-400/30 transition-all duration-300">
            <svg class="h-4 w-4 text-white/40 group-hover:text-teal-400 transition-colors" :class="{ 'animate-spin': isRefreshing }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 space-y-6 custom-scrollbar">
      
      <!-- Critical Alert / Intelligence Interrupt -->
      <transition name="slide-down">
        <div v-if="alert" class="relative group">
          <div class="absolute inset-0 bg-red-500/5 blur-2xl rounded-[1.5rem] sm:rounded-[2rem] opacity-50 group-hover:opacity-100 transition-opacity"></div>
          <div class="relative bg-white/[0.02] backdrop-blur-3xl border border-red-500/20 rounded-[1.5rem] sm:rounded-[2rem] p-5 sm:p-6 flex flex-col sm:flex-row items-start sm:items-center gap-4 sm:gap-6 overflow-hidden">
            <div class="w-12 h-12 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center flex-shrink-0 animate-pulse">
              <svg class="h-6 w-6 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-red-400 mb-1 italic">Intelligence Interrupt // {{ alert.title }}</h3>
              <p class="text-sm font-bold text-white/80 uppercase tracking-widest leading-relaxed">{{ alert.message }}</p>
            </div>
            <div class="flex items-center gap-3">
              <button v-if="alert.action" @click="alert.action.callback" class="px-6 py-2 bg-red-500/20 border border-red-500/30 text-[10px] font-black uppercase tracking-widest text-red-400 rounded-xl hover:bg-red-500/30 transition-all">
                Execute Action
              </button>
              <button @click="dismissAlert" class="p-2 text-white/20 hover:text-white transition-colors">
                <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
          </div>
        </div>
      </transition>

      <!-- Top Row Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        
        <!-- Tank Level Visualizer -->
        <div class="md:col-span-2 lg:col-span-1 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[2.5rem] p-6 sm:p-8 flex flex-col justify-between group hover:border-white/10 transition-all duration-500">
          <div class="flex justify-between items-center mb-8">
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Volumetric Status</h3>
            <span :class="[levelStatusClass, 'text-[8px] font-black uppercase tracking-[0.2em] px-3 py-1 rounded-full border border-current opacity-60']">{{ levelStatusText }}</span>
          </div>

          <div class="relative py-4 sm:py-8 flex justify-center">
            <!-- Circular Gauge or Sleek Linear -->
            <div class="relative w-40 h-40 sm:w-48 sm:h-48 rounded-full border-4 border-white/5 flex items-center justify-center p-4">
              <svg class="absolute inset-0 w-full h-full -rotate-90">
                <circle cx="96" cy="96" r="88" fill="none" stroke="currentColor" stroke-width="8" class="text-white/5" />
                <circle cx="96" cy="96" r="88" fill="none" stroke="currentColor" stroke-width="8" 
                  :class="levelTextColorClass" 
                  stroke-dasharray="552.92" 
                  :stroke-dashoffset="552.92 * (1 - tank.level / 100)"
                  class="transition-all duration-1000 ease-out"
                />
              </svg>
              <div class="text-center group-hover:scale-110 transition-transform duration-500">
                <div :class="[levelTextColorClass, 'text-5xl font-black italic tracking-tighter mb-1']">{{ Math.round(tank.level) }}%</div>
                <div class="text-[10px] font-black uppercase tracking-[0.2em] text-white/20">Remanence</div>
              </div>
              <div class="absolute inset-0 rounded-full shadow-[inset_0_0_40px_rgba(255,255,255,0.02)]"></div>
            </div>
            <!-- Glow Accent -->
            <div class="absolute inset-0 opacity-20 blur-[60px] pointer-events-none" :class="levelTextColorClass.replace('text-', 'bg-')"></div>
          </div>

          <button @click="showRefillModal = true" class="mt-8 w-full py-4 bg-teal-400 rounded-2xl text-[10px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_30px_rgba(45,212,191,0.4)] transition-all">
            Schedule Refill Protocol
          </button>
        </div>

        <!-- Tank Metadata & Intelligence -->
        <div class="md:col-span-2 space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 h-full">
            
            <!-- Information Grid -->
            <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[2.5rem] p-6 sm:p-8 space-y-8 flex flex-col justify-between">
              <div class="flex justify-between items-center">
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Node Metadata</h3>
                <svg class="h-4 w-4 text-white/10" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              </div>

              <div class="space-y-6">
                <div v-for="info in tankInfo" :key="info.label" class="flex justify-between items-end border-b border-white/5 pb-2">
                  <span class="text-[9px] font-black uppercase tracking-widest text-white/20">{{ info.label }}</span>
                  <span class="text-sm font-bold text-white/80 italic tracking-tight">{{ info.value }}</span>
                </div>
              </div>

              <div class="pt-4">
                <div class="flex items-center justify-between mb-2">
                  <span class="text-[10px] font-black uppercase tracking-widest text-white/20 italic">Daily Consumption Pattern</span>
                  <span class="text-xs font-black text-teal-400 italic tracking-tight">{{ dailyUsage }} kg/day</span>
                </div>
                <div class="w-full bg-white/5 rounded-full h-1 overflow-hidden">
                  <div class="bg-gradient-to-r from-teal-400 to-blue-500 h-full transition-all duration-1000" :style="`width: ${Math.min(dailyUsage / tank.capacity * 100, 100)}%`"></div>
                </div>
              </div>
            </div>

            <!-- AI Consumption Prediction Layer -->
            <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[2.5rem] p-6 sm:p-8 flex flex-col justify-between relative overflow-hidden group/pred">
              <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-500/5 to-transparent pointer-events-none"></div>
              
              <div class="flex justify-between items-center relative z-10">
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic flex items-center">
                  <span class="w-1.5 h-1.5 rounded-full bg-teal-400 mr-2 animate-pulse shadow-[0_0_8px_rgba(45,212,191,0.5)]"></span>
                  Predictive Analysis
                </h3>
              </div>

              <div v-if="isPredicting" class="flex-1 flex flex-col items-center justify-center space-y-4">
                <div class="w-12 h-12 border-2 border-teal-400/20 border-t-teal-400 rounded-full animate-spin"></div>
                <span class="text-[10px] font-black uppercase tracking-[0.2em] text-white/20 italic">Processing Logic...</span>
              </div>

              <div v-else class="space-y-8 relative z-10">
                <div class="text-center py-4">
                  <div class="text-6xl font-black text-white italic tracking-tighter mb-1 group-hover/pred:scale-110 transition-transform duration-700">{{ prediction.days_remaining }}</div>
                  <div class="text-[10px] font-black uppercase tracking-[0.3em] text-white/20">Projected Uptime / Days</div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                  <div class="bg-white/[0.03] border border-white/5 rounded-2xl p-4 text-center">
                    <div class="text-[9px] font-black uppercase tracking-widest text-white/20 mb-1">Bias Confidence</div>
                    <div class="text-lg font-black text-teal-400 italic tabular-nums">{{ (prediction.confidence * 100).toFixed(0) }}%</div>
                  </div>
                  <div class="bg-white/[0.03] border border-white/5 rounded-2xl p-4 text-center">
                    <div class="text-[9px] font-black uppercase tracking-widest text-white/20 mb-1">Trend Curve</div>
                    <div class="text-lg font-black text-blue-400 italic uppercase">{{ prediction.trend }}</div>
                  </div>
                </div>

                <div class="bg-teal-400/10 border border-teal-400/20 rounded-2xl p-4">
                  <p class="text-[9px] font-bold text-white/60 leading-relaxed uppercase tracking-widest italic group-hover/pred:text-white/80 transition-colors">
                    "{{ prediction.recommendation }}"
                  </p>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>

      <!-- Analysis Charts Row -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Level History Chart -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-8 hover:border-white/10 transition-all duration-500">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-8 gap-4">
            <div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Logic Stream</h3>
              <div class="text-xl font-black text-white italic tracking-tight uppercase">Remanence History</div>
            </div>
            <div class="flex bg-white/5 rounded-xl p-1 border border-white/5">
              <button 
                v-for="range in ['week', 'month', 'year']" 
                :key="range"
                @click="chartRange = range"
                :class="[chartRange === range ? 'bg-teal-400 text-gray-900' : 'text-white/40 hover:text-white/60', 'px-4 py-1.5 text-[9px] font-black uppercase tracking-widest rounded-lg transition-all']"
              >
                {{ range }}
              </button>
            </div>
          </div>
          <div class="h-[300px] w-full relative">
            <canvas id="levelChart"></canvas>
          </div>
        </div>

        <!-- Consumption Distribution Chart -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-8 hover:border-white/10 transition-all duration-500">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between mb-8 gap-4">
            <div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Resource Drain</h3>
              <div class="text-xl font-black text-white italic tracking-tight uppercase">Consumption Intensity</div>
            </div>
            <div class="text-right">
              <div class="text-[10px] font-black uppercase tracking-widest text-white/20 mb-0.5">Aggregate Drain</div>
              <div class="text-lg font-black text-teal-400 italic tabular-nums">{{ totalConsumption.toFixed(2) }} kg</div>
            </div>
          </div>
          <div class="h-[300px] w-full relative">
            <canvas id="consumptionChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Cookable Foods Module -->
      <div class="h-[400px]">
        <CookableFoodsWidget ref="cookableFoodsWidgetRef" />
      </div>

      <!-- Quick Commands Row -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <button 
          v-for="(action, index) in quickActions" 
          :key="action.text"
          @click="action.handler" 
          class="group/action flex flex-col items-center justify-center p-6 sm:p-8 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[1.5rem] sm:rounded-[2rem] hover:border-teal-400/50 hover:bg-teal-400/5 transition-all duration-500"
        >
          <div class="w-12 h-12 mb-4 bg-white/5 rounded-2xl flex items-center justify-center group-hover/action:scale-110 transition-transform duration-500 border border-white/5 relative">
            <div class="absolute inset-0 bg-current opacity-0 group-hover/action:opacity-10 rounded-2xl blur-lg transition-opacity" :class="getActionIconClass(action.text)"></div>
            <svg class="h-6 w-6 transition-colors" :class="getActionIconClass(action.text)" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" :d="action.icon"/>
            </svg>
          </div>
          <span class="text-[10px] font-black uppercase tracking-[0.2em] text-white/40 group-hover/action:text-white transition-colors">{{ action.text }}</span>
        </button>
      </div>

    </main>

    <!-- Modals Layer -->
    <transition name="modal-fade">
      <div v-if="showRefillModal" @click.self="showRefillModal = false" class="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 bg-gray-950/80 backdrop-blur-xl">
        <div class="bg-gray-900 border border-white/10 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-10 max-w-md w-full relative group/modal overflow-hidden">
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] rounded-full opacity-50"></div>
          <div class="relative z-10">
            <div class="flex justify-between items-center mb-10">
              <div>
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 mb-1 italic">Protocol Entry</h3>
                <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Schedule Refill</h2>
              </div>
              <button @click="showRefillModal = false" class="p-2 text-white/20 hover:text-white transition-colors">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>

            <div class="space-y-6">
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Synchronization Node / Date</label>
                <input type="date" v-model="refillDate" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic">
              </div>
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Temporal Window</label>
                <select v-model="refillTime" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold italic appearance-none cursor-pointer">
                  <option>Morning (8am-12pm)</option>
                  <option>Afternoon (12pm-4pm)</option>
                  <option>Evening (4pm-8pm)</option>
                </select>
              </div>
              <div class="space-y-2">
                <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Volume Requirement (KG)</label>
                <input type="number" v-model="refillQuantity" min="10" max="100" class="w-full px-6 py-4 bg-white/5 border border-white/10 rounded-2xl focus:border-teal-400/50 focus:outline-none text-white font-bold tabular-nums italic">
              </div>

              <div class="pt-6">
                <button @click="scheduleRefill" class="w-full py-5 bg-teal-400 rounded-2xl text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_40px_rgba(45,212,191,0.5)] transition-all">
                  Execute Transmission
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <!-- Settings Modal Layer -->
    <transition name="modal-fade">
      <div v-if="showSettingsModal" @click.self="showSettingsModal = false" class="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 bg-gray-950/80 backdrop-blur-xl">
        <div class="bg-gray-900 border border-white/10 rounded-[2rem] sm:rounded-[3rem] p-6 sm:p-10 max-w-md w-full relative group/modal overflow-hidden">
          <div class="absolute inset-0 bg-blue-600/5 blur-[100px] rounded-full opacity-50"></div>
          <div class="relative z-10">
            <div class="flex justify-between items-center mb-10">
              <div>
                <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-blue-400 mb-1 italic">Core Configuration</h3>
                <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Safety Bias</h2>
              </div>
              <button @click="showSettingsModal = false" class="p-2 text-white/20 hover:text-white transition-colors">
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>

            <div class="space-y-8">
              <div class="space-y-2">
                <div class="flex justify-between items-center px-4">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">Yellow Alert Pulse (%)</label>
                  <span class="text-xs font-black text-white italic">{{ alertThresholds.lowLevel }}%</span>
                </div>
                <input type="range" v-model="alertThresholds.lowLevel" min="5" max="30" class="w-full h-1.5 bg-white/5 rounded-full appearance-none cursor-pointer accent-teal-400">
              </div>
              
              <div class="space-y-2">
                <div class="flex justify-between items-center px-4">
                  <label class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">Red Critical pulse (%)</label>
                  <span class="text-xs font-black text-red-400 italic">{{ alertThresholds.criticalLevel }}%</span>
                </div>
                <input type="range" v-model="alertThresholds.criticalLevel" min="1" max="15" class="w-full h-1.5 bg-white/5 rounded-full appearance-none cursor-pointer accent-red-400">
              </div>

              <div class="pt-6">
                <button @click="saveSettings" class="w-full py-5 bg-gradient-to-r from-teal-400 to-blue-500 rounded-2xl text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 hover:shadow-[0_0_40px_rgba(45,212,191,0.5)] transition-all">
                  Commit Logic Change
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </transition>
    
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'
import CookableFoodsWidget from '../../components/private/CookableFoodsWidget.vue'

const router = useRouter()
const { isDark, themeClasses } = useTheme()

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
  Legend,
  Filler
} from 'chart.js'

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
  Legend,
  Filler
)

// State
const lastUpdated = ref(new Date())
const showRefillModal = ref(false)
const showSettingsModal = ref(false)
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
const isRefreshing = ref(false)
const cookableFoodsWidgetRef = ref(null)

const tank = ref({
  level: 0,
  lastRefill: '2025-06-01',
  capacity: 20,
  type: 'Propane', 
  serialNumber: 'HTK-2025-0425',
  installationDate: '2025-04-25'
})

const alertThresholds = ref({
  lowLevel: 20,
  criticalLevel: 10
})

const prediction = ref({
  days_remaining: 0,
  confidence: 0,
  trend: 'stable',
  recommendation: ''
})

// Computed Tank Info
const tankInfo = computed(() => [
  { label: 'Infrastructure Unit', value: 'Propane Node / V2' },
  { label: 'Identity ID', value: tank.value.serialNumber },
  { label: 'Volumetric Max', value: `${tank.value.capacity} KG` },
  { label: 'Initial Uplink', value: tank.value.installationDate }
])

// Styles & Status
const levelStatusClass = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'text-red-400 bg-red-400/10'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'text-yellow-400 bg-yellow-400/10'
  return 'text-teal-400 bg-teal-400/10'
})

const levelStatusText = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'Protocol Red // Critical'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'Warning // Low Bias'
  return 'Stable // Nominal'
})

const levelTextColorClass = computed(() => {
  if (tank.value.level < alertThresholds.value.criticalLevel) return 'text-red-400'
  if (tank.value.level < alertThresholds.value.lowLevel) return 'text-yellow-400'
  return 'text-teal-400'
})

const dailyUsage = computed(() => {
  if (usageHistory.value.length === 0) return 0
  const sorted = [...usageHistory.value].sort((a, b) => new Date(a.date) - new Date(b.date))
  const total = sorted.reduce((sum, day) => sum + day.consumption_kg, 0)
  return (total / sorted.length).toFixed(2)
})

const totalConsumption = computed(() => {
  return usageHistory.value.reduce((sum, day) => sum + (day.consumption_kg || 0), 0)
})

const dailyConsumptionData = computed(() => {
  return [...usageHistory.value]
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .map(day => ({
      date: day.date,
      consumption: day.consumption_kg.toFixed(2),
      is_weekend: day.is_weekend
    }))
})

const quickActions = [
  { text: 'Sync Refill', icon: 'M12 6v6m0 0v6m0-6h6m-6 0H6', handler: () => showRefillModal.value = true },
  { text: 'Log Archive', icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2', handler: () => {} },
  { text: 'Bias Logic', icon: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z M15 12a3 3 0 11-6 0 3 3 0 016 0z', handler: () => showSettingsModal.value = true },
  { text: 'AI Command', icon: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z', handler: () => router.push({ name: 'ai-chat' }) }
]

function getActionIconClass(text) {
  if (text === 'Sync Refill') return 'text-teal-400'
  if (text === 'Log Archive') return 'text-blue-400'
  if (text === 'Bias Logic') return 'text-purple-400'
  return 'text-cyan-400'
}

// Logic Methods
const formatTime = (date) => new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
const getNextAvailableDate = () => {
  const date = new Date()
  date.setDate(date.getDate() + 2)
  return date.toISOString().split('T')[0]
}

const dismissAlert = () => alert.value = null

const refreshData = async () => {
  isRefreshing.value = true
  lastUpdated.value = new Date()
  await fetchGasReadings()
  if (cookableFoodsWidgetRef.value) {
    cookableFoodsWidgetRef.value.refreshData()
  }
  isRefreshing.value = false
}

const scheduleRefill = () => {
  alert(`Protocol Synchronized: Refill pending on ${refillDate.value} Window: ${refillTime.value}`)
  showRefillModal.value = false
  tank.value.lastRefill = new Date().toISOString().split('T')[0]
}

const saveSettings = () => {
  showSettingsModal.value = false
  checkForAlerts()
}

const fetchBackendAlerts = async () => {
  try {
    const response = await api.get('alerts/')
    backendAlerts.value = response.data.filter(a => !a.is_resolved)
  } catch (e) { console.error('Alert fetch error', e) }
}

const checkForAlerts = () => {
  alert.value = null
  const leak = backendAlerts.value.find(a => a.alert_type === 'GAS_LEAK')
  if (leak) {
    alert.value = {
      type: 'error',
      title: 'ANOMALY DETECTED',
      message: `Critical pressure drop reported at Node Alpha. Direct intervention required.`,
      action: { text: 'Abort Nodes', callback: () => {} }
    }
    return
  }
  
  if (tank.value.level < alertThresholds.value.criticalLevel) {
    alert.value = {
      type: 'error',
      title: 'CRITICAL DEPLETION',
      message: `System reserves at ${Math.round(tank.value.level)}%. Autonomous grid failure imminent.`,
      action: { text: 'Execute Refill', callback: () => showRefillModal.value = true }
    }
  } else if (tank.value.level < alertThresholds.value.lowLevel) {
    alert.value = {
      type: 'warning',
      title: 'LOW BIAS DETECTED',
      message: `Predicted exhaustion in ${prediction.value.days_remaining} cycles. Schedule sync.`,
      action: { text: 'Queue Sync', callback: () => showRefillModal.value = true }
    }
  }
}

const fetchGasReadings = async () => {
  try {
    const res = await api.get('sensors/')
    const sensors = res.data
    if (sensors.length > 0) {
      tank.value.level = (sensors[0].current_gas_level / tank.value.capacity * 100)
      
      const usageRes = await api.get('/gas-readings/daily/', {
        params: {
          start_date: new Date(Date.now() - 30 * 86400000).toISOString().split('T')[0],
          end_date: new Date().toISOString().split('T')[0]
        }
      })
      if (usageRes.data.status_code === 200) {
        usageHistory.value = usageRes.data.data.map(d => ({
          date: d.date,
          level: d.gas_percentage,
          consumption_kg: d.consumption_kg,
          is_weekend: [0, 6].includes(new Date(d.date).getDay())
        }))
      }

      isPredicting.value = true
      const predRes = await api.get('/gas/prediction/')
      if (predRes.data.status_code === 200) {
        prediction.value = {
          days_remaining: predRes.data.projected_days,
          confidence: predRes.data.confidence,
          trend: predRes.data.trend,
          recommendation: predRes.data.recommendation
        }
      }
      
      updateCharts()
      checkForAlerts()
    }
  } catch (e) { console.error('Uplink failed', e) }
  finally { isPredicting.value = false }
}

function createGradient(ctx, color) {
  const gradient = ctx.createLinearGradient(0, 0, 0, 300)
  gradient.addColorStop(0, `${color}40`) // 25% opacity
  gradient.addColorStop(1, `${color}00`) // 0% opacity
  return gradient
}

const initializeCharts = () => {
  const levelCtx = document.getElementById('levelChart')?.getContext('2d')
  if (levelCtx) {
    levelChartInstance.value = new Chart(levelCtx, {
      type: 'line',
      data: {
        labels: usageHistory.value.map(d => d.date),
        datasets: [{
          label: 'Remanence',
          data: usageHistory.value.map(d => d.level),
          borderColor: '#2dd4bf',
          backgroundColor: createGradient(levelCtx, '#2dd4bf'),
          fill: true,
          tension: 0.4,
          pointRadius: 0,
          borderWidth: 3,
          pointHoverRadius: 6,
          pointHoverBackgroundColor: '#2dd4bf',
          pointHoverBorderColor: '#fff',
          pointHoverBorderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false }, tooltip: { backgroundColor: '#0f172a', titleFont: { family: 'Inter', weight: '900' }, bodyFont: { family: 'Inter' } } },
        scales: {
          y: { min: 0, max: 100, grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 10, family: 'Inter', weight: '900' } } },
          x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 9, family: 'Inter', weight: '900' } } }
        }
      }
    })
  }

  const consumptionCtx = document.getElementById('consumptionChart')?.getContext('2d')
  if (consumptionCtx) {
    consumptionChartInstance.value = new Chart(consumptionCtx, {
      type: 'bar',
      data: {
        labels: dailyConsumptionData.value.map(d => d.date),
        datasets: [{
          label: 'Drain Intensity',
          data: dailyConsumptionData.value.map(d => d.consumption),
          backgroundColor: dailyConsumptionData.value.map(d => d.is_weekend ? '#3b82f6' : '#2dd4bf'),
          borderRadius: 6,
          borderSkipped: false
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false }, tooltip: { backgroundColor: '#0f172a' } },
        scales: {
          y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 10, weight: '900' } } },
          x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 9, weight: '900' } } }
        }
      }
    })
  }
}

const updateCharts = () => {
  if (!levelChartInstance.value) {
    initializeCharts()
    return
  }
  levelChartInstance.value.data.labels = usageHistory.value.map(d => d.date)
  levelChartInstance.value.data.datasets[0].data = usageHistory.value.map(d => d.level)
  levelChartInstance.value.update()

  consumptionChartInstance.value.data.labels = dailyConsumptionData.value.map(d => d.date)
  consumptionChartInstance.value.data.datasets[0].data = dailyConsumptionData.value.map(d => d.consumption)
  consumptionChartInstance.value.update()
}

onMounted(async () => {
  refillDate.value = getNextAvailableDate()
  await fetchGasReadings()
})

onUnmounted(() => {
  levelChartInstance.value?.destroy()
  consumptionChartInstance.value?.destroy()
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

.slide-down-enter-active, .slide-down-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.slide-down-enter-from { opacity: 0; transform: translateY(-20px); }

.modal-fade-enter-active, .modal-fade-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-fade-enter-from, .modal-fade-leave-to { opacity: 0; transform: scale(0.95); }

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  height: 16px; width: 16px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
  box-shadow: 0 0 10px rgba(45,212,191,0.5);
  border: 2px solid #fff;
}
</style>