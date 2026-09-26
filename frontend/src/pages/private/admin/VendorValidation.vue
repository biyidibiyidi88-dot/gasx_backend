<template>
  <div :class="[themeClasses.bg.primary, 'min-h-full flex-1 p-5 text-white sm:p-8']">
    <div class="mx-auto max-w-7xl space-y-7">
      <header class="flex flex-col gap-4 border-b border-white/10 pb-6 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">System administration</p>
          <h1 class="mt-2 text-3xl font-black tracking-tight">Application review</h1>
          <p class="mt-2 text-sm text-white/45">Validate gas suppliers and delivery people before they can use their workspaces.</p>
        </div>
        <button @click="loadApplications" :disabled="loading" class="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-xs font-black uppercase tracking-wider disabled:opacity-50">{{ loading ? 'Refreshing…' : 'Refresh queue' }}</button>
      </header>

      <div v-if="error" class="rounded-xl border border-red-400/20 bg-red-400/10 p-4 text-sm text-red-200">{{ error }}</div>
      <div class="flex flex-wrap items-center gap-3">
        <button v-for="option in applicantTypes" :key="option.key" @click="activeType = option.key" :class="activeType === option.key ? 'bg-teal-400 text-gray-950' : 'border border-white/10 bg-white/5 text-white/60'" class="rounded-xl px-4 py-3 text-xs font-black uppercase tracking-wider">{{ option.label }} <span class="ml-2 opacity-70">{{ countFor(option.key) }}</span></button>
        <select v-model="filter" class="rounded-xl border border-white/10 bg-gray-900 px-4 py-3 text-xs font-bold text-white">
          <option value="PENDING">Pending review</option><option value="ALL">All applications</option><option value="APPROVED">Approved</option><option value="REJECTED">Rejected</option>
        </select>
      </div>

      <div v-if="loading && !activeApplications.length" class="rounded-2xl border border-white/10 bg-white/[0.03] p-8 text-sm text-white/50">Loading application records…</div>
      <div v-else-if="!filteredApplications.length" class="rounded-2xl border border-white/10 bg-white/[0.03] p-10 text-center">
        <h2 class="text-lg font-bold">No matching applications</h2><p class="mt-2 text-sm text-white/40">There are no {{ filter === 'PENDING' ? 'pending ' : '' }}{{ activeType === 'suppliers' ? 'supplier' : 'delivery-person' }} applications in this queue.</p>
      </div>
      <div v-else class="grid gap-5 xl:grid-cols-2">
        <article v-for="application in filteredApplications" :key="application.id" class="space-y-5 rounded-2xl border border-white/10 bg-white/[0.03] p-5 sm:p-6">
          <div class="flex items-start justify-between gap-4">
            <div><p class="text-lg font-black">{{ applicantName(application) }}</p><p class="mt-1 text-sm text-white/50">{{ application.user_email }}<span v-if="application.user_phone"> · {{ application.user_phone }}</span></p><p v-if="activeType === 'suppliers'" class="mt-2 text-sm text-white/65">{{ application.address }}<span v-if="application.latitude != null"> · {{ application.latitude }}, {{ application.longitude }}</span></p></div>
            <span :class="statusClass(application.application_status)" class="shrink-0 rounded-full border px-3 py-1 text-[9px] font-black uppercase tracking-wider">{{ application.application_status }}</span>
          </div>
          <p v-if="application.rejection_reason" class="rounded-xl bg-red-400/10 p-3 text-sm text-red-200">Previous rejection: {{ application.rejection_reason }}</p>
          <div class="grid gap-3 sm:grid-cols-2">
            <button v-for="document in documentsFor(application)" :key="document.key" @click="downloadDocument(application, document)" :disabled="!application[document.present] || downloading === document.key + application.id" class="flex items-center justify-between rounded-xl border border-white/10 bg-black/10 px-4 py-3 text-left text-xs font-bold text-white/75 disabled:cursor-not-allowed disabled:opacity-30">
              <span>{{ document.label }}</span><span>{{ application[document.present] ? 'View / download ↗' : 'Not provided' }}</span>
            </button>
          </div>
          <div v-if="application.application_status === 'PENDING'" class="flex flex-wrap gap-3 border-t border-white/10 pt-4">
            <button @click="review(application, 'APPROVED')" :disabled="saving === activeType + application.id" class="flex-1 rounded-xl bg-teal-400 px-4 py-3 text-xs font-black uppercase tracking-wider text-gray-950 disabled:opacity-50">Approve</button>
            <button @click="review(application, 'REJECTED')" :disabled="saving === activeType + application.id" class="flex-1 rounded-xl border border-red-400/30 bg-red-400/10 px-4 py-3 text-xs font-black uppercase tracking-wider text-red-200 disabled:opacity-50">Reject with reason</button>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import api from '../../../config/api'
import { useTheme } from '../../../composables/useTheme'

const { themeClasses } = useTheme()
const applicantTypes = [{ key: 'suppliers', label: 'Gas suppliers' }, { key: 'delivery', label: 'Delivery people' }]
const activeType = ref('suppliers')
const filter = ref('PENDING')
const suppliers = ref([])
const deliveryPeople = ref([])
const loading = ref(false)
const error = ref('')
const saving = ref('')
const downloading = ref('')
const activeApplications = computed(() => activeType.value === 'suppliers' ? suppliers.value : deliveryPeople.value)
const filteredApplications = computed(() => filter.value === 'ALL' ? activeApplications.value : activeApplications.value.filter(item => item.application_status === filter.value))
const countFor = (type) => (type === 'suppliers' ? suppliers.value : deliveryPeople.value).filter(item => item.application_status === 'PENDING').length

function documentsFor(application) {
  return activeType.value === 'suppliers'
    ? [
        { key: 'identity_card', label: 'Identity card', present: 'has_identity_card' },
        { key: 'tax_payment_document', label: 'Tax payment proof', present: 'has_tax_payment_document' },
        { key: 'additional_document', label: 'Business authenticity document', present: 'has_additional_document' },
      ]
    : [
        { key: 'identity_card', label: 'Identity card', present: 'has_identity_card' },
        { key: 'supporting_document', label: 'Supporting document', present: 'has_supporting_document' },
      ]
}
function applicantName(application) { return activeType.value === 'suppliers' ? application.store_name || application.user_name : application.user_name }
function statusClass(status) {
  return ({ PENDING: 'border-amber-300/30 bg-amber-300/10 text-amber-200', APPROVED: 'border-teal-300/30 bg-teal-300/10 text-teal-200', REJECTED: 'border-red-300/30 bg-red-300/10 text-red-200' })[status] || 'border-white/10 text-white/50'
}
async function loadApplications() {
  loading.value = true; error.value = ''
  try {
    const [supplierResponse, deliveryResponse] = await Promise.all([
      api.get('admin/vendors/validation/'),
      api.get('admin/delivery-applications/'),
    ])
    suppliers.value = supplierResponse.data
    deliveryPeople.value = deliveryResponse.data
  } catch (e) {
    error.value = e.response?.data?.detail || 'Could not load the application queue. Check administrator access.'
  } finally { loading.value = false }
}
async function downloadDocument(application, document) {
  const key = document.key + application.id
  downloading.value = key
  try {
    const type = activeType.value === 'suppliers' ? 'supplier' : 'delivery'
    const response = await api.get(`admin/verification-documents/${type}/${application.id}/${document.key}/`, { responseType: 'blob' })
    const url = URL.createObjectURL(response.data)
    const link = window.document.createElement('a')
    link.href = url
    link.download = `${type}-${application.id}-${document.key}`
    link.click()
    window.setTimeout(() => URL.revokeObjectURL(url), 1000)
  } catch (e) { error.value = 'This document could not be downloaded.' }
  finally { downloading.value = '' }
}
async function review(application, decision) {
  let rejectionReason = ''
  if (decision === 'REJECTED') {
    rejectionReason = window.prompt('Enter a reason for rejecting this application:')?.trim() || ''
    if (!rejectionReason) return
  }
  const key = activeType.value + application.id
  saving.value = key; error.value = ''
  try {
    const endpoint = activeType.value === 'suppliers' ? `admin/vendors/validation/${application.id}/` : `admin/delivery-applications/${application.id}/`
    await api.patch(endpoint, { decision, rejection_reason: rejectionReason })
    application.application_status = decision
    if (activeType.value === 'suppliers') application.is_approved = decision === 'APPROVED'
    application.rejection_reason = rejectionReason
  } catch (e) { error.value = e.response?.data?.error || 'The application decision could not be saved.' }
  finally { saving.value = '' }
}
onMounted(loadApplications)
</script>
