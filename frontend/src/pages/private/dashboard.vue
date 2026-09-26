<template>
  <div :class="[themeClasses.bg.primary, 'min-h-full flex-1 p-5 sm:p-8 text-white']">
    <div class="mx-auto max-w-7xl space-y-8">
      <header class="flex flex-col gap-5 border-b border-white/10 pb-6 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">GaSX / System Administration</p>
          <h1 class="mt-2 text-3xl font-black tracking-tight sm:text-4xl">Operations overview</h1>
          <p class="mt-2 text-sm text-white/45">Platform activity, safety events, accounts, and fulfilment.</p>
        </div>
        <div class="flex flex-wrap gap-3">
          <select v-model="reportType" class="rounded-xl border border-white/10 bg-gray-900 px-4 py-3 text-xs font-bold text-white">
            <option value="orders">Orders report</option>
            <option value="users">Users report</option>
            <option value="sensors">Sensors report</option>
            <option value="suppliers">Suppliers report</option>
          </select>
          <button @click="downloadReport" :disabled="downloading" class="rounded-xl bg-teal-400 px-4 py-3 text-xs font-black uppercase tracking-wider text-gray-950 disabled:opacity-50">
            {{ downloading ? 'Preparing…' : 'Export CSV' }}
          </button>
          <button @click="loadOverview" :disabled="loading" class="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black uppercase tracking-wider text-white disabled:opacity-50">
            {{ loading ? 'Refreshing…' : 'Refresh' }}
          </button>
        </div>
      </header>

      <div v-if="error" class="rounded-2xl border border-red-400/20 bg-red-400/10 p-4 text-sm text-red-200">{{ error }}</div>
      <div v-if="loading && !overview" class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <div v-for="n in 8" :key="n" class="h-28 animate-pulse rounded-2xl border border-white/5 bg-white/[0.03]"></div>
      </div>

      <template v-if="overview">
        <section class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <article v-for="card in cards" :key="card.label" class="rounded-2xl border border-white/10 bg-white/[0.03] p-5">
            <p class="text-[10px] font-black uppercase tracking-[0.2em] text-white/40">{{ card.label }}</p>
            <p class="mt-3 text-3xl font-black tabular-nums" :class="card.color">{{ card.value }}</p>
            <p class="mt-2 text-xs text-white/35">{{ card.note }}</p>
          </article>
        </section>

        <section class="grid gap-6 xl:grid-cols-3">
          <article class="rounded-2xl border border-white/10 bg-white/[0.03] p-6 xl:col-span-2">
            <div class="mb-5 flex items-center justify-between">
              <div>
                <h2 class="text-lg font-black">System activity</h2>
                <p class="mt-1 text-xs text-white/40">Current orders, sensors, and safety alerts</p>
              </div>
              <span class="rounded-full border border-teal-400/20 bg-teal-400/10 px-3 py-1 text-[10px] font-bold uppercase text-teal-300">Live summary</span>
            </div>
            <div class="grid gap-3 sm:grid-cols-3">
              <div class="rounded-xl bg-black/20 p-4"><p class="text-xs text-white/40">Orders today</p><p class="mt-2 text-2xl font-black">{{ overview.orders.today }}</p></div>
              <div class="rounded-xl bg-black/20 p-4"><p class="text-xs text-white/40">Open orders</p><p class="mt-2 text-2xl font-black">{{ overview.orders.pending + overview.orders.in_progress }}</p></div>
              <div class="rounded-xl bg-black/20 p-4"><p class="text-xs text-white/40">Critical alerts</p><p class="mt-2 text-2xl font-black" :class="overview.alerts.critical ? 'text-red-300' : 'text-teal-300'">{{ overview.alerts.critical }}</p></div>
            </div>
            <div class="mt-5 grid gap-3 sm:grid-cols-2">
              <router-link to="/admin/users" class="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-4 hover:border-teal-400/30">
                <span class="text-sm font-bold">Manage accounts</span><span class="text-xs text-white/40">{{ overview.users.total }} total →</span>
              </router-link>
              <router-link to="/admin/vendor-validation" class="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-4 hover:border-teal-400/30">
                <span class="text-sm font-bold">Review applications</span><span class="text-xs text-amber-300">{{ overview.applications.delivery_pending + overview.applications.supplier_pending }} pending →</span>
              </router-link>
              <router-link to="/admin/delivery-dashboard" class="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-4 hover:border-teal-400/30">
                <span class="text-sm font-bold">Manage fulfilment</span><span class="text-xs text-white/40">{{ overview.orders.total }} orders →</span>
              </router-link>
              <router-link to="/admin/system-alerts" class="flex items-center justify-between rounded-xl border border-white/5 bg-white/[0.02] p-4 hover:border-teal-400/30">
                <span class="text-sm font-bold">Safety events</span><span class="text-xs text-white/40">{{ overview.alerts.unresolved }} unresolved →</span>
              </router-link>
            </div>
          </article>

          <article class="rounded-2xl border border-white/10 bg-white/[0.03] p-6">
            <h2 class="text-lg font-black">Verification queue</h2>
            <p class="mt-1 text-xs text-white/40">Supplier and delivery-person applications</p>
            <div class="mt-6 space-y-4">
              <div class="flex items-center justify-between"><span class="text-sm text-white/70">Gas suppliers</span><strong class="text-xl text-amber-300">{{ overview.applications.supplier_pending }}</strong></div>
              <div class="flex items-center justify-between"><span class="text-sm text-white/70">Delivery people</span><strong class="text-xl text-amber-300">{{ overview.applications.delivery_pending }}</strong></div>
              <div class="flex items-center justify-between"><span class="text-sm text-white/70">Rejected applications</span><strong class="text-xl">{{ overview.applications.rejected }}</strong></div>
              <router-link to="/admin/vendor-validation" class="block rounded-xl bg-teal-400 px-4 py-3 text-center text-xs font-black uppercase tracking-wider text-gray-950">Open review queue</router-link>
            </div>
          </article>
        </section>

        <section class="grid gap-6 lg:grid-cols-2">
          <article class="rounded-2xl border border-white/10 bg-white/[0.03] p-6">
            <div class="flex items-center justify-between"><div><h2 class="text-lg font-black">Sensor network</h2><p class="mt-1 text-xs text-white/40">Device activity and stored readings</p></div><router-link to="/admin/admin-sensors" class="text-xs font-bold text-teal-300">Manage sensors →</router-link></div>
            <div class="mt-6 grid grid-cols-3 gap-3 text-center">
              <div class="rounded-xl bg-black/20 p-4"><strong class="block text-2xl">{{ overview.sensors.total }}</strong><span class="text-[10px] uppercase text-white/40">Total</span></div>
              <div class="rounded-xl bg-black/20 p-4"><strong class="block text-2xl text-teal-300">{{ overview.sensors.active }}</strong><span class="text-[10px] uppercase text-white/40">Active</span></div>
              <div class="rounded-xl bg-black/20 p-4"><strong class="block text-2xl">{{ overview.sensors.readings }}</strong><span class="text-[10px] uppercase text-white/40">Readings</span></div>
            </div>
          </article>

          <article class="rounded-2xl border border-white/10 bg-white/[0.03] p-6">
            <div class="flex items-center justify-between"><div><h2 class="text-lg font-black">Recent alerts</h2><p class="mt-1 text-xs text-white/40">Latest safety and system events</p></div><router-link to="/admin/system-alerts" class="text-xs font-bold text-teal-300">All alerts →</router-link></div>
            <div v-if="overview.recent_alerts.length" class="mt-4 divide-y divide-white/5">
              <div v-for="item in overview.recent_alerts" :key="item.id" class="flex items-start justify-between gap-4 py-3">
                <div><p class="text-sm font-bold">{{ item.alert_type.replaceAll('_', ' ') }}</p><p class="mt-1 line-clamp-2 text-xs text-white/40">{{ item.alert_message }}</p></div>
                <span class="shrink-0 rounded-full px-2 py-1 text-[9px] font-black uppercase" :class="item.is_resolved ? 'bg-white/5 text-white/40' : 'bg-red-400/10 text-red-300'">{{ item.is_resolved ? 'Resolved' : item.severity_level }}</span>
              </div>
            </div>
            <p v-else class="mt-6 text-sm text-white/40">No alerts have been recorded.</p>
          </article>
        </section>
        <p class="text-right text-[10px] uppercase tracking-widest text-white/25">Updated {{ new Date(overview.generated_at).toLocaleString() }}</p>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import api from '../../config/api'
import { useTheme } from '../../composables/useTheme'

const { themeClasses } = useTheme()
const overview = ref(null)
const loading = ref(false)
const downloading = ref(false)
const error = ref('')
const reportType = ref('orders')
let refreshTimer

const cards = computed(() => {
  if (!overview.value) return []
  const data = overview.value
  return [
    { label: 'Accounts', value: data.users.total, note: `${data.users.clients} customers · ${data.users.suppliers} suppliers · ${data.users.delivery_people} drivers`, color: 'text-white' },
    { label: 'Active sensors', value: data.sensors.active, note: `${data.sensors.inactive} currently inactive`, color: 'text-teal-300' },
    { label: 'Unresolved alerts', value: data.alerts.unresolved, note: `${data.alerts.critical} critical alerts`, color: data.alerts.critical ? 'text-red-300' : 'text-white' },
    { label: 'Gas orders', value: data.orders.total, note: `${data.orders.pickup} pickup · ${data.orders.delivery} delivery`, color: 'text-blue-300' },
  ]
})

async function loadOverview() {
  loading.value = true
  error.value = ''
  try {
    const response = await api.get('admin/overview/')
    overview.value = response.data
  } catch (e) {
    error.value = e.response?.data?.detail || 'Could not load the admin overview. Check that your account has administrator access.'
  } finally {
    loading.value = false
  }
}

async function downloadReport() {
  downloading.value = true
  try {
    const response = await api.get('admin/reports/', { params: { type: reportType.value }, responseType: 'blob' })
    const url = URL.createObjectURL(new Blob([response.data], { type: 'text/csv' }))
    const link = document.createElement('a')
    link.href = url
    link.download = `gasx-${reportType.value}-report.csv`
    link.click()
    URL.revokeObjectURL(url)
  } catch (e) {
    error.value = 'The report could not be generated.'
  } finally {
    downloading.value = false
  }
}

onMounted(() => {
  loadOverview()
  refreshTimer = window.setInterval(loadOverview, 60000)
})
onUnmounted(() => window.clearInterval(refreshTimer))
</script>
