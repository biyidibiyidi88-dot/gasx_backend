<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen']">
    <div class="max-w-3xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden']">
        <!-- Header with current plan -->
        <div :class="[themeClasses.border.primary, 'px-6 py-4 border-b']">
          <div class="flex justify-between items-start">
            <div>
              <div class="flex items-center space-x-4">
                <h2 :class="[themeClasses.text.primary, 'text-xl font-semibold']">Your Plan</h2>
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
              <p :class="[themeClasses.text.secondary, 'mt-1']">
                <span :class="themeClasses.text.accent">{{ currentPlan.name }}</span>
                <span v-if="currentPlan.sensors > 0" :class="[themeClasses.text.tertiary, 'ml-2']">
                  ({{ userSensors }}/{{ currentPlan.sensors }} sensors)
                </span>
              </p>
            </div>
            <span 
              v-if="showUpgradeBadge"
              :class="[themeClasses.alert.success, 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium']"
            >
              Upgrade Available
            </span>
          </div>
        </div>
  
      <div class="px-6 py-4">
        <!-- Sensor Status Card -->
        <div 
          v-if="currentPlan.sensors === 0"
          :class="[themeClasses.alert.warning, 'rounded-lg p-4 mb-6']"
        >
          <div class="flex items-center">
            <svg :class="[themeClasses.text.warning, 'h-5 w-5 mr-2']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
            </svg>
            <h3 :class="[themeClasses.text.warning, 'text-sm font-medium']">No Active Sensors</h3>
          </div>
          <p :class="[themeClasses.text.warning, 'mt-2 text-sm']">
            Add sensors to start monitoring gas levels in your home.
          </p>
        </div>
  
        <!-- Upgrade Options -->
        <div class="space-y-4">
          <h3 :class="[themeClasses.text.primary, 'text-sm font-medium']">Available Plans</h3>
        
          <!-- Basic Plan -->
          <div 
            @click="selectPlan('basic')"
            :class="[
              selectedPlan === 'basic' ? [themeClasses.border.accent, themeClasses.bg.selected] : [themeClasses.border.primary, themeClasses.border.secondary.replace('border-', 'hover:border-')],
              'border rounded-lg p-4 cursor-pointer transition-colors'
            ]"
          >
            <div class="flex justify-between">
              <h4 :class="[themeClasses.text.primary, 'font-medium']">Basic</h4>
              <p :class="themeClasses.text.accent">
                <span v-if="billingCycle === 'monthly'">$9.99</span>
                <span v-else>$7.99</span>
                <span :class="[themeClasses.text.tertiary, 'text-sm']">/month</span>
              </p>
            </div>
            <ul :class="[themeClasses.text.secondary, 'mt-3 space-y-2 text-sm']">
              <li class="flex items-center">
                <svg :class="[themeClasses.text.success, 'h-4 w-4 mr-2']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                1 Sensor
              </li>
              <li class="flex items-center">
                <svg :class="[themeClasses.text.success, 'h-4 w-4 mr-2']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                Email Alerts
              </li>
            </ul>
          </div>
  
          <!-- Pro Plan -->
          <div 
            @click="selectPlan('pro')"
            :class="{
              'border-blue-500 bg-blue-50': selectedPlan === 'pro',
              'border-gray-200 hover:border-gray-300': selectedPlan !== 'pro'
            }"
            class="border rounded-lg p-4 cursor-pointer transition-colors"
          >
            <div class="flex justify-between">
              <div class="flex items-center">
                <h4 class="font-medium text-gray-900">Professional</h4>
                <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                  Recommended
                </span>
              </div>
              <p class="text-blue-600">
                <span v-if="billingCycle === 'monthly'">$19.99</span>
                <span v-else>$15.99</span>
                <span class="text-gray-500 text-sm">/month</span>
              </p>
            </div>
            <ul class="mt-3 space-y-2 text-sm text-gray-600">
              <li class="flex items-center">
                <svg class="h-4 w-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                5 Sensors
              </li>
              <li class="flex items-center">
                <svg class="h-4 w-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                Email & SMS Alerts
              </li>
              <li class="flex items-center">
                <svg class="h-4 w-4 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                AI Predictions
              </li>
            </ul>
          </div>
        </div>
  
        <!-- Billing Cycle Toggle -->
        <div class="mt-6 flex items-center justify-center bg-gray-100 rounded-lg p-1">
          <button
            @click="billingCycle = 'monthly'"
            :class="{
              'bg-white text-gray-900 shadow-sm': billingCycle === 'monthly',
              'text-gray-600 hover:text-gray-800': billingCycle !== 'monthly'
            }"
            class="px-3 py-1 rounded-md text-sm font-medium transition-colors"
          >
            Monthly
          </button>
          <button
            @click="billingCycle = 'yearly'"
            :class="{
              'bg-white text-gray-900 shadow-sm': billingCycle === 'yearly',
              'text-gray-600 hover:text-gray-800': billingCycle !== 'yearly'
            }"
            class="px-3 py-1 rounded-md text-sm font-medium transition-colors"
          >
            Yearly
            <span class="ml-1 text-xs text-green-600">(Save 20%)</span>
          </button>
        </div>
  
        <!-- Upgrade Button -->
        <div class="mt-6">
          <button
            @click="handleUpgrade"
            :disabled="!selectedPlan"
            class="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed text-white py-3 px-4 rounded-lg font-medium transition-colors"
          >
            {{ selectedPlan ? `Upgrade to ${selectedPlan.charAt(0).toUpperCase() + selectedPlan.slice(1)}` : 'Select a Plan' }}
          </button>
        </div>

        <!-- Add Sensor Button -->
        <div class="mt-4">
          <button
            @click="navigateToSensorStore"
            class="w-full bg-gray-100 hover:bg-gray-200 text-gray-800 py-2 px-4 rounded-lg font-medium transition-colors"
          >
            Add New Sensor
          </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useTheme } from '../../composables/useTheme';

const router = useRouter();

// Theme composable
const { isDark, toggleTheme, themeClasses } = useTheme();

// User data (would come from your store/API)
const userPlan = ref('free'); // 'free' | 'basic' | 'pro' | 'enterprise'
const userSensors = ref(0); // Current connected sensors
const billingCycle = ref('monthly');
const selectedPlan = ref(null);

const plans = {
  free: { name: "Free", sensors: 0 },
  basic: { name: "Basic", sensors: 1 },
  pro: { name: "Professional", sensors: 5 },
  enterprise: { name: "Enterprise", sensors: 999 }
};

const currentPlan = computed(() => plans[userPlan.value]);
const showUpgradeBadge = computed(() => userPlan.value !== 'pro' && userPlan.value !== 'enterprise');
const showSensorPurchase = computed(() => userPlan.value !== 'free' && userSensors.value >= currentPlan.value.sensors);

const ctaText = computed(() => {
  if (userPlan.value === 'free') return 'Start Monitoring';
  if (selectedPlan.value === userPlan.value) return 'Manage Plan';
  return selectedPlan.value ? 'Upgrade Plan' : 'Select a Plan';
});

function selectPlan(plan) {
  if (userPlan.value === plan) {
    selectedPlan.value = null;
  } else {
    selectedPlan.value = plan;
  }
}
  
  function handleUpgrade() {
    if (!selectedPlan.value) return;
    
    // Handle different scenarios
    if (userPlan.value === 'free') {
      router.push('/sensor-setup'); // First-time sensor setup
    } else if (selectedPlan.value === userPlan.value) {
      router.push('/account/billing'); // Manage existing plan
    } else {
      // Initiate upgrade flow
      console.log(`Upgrading to ${selectedPlan.value} plan`);
      // Would trigger payment modal or redirect
    }
  }
  
  function navigateToSensorStore() {
    router.push('/sensors');
  }
  </script>
  
  <style scoped>
  .pricing-widget {
    transition: all 0.3s ease;
  }
  
  /* Pulse animation for upgrade badge */
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.7; }
  }
  
  .bg-green-500\/20 {
    animation: pulse 2s infinite;
  }
  </style>