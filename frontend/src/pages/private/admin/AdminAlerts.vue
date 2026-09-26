<template>
  <div :class="[themeClasses.bg.primary, 'min-h-full flex-1 p-5 text-white sm:p-8']">
    <div class="mx-auto max-w-6xl space-y-7">
      <header class="flex flex-col gap-4 border-b border-white/10 pb-6 sm:flex-row sm:items-end sm:justify-between"><div><p class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">System administration</p><h1 class="mt-2 text-3xl font-black">Safety alerts</h1><p class="mt-2 text-sm text-white/45">Platform-wide gas leak and sensor alerts.</p></div><button @click="load" :disabled="loading" class="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black uppercase tracking-wider">{{ loading ? 'Refreshing…' : 'Refresh alerts' }}</button></header>
      <div v-if="error" class="rounded-xl border border-red-400/20 bg-red-400/10 p-4 text-sm text-red-200">{{ error }}</div>
      <div class="grid gap-4 sm:grid-cols-3"><div v-for="card in metrics" :key="card.label" class="rounded-2xl border border-white/10 bg-white/[0.03] p-5"><p class="text-[10px] font-bold uppercase tracking-widest text-white/40">{{ card.label }}</p><p class="mt-2 text-3xl font-black" :class="card.class">{{ card.value }}</p></div></div>
      <div class="space-y-3"><article v-for="alert in alerts" :key="alert.id" class="flex flex-col gap-4 rounded-2xl border border-white/10 bg-white/[0.03] p-5 sm:flex-row sm:items-start sm:justify-between"><div><div class="flex flex-wrap items-center gap-3"><h2 class="font-bold">{{ alert.alert_type.replaceAll('_', ' ') }}</h2><span :class="alert.is_resolved ? 'text-white/40 bg-white/5' : severityClass(alert.severity_level)" class="rounded-full px-3 py-1 text-[9px] font-black uppercase">{{ alert.is_resolved ? 'Resolved' : alert.severity_level }}</span></div><p class="mt-2 max-w-3xl text-sm text-white/65">{{ alert.alert_message }}</p><p class="mt-2 text-xs text-white/35">{{ alert.sensor_name }} · {{ alert.house_address || 'Address unavailable' }} · {{ alert.triggered_at ? new Date(alert.triggered_at).toLocaleString() : '' }}</p></div><span class="shrink-0 text-xs text-white/40">Account #{{ alert.user }}</span></article><div v-if="!loading && alerts.length === 0" class="rounded-2xl border border-white/10 bg-white/[0.03] p-10 text-center text-sm text-white/45">No platform alerts are recorded.</div><div v-if="loading && alerts.length === 0" class="p-8 text-center text-sm text-white/40">Loading alerts…</div></div>
    </div>
  </div>
</template>
<script setup>
import { computed, onMounted, ref } from 'vue'
import api from '../../../config/api'
import { useTheme } from '../../../composables/useTheme'
const { themeClasses } = useTheme()
const alerts = ref([])
const loading = ref(false)
const error = ref('')
const metrics = computed(() => [
  { label: 'Total alerts', value: alerts.value.length, class: 'text-white' },
  { label: 'Unresolved', value: alerts.value.filter(item => !item.is_resolved).length, class: 'text-amber-300' },
  { label: 'Critical open', value: alerts.value.filter(item => !item.is_resolved && item.severity_level === 'CRITICAL').length, class: 'text-red-300' },
])
const severityClass = (severity) => severity === 'CRITICAL' || severity === 'HIGH' ? 'bg-red-400/10 text-red-300' : 'bg-amber-400/10 text-amber-200'
async function load() { loading.value = true; error.value = ''; try { alerts.value = (await api.get('alerts/')).data } catch (e) { error.value = e.response?.data?.detail || 'Could not load system alerts.' } finally { loading.value = false } }
onMounted(load)
</script>
