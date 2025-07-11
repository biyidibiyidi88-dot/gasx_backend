<template>
    <div class="pricing-widget bg-gray-900/50 border border-gray-700 rounded-xl p-6 backdrop-blur-sm">
      <!-- Header with current plan -->
      <div class="flex justify-between items-start mb-6">
        <div>
          <h2 class="text-xl font-semibold text-gray-100">Your Plan</h2>
          <p class="text-gray-400 mt-1">
            <span class="text-blue-400">{{ currentPlan.name }}</span>
            <span v-if="currentPlan.sensors > 0" class="text-gray-500 ml-2">
              ({{ userSensors }}/{{ currentPlan.sensors }} sensors)
            </span>
          </p>
        </div>
        <span 
          v-if="showUpgradeBadge"
          class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-500/20 text-green-400"
        >
          Upgrade Available
        </span>
      </div>
  
      <!-- Sensor Status Card -->
      <div 
        v-if="currentPlan.sensors === 0"
        class="bg-orange-500/10 border border-orange-500/30 rounded-lg p-4 mb-6"
      >
        <div class="flex items-center">
          <svg class="h-5 w-5 text-orange-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
          </svg>
          <h3 class="text-sm font-medium text-orange-300">No Active Sensors</h3>
        </div>
        <p class="mt-2 text-sm text-orange-400/90">
          Add sensors to start monitoring gas levels in your home.
        </p>
      </div>
  
      <!-- Upgrade Options -->
      <div class="space-y-4">
        <h3 class="text-sm font-medium text-gray-300">Available Plans</h3>
        
        <!-- Basic Plan -->
        <div 
          @click="selectPlan('basic')"
          :class="{
            'border-blue-500': selectedPlan === 'basic',
            'border-gray-700 hover:border-gray-600': selectedPlan !== 'basic'
          }"
          class="border rounded-lg p-4 cursor-pointer transition-colors"
        >
          <div class="flex justify-between">
            <h4 class="font-medium text-gray-100">Basic</h4>
            <p class="text-blue-400">
              <span v-if="billingCycle === 'monthly'">$9.99</span>
              <span v-else>$7.99</span>
              <span class="text-gray-400 text-sm">/month</span>
            </p>
          </div>
          <ul class="mt-3 space-y-2 text-sm text-gray-400">
            <li class="flex items-center">
              <svg class="h-4 w-4 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              1 Sensor
            </li>
            <li class="flex items-center">
              <svg class="h-4 w-4 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
            'border-blue-500': selectedPlan === 'pro',
            'border-gray-700 hover:border-gray-600': selectedPlan !== 'pro'
          }"
          class="border rounded-lg p-4 cursor-pointer transition-colors"
        >
          <div class="flex justify-between">
            <div class="flex items-center">
              <h4 class="font-medium text-gray-100">Professional</h4>
              <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-500/20 text-blue-400">
                Recommended
              </span>
            </div>
            <p class="text-blue-400">
              <span v-if="billingCycle === 'monthly'">$19.99</span>
              <span v-else>$15.99</span>
              <span class="text-gray-400 text-sm">/month</span>
            </p>
          </div>
          <ul class="mt-3 space-y-2 text-sm text-gray-400">
            <li class="flex items-center">
              <svg class="h-4 w-4 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              5 Sensors
            </li>
            <li class="flex items-center">
              <svg class="h-4 w-4 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              SMS & Push Alerts
            </li>
          </ul>
        </div>
      </div>
  
      <!-- Billing Toggle -->
      <div class="mt-6 flex items-center justify-center bg-gray-800/50 rounded-lg p-1">
        <button
          @click="billingCycle = 'monthly'"
          :class="{
            'bg-gray-700 text-white': billingCycle === 'monthly',
            'text-gray-400 hover:bg-gray-700/50': billingCycle !== 'monthly'
          }"
          class="px-4 py-2 text-sm font-medium rounded-md transition-colors w-1/2"
        >
          Monthly
        </button>
        <button
          @click="billingCycle = 'annually'"
          :class="{
            'bg-gray-700 text-white': billingCycle === 'annually',
            'text-gray-400 hover:bg-gray-700/50': billingCycle !== 'annually'
          }"
          class="px-4 py-2 text-sm font-medium rounded-md transition-colors w-1/2"
        >
          Save 20% (Annual)
        </button>
      </div>
  
      <!-- CTA Button -->
      <button
        @click="handleUpgrade"
        class="mt-6 w-full py-2.5 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-medium transition-colors"
      >
        {{ ctaText }}
      </button>
  
      <!-- Sensor Purchase Option -->
      <div v-if="showSensorPurchase" class="mt-6 border-t border-gray-700 pt-6">
        <h4 class="text-sm font-medium text-gray-300 mb-3">Need more sensors?</h4>
        <button
          @click="navigateToSensorStore"
          class="w-full py-2 px-4 rounded-lg bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 transition-colors flex items-center justify-center"
        >
          <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
          </svg>
          Buy Additional Sensors
        </button>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed } from 'vue';
  import { useRouter } from 'vue-router';
  
  const router = useRouter();
  
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