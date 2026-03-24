<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 right-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 left-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between px-6 sm:px-8 py-4 sm:py-5 gap-4">
        <div class="flex items-center space-x-4">
          <div class="w-1.5 h-1.5 sm:w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
          <h1 class="text-[10px] sm:text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Intelligence / <span class="text-white/80">Command Suite</span></h1>
        </div>
        
        <div class="flex items-center gap-4">
          <div class="relative group">
            <select v-model="timeRange" @change="updateCharts" class="appearance-none bg-white/5 border border-white/10 rounded-xl px-6 py-2 pr-10 text-[10px] font-black uppercase tracking-widest text-white/60 focus:outline-none focus:border-teal-400/50 transition-all cursor-pointer italic">
              <option value="7">Last 7 Cycles</option>
              <option value="30">Last 30 Cycles</option>
              <option value="90">Last 90 Cycles</option>
              <option value="365">Annual Review</option>
            </select>
            <div class="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-white/20">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M19 9l-7 7-7-7" /></svg>
            </div>
          </div>
          
          <button @click="exportData" class="group p-2.5 bg-white/5 border border-white/10 rounded-xl text-white/40 hover:text-teal-400 hover:border-teal-400/30 transition-all">
            <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" /></svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-4 sm:p-8 space-y-6 sm:space-y-8 custom-scrollbar">
      
      <!-- Intelligence Summary Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Avg Daily Usage -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[2.5rem] p-6 sm:p-8 group hover:border-blue-400/30 transition-all duration-500 relative overflow-hidden">
          <div class="absolute inset-0 bg-blue-400/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-6">Daily Depletion</h3>
          <div class="flex items-baseline gap-2 mb-2">
            <span class="text-3xl sm:text-4xl font-black text-white italic tracking-tighter">{{ averageDailyUsage }}</span>
            <span class="text-[10px] font-black text-white/20 uppercase tracking-widest">KG / CYCLE</span>
          </div>
          <div :class="[usageTrend > 0 ? 'text-red-400' : 'text-teal-400', 'text-[10px] font-black uppercase tracking-widest flex items-center gap-1.5']">
            <svg class="w-3 h-3" :class="usageTrend > 0 ? '' : 'rotate-180'" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 10l7-7m0 0l7 7m-7-7v18"/></svg>
            {{ Math.abs(usageTrend) }}% DEV FROM PRIOR
          </div>
        </div>

        <!-- Bottle Duration -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 group hover:border-teal-400/30 transition-all duration-500 relative overflow-hidden">
          <div class="absolute inset-0 bg-teal-400/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-6">Uptime Continuity</h3>
          <div class="flex items-baseline gap-2 mb-2">
            <span class="text-4xl font-black text-white italic tracking-tighter">{{ currentBottleDays }}</span>
            <span class="text-[10px] font-black text-white/20 uppercase tracking-widest">CYCLES ACTIVE</span>
          </div>
          <div class="text-[10px] font-black text-teal-400/60 uppercase tracking-widest italic tracking-tighter">
            EST. TERMINATION: {{ estimatedRefillDate }}
          </div>
        </div>

        <!-- Total Consumption -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 group hover:border-purple-400/30 transition-all duration-500 relative overflow-hidden">
          <div class="absolute inset-0 bg-purple-400/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-6">Aggregate Output</h3>
          <div class="flex items-baseline gap-2 mb-2">
            <span class="text-4xl font-black text-white italic tracking-tighter">{{ totalConsumption }}</span>
            <span class="text-[10px] font-black text-white/20 uppercase tracking-widest">KG TOTAL</span>
          </div>
          <div class="text-[10px] font-black text-white/20 uppercase tracking-widest italic tracking-tighter">
            SINCE INITIAL COMM: {{ firstRefillDate }}
          </div>
        </div>
      </div>

      <!-- Analysis Charts Row -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Daily Consumption Chart -->
        <div class="lg:col-span-2 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-8 hover:border-white/10 transition-all duration-500">
          <div class="flex items-center justify-between mb-8">
            <div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Telemetry Stream</h3>
              <div class="text-xl font-black text-white italic uppercase tracking-tighter">Daily Consumption Intensity</div>
            </div>
            <div class="flex bg-white/5 rounded-xl p-1">
              <button @click="setChartType('bar')" :class="[chartType === 'bar' ? 'bg-teal-400 text-gray-950' : 'text-white/40 hover:text-white', 'p-2 rounded-lg transition-all']">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>
              </button>
              <button @click="setChartType('line')" :class="[chartType === 'line' ? 'bg-teal-400 text-gray-950' : 'text-white/40 hover:text-white', 'p-2 rounded-lg transition-all']">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"/></svg>
              </button>
            </div>
          </div>
          <div class="h-[250px] sm:h-[300px] w-full relative">
            <canvas ref="dailyChart"></canvas>
          </div>
          <div class="mt-6 flex justify-between text-[10px] font-black uppercase tracking-widest italic">
            <div class="text-teal-400/40">Peak Intensity: <span class="text-white/60 ml-1">{{ peakUsage }} KG // {{ peakUsageDate }}</span></div>
            <div class="text-blue-400/40">Minimum Drain: <span class="text-white/60 ml-1">{{ lowestUsage }} KG // {{ lowestUsageDate }}</span></div>
          </div>
        </div>

        <!-- Pattern Analysis -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-8 space-y-8">
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic">Temporal Patterns</h3>
          
          <div class="space-y-4">
            <div class="flex justify-between items-center text-[9px] font-black uppercase tracking-widest text-white/20 italic">
              <span>By Cycle / Day of Week</span>
              <span class="text-teal-400">Peak: Friday</span>
            </div>
            <div class="h-32">
              <canvas ref="weekdayChart"></canvas>
            </div>
          </div>

          <div class="space-y-4 pt-4 border-t border-white/5">
            <div class="flex justify-between items-center text-[9px] font-black uppercase tracking-widest text-white/20 italic">
              <span>By Hour / Temporal Phase</span>
              <span class="text-blue-400">Peak: 19:00</span>
            </div>
            <div class="h-32">
              <canvas ref="hourlyChart"></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Third Row Charts -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Refill Logic -->
        <div class="lg:col-span-2 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-8">
          <div class="flex items-center justify-between mb-8">
             <div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Continuity History</h3>
              <div class="text-xl font-black text-white italic uppercase tracking-tighter">Cycle Duration Variance</div>
            </div>
            <div class="text-right">
              <div class="text-[9px] font-black text-white/20 uppercase tracking-widest italic">Aggregate Mean</div>
              <div class="text-lg font-black text-teal-400 italic tabular-nums">{{ averageRefillInterval }} CYCLES</div>
            </div>
          </div>
          <div class="h-[250px]">
            <canvas ref="refillChart"></canvas>
          </div>
        </div>

        <!-- Efficiency Radar -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] p-6 sm:p-8 relative overflow-hidden">
          <div class="absolute inset-0 bg-blue-500/[0.02] pointer-events-none"></div>
          <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-8">Node Efficiency Matrix</h3>
          <div class="h-48 sm:h-64 mb-8">
            <canvas ref="efficiencyChart"></canvas>
          </div>
          <div class="space-y-4">
            <div class="space-y-2">
              <div class="flex justify-between text-[10px] font-black uppercase tracking-widest italic px-2">
                <span class="text-white/20">Current Node Pulse</span>
                <span class="text-teal-400">{{ currentEfficiency }}%</span>
              </div>
              <div class="w-full bg-white/5 rounded-full h-1 overflow-hidden">
                <div class="bg-gradient-to-r from-teal-400 to-blue-500 h-full transition-all duration-1000" :style="`width: ${currentEfficiency}%`"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Detailed Analytics Registry -->
      <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-2xl sm:rounded-[3rem] overflow-hidden hover:border-white/10 transition-all duration-500">
        <div class="px-8 py-6 border-b border-white/5 flex flex-col sm:flex-row items-center justify-between gap-4">
          <div>
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">Raw Telemetry</h3>
            <div class="text-xl font-black text-white italic uppercase tracking-tighter">Data Logic Registry</div>
          </div>
          <div class="flex items-center gap-4 w-full sm:w-auto">
            <div class="relative flex-1 sm:min-w-[250px] group">
              <div class="absolute inset-y-0 left-4 flex items-center pointer-events-none">
                <svg class="h-4 w-4 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
              </div>
              <input v-model="searchQuery" type="text" placeholder="FILTER REGISTRY..." class="w-full pl-12 pr-6 py-2.5 bg-white/5 border border-white/5 rounded-xl focus:border-teal-400/50 focus:outline-none text-white text-[10px] font-black tracking-[0.2em] italic uppercase">
            </div>
            <button @click="exportFilteredData" class="p-2.5 bg-white/5 border border-white/10 rounded-xl text-white/40 hover:text-teal-400 transition-all">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" /></svg>
            </button>
          </div>
        </div>
        
        <div class="overflow-x-auto custom-scrollbar">
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-white/[0.01] border-b border-white/5">
                <th v-for="header in tableHeaders" :key="header.key" @click="sortTable(header.key)" class="px-5 sm:px-8 py-4 sm:py-6 text-left text-[9px] font-black uppercase tracking-[0.3em] text-white/30 italic cursor-pointer group">
                  <div class="flex items-center gap-2 group-hover:text-white/60 transition-colors">
                    {{ header.label }}
                    <span v-if="sortColumn === header.key" class="text-teal-400">
                      <svg v-if="sortDirection === 'asc'" class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 15l7-7 7 7"/></svg>
                      <svg v-else class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M19 9l-7 7-7-7"/></svg>
                    </span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr v-for="(row, index) in paginatedTableData" :key="index" class="hover:bg-white/[0.03] transition-colors">
                <td class="px-5 sm:px-8 py-4 sm:py-6 text-[11px] font-black text-white italic tracking-tighter uppercase">{{ row.date }}</td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 text-xs font-black text-teal-400 italic tabular-nums group-hover/tr:scale-105 transition-transform">{{ row.usage }} KG</td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 text-[11px] font-black text-blue-400 italic tabular-nums">{{ row.temperature }}°C</td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 text-[11px] font-black text-purple-400 italic tabular-nums">{{ row.humidity }}%</td>
                <td class="px-5 sm:px-8 py-4 sm:py-6 text-[11px] font-black text-white/40 italic tabular-nums">{{ row.duration }} CYCLES</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="px-8 py-6 bg-white/[0.01] border-t border-white/5 flex items-center justify-between">
          <div class="text-[9px] font-black uppercase tracking-widest text-white/20 italic">
            Visualizing <span class="text-white/60">{{ (currentPage - 1) * 10 + 1 }}-{{ Math.min(currentPage * 10, filteredTableData.length) }}</span> // Aggregate <span class="text-white/60">{{ filteredTableData.length }}</span> Log Items
          </div>
          <div class="flex items-center gap-4">
             <button @click="prevPage" :disabled="currentPage === 1" class="p-2 border border-white/10 rounded-xl text-white/40 hover:text-white disabled:opacity-20 transition-all">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M15 19l-7-7 7-7"/></svg>
            </button>
            <span class="text-[10px] font-black text-teal-400 italic tracking-widest uppercase">Phase {{ currentPage }} / {{ totalPages }}</span>
            <button @click="nextPage" :disabled="currentPage === totalPages" class="p-2 border border-white/10 rounded-xl text-white/40 hover:text-white disabled:opacity-20 transition-all">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M9 5l7 7-7 7"/></svg>
            </button>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useTheme } from '../../composables/useTheme';
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
  Filler,
  RadarController,
  RadialLinearScale
} from 'chart.js';

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
  Filler,
  RadarController,
  RadialLinearScale
);

const { themeClasses } = useTheme();

// Analytics State
const timeRange = ref('30');
const chartType = ref('bar');
const searchQuery = ref('');
const currentPage = ref(1);
const itemsPerPage = 10;
const sortColumn = ref('date');
const sortDirection = ref('desc');

// Intelligence Metrics
const averageDailyUsage = ref(1.28);
const usageTrend = ref(-3.2);
const currentBottleDays = ref(24);
const estimatedRefillDate = ref('JUNE 18 / 2026');
const totalConsumption = ref(482.5);
const firstRefillDate = ref('JAN 04 / 2026');
const peakUsage = ref(3.1);
const peakUsageDate = ref('MAY 12 / 2026');
const lowestUsage = ref(0.4);
const lowestUsageDate = ref('APR 22 / 2026');
const averageRefillInterval = ref(28.5);
const daysSinceLastRefill = ref(12);
const averageRefillCost = ref(45.00);
const currentEfficiency = ref(92);
const averageEfficiency = ref(84);

const tableHeaders = [
  { key: 'date', label: 'Cycle Date' },
  { key: 'usage', label: 'Depletion Unit' },
  { key: 'temperature', label: 'Thermal Mean' },
  { key: 'humidity', label: 'Hydration Stat' },
  { key: 'duration', label: 'Continuity Duration' }
];

const tableData = ref(generateTableData());

// Chart Refs
const dailyChart = ref(null);
const weekdayChart = ref(null);
const hourlyChart = ref(null);
const refillChart = ref(null);
const efficiencyChart = ref(null);

// Instances
let dailyInstance = null;
let weekdayInstance = null;
let hourlyInstance = null;
let refillInstance = null;
let efficiencyInstance = null;

// Logic Functions
function generateTableData() {
  const data = [];
  const now = new Date();
  for (let i = 0; i < 50; i++) {
    const d = new Date(now);
    d.setDate(now.getDate() - i);
    data.push({
      date: d.toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' }).toUpperCase(),
      usage: (Math.random() * 2.5 + 0.5).toFixed(2),
      temperature: (18 + Math.random() * 12).toFixed(1),
      humidity: Math.floor(40 + Math.random() * 40),
      duration: Math.floor(20 + Math.random() * 15)
    });
  }
  return data;
}

const filteredTableData = computed(() => {
  let filtered = [...tableData.value];
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase();
    filtered = filtered.filter(r => r.date.toLowerCase().includes(q) || r.usage.includes(q));
  }
  filtered.sort((a, b) => {
    const valA = a[sortColumn.value], valB = b[sortColumn.value];
    return sortDirection.value === 'asc' ? (valA > valB ? 1 : -1) : (valA < valB ? 1 : -1);
  });
  return filtered;
});

const totalPages = computed(() => Math.ceil(filteredTableData.value.length / itemsPerPage));
const paginatedTableData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredTableData.value.slice(start, start + itemsPerPage);
});

function sortTable(key) {
  if (sortColumn.value === key) sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc';
  else { sortColumn.value = key; sortDirection.value = 'desc'; }
}

function prevPage() { if (currentPage.value > 1) currentPage.value--; }
function nextPage() { if (currentPage.value < totalPages.value) currentPage.value++; }

function createGradient(ctx, color) {
  const g = ctx.createLinearGradient(0, 0, 0, 300);
  g.addColorStop(0, `${color}40`);
  g.addColorStop(1, `${color}00`);
  return g;
}

const initCharts = () => {
  // Main Daily Chart
  const dailyCtx = dailyChart.value.getContext('2d');
  dailyInstance = new Chart(dailyCtx, {
    type: chartType.value,
    data: {
      labels: Array.from({ length: parseInt(timeRange.value) }, (_, i) => `${i + 1}`),
      datasets: [{
        label: 'Depletion',
        data: Array.from({ length: 30 }, () => Math.random() * 2 + 0.5),
        borderColor: '#2dd4bf',
        backgroundColor: chartType.value === 'line' ? createGradient(dailyCtx, '#2dd4bf') : '#2dd4bf90',
        borderWidth: 3,
        tension: 0.4,
        fill: true,
        pointRadius: 0,
        pointHoverRadius: 6,
        pointHoverBorderWidth: 2,
        pointHoverBackgroundColor: '#2dd4bf',
        pointHoverBorderColor: '#fff'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false }, tooltip: { backgroundColor: '#0f172a', titleFont: { family: 'Inter', weight: '900' }, bodyFont: { family: 'Inter' } } },
      scales: {
        y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 10, family: 'Inter', weight: '900' } } },
        x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.2)', font: { size: 9, family: 'Inter', weight: '900' } } }
      }
    }
  });

  // Weekday Chart
  weekdayInstance = new Chart(weekdayChart.value.getContext('2d'), {
    type: 'bar',
    data: {
      labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      datasets: [{
        data: [1.2, 1.1, 1.4, 1.3, 1.8, 2.2, 1.9],
        backgroundColor: '#3b82f6',
        borderRadius: 4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { grid: { display: false }, ticks: { display: false } },
        x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.4)', font: { size: 10, weight: '900' } } }
      }
    }
  });

  // Hourly Chart
  const hourlyCtx = hourlyChart.value.getContext('2d');
  hourlyInstance = new Chart(hourlyCtx, {
    type: 'line',
    data: {
      labels: Array.from({ length: 12 }, (_, i) => `${i * 2}:00`),
      datasets: [{
        data: Array.from({ length: 12 }, () => Math.random() * 2),
        borderColor: '#2dd4bf',
        borderWidth: 2,
        tension: 0.4,
        pointRadius: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { grid: { display: false }, ticks: { display: false } },
        x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.4)', font: { size: 10, weight: '900' } } }
      }
    }
  });

  // Refill Continuity Chart
  const refillCtx = refillChart.value.getContext('2d');
  refillInstance = new Chart(refillCtx, {
    type: 'line',
    data: {
      labels: ['P1', 'P2', 'P3', 'P4', 'P5', 'P6'],
      datasets: [{
        data: [28, 32, 26, 30, 24, 28],
        borderColor: '#8b5cf6',
        backgroundColor: createGradient(refillCtx, '#8b5cf6'),
        fill: true,
        borderWidth: 3,
        tension: 0.4,
        pointRadius: 4,
        pointBackgroundColor: '#8b5cf6'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        y: { grid: { color: 'rgba(255,255,255,0.03)' }, ticks: { color: 'rgba(255,255,255,0.2)', font: { weight: '900' } } },
        x: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.2)', font: { weight: '900' } } }
      }
    }
  });

  // Radar Efficiency
  efficiencyInstance = new Chart(efficiencyChart.value.getContext('2d'), {
    type: 'radar',
    data: {
      labels: ['LOAD', 'DRAIN', 'THERM', 'FLUID', 'STAB'],
      datasets: [{
        label: 'Current',
        data: [85, 92, 78, 80, 88],
        borderColor: '#2dd4bf',
        backgroundColor: 'rgba(45, 212, 191, 0.1)',
        borderWidth: 2,
        pointRadius: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        r: {
          grid: { color: 'rgba(255,255,255,0.05)' },
          angleLines: { color: 'rgba(255,255,255,0.05)' },
          pointLabels: { color: 'rgba(255,255,255,0.4)', font: { family: 'Inter', weight: '900', size: 9 } },
          ticks: { display: false },
          suggestedMin: 50
        }
      }
    }
  });
};

function updateCharts() {
  if (dailyInstance) {
    dailyInstance.data.labels = Array.from({ length: parseInt(timeRange.value) }, (_, i) => `${i + 1}`);
    dailyInstance.data.datasets[0].data = Array.from({ length: parseInt(timeRange.value) }, () => Math.random() * 2 + 0.5);
    dailyInstance.update();
  }
}

function setChartType(type) {
  chartType.value = type;
  if (dailyInstance) {
    dailyInstance.config.type = type;
    const ctx = dailyChart.value.getContext('2d');
    dailyInstance.data.datasets[0].backgroundColor = type === 'line' ? createGradient(ctx, '#2dd4bf') : '#2dd4bf90';
    dailyInstance.update();
  }
}

function exportData() { console.log('DATA_EXPORT_PROTOCOL_INITIALIZED'); }
function exportFilteredData() { console.log('REGISTRY_EXPORT_PROTOCOL_INITIALIZED'); }

onMounted(() => {
  initCharts();
});
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; height: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.1); }

/* Animation Keyframes */
@keyframes pulse {
  0%, 100% { opacity: 0.1; }
  50% { opacity: 0.2; }
}

input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  height: 14px; width: 14px;
  border-radius: 50%;
  background: #2dd4bf;
  cursor: pointer;
  box-shadow: 0 0 10px rgba(45,212,191,0.5);
  border: 2px solid white;
}
</style>