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
          <h1 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 italic">Logistics / <span class="text-white/80">Node Supply Matrix</span></h1>
        </div>
        
        <div class="flex items-center gap-4">
           <div class="px-4 py-1.5 rounded-full bg-teal-400/5 border border-teal-400/20 text-[9px] font-black text-teal-400 uppercase tracking-widest italic">
            GRID_ACTIVE: EU_WEST_1
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-8 space-y-8 custom-scrollbar">
      
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
        
        <!-- Interactive Node Radar (Map Placeholder) -->
        <div class="lg:col-span-2 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3.5rem] p-12 h-[500px] relative overflow-hidden group/radar">
          <div class="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-teal-400/[0.03] via-transparent to-transparent opacity-50 group-hover/radar:opacity-100 transition-opacity duration-1000"></div>
          
          <!-- Radar Grid -->
          <div class="absolute inset-0 opacity-10 pointer-events-none" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 40px 40px;"></div>
          
          <div class="relative h-full flex flex-col items-center justify-center text-center space-y-6">
            <div class="w-48 h-48 rounded-full border border-teal-400/20 flex items-center justify-center relative">
               <div class="absolute inset-0 border border-teal-400/10 rounded-full animate-ping opacity-20"></div>
               <div class="absolute inset-4 border border-teal-400/10 rounded-full"></div>
               <svg class="h-16 w-16 text-teal-400/40" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
            </div>
            
            <div class="space-y-2">
              <h2 class="text-2xl font-black text-white italic uppercase tracking-tighter">Geo-Registry Radar</h2>
              <p class="text-[10px] font-bold text-white/30 uppercase tracking-[0.3em] italic">Visualizing regional supply nodes across active grid.</p>
            </div>

            <div v-if="selectedStation" class="px-6 py-3 bg-white/5 border border-white/10 rounded-2xl flex items-center gap-4 backdrop-blur-md">
              <div class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></div>
              <span class="text-[9px] font-black text-white/80 uppercase tracking-widest italic">Locked on: {{ selectedStation.name }}</span>
            </div>
          </div>

          <!-- Radar Sweep Effect -->
          <div class="absolute inset-0 bg-gradient-to-r from-teal-400/10 to-transparent w-full h-full -translate-x-full animate-radar-sweep pointer-events-none"></div>
        </div>

        <!-- Node Registry (Stations List) -->
        <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3rem] overflow-hidden flex flex-col h-[500px]">
          <div class="px-8 py-6 border-b border-white/5 flex justify-between items-center">
            <h2 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/40 italic">Regional Nodes</h2>
            <div class="text-[9px] font-black text-teal-400 uppercase italic">{{ stations.length }} Detected</div>
          </div>
          
          <div class="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-3">
            <button
              v-for="station in stations"
              :key="station.id"
              @click="selectStation(station)"
              class="w-full group p-6 rounded-[2rem] border transition-all duration-500 relative overflow-hidden"
              :class="selectedStation?.id === station.id ? 'bg-teal-400/10 border-teal-400/30' : 'bg-white/5 border-white/5 hover:border-white/10'"
            >
              <div class="relative z-10 flex flex-col items-start gap-1">
                <div class="flex justify-between items-center w-full">
                  <span class="text-lg font-black italic uppercase tracking-tighter transition-colors" :class="selectedStation?.id === station.id ? 'text-white' : 'text-white/60 group-hover:text-white'">{{ station.name }}</span>
                  <span class="text-[9px] font-black text-teal-400/60 uppercase tracking-widest italic">APPROVED SUPPLIER</span>
                </div>
                <p class="text-[10px] font-bold text-white/20 uppercase tracking-widest italic truncate w-full">{{ station.address }}</p>
              </div>
            </button>
          </div>
        </div>
      </div>

      <section v-if="selectedStation" class="rounded-3xl border border-white/10 bg-white/[0.03] p-6">
        <h2 class="text-sm font-black uppercase tracking-wider text-white">Order fulfilment</h2>
        <p class="mt-1 text-xs text-white/45">Choose to collect your bottle or have a delivery person bring it to you.</p>
        <div class="mt-4 grid gap-4 sm:grid-cols-2">
          <select v-model="fulfillmentMethod" class="rounded-xl border border-white/10 bg-gray-900 px-4 py-3 text-sm text-white">
            <option value="PICKUP">I will collect it myself</option>
            <option value="DELIVERY">Book a delivery person</option>
          </select>
          <div v-if="fulfillmentMethod === 'DELIVERY'" class="space-y-2">
            <input v-model="deliveryAddress" @input="clearDeliveryCoordinates" type="text" required placeholder="Delivery address" class="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder:text-white/30">
            <button type="button" @click="syncDeliveryLocation" :disabled="locationBusy" class="rounded-xl border border-teal-300/25 bg-teal-300/5 px-4 py-2.5 text-xs font-black uppercase tracking-wider text-teal-100 disabled:opacity-50">
              {{ locationBusy ? 'Getting location…' : deliveryCoordinates ? 'Update current location' : 'Use my current location' }}
            </button>
            <p v-if="deliveryCoordinates" class="text-xs text-white/45">Your GPS location will be shared with the assigned delivery person.</p>
            <p v-if="locationError" class="text-xs text-red-200">{{ locationError }}</p>
          </div>
        </div>
        <div class="mt-4 grid gap-4 sm:grid-cols-[minmax(0,1fr)_auto] sm:items-end">
          <label class="block text-xs font-bold uppercase tracking-wider text-white/55">
            Bottle brand and size
            <select v-model="selectedBottleId" class="mt-2 w-full rounded-xl border border-white/10 bg-gray-900 px-4 py-3 text-sm normal-case tracking-normal text-white" :disabled="availableInventory.length === 0">
              <option v-for="item in availableInventory" :key="item.id" :value="item.id" class="bg-gray-900 text-white">
                {{ item.type }} — {{ item.price }} FCFA ({{ item.quantity }} available)
              </option>
            </select>
          </label>
          <button
            v-if="selectedBottle"
            @click="startCheckout"
            :disabled="paymentBusy || statusChecking"
            class="rounded-xl bg-teal-400 px-6 py-3 text-sm font-black text-gray-950 transition hover:bg-teal-300 disabled:opacity-50"
          >
            {{ paymentBusy ? 'Starting payment…' : `Continue · ${selectedBottle.price} FCFA` }}
          </button>
          <p v-else class="rounded-xl border border-white/10 px-4 py-3 text-sm text-white/45">This supplier has no bottles in stock.</p>
        </div>
        <p v-if="selectionHint" class="mt-2 text-xs text-white/45">{{ selectionHint }}</p>
        <p v-if="orderMessage" class="mt-4 rounded-xl p-3 text-sm" :class="orderError ? 'bg-red-400/10 text-red-200' : 'bg-teal-400/10 text-teal-200'">{{ orderMessage }}</p>

        <div v-if="paymentFormOpen" class="mt-6 rounded-2xl border border-white/10 bg-gray-950/60 p-5">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h3 class="text-sm font-black uppercase tracking-wider text-white">Pay for {{ checkoutBottle?.type }}</h3>
              <p class="mt-1 text-xs text-white/45">{{ checkoutMethod === 'DELIVERY' ? 'Delivery' : 'Pickup' }} · secure DigiPay Mobile Money</p>
            </div>
            <button @click="paymentFormOpen = false" :disabled="paymentBusy || statusChecking" class="text-xs font-bold text-white/45 hover:text-white disabled:opacity-40">Close</button>
          </div>
          <div class="mt-4 space-y-2 border-y border-white/10 py-4 text-sm">
            <div class="flex justify-between text-white/65"><span>Supplier price</span><span>{{ checkoutBottle?.price }} FCFA</span></div>
            <div class="flex justify-between text-white/65"><span>Delivery fee</span><span>{{ checkoutMethod === 'DELIVERY' ? '25' : '0' }} FCFA</span></div>
            <div class="flex justify-between font-black text-teal-300"><span>Total</span><span>{{ checkoutTotal.toLocaleString() }} FCFA</span></div>
          </div>
          <p class="mt-4 text-xs font-bold uppercase tracking-wider text-white/55">Choose payment operator</p>
          <div class="mt-2 grid grid-cols-2 gap-3">
            <button type="button" @click="paymentOperator = 'ORANGE_MONEY'" :aria-pressed="paymentOperator === 'ORANGE_MONEY'" :class="paymentOperator === 'ORANGE_MONEY' ? 'border-orange-400 bg-orange-400/10 text-orange-200' : 'border-white/10 bg-white/5 text-white/65'" class="rounded-xl border px-4 py-3 text-sm font-bold">🟠 Orange Money</button>
            <button type="button" @click="paymentOperator = 'MTN_MOMO'" :aria-pressed="paymentOperator === 'MTN_MOMO'" :class="paymentOperator === 'MTN_MOMO' ? 'border-yellow-300 bg-yellow-300/10 text-yellow-100' : 'border-white/10 bg-white/5 text-white/65'" class="rounded-xl border px-4 py-3 text-sm font-bold">🟡 MTN MoMo</button>
          </div>
          <label v-if="paymentOperator" class="mt-4 block text-xs font-bold uppercase tracking-wider text-white/55">
            {{ paymentOperator === 'ORANGE_MONEY' ? 'Orange Money' : 'MTN MoMo' }} number to debit
            <span class="mt-2 flex rounded-xl border border-white/10 bg-white/5 text-white">
              <span class="border-r border-white/10 px-4 py-3 text-white/60">+237</span>
              <input v-model="payerPhone" :disabled="paymentOrderId !== null" type="tel" inputmode="numeric" maxlength="9" placeholder="6XX XXX XXX" class="min-w-0 flex-1 bg-transparent px-4 py-3 text-sm tracking-normal text-white outline-none placeholder:text-white/30">
            </span>
          </label>
          <p v-if="paymentOrderId" class="mt-3 break-all text-xs text-white/45">Order #{{ paymentOrderId }}<span v-if="paymentTransactionId"> · DigiPay reference {{ paymentTransactionId }}</span></p>
          <p v-if="paymentMessage" class="mt-3 text-sm" :class="paymentError ? 'text-red-200' : 'text-amber-200'">{{ paymentMessage }}</p>
          <div class="mt-4 flex flex-wrap gap-3">
            <button v-if="paymentOrderId && paymentTransactionId" @click="checkPaymentStatus(false)" :disabled="paymentBusy || statusChecking" class="rounded-xl border border-teal-300/30 px-5 py-3 text-sm font-black text-teal-200 disabled:opacity-50">{{ statusChecking ? 'Checking…' : 'Check payment status' }}</button>
            <button v-else-if="!paymentOrderId" @click="submitPayment" :disabled="paymentBusy || !paymentOperator || payerPhone.replace(/\D/g, '').length !== 9" class="rounded-xl bg-teal-400 px-5 py-3 text-sm font-black text-gray-950 disabled:opacity-50">{{ paymentBusy ? 'Starting…' : `Pay ${checkoutTotal.toLocaleString()} FCFA` }}</button>
            <p v-else class="text-sm font-bold text-amber-200">Contact support with this order number before trying another payment.</p>
          </div>
        </div>
      </section>

      <!-- Volumetric Inventory (Table) -->
      <div v-if="selectedStation" class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[3.5rem] p-10 overflow-hidden relative group/inventory">
        <div class="absolute inset-x-0 bottom-0 h-1/2 bg-gradient-to-t from-blue-500/[0.02] to-transparent pointer-events-none"></div>
        
        <div class="flex items-center gap-6 mb-10 pb-6 border-b border-white/5 relative z-10">
          <div class="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-white/20 border border-white/10 group-hover/inventory:border-blue-400/30 group-hover/inventory:text-blue-400 transition-all">
             <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>
          </div>
          <div>
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-white/30 italic mb-1">{{ selectedStation.name }} Matrix</h3>
            <h2 class="text-3xl font-black text-white italic uppercase tracking-tighter">Available Capacities</h2>
          </div>
        </div>

        <div class="overflow-x-auto relative z-10">
          <table class="w-full">
            <thead>
              <tr class="text-left text-[10px] font-black uppercase tracking-[0.4em] text-white/20 italic">
                <th class="px-6 py-4">Matrix Component</th>
                <th class="px-6 py-4 text-center">Protocol Level</th>
                <th class="px-6 py-4 text-right">Acquisition</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-white/5">
              <tr v-for="item in selectedStation.inventory" :key="item.id" class="group/row transition-all" :class="String(selectedBottleId) === String(item.id) ? 'bg-teal-400/[0.06]' : 'hover:bg-white/[0.02]'">
                <td class="px-6 py-8">
                  <div class="flex items-center gap-4">
                    <div class="w-2 h-2 rounded-full" :class="item.quantity > 0 ? 'bg-teal-400' : 'bg-red-500'"></div>
                    <div><span class="text-lg font-black text-white italic uppercase tracking-tighter">{{ item.type }}</span><p class="mt-1 text-xs text-white/45">{{ item.price }} FCFA</p></div>
                  </div>
                </td>
                <td class="px-6 py-8 text-center">
                  <span :class="[
                    item.quantity > 10 ? 'text-teal-400 bg-teal-400/10 border-teal-400/20' : 
                    item.quantity > 0 ? 'text-yellow-400 bg-yellow-400/10 border-yellow-400/20' : 
                    'text-red-500 bg-red-400/10 border-red-500/20',
                    'px-4 py-1.5 rounded-full text-[9px] font-black uppercase tracking-widest border italic'
                  ]">
                    {{ item.quantity }} UNITS_IN_NODE
                  </span>
                </td>
                <td class="px-6 py-8 text-right">
                  <button
                    v-if="item.quantity > 0"
                    @click="selectedBottleId = item.id"
                    :aria-pressed="String(selectedBottleId) === String(item.id)"
                    class="px-6 py-3 bg-white/5 border border-white/10 rounded-xl text-[10px] font-black uppercase tracking-widest text-white/65 hover:bg-teal-400 hover:text-gray-950 hover:border-teal-400 transition-all"
                  >
                    {{ String(selectedBottleId) === String(item.id) ? 'Selected' : 'Choose this bottle' }}
                  </button>
                  <span v-else class="text-[9px] font-black text-white/10 uppercase tracking-widest italic">MATRIX_EMPTY</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'
import { useRouter } from 'vue-router'

const router = useRouter()
const { isDark, themeClasses } = useTheme()

const stations = ref([])
const selectedStation = ref(null)
const loading = ref(true)
const orderMessage = ref('')
const orderError = ref(false)
const fulfillmentMethod = ref('PICKUP')
const deliveryAddress = ref('')
const deliveryCoordinates = ref(null)
const checkoutCoordinates = ref(null)
const locationBusy = ref(false)
const locationError = ref('')
const preferredBottleBrand = ref('')
const preferredBottleSize = ref('')
const selectedBottleId = ref(null)
const paymentFormOpen = ref(false)
const paymentOperator = ref('')
const payerPhone = ref('')
const checkoutBottle = ref(null)
const checkoutMethod = ref('PICKUP')
const checkoutAddress = ref('')
const paymentOrderId = ref(null)
const paymentTransactionId = ref('')
const paymentAmount = ref(null)
const paymentMessage = ref('')
const paymentError = ref(false)
const paymentBusy = ref(false)
const statusChecking = ref(false)

const checkoutTotal = computed(() => Number(paymentAmount.value ?? (
  Number(checkoutBottle.value?.price || 0) + (checkoutMethod.value === 'DELIVERY' ? 25 : 0)
)))

const availableInventory = computed(() =>
  (selectedStation.value?.inventory || []).filter(item => Number(item.quantity) > 0)
)
const selectedBottle = computed(() =>
  availableInventory.value.find(item => String(item.id) === String(selectedBottleId.value)) || null
)
const preferredBottleAvailable = computed(() =>
  availableInventory.value.some(item => item.brandCode === preferredBottleBrand.value && item.sizeCode === preferredBottleSize.value)
)
const selectionHint = computed(() => {
  if (!selectedBottle.value) return ''
  const hasPreference = preferredBottleBrand.value && preferredBottleSize.value
  const matchesPreference = selectedBottle.value.brandCode === preferredBottleBrand.value && selectedBottle.value.sizeCode === preferredBottleSize.value
  if (hasPreference && matchesPreference) return 'Your saved brand and size are selected. You can choose a different in-stock bottle above.'
  if (preferredBottleAvailable.value) return 'Your saved bottle is in stock, and you have selected a different variant. You can switch back above.'
  if (hasPreference) return 'Your saved brand and size are unavailable from this supplier. Choose any in-stock bottle above.'
  return 'Choose any in-stock brand and size you want to buy.'
})

const selectStation = (station) => {
  selectedStation.value = station
  const inStock = station.inventory.filter(item => Number(item.quantity) > 0)
  const preferred = inStock.find(item => item.brandCode === preferredBottleBrand.value && item.sizeCode === preferredBottleSize.value)
  selectedBottleId.value = (preferred || inStock[0])?.id ?? null
  orderMessage.value = ''
}

const loadVendors = async () => {
  loading.value = true
  try {
    const [res] = await Promise.all([
      api.get('public/vendors/'),
      api.get('users/profile/').then(profile => {
        preferredBottleBrand.value = profile.data.preferred_bottle_brand || ''
        preferredBottleSize.value = profile.data.preferred_bottle_size || ''
      }).catch(error => console.warn('Could not load saved bottle preference', error))
    ])
    if (res.data && res.data.length > 0) {
      stations.value = res.data.map(v => ({
        id: v.id,
        name: v.store_name || v.user_name || 'Gas Supplier',
        address: v.address || 'Location not provided',
        latitude: v.latitude,
        longitude: v.longitude,
        inventory: (v.gas_bottles || []).map(b => ({
          id: b.id,
          brandCode: b.brand,
          sizeCode: b.size,
          type: `${b.brand_display || b.brand} ${b.size_display || b.size}`,
          quantity: b.stock_quantity,
          price: b.price
        }))
      }))
    }
  } catch (e) {
    console.error('Failed to load vendors', e)
    orderError.value = true
    orderMessage.value = 'Could not load approved gas suppliers. Please refresh and try again.'
  } finally {
    loading.value = false
    if (stations.value.length > 0) {
      selectStation(stations.value[0])
    }
  }
}

const startCheckout = () => {
  if (!selectedBottle.value) return
  if (fulfillmentMethod.value === 'DELIVERY' && !deliveryAddress.value.trim()) {
    orderError.value = true
    orderMessage.value = 'Enter a delivery address to book delivery.'
    return
  }
  orderMessage.value = ''
  orderError.value = false
  checkoutBottle.value = selectedBottle.value
  checkoutMethod.value = fulfillmentMethod.value
  checkoutAddress.value = deliveryAddress.value.trim()
  checkoutCoordinates.value = deliveryCoordinates.value
  paymentOperator.value = ''
  payerPhone.value = ''
  paymentOrderId.value = null
  paymentTransactionId.value = ''
  paymentAmount.value = null
  paymentMessage.value = ''
  paymentError.value = false
  paymentFormOpen.value = true
}

const clearDeliveryCoordinates = () => {
  deliveryCoordinates.value = null
  locationError.value = ''
}

const syncDeliveryLocation = async () => {
  locationError.value = ''
  if (!navigator.geolocation) {
    locationError.value = 'This browser cannot access device location.'
    return
  }
  locationBusy.value = true
  try {
    const position = await new Promise((resolve, reject) => {
      navigator.geolocation.getCurrentPosition(resolve, reject, {
        enableHighAccuracy: true,
        timeout: 20000,
        maximumAge: 0,
      })
    })
    const latitude = position.coords.latitude
    const longitude = position.coords.longitude
    deliveryCoordinates.value = { latitude, longitude }
    deliveryAddress.value = `Current GPS location (${latitude.toFixed(6)}, ${longitude.toFixed(6)})`
  } catch (error) {
    locationError.value = error.code === 1
      ? 'Allow location access in your browser to share your current position.'
      : 'Could not get your current location. Check device location and try again.'
  } finally {
    locationBusy.value = false
  }
}

const submitPayment = async () => {
  if (!paymentOperator.value || payerPhone.value.replace(/\D/g, '').length !== 9) return
  paymentBusy.value = true
  paymentMessage.value = 'Sending a payment request to your phone…'
  try {
    const response = await api.post('payments/initiate/', {
      gas_bottle: checkoutBottle.value.id,
      fulfillment_method: checkoutMethod.value,
      ...(checkoutMethod.value === 'DELIVERY' ? { delivery_address: checkoutAddress.value } : {}),
      ...(checkoutMethod.value === 'DELIVERY' && checkoutCoordinates.value ? checkoutCoordinates.value : {}),
      payment_operator: paymentOperator.value,
      payer_phone: `237${payerPhone.value.replace(/\D/g, '')}`
    })
    paymentOrderId.value = response.data.order_id
    paymentTransactionId.value = response.data.transaction_id || ''
    paymentAmount.value = Number(response.data.amount || checkoutTotal.value)
    paymentMessage.value = response.data.message || 'Approve the payment prompt on your phone.'
    if (response.data.payment_status === 'PAID') {
      finishPaidOrder(response.data.order)
    } else if (response.data.payment_status === 'FAILED') {
      paymentError.value = true
      paymentMessage.value = response.data.message || 'Payment was declined. Try again.'
    } else if (paymentOrderId.value && response.data.payment_status !== 'UNKNOWN') {
      await checkPaymentStatus(true)
    }
  } catch (e) {
    console.error('Payment initiation failed', e)
    paymentError.value = true
    paymentMessage.value = e.response?.data?.message || e.response?.data?.detail || e.response?.data?.payer_phone?.[0] || e.response?.data?.gas_bottle?.[0] || 'Payment could not be started. Check the number and try again.'
  } finally {
    paymentBusy.value = false
  }
}

const checkPaymentStatus = async (poll = false) => {
  if (!paymentOrderId.value) return
  statusChecking.value = true
  paymentError.value = false
  const attempts = poll ? 12 : 1
  try {
    for (let index = 0; index < attempts; index++) {
      if (index > 0) await new Promise(resolve => setTimeout(resolve, 5000))
      const response = await api.post(`payments/${paymentOrderId.value}/status/`)
      const paymentStatus = response.data.payment_status
      if (paymentStatus === 'PAID' && response.data.order) {
        finishPaidOrder(response.data.order)
        return
      }
      if (paymentStatus === 'FAILED') {
        paymentError.value = true
        paymentMessage.value = response.data.message || 'Payment was declined. Close checkout and try again.'
        return
      }
      paymentMessage.value = response.data.message || 'Waiting for operator confirmation…'
      if (!poll) return
    }
    if (poll) paymentMessage.value = 'Still waiting. You can check the payment status again below.'
  } catch (e) {
    paymentError.value = true
    paymentMessage.value = e.response?.data?.message || 'Could not check payment status. Try again shortly.'
  } finally {
    statusChecking.value = false
  }
}

const finishPaidOrder = (order) => {
  if (!order) return
  const purchasedBottle = selectedStation.value?.inventory.find(item => item.id === checkoutBottle.value?.id)
  if (purchasedBottle) purchasedBottle.quantity = Math.max(0, Number(purchasedBottle.quantity) - 1)
  orderMessage.value = `Payment confirmed. Order #${order.id} placed.`
  paymentMessage.value = orderMessage.value
  paymentError.value = false
  setTimeout(() => router.push('/admin/client-orders'), 1000)
}

onMounted(loadVendors)
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.05); border-radius: 10px; }

@keyframes radar-sweep {
  from { transform: translateX(-100%) rotate(0deg); }
  to { transform: translateX(100%) rotate(0deg); }
}

.animate-radar-sweep {
  animation: radar-sweep 4s linear infinite;
  background: linear-gradient(90deg, transparent, rgba(45, 212, 191, 0.05), transparent);
}
</style>
