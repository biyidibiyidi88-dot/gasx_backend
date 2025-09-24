<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen flex flex-col overflow-hidden']">
    <div class="max-w-4xl mx-auto py-4 px-4 sm:py-8 sm:px-6 lg:px-8 flex-1">
      <!-- Animated background elements -->
      <div class="absolute inset-0 overflow-hidden opacity-10">
        <div class="absolute -top-1/2 -right-1/2 w-full h-full bg-gradient-to-br from-blue-400 to-purple-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color"></div>
        <div class="absolute -bottom-1/2 -left-1/2 w-full h-full bg-gradient-to-tr from-cyan-400 to-blue-600 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob-color animation-delay-2000"></div>
      </div>
      
      <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg overflow-hidden relative animate-pulse-card']">
        <!-- Header -->
        <div :class="[themeClasses.border.primary, 'px-4 sm:px-6 py-4 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-2">
            <div class="flex items-center justify-between w-full">
              <div>
                <h2 :class="[themeClasses.text.primary, 'text-lg sm:text-xl font-semibold']">Gas Monitoring Plans</h2>
                <p :class="[themeClasses.text.secondary, 'mt-1 text-sm sm:text-base']">
                  <span :class="themeClasses.text.accent">{{ currentPlan.name }}</span>
                  <span v-if="currentPlan.sensors > 0" :class="[themeClasses.text.tertiary, 'ml-2']">
                    ({{ userSensors }}/{{ currentPlan.sensors }} sensors)
                  </span>
                </p>
              </div>
              <!-- Theme Toggle Button -->
              <button 
                @click="toggleTheme" 
                :class="[themeClasses.text.secondary, themeClasses.text.primary.replace('text-', 'hover:text-'), 'p-1 sm:p-2 rounded-lg transition-colors animate-hover-scale']"
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
            <span 
              v-if="showUpgradeBadge"
              :class="[themeClasses.alert.success, 'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium self-start sm:self-auto animate-pulse-badge']"
            >
              Upgrade Available
            </span>
          </div>
        </div>

        <!-- Tabs -->
        <div class="px-4 sm:px-6 py-4">
          <div class="border-b border-gray-200 dark:border-gray-700">
            <nav class="-mb-px flex space-x-8" aria-label="Tabs">
              <button
                @click="activeTab = 'plans'"
                :class="[
                  activeTab === 'plans' ? [themeClasses.text.accent, 'border-blue-500'] : [themeClasses.text.secondary, 'border-transparent hover:text-blue-500 hover:border-blue-500'],
                  'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm transition-colors animate-hover-scale'
                ]"
              >
                <svg class="h-4 w-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Plans
              </button>
              <button
                @click="activeTab = 'payment'"
                :disabled="!selectedPlan"
                :class="[
                  activeTab === 'payment' ? [themeClasses.text.accent, 'border-blue-500'] : [themeClasses.text.secondary, 'border-transparent hover:text-blue-500 hover:border-blue-500'],
                  'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm transition-colors animate-hover-scale',
                  !selectedPlan ? 'opacity-50 cursor-not-allowed' : ''
                ]"
              >
                <svg class="h-4 w-4 mr-2 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                </svg>
                Payment
              </button>
            </nav>
          </div>

          <!-- Plans Tab -->
          <div v-if="activeTab === 'plans'" class="mt-6 space-y-6">
            <div class="grid gap-6 sm:grid-cols-2">
              <div 
                v-for="plan in membershipPlans" 
                :key="plan.id"
                @click="selectPlan(plan.id)"
                :class="[
                  themeClasses.bg.card, 
                  themeClasses.shadow, 
                  selectedPlan === plan.id ? [themeClasses.border.accent, themeClasses.bg.selected] : [themeClasses.border.primary, themeClasses.border.secondary.replace('border-', 'hover:border-')],
                  'relative rounded-lg p-4 cursor-pointer transition-colors animate-pulse-card',
                  plan.popular ? 'border-blue-500' : ''
                ]"
              >
                <div v-if="plan.popular" :class="[themeClasses.alert.info, 'absolute -top-2 left-4 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium animate-pulse-badge']">
                  Popular
                </div>
                <div class="space-y-2">
                  <div class="flex justify-between items-center">
                    <h4 :class="[themeClasses.text.primary, 'text-lg font-semibold']">{{ plan.name }}</h4>
                    <p :class="themeClasses.text.accent">
                      {{ plan.displayPrice.toLocaleString() }} FCFA
                      <span :class="[themeClasses.text.tertiary, 'text-sm']">/month</span>
                    </p>
                  </div>
                  <p :class="[themeClasses.text.secondary, 'text-sm']">Perfect for your gas monitoring needs</p>
                  <ul :class="[themeClasses.text.secondary, 'space-y-2 text-sm']">
                    <li v-for="(feature, index) in plan.features" :key="index" class="flex items-center">
                      <svg :class="[themeClasses.text.success, 'h-4 w-4 mr-2 flex-shrink-0']" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                      </svg>
                      {{ feature }}
                    </li>
                  </ul>
                  <button 
                    :class="[themeClasses.button.primary, 'w-full mt-4 py-2 rounded-md text-sm font-medium transition-colors animate-hover-glow', plan.popular ? '' : themeClasses.button.secondary]"
                  >
                    Select {{ plan.name }} Plan
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Payment Tab -->
          <div v-if="activeTab === 'payment' && selectedPlan" class="mt-6 space-y-6 max-w-2xl mx-auto">
            <!-- Selected Plan -->
            <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg animate-pulse-card']">
              <div :class="[themeClasses.border.primary, 'px-4 py-3 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
                <h3 :class="[themeClasses.text.primary, 'text-lg font-medium']">Selected Plan</h3>
              </div>
              <div class="p-4">
                <div :class="[themeClasses.bg.secondary, 'flex items-center justify-between p-4 rounded-lg']">
                  <div>
                    <h4 :class="[themeClasses.text.primary, 'font-semibold']">{{ selectedPlan.name }} Plan</h4>
                    <p :class="[themeClasses.text.secondary, 'text-sm']">
                      {{ selectedPlan.displayPrice.toLocaleString() }} FCFA per month
                    </p>
                  </div>
                  <button 
                    @click="activeTab = 'plans'"
                    :disabled="isProcessing"
                    :class="[themeClasses.button.secondary, 'text-sm px-3 py-1 rounded-md animate-hover-scale']"
                  >
                    Change Plan
                  </button>
                </div>
              </div>
            </div>

            <!-- Payment Details -->
            <div :class="[themeClasses.bg.card, themeClasses.shadow, 'rounded-lg animate-pulse-card']">
              <div :class="[themeClasses.border.primary, 'px-4 py-3 border-b bg-gradient-to-br from-blue-500/10 to-purple-500/10 animate-gradient-shift']">
                <h3 :class="[themeClasses.text.primary, 'text-lg font-medium']">Payment Details</h3>
                <p :class="[themeClasses.text.secondary, 'text-sm']">Complete your payment using your mobile money account</p>
              </div>
              <div class="p-4 space-y-4">
                <!-- Phone Number -->
                <div class="space-y-2">
                  <label :class="[themeClasses.text.primary, 'block text-sm font-medium']">Phone Number</label>
                  <div class="flex space-x-2">
                    <div :class="[themeClasses.bg.secondary, 'flex items-center rounded-md border px-3 text-sm']">+237</div>
                    <input 
                      v-model="phoneNumber"
                      type="text"
                      placeholder="6XX XXX XXX"
                      :class="[themeClasses.bg.secondary, themeClasses.text.primary, themeClasses.border.primary, 'flex-1 px-3 py-2 border rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500 animate-input-focus']"
                      :disabled="isProcessing"
                      @input="phoneNumber = phoneNumber.replace(/\D/g, '')"
                    >
                  </div>
                  <p :class="[themeClasses.text.secondary, 'text-sm']">
                    Enter your {{ selectedPaymentMethod.name }} number
                  </p>
                </div>

                <!-- Payment Method -->
                <div class="space-y-2">
                  <label :class="[themeClasses.text.primary, 'block text-sm font-medium']">Payment Method</label>
                  <div class="grid grid-cols-2 gap-4">
                    <button
                      v-for="method in paymentMethods"
                      :key="method.id"
                      @click="selectedPaymentMethod = method"
                      :disabled="isProcessing"
                      :class="[
                        selectedPaymentMethod.id === method.id ? [method.color, method.textColor] : [themeClasses.border.primary, themeClasses.border.accent.replace('border-', 'hover:border-')],
                        'flex items-center space-x-2 p-3 rounded-md text-sm font-medium transition-colors animate-hover-scale'
                      ]"
                    >
                      <span class="text-xl">{{ method.icon }}</span>
                      <span>{{ method.name }}</span>
                    </button>
                  </div>
                </div>

                <!-- Summary -->
                <div class="pt-4">
                  <div class="flex items-center justify-between py-2">
                    <span :class="[themeClasses.text.secondary, 'text-sm']">Plan</span>
                    <span :class="[themeClasses.text.primary, 'text-sm font-medium']">{{ selectedPlan.name }}</span>
                  </div>
                  <div class="flex items-center justify-between py-2">
                    <span :class="[themeClasses.text.secondary, 'text-sm']">Billing Cycle</span>
                    <span :class="[themeClasses.text.primary, 'text-sm font-medium']">Monthly</span>
                  </div>
                  <div class="flex items-center justify-between py-2 font-semibold border-t mt-4 pt-4">
                    <span :class="[themeClasses.text.primary, 'text-sm']">Total Amount</span>
                    <span :class="[themeClasses.text.primary, 'text-sm']">{{ selectedPlan.displayPrice.toLocaleString() }} FCFA</span>
                  </div>
                </div>
              </div>
              <div class="p-4 flex flex-col space-y-2">
                <button 
                  @click="handlePayment"
                  :disabled="isProcessing || !phoneNumber"
                  :class="[
                    themeClasses.button.primary,
                    'w-full py-3 rounded-md text-sm font-medium transition-colors animate-hover-glow',
                    isProcessing || !phoneNumber ? [themeClasses.button.disabled, 'cursor-not-allowed'] : ''
                  ]"
                >
                  <span v-if="isProcessing">{{ renderPaymentStatus }}</span>
                  <span v-else>Pay {{ selectedPlan.displayPrice.toLocaleString() }} FCFA</span>
                </button>
                <div v-if="paymentStatus === 'success'" :class="[themeClasses.alert.success, 'p-3 rounded-md text-sm animate-pulse-alert']">
                  <div class="flex items-center">
                    <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    Payment successful! Your {{ selectedPlan.name }} plan has been activated.
                  </div>
                  <div v-if="transactionRef" :class="[themeClasses.text.secondary, 'mt-2 text-xs opacity-75']">
                    Transaction ID: {{ transactionRef }}
                  </div>
                </div>
                <div v-else-if="paymentStatus === 'failed'" :class="[themeClasses.alert.error, 'p-3 rounded-md text-sm animate-pulse-alert']">
                  <div class="flex items-center">
                    <svg class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    Payment failed. Please try again.
                  </div>
                </div>
                <p v-else :class="[themeClasses.text.secondary, 'text-xs text-center']">
                  By proceeding, you agree to our Terms of Service and Privacy Policy.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useTheme } from '../../composables/useTheme'
import axios from 'axios'

// CamPay API Configuration
const CAMPAY_BASE_URL = 'https://demo.campay.net/api'
const CAMPAY_ACCESS_TOKEN = '81306ed002da31cea33d6d04ce2c7ccbc08b6aa5'

// Membership plans
const membershipPlans = [
  {
    id: 'basic',
    name: 'Basic',
    displayPrice: 9990, // CFA
    apiPrice: 99, // XAF for CamPay
    sensors: 1,
    features: [
      '1 Sensor',
      'Email Alerts'
    ],
    popular: false
  },
  {
    id: 'pro',
    name: 'Professional',
    displayPrice: 19990, // CFA
    apiPrice: 199, // XAF for CamPay
    sensors: 5,
    features: [
      '5 Sensors',
      'Email & SMS Alerts',
      'AI Predictions'
    ],
    popular: true
  }
]

// Payment methods
const paymentMethods = [
  {
    id: 'orange',
    name: 'Orange Money',
    icon: '🟠',
    color: 'bg-orange-500',
    textColor: 'text-orange-600'
  },
  {
    id: 'mtn',
    name: 'MTN Mobile Money',
    icon: '🟡',
    color: 'bg-yellow-500',
    textColor: 'text-yellow-600'
  }
]

// State
const router = useRouter()
const { isDark, toggleTheme, themeClasses } = useTheme()
const activeTab = ref('plans')
const userPlan = ref('free')
const userSensors = ref(0)
const selectedPlan = ref(null)
const selectedPaymentMethod = ref(paymentMethods[1]) // Default to MTN
const phoneNumber = ref('')
const isProcessing = ref(false)
const paymentStatus = ref(null) // 'processing' | 'pending' | 'success' | 'failed' | null
const transactionRef = ref('')

// Computed properties
const plans = {
  free: { name: 'Free', sensors: 0 },
  basic: { name: 'Basic', sensors: 1 },
  pro: { name: 'Professional', sensors: 5 }
}

const currentPlan = computed(() => plans[userPlan.value])
const showUpgradeBadge = computed(() => userPlan.value !== 'pro')
const showSensorPurchase = computed(() => userPlan.value !== 'free' && userSensors.value >= currentPlan.value.sensors)

// Methods
const selectPlan = (planId) => {
  if (userPlan.value === planId) {
    selectedPlan.value = null
    activeTab.value = 'plans'
  } else {
    selectedPlan.value = membershipPlans.find(plan => plan.id === planId)
    activeTab.value = 'payment'
  }
}

const handlePayment = async () => {
  if (!selectedPlan.value || !selectedPaymentMethod.value || !phoneNumber.value) {
    alert('Please select a plan, payment method, and enter your phone number.')
    return
  }

  isProcessing.value = true
  paymentStatus.value = 'processing'

  let formattedPhone = phoneNumber.value.trim()
  if (!formattedPhone.startsWith('237')) {
    formattedPhone = '237' + formattedPhone.replace(/^\+?237?/, '')
  }

  try {
    const response = await axios.post(
      `${CAMPAY_BASE_URL}/collect/`,
      {
        amount: selectedPlan.value.apiPrice,
        currency: 'XAF',
        from: formattedPhone,
        description: `Gas Monitoring ${selectedPlan.value.name} Plan`,
        external_reference: `PLAN-${Date.now()}`
      },
      {
        headers: {
          'Authorization': `Token ${CAMPAY_ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    )

    transactionRef.value = response.data.reference
    paymentStatus.value = 'pending'

    alert('Payment request sent. Please check your phone to complete the payment.')
    pollPaymentStatus(response.data.reference)
  } catch (error) {
    console.error('Payment error:', error)
    paymentStatus.value = 'failed'
    isProcessing.value = false
    alert(error.response?.data?.message || 'An error occurred while processing your payment.')
  }
}

const pollPaymentStatus = async (reference) => {
  try {
    const response = await axios.get(
      `${CAMPAY_BASE_URL}/transaction/${reference}/`,
      {
        headers: {
          'Authorization': `Token ${CAMPAY_ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    )

    const status = response.data.status

    if (status === 'SUCCESSFUL') {
      paymentStatus.value = 'success'
      isProcessing.value = false
      alert(`Your ${selectedPlan.value.name} plan has been activated!`)
      userPlan.value = selectedPlan.value.id
      selectedPlan.value = null
      activeTab.value = 'plans'
    } else if (status === 'FAILED') {
      paymentStatus.value = 'failed'
      isProcessing.value = false
      alert('Payment failed. Please try again.')
    } else {
      setTimeout(() => pollPaymentStatus(reference), 5000)
    }
  } catch (error) {
    console.error('Error checking payment status:', error)
    paymentStatus.value = 'failed'
    isProcessing.value = false
    alert('An error occurred while checking your payment status. Please check your transaction history.')
  }
}

const navigateToSensorStore = () => {
  router.push('/sensors')
}

const renderPaymentStatus = computed(() => {
  switch (paymentStatus.value) {
    case 'processing':
      return `
        <div class="flex items-center space-x-2 ${themeClasses.text.primary}">
          <svg class="h-4 w-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          <span>Processing payment request...</span>
        </div>
      `
    case 'pending':
      return `
        <div class="flex items-center space-x-2 ${themeClasses.text.warning}">
          <svg class="h-4 w-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          <span>Payment pending - Check your phone</span>
        </div>
      `
    default:
      return ''
  }
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
::-webkit-scrollbar {
  width: 8px;
}
::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
}
::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
}
::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.2);
}

/* Ensure text stays within frame */
.break-words {
  word-break: break-word;
  overflow-wrap: break-word;
  hyphens: auto;
}
</style>