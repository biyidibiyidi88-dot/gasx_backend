<template>
  <div class="min-h-screen bg-[#020617] relative overflow-hidden font-['Inter',sans-serif] selection:bg-teal-500/30 selection:text-teal-200">
    <!-- Bipsync 3D Grid Background -->
    <div class="absolute inset-0 z-0">
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_-20%,#0f172a,transparent)]"></div>
      <div class="absolute inset-0" 
           style="background-image: linear-gradient(to right, rgba(255,255,255,0.02) 1px, transparent 1px), 
                                  linear-gradient(to bottom, rgba(255,255,255,0.02) 1px, transparent 1px); 
                  background-size: 50px 50px; 
                  mask-image: radial-gradient(ellipse at center, black, transparent 80%);">
      </div>
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(45,212,191,0.03),transparent_50%)]"></div>
    </div>

    <!-- Volumetric Light Accents -->
    <div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-teal-500/5 blur-[120px] rounded-full animate-pulse-slow"></div>
    <div class="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-blue-500/5 blur-[120px] rounded-full animate-pulse-slow" style="animation-delay: 2s"></div>

    <div class="relative z-10 max-w-6xl mx-auto py-6 sm:py-10 px-4 sm:px-10 lg:px-14 flex flex-col h-screen">
      <!-- Tactical Header -->
      <div class="flex flex-col md:flex-row justify-between items-start md:items-end mb-12 gap-6">
        <div>
          <div class="flex items-center space-x-3 mb-3">
            <div class="w-10 h-1 h-px bg-teal-400/50"></div>
            <span class="text-[10px] font-black uppercase tracking-[0.4em] text-teal-400/60">Neural Interface v4.0</span>
          </div>
          <h1 class="text-4xl sm:text-7xl font-black text-white uppercase italic tracking-tighter leading-none mb-4">
            AI <span class="text-transparent border-t border-b border-white/20 px-2">Assistant</span>
          </h1>
          <p class="text-sm font-medium text-white/40 max-w-xl uppercase tracking-widest leading-relaxed">
            Holographic Intelligence for sub-surface telemetry and gas management optimization
          </p>
        </div>

        <!-- Model Selection HUD -->
        <div class="group relative">
          <div class="absolute -inset-1 bg-gradient-to-r from-teal-500/20 to-blue-500/20 rounded-2xl blur opacity-0 group-hover:opacity-100 transition duration-1000"></div>
          <div class="relative bg-white/[0.03] backdrop-blur-3xl border border-white/10 rounded-2xl p-1.5 flex items-center">
            <div class="px-4 py-2 border-r border-white/10">
              <span class="text-[9px] font-black uppercase tracking-widest text-white/30 block mb-0.5">Engine</span>
              <span class="text-xs font-black text-teal-400 uppercase italic">Active</span>
            </div>
            <select 
              v-model="selectedModel"
              class="bg-transparent text-[10px] sm:text-xs font-black text-white uppercase tracking-widest px-3 sm:px-6 py-2 focus:outline-none appearance-none cursor-pointer"
            >
              <option value="anthropic/claude-3-haiku" class="bg-gray-900">Claude 3 Haiku</option>
              <option value="mistralai/mistral-7b-instruct:free" class="bg-gray-900">Mistral 7B (Free)</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Main Chat Core (Holographic HUD) -->
      <div class="flex-1 min-h-0 bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2rem] sm:rounded-[3rem] flex flex-col relative overflow-hidden shadow-[0_30px_100px_rgba(0,0,0,0.4)]">
        <!-- Top HUD Bar -->
        <div class="px-5 sm:px-10 py-4 sm:py-6 border-b border-white/5 flex justify-between items-center bg-white/[0.01]">
          <div class="flex items-center space-x-4">
            <div class="w-2 h-2 rounded-full bg-teal-400 animate-pulse shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
            <span class="text-[10px] font-black uppercase tracking-[.3em] text-white">Neural Hub Initialized</span>
          </div>
          <button 
            @click="refreshChat"
            class="text-[9px] font-black uppercase tracking-widest text-white/30 hover:text-white transition-colors flex items-center space-x-2"
          >
            <span>Reset History</span>
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-width="3" stroke-linecap="round"/></svg>
          </button>
        </div>

        <!-- Message Stream -->
        <div 
          ref="messagesContainer"
          class="flex-1 overflow-y-auto px-5 sm:px-10 py-6 sm:py-10 space-y-8 sm:space-y-12 custom-scrollbar"
        >
          <!-- System Welcome (If no messages) -->
          <div v-if="messages.length === 0" class="h-full flex flex-col items-center justify-center text-center max-w-2xl mx-auto">
            <div class="w-24 h-24 mb-10 relative group">
              <div class="absolute inset-0 bg-teal-400/20 blur-2xl rounded-full animate-pulse"></div>
              <div class="relative bg-white/5 border border-white/10 rounded-3xl w-full h-full flex items-center justify-center rotate-45 group-hover:rotate-90 transition-transform duration-700">
                <svg class="w-10 h-10 text-white -rotate-45 group-hover:-rotate-90 transition-transform duration-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
                </svg>
              </div>
            </div>
            <h2 class="text-3xl font-black text-white uppercase italic tracking-tighter mb-4">Intelligence Uplink</h2>
            <p class="text-sm text-white/40 uppercase tracking-widest leading-relaxed mb-12 px-10">
              Standing by for technical inquiries regarding storage pressure, safety protocols, and consumption analytics.
            </p>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full">
              <button 
                v-for="(action, idx) in quickActions.slice(0, 4)" 
                :key="idx"
                @click="sendQuickMessage(action.text)"
                class="bg-white/[0.03] border border-white/5 p-6 rounded-3xl text-left hover:bg-white/[0.08] hover:border-teal-500/30 transition-all group"
              >
                <div class="text-[10px] font-black uppercase tracking-[.2em] text-teal-400 mb-2">{{ action.label }}</div>
                <div class="text-xs text-white/50 uppercase tracking-widest line-clamp-1 group-hover:text-white transition-colors">{{ action.text }}</div>
              </button>
            </div>
          </div>

          <!-- Active Message List -->
          <div 
            v-for="(message, index) in messages" 
            :key="index"
            :class="['flex', message.role === 'user' ? 'justify-end' : 'justify-start']"
          >
            <div :class="[
              'max-w-[95%] sm:max-w-[85%] md:max-w-[70%] relative group',
              message.role === 'user' ? 'text-right' : 'text-left'
            ]">
              <!-- Identity Label -->
              <div :class="['text-[9px] font-black uppercase tracking-[.4em] mb-3 opactiy-40', message.role === 'user' ? 'text-teal-400' : 'text-blue-400']">
                {{ message.role === 'user' ? 'Source Node' : 'Intelligence Engine' }}
              </div>

              <!-- Message Bubble -->
              <div :class="[
                'p-4 sm:p-8 rounded-2xl sm:rounded-[2rem] border transition-all duration-500',
                message.role === 'user' 
                  ? 'bg-teal-500/10 border-teal-500/20 text-teal-50 shadow-[0_10px_30px_rgba(45,212,191,0.05)]' 
                  : 'bg-white/[0.03] border-white/10 text-white/90 shadow-[0_10px_30px_rgba(255,255,255,0.02)]'
              ]">
                <div class="text-sm font-medium leading-relaxed prose prose-invert prose-sm max-w-none whitespace-pre-wrap">
                  {{ message.content }}
                </div>
                
                <div class="mt-6 pt-4 border-t border-white/5 flex items-center justify-between">
                  <span class="text-[8px] font-black text-white/20 uppercase tracking-widest">{{ formatTime(message.timestamp) }}</span>
                  <div class="flex space-x-1">
                    <div v-for="i in 3" :key="i" class="w-1 h-1 rounded-full bg-white/10"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Thinking Loader -->
          <div v-if="isLoading" class="flex justify-start">
            <div class="bg-white/[0.03] border border-white/10 p-8 rounded-[2rem] flex items-center space-x-4">
              <div class="flex space-x-2">
                <div class="w-2 h-2 bg-teal-400 rounded-full animate-bounce" style="animation-delay: 0s"></div>
                <div class="w-2 h-2 bg-teal-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                <div class="w-2 h-2 bg-teal-400 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
              </div>
              <span class="text-[10px] font-black text-teal-400 uppercase tracking-widest">Processing Data...</span>
            </div>
          </div>
        </div>

        <!-- Input Section -->
        <div class="p-5 sm:p-8 bg-white/[0.01] border-t border-white/5">
          <div class="relative group">
            <div class="absolute -inset-1 bg-gradient-to-r from-teal-500/20 to-blue-500/20 rounded-[2rem] blur opacity-0 group-hover:opacity-100 transition duration-700"></div>
            <div class="relative flex items-end space-x-4">
              <textarea
                v-model="newMessage"
                @keydown.enter.prevent="handleEnterKey"
                placeholder="TRANSMIT REQUEST..."
                :disabled="isLoading"
                class="flex-1 bg-white/[0.03] border border-white/10 rounded-3xl p-6 text-sm text-white focus:outline-none focus:border-teal-500/50 focus:bg-white/[0.05] transition-all resize-none max-h-40 uppercase font-black tracking-widest placeholder:text-white/10 italic"
                rows="1"
                ref="messageInput"
              ></textarea>
              
              <button
                @click="sendMessage"
                :disabled="isLoading || !newMessage.trim()"
                class="w-14 h-14 sm:w-20 sm:h-20 rounded-2xl sm:rounded-3xl bg-white border border-white/10 text-gray-950 flex items-center justify-center hover:bg-teal-400 hover:text-gray-950 transition-all group disabled:opacity-20 disabled:grayscale"
              >
                <svg class="w-6 h-6 sm:w-8 sm:h-8 group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                </svg>
              </button>
            </div>
          </div>
          <div class="mt-4 flex justify-between px-2">
            <span class="text-[9px] font-bold text-white/20 uppercase tracking-[.2em]">Ready for Transmission</span>
            <span class="text-[9px] font-bold text-white/20 uppercase tracking-[.2em]">{{ newMessage.length }}/1000 characters</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Notification Overlay -->
    <transition name="fade">
      <div v-if="showNotification" class="fixed bottom-10 right-10 z-[100]">
        <div :class="['px-8 py-4 rounded-2xl border backdrop-blur-3xl shadow-2xl flex items-center space-x-4 animate-slide-up', 
                     notificationType === 'success' ? 'bg-teal-500/10 border-teal-500/20' : 'bg-red-500/10 border-red-500/20']">
          <div :class="['w-2 h-2 rounded-full', notificationType === 'success' ? 'bg-teal-400 shadow-[0_0_8px_rgba(45,212,191,0.5)]' : 'bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.5)]']"></div>
          <span class="text-[11px] font-black text-white uppercase tracking-widest">{{ notificationMessage }}</span>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, watch, computed } from 'vue'
import { useTheme } from '../composables/useTheme'

const { isDark, themeClasses } = useTheme()

const messages = ref([])
const newMessage = ref('')
const isLoading = ref(false)
const selectedModel = ref('anthropic/claude-3-haiku')
const messagesContainer = ref(null)
const messageInput = ref(null)
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')

const API_URL = "https://openrouter.ai/api/v1/chat/completions"
const API_KEY = "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"

const quickActions = [
  { label: "System Status", text: "What's the current status of my gas monitoring system?" },
  { label: "Safety Tips", text: "Give me some gas safety tips and best practices." },
  { label: "Analytics Help", text: "How can I interpret my gas consumption analytics?" },
  { label: "Troubleshooting", text: "Help me troubleshoot common gas monitoring issues." }
]

const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => showNotification.value = false, 3000)
}

const formatTime = (timestamp) => {
  if (!timestamp) return '--:--'
  return new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false })
}

const scrollToBottom = (behavior = 'smooth') => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTo({
        top: messagesContainer.value.scrollHeight,
        behavior: behavior
      })
    }
  })
}

const handleEnterKey = (event) => {
  if (!event.shiftKey && newMessage.value.trim() && !isLoading.value) {
    event.preventDefault()
    sendMessage()
  }
}

const sendQuickMessage = (message) => {
  newMessage.value = message
  sendMessage()
}

const refreshChat = () => {
  messages.value = []
  newMessage.value = ''
  showNotificationMessage('Buffer Purged')
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || isLoading.value) return

  const userContent = newMessage.value.trim()
  messages.value.push({
    role: 'user',
    content: userContent,
    timestamp: new Date().toISOString()
  })

  newMessage.value = ''
  isLoading.value = true
  scrollToBottom()

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
        'HTTP-Referer': window.location.href,
        'X-Title': 'GaSX Bipsync AI'
      },
      body: JSON.stringify({
        model: selectedModel.value,
        messages: [
          {
            role: 'system',
            content: 'You are the Bipsync AI, a high-fidelity intelligence hub for GaSX. You specialize in technical telemetry, safety optimization, and industrial gas logistics. Maintain a professional, data-centric, and sophisticated tone.'
          },
          ...messages.value.map(m => ({ role: m.role, content: m.content }))
        ],
        temperature: 0.1,
        max_tokens: 1000
      })
    })

    if (!response.ok) throw new Error('Uplink Interrupted')
    const data = await response.json()
    
    messages.value.push({
      role: 'assistant',
      content: data.choices[0].message.content,
      timestamp: new Date().toISOString()
    })
    
    showNotificationMessage('Transmission Received')
  } catch (error) {
    showNotificationMessage('Uplink Failed', 'error')
    messages.value.push({
      role: 'assistant',
      content: '⚠️ NODE TRANSMISSION FAILURE. RE-ESTABLISH CONNECTION.',
      timestamp: new Date().toISOString()
    })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}

onMounted(() => {
  if (messageInput.value) messageInput.value.focus()
  scrollToBottom('auto')
})
</script>

<style scoped>
.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(45, 212, 191, 0.1);
  border-radius: 10px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(45, 212, 191, 0.3);
}

@keyframes pulse-slow {
  0%, 100% { opacity: 0.3; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(1.1); }
}
.animate-pulse-slow {
  animation: pulse-slow 8s ease-in-out infinite;
}

@keyframes slide-up {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
.animate-slide-up {
  animation: slide-up 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.5s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>