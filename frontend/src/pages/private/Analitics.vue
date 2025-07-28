<template>
    <div :class="[themeClasses.bg.primary, 'gas-analytics-page p-6 min-h-screen']">
      <!-- Analytics Header -->
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
        <div>
          <div class="flex items-center space-x-4">
            <h1 :class="[themeClasses.text.primary, 'text-2xl md:text-3xl font-bold']">Gas Bottle Analytics</h1>
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
          </div>
          <p :class="[themeClasses.text.secondary, 'mt-1']">Detailed usage patterns and historical data</p>
        </div>
        <div class="mt-4 md:mt-0 flex gap-2">
          <div class="relative">
            <select v-model="timeRange" @change="updateCharts" :class="[themeClasses.bg.input, themeClasses.border.primary, themeClasses.text.primary, 'appearance-none border rounded-lg px-4 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500']">
              <option value="7">Last 7 Days</option>
              <option value="30">Last 30 Days</option>
              <option value="90">Last 3 Months</option>
              <option value="365">Last Year</option>
            </select>
            <div :class="[themeClasses.text.secondary, 'pointer-events-none absolute inset-y-0 right-0 flex items-center px-2']">
              <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          <button @click="exportData" :class="[themeClasses.button.secondary, 'flex items-center gap-2 rounded-lg px-3 py-2 text-sm transition-colors']">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            Export
          </button>
        </div>
      </div>
  
      <!-- Main Analytics Content -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Key Metrics Summary -->
        <div :class="[themeClasses.bg.card, themeClasses.shadow, themeClasses.border.primary, 'p-6 rounded-xl border']">
          <h2 :class="[themeClasses.text.primary, 'text-lg font-semibold mb-4']">Key Metrics</h2>
          <div class="space-y-4">
            <div class="p-4 bg-blue-50 rounded-lg">
              <p class="text-sm text-blue-600 font-medium">Average Daily Usage</p>
              <p class="text-2xl font-bold text-blue-800">{{ averageDailyUsage }} kg/day</p>
              <p class="text-xs text-blue-500 mt-1" :class="usageTrendClass">
                <span v-if="usageTrend > 0">↑</span>
                <span v-else-if="usageTrend < 0">↓</span>
                {{ Math.abs(usageTrend) }}% from previous period
              </p>
            </div>
            
            <div class="p-4 bg-green-50 rounded-lg">
              <p class="text-sm text-green-600 font-medium">Current Bottle Duration</p>
              <p class="text-2xl font-bold text-green-800">{{ currentBottleDays }} days</p>
              <p class="text-xs text-green-500 mt-1">Estimated {{ estimatedRefillDate }}</p>
            </div>
            
            <div class="p-4 bg-purple-50 rounded-lg">
              <p class="text-sm text-purple-600 font-medium">Total Consumption</p>
              <p class="text-2xl font-bold text-purple-800">{{ totalConsumption }} kg</p>
              <p class="text-xs text-purple-500 mt-1">Since {{ firstRefillDate }}</p>
            </div>
          </div>
        </div>
  
        <!-- Daily Usage Chart -->
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 lg:col-span-2">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg font-semibold text-gray-800">Daily Consumption</h2>
            <div class="flex gap-2">
              <button 
                @click="setChartType('bar')" 
                :class="`p-1 rounded ${chartType === 'bar' ? 'bg-blue-100 text-blue-600' : 'text-gray-500 hover:bg-gray-100'}`"
              >
                <i class="fas fa-chart-bar"></i>
              </button>
              <button 
                @click="setChartType('line')" 
                :class="`p-1 rounded ${chartType === 'line' ? 'bg-blue-100 text-blue-600' : 'text-gray-500 hover:bg-gray-100'}`"
              >
                <i class="fas fa-chart-line"></i>
              </button>
            </div>
          </div>
          <div class="h-64">
            <canvas ref="dailyChart"></canvas>
          </div>
          <div class="mt-4 flex justify-between text-xs text-gray-500">
            <span>Peak: {{ peakUsage }} kg on {{ peakUsageDate }}</span>
            <span>Lowest: {{ lowestUsage }} kg on {{ lowestUsageDate }}</span>
          </div>
        </div>
  
        <!-- Usage Patterns -->
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 lg:col-span-3">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Usage Patterns</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Day of Week Pattern -->
            <div>
              <h3 class="text-sm font-medium text-gray-500 mb-3">By Day of Week</h3>
              <div class="h-48">
                <canvas ref="weekdayChart"></canvas>
              </div>
            </div>
            
            <!-- Time of Day Pattern -->
            <div>
              <h3 class="text-sm font-medium text-gray-500 mb-3">By Time of Day</h3>
              <div class="h-48">
                <canvas ref="hourlyChart"></canvas>
              </div>
            </div>
            
            <!-- Seasonal Pattern -->
            <div>
              <h3 class="text-sm font-medium text-gray-500 mb-3">Seasonal Trends</h3>
              <div class="h-48">
                <canvas ref="seasonalChart"></canvas>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Refill History -->
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 lg:col-span-2">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Refill History</h2>
          <div class="h-64">
            <canvas ref="refillChart"></canvas>
          </div>
          <div class="mt-4">
            <div class="flex justify-between items-center mb-2">
              <h3 class="text-sm font-medium text-gray-500">Refill Statistics</h3>
              <span class="text-xs text-gray-500"> refills recorded</span>
            </div>
            <div class="grid grid-cols-3 gap-2 text-center">
              <div class="p-2 bg-gray-50 rounded">
                <p class="text-sm text-gray-500">Average</p>
                <p class="font-medium">{{ averageRefillInterval }} days</p>
              </div>
              <div class="p-2 bg-gray-50 rounded">
                <p class="text-sm text-gray-500">Last</p>
                <p class="font-medium">{{ daysSinceLastRefill }} days ago</p>
              </div>
              <div class="p-2 bg-gray-50 rounded">
                <p class="text-sm text-gray-500">Cost</p>
                <p class="font-medium">${{ averageRefillCost }}</p>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Bottle Efficiency -->
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
          <h2 class="text-lg font-semibold text-gray-800 mb-4">Bottle Efficiency</h2>
          <div class="h-48 mb-4">
            <canvas ref="efficiencyChart"></canvas>
          </div>
          <div class="space-y-3">
            <div>
              <div class="flex justify-between text-sm mb-1">
                <span class="text-gray-500">Current Bottle</span>
                <span class="font-medium">{{ currentEfficiency }}% efficient</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2">
                <div 
                  class="h-2 rounded-full bg-gradient-to-r from-blue-500 to-green-500" 
                  :style="{ width: `${currentEfficiency}%` }"
                ></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between text-sm mb-1">
                <span class="text-gray-500">All-time Average</span>
                <span class="font-medium">{{ averageEfficiency }}% efficient</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-2">
                <div 
                  class="h-2 rounded-full bg-gradient-to-r from-blue-500 to-green-500" 
                  :style="{ width: `${averageEfficiency}%` }"
                ></div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- Detailed Data Table -->
        <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200 lg:col-span-3">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-lg font-semibold text-gray-800">Detailed Usage Data</h2>
            <div class="flex items-center gap-2">
              <input 
                v-model="searchQuery" 
                type="text" 
                placeholder="Search..." 
                class="px-3 py-1 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
              <button 
                @click="exportFilteredData" 
                class="p-1 text-gray-500 hover:text-blue-600"
                title="Export filtered data"
              >
                <i class="fas fa-download"></i>
              </button>
            </div>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th 
                    v-for="header in tableHeaders" 
                    :key="header.key"
                    scope="col" 
                    class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                    @click="sortTable(header.key)"
                  >
                    <div class="flex items-center">
                      {{ header.label }}
                      <span v-if="sortColumn === header.key" class="ml-1">
                        <i v-if="sortDirection === 'asc'" class="fas fa-sort-up"></i>
                        <i v-else class="fas fa-sort-down"></i>
                      </span>
                    </div>
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="(row, index) in filteredTableData" :key="index">
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ row.date }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ row.usage }} kg</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ row.temperature }}°C</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ row.humidity }}%</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ row.duration }} days</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="flex justify-between items-center mt-4">
            <div class="text-sm text-gray-500">
              Showing {{ filteredTableData.length }} of {{ tableData.length }} records
            </div>
            <div class="flex gap-2">
              <button 
                @click="prevPage" 
                :disabled="currentPage === 1"
                class="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              <span class="px-3 py-1 text-sm">
                Page {{ currentPage }} of {{ totalPages }}
              </span>
              <button 
                @click="nextPage" 
                :disabled="currentPage === totalPages"
                class="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import { ref, computed, onMounted, watch } from 'vue';
  import { useTheme } from '../../composables/useTheme';
  import Chart from 'chart.js/auto';
  import axios from 'axios'
  export default {
    name: 'GasBottleAnalytics',
    setup() {
      // Time range selection
      const timeRange = ref('30');
      
      // Chart type toggle
      const chartType = ref('bar');
      
      // Data for charts and tables
      const averageDailyUsage = ref(1.2);
      const usageTrend = ref(5.3);
      const currentBottleDays = ref(18);
      const estimatedRefillDate = ref('June 12, 2023');
      const totalConsumption = ref(156);
      const firstRefillDate = ref('Jan 2022');
      const peakUsage = ref(2.4);
      const peakUsageDate = ref('May 15, 2023');
      const lowestUsage = ref(0.6);
      const lowestUsageDate = ref('Apr 2, 2023');
      const averageRefillInterval = ref(24);
      const daysSinceLastRefill = ref(12);
      const averageRefillCost = ref(42.5);
      const currentEfficiency = ref(85);
      const averageEfficiency = ref(78);
      
      // Table data and sorting
      const tableHeaders = ref([
        { key: 'date', label: 'Date' },
        { key: 'usage', label: 'Usage (kg)' },
        { key: 'temperature', label: 'Avg Temp' },
        { key: 'humidity', label: 'Humidity' },
        { key: 'duration', label: 'Duration' }
      ]);
      
      const tableData = ref(generateTableData());
      const sortColumn = ref('date');
      const sortDirection = ref('desc');
      const searchQuery = ref('');
      const currentPage = ref(1);
      const itemsPerPage = 10;
      
      // Chart refs
      const dailyChart = ref(null);
      const weekdayChart = ref(null);
      const hourlyChart = ref(null);
      const seasonalChart = ref(null);
      const refillChart = ref(null);
      const efficiencyChart = ref(null);
      
      // Chart instances
      let dailyChartInstance = null;
      let weekdayChartInstance = null;
      let hourlyChartInstance = null;
      let seasonalChartInstance = null;
      let refillChartInstance = null;
      let efficiencyChartInstance = null;
      
      // Computed properties
      const usageTrendClass = computed(() => {
        return usageTrend.value > 0 ? 'text-red-500' : 'text-green-500';
      });
      
      const filteredTableData = computed(() => {
        let filtered = [...tableData.value];
        
        // Apply search filter
        if (searchQuery.value) {
          const query = searchQuery.value.toLowerCase();
          filtered = filtered.filter(row => 
            row.date.toLowerCase().includes(query) ||
            row.usage.toString().includes(query) ||
            row.temperature.toString().includes(query) ||
            row.humidity.toString().includes(query) ||
            row.duration.toString().includes(query)
          );
        }
        
        // Apply sorting
        filtered.sort((a, b) => {
          const valA = a[sortColumn.value];
          const valB = b[sortColumn.value];
          
          if (typeof valA === 'string') {
            return sortDirection.value === 'asc' 
              ? valA.localeCompare(valB)
              : valB.localeCompare(valA);
          } else {
            return sortDirection.value === 'asc' 
              ? valA - valB
              : valB - valA;
          }
        });
        
        return filtered;
      });
      
      const totalPages = computed(() => {
        return Math.ceil(filteredTableData.value.length / itemsPerPage);
      });
      
      const paginatedTableData = computed(() => {
        const start = (currentPage.value - 1) * itemsPerPage;
        const end = start + itemsPerPage;
        return filteredTableData.value.slice(start, end);
      });
      
      // Methods
      function generateTableData() {
        const data = [];
        const now = new Date();
        
        for (let i = 0; i < 100; i++) {
          const date = new Date();
          date.setDate(now.getDate() - i);
          
          data.push({
            date: date.toLocaleDateString(),
            usage: (Math.random() * 2 + 0.5).toFixed(1),
            temperature: Math.floor(Math.random() * 15 + 15),
            humidity: Math.floor(Math.random() * 30 + 50),
            duration: Math.floor(Math.random() * 5 + 1)
          });
        }
        
        return data;
      }
      
      function updateCharts() {
        // In a real app, this would fetch new data based on timeRange
        // For demo, we'll just simulate with random data
        const days = parseInt(timeRange.value);
        
        // Update daily chart
        if (dailyChartInstance) {
          dailyChartInstance.data.labels = generateDateLabels(days);
          dailyChartInstance.data.datasets[0].data = generateRandomData(days, 0.5, 2.5);
          dailyChartInstance.update();
        }
        
        // Update other charts similarly...
        console.log(`Updated charts for ${days} days range`);
      }
      
      function generateDateLabels(days) {
        const labels = [];
        const now = new Date();
        
        for (let i = days - 1; i >= 0; i--) {
          const date = new Date(now);
          date.setDate(date.getDate() - i);
          labels.push(date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
        }
        
        return labels;
      }
      
      function generateRandomData(count, min, max) {
        return Array.from({ length: count }, () => 
          Math.random() * (max - min) + min
        );
      }
      
      function setChartType(type) {
        chartType.value = type;
        if (dailyChartInstance) {
          dailyChartInstance.config.type = type;
          dailyChartInstance.update();
        }
      }
      
      function sortTable(column) {
        if (sortColumn.value === column) {
          sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc';
        } else {
          sortColumn.value = column;
          sortDirection.value = 'asc';
        }
      }
      
      function prevPage() {
        if (currentPage.value > 1) {
          currentPage.value--;
        }
      }
      
      function nextPage() {
        if (currentPage.value < totalPages.value) {
          currentPage.value++;
        }
      }
      
      function exportData() {
        console.log('Exporting all analytics data');
        // In a real app, this would trigger a download
      }
      
      function exportFilteredData() {
        console.log('Exporting filtered table data');
        // In a real app, this would export only the filtered data
      }
      
      // Initialize charts
      function initCharts() {
        // Daily Usage Chart
        dailyChartInstance = new Chart(dailyChart.value.getContext('2d'), {
          type: chartType.value,
          data: {
            labels: generateDateLabels(parseInt(timeRange.value)),
            datasets: [{
              label: 'Daily Usage (kg)',
              data: generateRandomData(parseInt(timeRange.value), 0.5, 2.5),
              backgroundColor: '#3B82F6',
              borderColor: '#3B82F6',
              borderWidth: 2,
              tension: 0.1,
              fill: false
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              },
              tooltip: {
                callbacks: {
                  label: function(context) {
                    return `${context.dataset.label}: ${context.parsed.y.toFixed(2)} kg`;
                  }
                }
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                title: {
                  display: true,
                  text: 'kg'
                }
              }
            }
          }
        });
        
        // Weekday Pattern Chart
        weekdayChartInstance = new Chart(weekdayChart.value.getContext('2d'), {
          type: 'bar',
          data: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
              label: 'Average Usage',
              data: [1.1, 1.0, 1.2, 1.3, 1.4, 1.6, 1.2],
              backgroundColor: '#10B981'
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              }
            },
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
        
        // Hourly Pattern Chart
        hourlyChartInstance = new Chart(hourlyChart.value.getContext('2d'), {
          type: 'line',
          data: {
            labels: Array.from({ length: 24 }, (_, i) => `${i}:00`),
            datasets: [{
              label: 'Usage by Hour',
              data: Array.from({ length: 24 }, () => Math.random() * 0.2 + 0.1),
              borderColor: '#6366F1',
              backgroundColor: 'rgba(99, 102, 241, 0.1)',
              tension: 0.3,
              fill: true
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              }
            },
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
        
        // Seasonal Pattern Chart
        seasonalChartInstance = new Chart(seasonalChart.value.getContext('2d'), {
          type: 'bar',
          data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            datasets: [{
              label: 'Monthly Average',
              data: [28, 26, 22, 18, 15, 12, 10, 11, 15, 20, 25, 28],
              backgroundColor: '#F59E0B'
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              }
            },
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
        
        // Refill History Chart
        refillChartInstance = new Chart(refillChart.value.getContext('2d'), {
          type: 'line',
          data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
            datasets: [{
              label: 'Days Between Refills',
              data: [25, 28, 22, 24, 20, 18],
              borderColor: '#EC4899',
              backgroundColor: 'rgba(236, 72, 153, 0.1)',
              tension: 0.3,
              fill: true
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
              legend: {
                display: false
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                title: {
                  display: true,
                  text: 'Days'
                }
              }
            }
          }
        });
        
        // Efficiency Chart
        efficiencyChartInstance = new Chart(efficiencyChart.value.getContext('2d'), {
          type: 'radar',
          data: {
            labels: ['Usage Rate', 'Leakage', 'Temperature', 'Humidity', 'Duration'],
            datasets: [{
              label: 'Current',
              data: [85, 92, 78, 80, 88],
              backgroundColor: 'rgba(59, 130, 246, 0.2)',
              borderColor: '#3B82F6',
              borderWidth: 2
            }, {
              label: 'Average',
              data: [78, 85, 75, 72, 80],
              backgroundColor: 'rgba(16, 185, 129, 0.2)',
              borderColor: '#10B981',
              borderWidth: 2
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
              r: {
                angleLines: {
                  display: true
                },
                suggestedMin: 50,
                suggestedMax: 100
              }
            }
          }
        });
      }
      
      // Watch for time range changes
      watch(timeRange, updateCharts);
      
      // Initialize on mount
      onMounted(() => {
        initCharts();
      });
      
      return {
        // Refs
        timeRange,
        chartType,
        averageDailyUsage,
        usageTrend,
        currentBottleDays,
        estimatedRefillDate,
        totalConsumption,
        firstRefillDate,
        peakUsage,
        peakUsageDate,
        lowestUsage,
        lowestUsageDate,
        averageRefillInterval,
        daysSinceLastRefill,
        averageRefillCost,
        currentEfficiency,
        averageEfficiency,
        tableHeaders,
        tableData,
        sortColumn,
        sortDirection,
        searchQuery,
        currentPage,
        dailyChart,
        weekdayChart,
        hourlyChart,
        seasonalChart,
        refillChart,
        efficiencyChart,
        
        // Computed
        usageTrendClass,
        filteredTableData: paginatedTableData,
        totalPages,
        
        // Methods
        updateCharts,
        setChartType,
        sortTable,
        prevPage,
        nextPage,
        exportData,
        exportFilteredData
      };
    }
  };
  </script>
  
  <style scoped>
  .gas-analytics-page {
    transition: all 0.3s ease;
  }
  
  /* Smooth transitions for charts */
  canvas {
    transition: opacity 0.3s ease;
  }
  
  /* Responsive table */
  @media (max-width: 640px) {
    .table-responsive {
      display: block;
      width: 100%;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
    }
  }
  </style>