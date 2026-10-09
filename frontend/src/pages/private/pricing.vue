<template>
  <div :class="[themeClasses.bg.primary, 'flex-1 flex flex-col overflow-hidden relative font-[\'Inter\',-apple-system,BlinkMacSystemFont,sans-serif]']">
    
    <!-- Sophisticated Background Accents -->
    <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-blue-500/5 blur-[150px] -z-10 animate-pulse"></div>
    <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-teal-600/5 blur-[180px] -z-10 animate-pulse" style="animation-delay: 2s"></div>

    <!-- Header / Nav -->
    <header class="z-10 bg-white/[0.01] backdrop-blur-xl border-b border-white/5">
      <div class="flex items-center justify-between px-8 py-5">
        <div class="flex items-center space-x-4">
          <div class="w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Plans / <span class="text-white/80">Choose a plan</span></h1>
        </div>
        
        <div class="flex items-center gap-6">
          <div class="text-right">
            <div class="text-[9px] font-black text-white/20 uppercase tracking-widest italic">Active Tier</div>
            <div class="text-[11px] font-bold text-teal-400 uppercase italic tracking-widest">{{ currentPlan.name }} plan</div>
          </div>
          <button @click="toggleTheme" class="p-2.5 bg-white/5 border border-white/10 rounded-xl text-white/40 hover:text-white transition-all">
            <svg v-if="isDark" class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
            <svg v-else class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/></svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar max-w-5xl mx-auto w-full">
      
      <!-- Tier Overview Card -->
      <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3.5rem] p-10 relative overflow-hidden group/main">
        <div class="absolute inset-0 bg-gradient-to-br from-teal-400/[0.02] to-transparent pointer-events-none"></div>
        
        <div class="flex flex-col md:flex-row justify-between items-center gap-8 relative z-10">
          <div>
            <h2 class="text-4xl font-black text-white italic uppercase tracking-tighter mb-2">Choose a plan</h2>
            <p class="text-[10px] font-bold text-white/30 uppercase tracking-[0.4em] italic">Choose how many gas sensors to use.</p>
          </div>

          <!-- Navigation Tabs -->
          <div class="flex p-1.5 bg-white/5 rounded-2xl border border-white/5">
            <button @click="activeTab = 'plans'" :class="activeTab === 'plans' ? 'bg-teal-400 text-gray-950' : 'text-white/40 hover:text-white'" class="px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all duration-500 italic">Plans</button>
            <button @click="activeTab = 'payment'" :disabled="!selectedPlan" :class="activeTab === 'payment' ? 'bg-teal-400 text-gray-950' : 'text-white/40 hover:text-white disabled:opacity-20'" class="px-6 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all duration-500 italic">Payment</button>
          </div>
        </div>

        <!-- Plans Pro -->
        <div v-if="activeTab === 'plans'" class="grid grid-cols-1 md:grid-cols-2 gap-8 mt-12">
          <div 
            v-for="plan in membershipPlans" 
            :key="plan.id"
            @click="selectPlan(plan.id)"
            class="group/plan p-8 rounded-[2.5rem] border transition-all duration-500 cursor-pointer relative overflow-hidden"
            :class="selectedPlan?.id === plan.id ? 'bg-teal-400/10 border-teal-400/40 shadow-2xl' : 'bg-white/5 border-white/5 hover:border-white/20'"
          >
            <div v-if="plan.popular" class="absolute top-6 right-6 px-3 py-1 bg-teal-400 rounded-full text-[8px] font-black text-gray-950 uppercase tracking-widest italic animate-pulse">Best value</div>
            
            <div class="relative z-10 space-y-6">
              <div>
                <h4 class="text-[11px] font-black text-teal-400/60 uppercase tracking-widest mb-1 italic">{{ plan.name }} plan</h4>
                <div class="flex items-baseline gap-2">
                  <span class="text-4xl font-black text-white italic tracking-tighter">{{ plan.displayPrice.toLocaleString() }}</span>
                  <span class="text-[10px] font-black text-white/20 uppercase tracking-widest italic">FCFA / month</span>
                </div>
              </div>

              <ul class="space-y-3">
                <li v-for="feat in plan.features" :key="feat" class="flex items-center gap-3">
                  <div class="w-1.5 h-1.5 rounded-full bg-teal-400/40"></div>
                  <span class="text-[10px] font-bold text-white/40 uppercase tracking-widest italic">{{ feat }}</span>
                </li>
              </ul>

              <button class="w-full py-4 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all duration-500 italic" :class="selectedPlan?.id === plan.id ? 'bg-teal-400 text-gray-950' : 'bg-white/5 text-white border border-white/10 group-hover/plan:bg-white/10'">
                Choose this plan
              </button>
            </div>
          </div>
        </div>

        <!-- Payment Layer -->
        <div v-if="activeTab === 'payment' && selectedPlan" class="mt-12 space-y-12 animate-in">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
            
            <!-- Terminal Params -->
            <div class="space-y-8 bg-white/5 p-8 rounded-[2.5rem] border border-white/5">
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/40 italic ml-4">Your details</h3>
              
              <div class="space-y-4">
                 <div class="space-y-2 group/input">
                    <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic group-focus-within/input:text-teal-400 transition-colors">Phone number</label>
                    <div class="flex gap-2">
                      <div class="px-4 py-4 bg-white/5 border border-white/5 rounded-2xl text-white/40 text-sm font-black italic">+237</div>
                      <input v-model="phoneNumber" type="tel" placeholder="6XX XXX XXX" class="flex-1 px-6 py-4 bg-white/5 border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.08] focus:outline-none text-white text-sm font-black italic tracking-tight transition-all">
                    </div>
                </div>

                <div class="space-y-3">
                   <label class="text-[9px] font-black uppercase tracking-widest text-white/20 ml-4 italic">Payment method</label>
                   <div class="grid grid-cols-2 gap-4">
                    <button 
                      v-for="method in paymentMethods" 
                      :key="method.id" 
                      @click="selectedPaymentMethod = method"
                      class="p-4 rounded-2xl border transition-all duration-500 flex items-center gap-4"
                      :class="selectedPaymentMethod.id === method.id ? 'bg-teal-400/10 border-teal-400 text-teal-400' : 'bg-white/5 border-white/5 text-white/20 hover:border-white/10'"
                    >
                      <span class="text-xl grayscale transition-all" :class="selectedPaymentMethod.id === method.id ? 'grayscale-0' : ''">{{ method.icon }}</span>
                      <span class="text-[10px] font-black uppercase tracking-widest italic">{{ method.name }}</span>
                    </button>
                   </div>
                </div>
              </div>
            </div>

            <!-- Payment Summary -->
            <div class="space-y-8 bg-white/5 p-8 rounded-[2.5rem] border border-white/5 relative overflow-hidden group/summary">
              <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-teal-400/[0.03] to-transparent pointer-events-none"></div>
              <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/40 italic ml-4 relative z-10">Order summary</h3>
              
              <div class="space-y-4 relative z-10">
                <div v-for="(val, label) in { PLAN: selectedPlan.name, MONTH: 'MONTHLY', SENSORS: selectedPlan.sensors }" :key="label" class="flex justify-between items-center border-b border-white/5 pb-2">
                  <span class="text-[9px] font-black text-white/20 uppercase tracking-widest italic">{{ label }}</span>
                  <span class="text-[11px] font-black text-white italic">{{ val }}</span>
                </div>
                <div class="flex justify-between items-center pt-4">
                  <span class="text-[10px] font-black text-teal-400 uppercase tracking-[0.2em] italic">Total</span>
                  <span class="text-2xl font-black text-white italic tracking-tighter underline decoration-teal-400/40">{{ selectedPlan.displayPrice.toLocaleString() }} FCFA</span>
                </div>
              </div>

              <button 
                @click="handlePayment" 
                :disabled="isProcessing || !phoneNumber || paymentStatus === 'pending' || paymentStatus === 'unknown'"
                class="w-full py-5 bg-teal-400 hover:bg-teal-300 disabled:bg-white/5 disabled:text-white/20 rounded-2xl text-[11px] font-black uppercase tracking-[0.3em] text-gray-950 transition-all hover:shadow-[0_0_40px_rgba(45,212,191,0.4)] relative z-10 overflow-hidden"
              >
                 <span v-if="isProcessing">{{ paymentStatus === 'pending' ? 'Waiting for you to approve the payment...' : 'Confirming payment...' }}</span>
                 <span v-else-if="paymentStatus === 'pending'">Payment pending</span>
                 <span v-else-if="paymentStatus === 'unknown'">Payment needs support</span>
                 <span v-else>Start payment</span>
              </button>
            </div>
          </div>

          <!-- Status Alerts -->
          <div v-if="paymentStatus === 'paid'" class="bg-teal-400/10 border border-teal-400/20 p-6 rounded-3xl flex items-center gap-6 animate-pulse">
            <div class="w-12 h-12 rounded-2xl bg-teal-400/20 flex items-center justify-center text-teal-400"><svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg></div>
            <div>
              <h4 class="text-[11px] font-black text-teal-400 uppercase tracking-widest italic">Payment complete</h4>
              <p class="text-[9px] font-bold text-white/40 uppercase tracking-widest italic leading-relaxed">Your plan is active. Payment reference: {{ transactionRef }}.</p>
            </div>
          </div>
          <div v-else-if="paymentStatus === 'pending'" class="bg-amber-400/10 border border-amber-400/20 p-6 rounded-3xl flex flex-wrap items-center justify-between gap-4">
            <div>
              <h4 class="text-[11px] font-black text-amber-200 uppercase tracking-widest">Payment is pending</h4>
              <p class="mt-2 text-sm text-white/60">{{ statusMessage || 'Approve the DigiPay prompt on your phone.' }}</p>
              <p v-if="transactionRef" class="mt-2 text-xs text-white/40">Reference: {{ transactionRef }}</p>
            </div>
            <button @click="checkPaymentStatus" :disabled="statusChecking" class="rounded-xl border border-amber-200/30 px-4 py-3 text-xs font-bold text-amber-100 disabled:opacity-50">{{ statusChecking ? 'Checking…' : 'Check payment' }}</button>
          </div>
          <div v-else-if="paymentStatus === 'failed' || paymentStatus === 'unknown'" class="bg-red-400/10 border border-red-400/20 p-6 rounded-3xl">
            <h4 class="text-[11px] font-black text-red-200 uppercase tracking-widest">{{ paymentStatus === 'failed' ? 'Payment failed' : 'Payment needs support' }}</h4>
            <p class="mt-2 text-sm text-white/60">{{ statusMessage }}</p>
            <button v-if="paymentStatus === 'unknown' && paymentId && transactionRef" @click="checkPaymentStatus" :disabled="statusChecking" class="mt-4 rounded-xl border border-red-200/30 px-4 py-3 text-xs font-bold text-red-100 disabled:opacity-50">{{ statusChecking ? 'Checking…' : 'Check payment' }}</button>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useTheme } from '../../composables/useTheme'
import api from '../../config/api'

const { isDark, toggleTheme, themeClasses } = useTheme()

const membershipPlans = [
  { id: 'basic', name: 'Basic', displayPrice: 9990, sensors: 1, features: ['1 gas sensor', 'Email alerts', 'Gas readings'], popular: false },
  { id: 'pro', name: 'Professional', displayPrice: 19990, sensors: 5, features: ['5 gas sensors', 'App, email, and text alerts', 'Gas use reports'], popular: true }
]

const paymentMethods = [
  { id: 'orange', name: 'Orange', icon: '🟠' },
  { id: 'mtn', name: 'MTN', icon: '🟡' }
]

const activeTab = ref('plans')
const userPlan = ref('free')
const selectedPlan = ref(null)
const selectedPaymentMethod = ref(paymentMethods[1])
const phoneNumber = ref('')
const isProcessing = ref(false)
const paymentStatus = ref(null)
const transactionRef = ref('')
const paymentId = ref(null)
const statusMessage = ref('')
const statusChecking = ref(false)
let pollTimer = null

const currentPlan = computed(() =>
  ({ free: { name: 'Free' }, basic: { name: 'Basic' }, pro: { name: 'Pro' } }[userPlan.value])
)

const selectPlan = (id) => {
  if (['pending', 'unknown'].includes(paymentStatus.value)) return
  clearTimeout(pollTimer)
  selectedPlan.value = membershipPlans.find((plan) => plan.id === id)
  paymentStatus.value = null
  paymentId.value = null
  transactionRef.value = ''
  statusMessage.value = ''
  activeTab.value = 'payment'
}

const loadCurrentPlan = async () => {
  try {
    const { data } = await api.get('subscription/')
    userPlan.value = data.plan || 'free'
  } catch (_) {
    // The plans page remains usable when the account summary is unavailable.
  }
}

const pollStatus = async (retries = 0) => {
  if (!paymentId.value || statusChecking.value) return
  statusChecking.value = true
  let shouldRetry = false
  try {
    const { data } = await api.post('payments/subscriptions/' + paymentId.value + '/status/')
    paymentStatus.value = String(data.payment_status || 'UNKNOWN').toLowerCase()
    statusMessage.value = data.message || ''
    transactionRef.value = data.transaction_id || transactionRef.value
    if (paymentStatus.value === 'paid') {
      isProcessing.value = false
      await loadCurrentPlan()
    } else if (paymentStatus.value === 'failed') {
      isProcessing.value = false
    } else {
      shouldRetry = retries > 0 && Boolean(transactionRef.value)
    }
  } catch (error) {
    statusMessage.value = error.response?.data?.message || 'Could not check the DigiPay payment yet.'
    shouldRetry = retries > 0 && Boolean(transactionRef.value)
  } finally {
    statusChecking.value = false
  }

  if (shouldRetry) {
    pollTimer = setTimeout(() => pollStatus(retries - 1), 5000)
  } else if (paymentStatus.value !== 'paid' && paymentStatus.value !== 'failed') {
    isProcessing.value = false
  }
}

const checkPaymentStatus = () => pollStatus(0)

const handlePayment = async () => {
  if (!selectedPlan.value || !phoneNumber.value || isProcessing.value || ['pending', 'unknown'].includes(paymentStatus.value)) return
  isProcessing.value = true
  paymentStatus.value = 'processing'
  statusMessage.value = ''
  transactionRef.value = ''
  paymentId.value = null

  try {
    const { data } = await api.post('payments/subscriptions/initiate/', {
      plan: selectedPlan.value.id,
      payment_operator: selectedPaymentMethod.value.id === 'orange' ? 'ORANGE_MONEY' : 'MTN_MOMO',
      payer_phone: phoneNumber.value.trim()
    })
    paymentId.value = data.payment_id
    transactionRef.value = data.transaction_id || ''
    statusMessage.value = data.message || ''
    paymentStatus.value = String(data.payment_status || 'UNKNOWN').toLowerCase()

    if (paymentStatus.value === 'paid') {
      await loadCurrentPlan()
      isProcessing.value = false
    } else if (paymentStatus.value === 'pending') {
      pollStatus(12)
    } else {
      isProcessing.value = false
    }
  } catch (error) {
    paymentStatus.value = 'failed'
    statusMessage.value = error.response?.data?.detail ||
      error.response?.data?.payer_phone?.[0] ||
      'Could not start the DigiPay payment.'
    isProcessing.value = false
  }
}

onMounted(loadCurrentPlan)
onBeforeUnmount(() => clearTimeout(pollTimer))
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }
.scrollbar-hide::-webkit-scrollbar { display: none; }
.animate-in { animation: slideUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
</style>
