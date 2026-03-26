<template>
  <a v-if="url" :href="url" target="_blank" rel="noopener noreferrer" class="flex flex-col items-center justify-center p-4 bg-white/5 hover:bg-white/10 border border-white/5 hover:border-teal-400/30 rounded-2xl group transition-all duration-300">
    <svg class="w-6 h-6 text-white/30 group-hover:text-teal-400 mb-2 transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
    <span class="text-[9px] font-black uppercase tracking-widest text-center text-white/60 group-hover:text-white">{{ label }}</span>
  </a>
  <div v-else class="flex flex-col items-center justify-center p-4 bg-white/[0.02] border border-white/5 rounded-2xl opacity-50">
    <svg class="w-6 h-6 text-white/10 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
    <span class="text-[9px] font-black uppercase tracking-widest text-center text-white/30">Missing File</span>
  </div>
</template>

<script setup>
defineProps({
  label: String,
  url: String
});
</script>
