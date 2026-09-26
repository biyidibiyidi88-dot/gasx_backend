<template>
  <div :class="[themeClasses.bg.primary, 'min-h-full flex-1 p-5 text-white sm:p-8']">
    <div class="mx-auto max-w-7xl space-y-7">
      <header class="flex flex-col gap-4 border-b border-white/10 pb-6 sm:flex-row sm:items-end sm:justify-between">
        <div><p class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">System administration</p><h1 class="mt-2 text-3xl font-black">Sensor network</h1><p class="mt-2 text-sm text-white/45">Device health and last reported gas weights across the platform.</p></div>
        <button @click="load" :disabled="loading" class="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black uppercase tracking-wider">{{ loading ? 'Refreshing…' : 'Refresh sensors' }}</button>
      </header>
      <div v-if="error" class="rounded-xl border border-red-400/20 bg-red-400/10 p-4 text-sm text-red-200">{{ error }}</div>
      <div class="grid gap-4 sm:grid-cols-3"><div v-for="card in metrics" :key="card.label" class="rounded-2xl border border-white/10 bg-white/[0.03] p-5"><p class="text-[10px] font-bold uppercase tracking-widest text-white/40">{{ card.label }}</p><p class="mt-2 text-3xl font-black" :class="card.class">{{ card.value }}</p></div></div>
      <div class="overflow-x-auto rounded-2xl border border-white/10 bg-white/[0.03]">
        <table class="w-full min-w-[760px] text-left">
          <thead class="border-b border-white/10 text-[10px] uppercase tracking-widest text-white/40"><tr><th class="p-4">Device</th><th class="p-4">Owner</th><th class="p-4">Location</th><th class="p-4">Raw weight</th><th class="p-4">Gas level</th><th class="p-4">Battery / status</th></tr></thead>
          <tbody class="divide-y divide-white/5"><tr v-for="sensor in sensors" :key="sensor.id" class="text-sm"><td class="p-4"><p class="font-bold">{{ sensor.sensor_name }}</p><p class="mt-1 text-xs text-white/40">{{ sensor.serial_number }}</p></td><td class="p-4"><p>{{ sensor.owner_name || '—' }}</p><p class="text-xs text-white/40">{{ sensor.owner_email }}</p></td><td class="p-4 text-white/60">{{ sensor.house_address || 'No address' }}</td><td class="p-4 font-semibold tabular-nums">{{ sensor.raw_weight ?? '—' }} kg</td><td class="p-4"><p>{{ sensor.current_gas_level }} kg</p><p class="text-xs text-white/40">{{ Number(sensor.current_gas_percentage || 0).toFixed(0) }}%</p></td><td class="p-4"><p>{{ sensor.battery_level_percentage }}%</p><span :class="sensor.is_active ? 'text-teal-300' : 'text-red-300'" class="text-[10px] font-black uppercase">{{ sensor.is_active ? 'Active' : 'Inactive' }}</span></td></tr></tbody>
        </table>
        <p v-if="!loading && sensors.length === 0" class="p-8 text-center text-sm text-white/40">No sensors have been registered.</p>
        <div v-if="loading && sensors.length === 0" class="p-8 text-center text-sm text-white/40">Loading sensor data…</div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { computed, onMounted, ref } from 'vue'
import api from '../../../config/api'
import { useTheme } from '../../../composables/useTheme'
const { themeClasses } = useTheme()
const sensors = ref([])
const loading = ref(false)
const error = ref('')
const metrics = computed(() => [
  { label: 'Registered devices', value: sensors.value.length, class: 'text-white' },
  { label: 'Online', value: sensors.value.filter(item => item.is_active).length, class: 'text-teal-300' },
  { label: 'Needs maintenance', value: sensors.value.filter(item => item.needs_maintenance).length, class: 'text-amber-300' },
])
async function load() {
  loading.value = true; error.value = ''
  try { const response = await api.get('sensors/'); sensors.value = response.data }
  catch (e) { error.value = e.response?.data?.detail || 'Could not load platform sensors.' }
  finally { loading.value = false }
}
onMounted(load)
</script>
