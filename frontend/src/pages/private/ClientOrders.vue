<template>
  <div :class="[themeClasses.bg.primary, 'min-h-full flex-1 p-5 text-white sm:p-8']">
    <div class="mx-auto max-w-5xl space-y-6">
      <header class="flex items-end justify-between gap-4 border-b border-white/10 pb-6"><div><p class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">Customer account</p><h1 class="mt-2 text-3xl font-black">My gas orders</h1><p class="mt-2 text-sm text-white/45">Track delivery and supplier pickup orders.</p></div><button @click="load" :disabled="loading" class="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black uppercase">Refresh</button></header>
      <p v-if="error" class="rounded-xl border border-red-400/20 bg-red-400/10 p-4 text-sm text-red-200">{{ error }}</p>
      <div v-if="loading && !orders.length" class="p-8 text-center text-white/50">Loading orders…</div>
      <div v-else-if="!orders.length" class="rounded-2xl border border-white/10 bg-white/[0.03] p-10 text-center"><p class="font-bold">No orders yet</p><router-link to="/admin/buy-gas" class="mt-4 inline-flex rounded-xl bg-teal-400 px-4 py-3 text-xs font-black uppercase text-gray-950">Browse gas suppliers</router-link></div>
      <article v-for="order in orders" :key="order.id" class="rounded-2xl border border-white/10 bg-white/[0.03] p-5 sm:p-6">
        <div class="flex flex-wrap items-center justify-between gap-3"><div><p class="font-black">{{ order.bottle_detail }}</p><p class="mt-1 text-xs text-white/45">Order #{{ order.id }} · {{ new Date(order.created_at).toLocaleString() }}</p></div><div class="flex flex-wrap gap-2"><span class="rounded-full bg-white/5 px-3 py-1 text-[9px] font-black uppercase text-white/60">{{ order.fulfillment_display }}</span><span :class="statusClass(order.status)" class="rounded-full px-3 py-1 text-[9px] font-black uppercase">{{ order.status_display }}</span><span v-if="order.payment_status && order.payment_status !== 'PAID'" class="rounded-full bg-amber-400/10 px-3 py-1 text-[9px] font-black uppercase text-amber-200">Payment {{ order.payment_status.toLowerCase() }}</span></div></div>
        <div class="mt-4 grid gap-3 text-sm sm:grid-cols-2"><p><span class="text-white/40">Supplier:</span> {{ order.vendor_name }}</p><p><span class="text-white/40">Total:</span> {{ order.payment_amount > 0 ? order.payment_amount : order.unit_price }} FCFA</p><p class="sm:col-span-2"><span class="text-white/40">{{ order.fulfillment_method === 'PICKUP' ? 'Pickup location:' : 'Delivery address:' }}</span> {{ order.delivery_address }}</p><p v-if="order.delivery_person_name"><span class="text-white/40">Delivery person:</span> {{ order.delivery_person_name }}</p></div>
        <div v-if="order.fulfillment_method === 'DELIVERY' && order.status === 'OUT_FOR_DELIVERY'" class="mt-4 rounded-xl border border-white/10 bg-white/[0.03] p-4">
          <p class="text-[10px] font-black uppercase tracking-wider text-white/55">Delivery completion</p>
          <p class="mt-2 text-xs" :class="order.driver_confirmed_delivery ? 'text-teal-200' : 'text-white/50'">{{ order.driver_confirmed_delivery ? 'Delivery person marked this order delivered.' : 'The delivery person is on the way.' }}</p>
          <button v-if="order.driver_confirmed_delivery && !order.client_confirmed_delivery" @click="confirmDelivery(order)" :disabled="confirmingId === order.id" class="mt-3 rounded-xl bg-teal-400 px-4 py-2.5 text-[10px] font-black uppercase tracking-wider text-gray-950 disabled:opacity-50">{{ confirmingId === order.id ? 'Confirming…' : 'Confirm I received the gas' }}</button>
          <p v-if="order.client_confirmed_delivery" class="mt-2 text-xs font-bold text-teal-200">You confirmed receipt. Delivery is complete.</p>
        </div>
        <p v-if="order.payment_status === 'UNKNOWN'" class="mt-3 text-sm text-amber-200">Payment needs support review. Do not submit another payment for this order.</p>
        <button v-if="['PENDING', 'UNKNOWN'].includes(order.payment_status) && order.payment_transaction_id" @click="checkPayment(order)" :disabled="checkingPaymentId === order.id" class="mt-4 rounded-xl border border-teal-300/25 bg-teal-300/10 px-4 py-2.5 text-[10px] font-black uppercase tracking-wider text-teal-100 disabled:opacity-50">{{ checkingPaymentId === order.id ? 'Checking payment…' : 'Check payment status' }}</button>
        <button v-if="order.status === 'PENDING' && (!order.payment_status || order.payment_status === 'PAID') && !order.payment_transaction_id" @click="cancelOrder(order)" class="mt-4 rounded-xl border border-red-400/25 bg-red-400/10 px-4 py-2.5 text-[10px] font-black uppercase tracking-wider text-red-200">Cancel order</button>
      </article>
    </div>
  </div>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'
const { themeClasses } = useTheme()
const orders = ref([])
const loading = ref(false)
const error = ref('')
const checkingPaymentId = ref(null)
const confirmingId = ref(null)
const statusClass = (status) => status === 'DELIVERED' || status === 'PICKED_UP' ? 'bg-teal-400/10 text-teal-200' : status === 'CANCELLED' ? 'bg-red-400/10 text-red-200' : status === 'PENDING' ? 'bg-amber-400/10 text-amber-200' : 'bg-blue-400/10 text-blue-200'
async function load() { loading.value = true; error.value = ''; try { orders.value = (await api.get('deliveries/')).data } catch (e) { error.value = e.response?.data?.detail || 'Could not load your orders.' } finally { loading.value = false } }
async function cancelOrder(order) { try { const response = await api.patch(`deliveries/${order.id}/`, { status: 'CANCELLED' }); Object.assign(order, response.data) } catch (e) { error.value = e.response?.data?.error || 'This order could not be cancelled.' } }
async function confirmDelivery(order) {
  confirmingId.value = order.id
  error.value = ''
  try {
    const response = await api.patch(`deliveries/${order.id}/`, { completion_confirmation: 'CLIENT' })
    Object.assign(order, response.data)
  } catch (e) {
    error.value = e.response?.data?.error || 'Could not confirm delivery.'
  } finally {
    confirmingId.value = null
  }
}
async function checkPayment(order) {
  checkingPaymentId.value = order.id
  error.value = ''
  try {
    const response = await api.post(`payments/${order.id}/status/`)
    order.payment_status = response.data.payment_status
    if (response.data.order) Object.assign(order, response.data.order)
    else if (response.data.payment_status === 'FAILED') order.status = 'CANCELLED'
    else if (response.data.message) error.value = response.data.message
  } catch (e) {
    error.value = e.response?.data?.message || 'Could not check payment status. Try again shortly.'
  } finally {
    checkingPaymentId.value = null
  }
}
onMounted(load)
</script>
