<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen transition-colors duration-500 relative overflow-hidden']">
    <!-- Enhanced Animated background elements -->
    <div class="absolute inset-0 overflow-hidden opacity-20">
      <div class="absolute -top-1/2 -right-1/2 w-[200%] h-[200%] bg-gradient-to-br from-blue-400 via-purple-500 to-pink-500 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-gradient-rotate animate-duration-[20s] animate-iteration-count-infinite"></div>
      <div class="absolute -bottom-1/2 -left-1/2 w-[200%] h-[200%] bg-gradient-to-tr from-cyan-400 via-blue-500 to-indigo-500 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-gradient-rotate animate-duration-[25s] animate-delay-2000 animate-iteration-count-infinite"></div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-black/10 dark:to-white/5"></div>
    </div>
    
    <div class="relative max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
      <!-- Notification Toast with pulse animation -->
      <transition 
        enter-active-class="transform ease-out duration-300 transition"
        enter-from-class="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
        enter-to-class="translate-y-0 opacity-100 sm:translate-x-0"
        leave-active-class="transition ease-in duration-100"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="showNotification" 
             :class="['fixed top-4 right-4 z-50 p-4 rounded-lg shadow-xl text-white transform transition-all duration-300', 
                     notificationType === 'success' ? 'bg-green-500/95 backdrop-blur-sm animate-pulse-success' : 'bg-red-500/95 backdrop-blur-sm animate-pulse-error',
                     'border border-white/10']">
          <div class="flex items-center">
            <svg v-if="notificationType === 'success'" class="h-6 w-6 mr-2 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            <svg v-else class="h-6 w-6 mr-2 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
            <span class="font-medium">{{ notificationMessage }}</span>
          </div>
        </div>
      </transition>

      <!-- Header -->
      <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8">
        <div class="mb-4 sm:mb-0">
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white animate-fade-in">AI Assistant</h1>
          <p class="text-gray-600 dark:text-gray-400 mt-1">Your intelligent gas monitoring assistant</p>
        </div>
        <div class="flex items-center space-x-3">
          <button 
            @click="refreshChat"
            class="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-full shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 transform hover:-translate-y-0.5 active:translate-y-0 ripple animate-hover-glow"
            :disabled="isLoading"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Refresh
          </button>
        </div>
      </div>

      <!-- Main Card with pulse animation -->
      <div :class="[themeClasses.bg.card, 'relative rounded-2xl overflow-hidden transition-all duration-300 transform hover:shadow-2xl border border-white/10 bg-opacity-80 dark:bg-opacity-80 backdrop-blur-sm mb-8 animate-pulse-card']">
        <!-- Decorative elements with gradient shift -->
        <div class="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-purple-500/10 dark:from-blue-500/5 dark:to-purple-500/5 animate-gradient-shift"></div>
        
        <div class="relative p-6 sm:p-8">
          <div class="flex flex-col sm:flex-row items-start justify-between mb-6">
            <div class="flex items-center space-x-4">
              <div class="p-3 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 animate-hover-scale">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
              </div>
              <div>
                <h1 :class="[themeClasses.text.primary, 'text-2xl font-bold']">AI Assistant</h1>
                <p :class="[themeClasses.text.muted, 'text-sm flex items-center mt-1']">
                  <span class="inline-block w-2 h-2 rounded-full bg-green-400 mr-2 animate-pulse"></span>
                  Your intelligent gas monitoring companion
                </p>
              </div>
            </div>
            
            <!-- Model Selection -->
            <div class="mt-4 sm:mt-0">
              <div class="flex items-center space-x-3">
                <label :class="[themeClasses.text.muted, 'text-sm font-medium hidden sm:block']">AI Model:</label>
                <div class="relative">
                  <select 
                    v-model="selectedModel"
                    :class="[
                      'appearance-none bg-white/10 backdrop-blur-sm border border-white/20 rounded-xl pl-4 pr-10 py-2 text-sm font-medium',
                      themeClasses.text.primary,
                      'focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50',
                      'transition-all duration-200 hover:bg-white/20 animate-input-focus',
                      'cursor-pointer min-w-[180px]'
                    ]"
                  >
                    <option value="anthropic/claude-3-haiku">Claude 3 Haiku</option>
                    <option value="mistralai/mistral-7b-instruct:free">Mistral 7B (Free)</option>
                  </select>
                  <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                    <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                    </svg>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Chat Container -->
          <div :class="[
            'flex flex-col h-[calc(100vh-300px)] sm:h-[calc(100vh-280px)]',
            'transition-all duration-300',
            isInputFocused ? 'ring-2 ring-blue-500/30' : ''
          ]">
            <!-- Chat Messages -->
            <div 
              ref="messagesContainer"
              class="flex-1 overflow-y-auto p-4 sm:p-6 space-y-4 scrollbar-thin scrollbar-thumb-gray-300 dark:scrollbar-thumb-gray-600 scrollbar-track-transparent"
            >
              <transition 
                name="fade-in"
                mode="out-in"
                appear
              >
                <div v-if="messages.length === 0" class="h-full flex items-center justify-center">
                  <div class="text-center max-w-md mx-auto py-12 px-6 bg-white/10 dark:bg-gray-700/30 backdrop-blur-sm rounded-2xl border border-white/10 dark:border-gray-600/30 animate-fade-in">
                    <div class="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-cyan-400 mb-6 shadow-lg animate-pulse-card">
                      <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                              d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                      </svg>
                    </div>
                    <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-2">Welcome to your AI Assistant!</h3>
                    <p class="text-gray-600 dark:text-gray-300 mb-6">Ask me anything about your gas monitoring system, safety protocols, analytics, or system management.</p>
                    
                    <!-- Quick Start Cards -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-6">
                      <button
                        v-for="(action, idx) in quickActions.slice(0, 4)"
                        :key="idx"
                        @click="sendQuickMessage(action.text)"
                        class="p-3 bg-white/50 dark:bg-gray-700/50 rounded-xl text-sm font-medium text-left hover:bg-white/70 dark:hover:bg-gray-600/50 transition-all duration-200 border border-white/20 dark:border-gray-600/50 hover:shadow-md hover:-translate-y-0.5 animate-hover-scale"
                      >
                        <div class="text-blue-500 mb-1">
                          <svg class="w-5 h-5 inline-block mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="action.icon" />
                          </svg>
                          {{ action.label }}
                        </div>
                        <div class="text-xs text-gray-500 dark:text-gray-400 line-clamp-2">{{ action.text }}</div>
                      </button>
                    </div>
                  </div>
                </div>
              </transition>
              
              <transition-group 
                name="chat-message" 
                tag="div" 
                class="space-y-4"
              >
                <div 
                  v-for="(message, index) in messages" 
                  :key="message.timestamp + '-' + index"
                  class="flex group"
                  :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
                >
                  <div 
                    class="relative max-w-[85%] sm:max-w-[70%] rounded-2xl px-5 py-3.5 transition-all duration-300 transform hover:scale-[1.02]"
                    :class="[
                      message.role === 'user'
                        ? 'bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-br-none shadow-lg animate-gradient-shift' 
                        : isDark 
                          ? 'bg-gray-700/80 text-gray-100 rounded-bl-none backdrop-blur-sm animate-gradient-shift' 
                          : 'bg-white/90 text-gray-800 rounded-bl-none shadow-md animate-gradient-shift',
                      'group-hover:shadow-lg'
                    ]"
                  >
                    <!-- Message content with markdown support -->
                    <div class="whitespace-pre-wrap prose prose-sm dark:prose-invert max-w-none break-words">
                      {{ message.content }}
                    </div>
                    
                    <!-- Timestamp -->
                    <div :class="[
                      'text-xs mt-2 flex items-center justify-end space-x-2',
                      message.role === 'user' ? 'text-blue-100/80' : 'text-gray-500'
                    ]">
                      <span>{{ formatTime(message.timestamp) }}</span>
                      <span v-if="message.role === 'user'" class="opacity-0 group-hover:opacity-100 transition-opacity">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path v-if="message.status === 'sent'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                          <path v-else-if="message.status === 'sending'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                          <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </span>
                    </div>
                    
                    <!-- Decorative elements -->
                    <div v-if="message.role !== 'user'" class="absolute -left-2 top-0 w-3 h-3 overflow-hidden">
                      <div class="absolute w-3 h-3 bg-gray-700/80 dark:bg-gray-800 -rotate-45 transform origin-top-left"></div>
                    </div>
                    <div v-else class="absolute -right-2 top-0 w-3 h-3 overflow-hidden">
                      <div class="absolute w-3 h-3 bg-blue-500 -rotate-45 transform origin-top-right"></div>
                    </div>
                  </div>
                </div>
              </transition-group>
              
              <!-- Loading indicator -->
              <transition name="fade-in">
                <div v-if="isLoading" class="flex justify-start">
                  <div class="relative max-w-[70%] rounded-2xl px-5 py-3 bg-white/80 dark:bg-gray-700/80 backdrop-blur-sm shadow-md">
                    <div class="flex items-center space-x-3">
                      <div class="flex space-x-1.5">
                        <div class="w-2.5 h-2.5 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0s"></div>
                        <div class="w-2.5 h-2.5 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
                        <div class="w-2.5 h-2.5 bg-blue-500 rounded-full animate-bounce" style="animation-delay: 0.4s"></div>
                      </div>
                      <span class="text-sm font-medium text-gray-700 dark:text-gray-300">AI is thinking...</span>
                    </div>
                    <!-- Decorative element -->
                    <div class="absolute -left-2 top-0 w-3 h-3 overflow-hidden">
                      <div class="absolute w-3 h-3 bg-white/80 dark:bg-gray-700/80 -rotate-45 transform origin-top-left"></div>
                    </div>
                  </div>
                </div>
              </transition>
            </div>
          </div>
          
          <!-- Input Area -->
          <div class="mt-6">
            <div :class="[themeClasses.bg.card, 'rounded-2xl p-4 border border-white/10 bg-opacity-80 dark:bg-opacity-80 backdrop-blur-sm']">
              <!-- Quick Actions -->
              <div class="mb-3 overflow-x-auto pb-2 scrollbar-hide">
                <div class="flex space-x-2 w-max">
                  <button
                    v-for="(action, idx) in quickActions"
                    :key="idx"
                    @click="sendQuickMessage(action.text)"
                    :disabled="isLoading"
                    class="px-3.5 py-1.5 text-xs sm:text-sm font-medium rounded-full whitespace-nowrap transition-all duration-200 transform hover:scale-105 active:scale-95 animate-hover-glow"
                    :class="[
                      'bg-white/50 dark:bg-gray-700/50 text-gray-700 dark:text-gray-300',
                      'border border-white/20 dark:border-gray-600/50',
                      'hover:bg-white/70 dark:hover:bg-gray-600/50',
                      'shadow-sm hover:shadow-md',
                      { 'opacity-50 cursor-not-allowed': isLoading }
                    ]"
                  >
                    {{ action.label }}
                  </button>
                </div>
              </div>
              
              <div class="flex space-x-3">
                <div class="flex-1 relative">
                  <div class="relative">
                    <textarea
                      v-model="newMessage"
                      @keydown.enter.prevent="handleEnterKey"
                      :placeholder="isLoading ? 'AI is thinking...' : 'Type your message... (Shift+Enter for new line, Enter to send)'"
                      :disabled="isLoading"
                      rows="1"
                      :class="[
                        'w-full px-4 sm:px-5 py-3.5 pr-14 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 resize-none',
                        'bg-white/80 dark:bg-gray-700/80 backdrop-blur-sm',
                        'text-gray-800 dark:text-gray-200 placeholder-gray-500 dark:placeholder-gray-400',
                        'border border-white/30 dark:border-gray-600/50 animate-input-focus',
                        'shadow-sm hover:shadow-md transition-all duration-200',
                        { 'opacity-70 cursor-not-allowed': isLoading }
                      ]"
                      ref="messageInput"
                      @focus="isInputFocused = true"
                      @blur="isInputFocused = false"
                    ></textarea>
                    
                    <!-- Attachment Button -->
                    <button 
                      class="absolute right-12 top-1/2 -translate-y-1/2 p-1.5 rounded-full text-gray-500 hover:text-blue-500 transition-colors animate-hover-scale"
                      :class="{ 'opacity-50 cursor-not-allowed': isLoading }"
                      :disabled="isLoading"
                      @click="handleAttachmentClick"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
                      </svg>
                    </button>
                    
                    <!-- Send Button -->
                    <button
                      @click="sendMessage"
                      :disabled="isLoading || !newMessage.trim()"
                      class="absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-full transition-all duration-200 transform hover:scale-110 active:scale-95 disabled:transform-none disabled:opacity-50 disabled:cursor-not-allowed animate-hover-glow"
                      :class="{
                        'bg-gradient-to-r from-blue-500 to-blue-600 text-white shadow-lg hover:from-blue-600 hover:to-blue-700': newMessage.trim(),
                        'bg-gray-200 dark:bg-gray-600 text-gray-500': !newMessage.trim()
                      }"
                      :title="newMessage.trim() ? 'Send message' : 'Type a message to send'"
                    >
                      <svg v-if="!isLoading" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                              d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                      </svg>
                      <svg v-else class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                    </button>
                  </div>
                  
                  <!-- Character Counter -->
                  <div class="absolute bottom-1 right-3 text-xs text-gray-400 dark:text-gray-500">
                    {{ newMessage.length }}/1000
                  </div>
                </div>
              </div>
              
              <!-- Input Hints -->
              <transition name="fade">
                <div v-if="isInputFocused && !newMessage" class="mt-2 text-xs text-gray-500 dark:text-gray-400 flex items-center">
                  <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Press Enter to send • Shift+Enter for new line
                </div>
              </transition>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, watch, computed } from 'vue'
import { useTheme } from '../composables/useTheme'

// Theme composable
const { isDark, themeClasses } = useTheme()

// Component state
const messages = ref([])
const newMessage = ref('')
const isLoading = ref(false)
const isInputFocused = ref(false)
const selectedModel = ref('anthropic/claude-3-haiku')
const messagesContainer = ref(null)
const messageInput = ref(null)
const showNotification = ref(false)
const notificationMessage = ref('')
const notificationType = ref('success')

// API configuration
const API_URL = "https://openrouter.ai/api/v1/chat/completions"
const API_KEY = "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"

// Quick actions for common queries
const quickActions = [
  { 
    label: "System Status", 
    text: "What's the current status of my gas monitoring system?",
    icon: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
  },
  { 
    label: "Safety Tips", 
    text: "Give me some gas safety tips and best practices.",
    icon: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
  },
  { 
    label: "Analytics Help", 
    text: "How can I interpret my gas consumption analytics?",
    icon: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
  },
  { 
    label: "Troubleshooting", 
    text: "Help me troubleshoot common gas monitoring issues.",
    icon: "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
  },
  { 
    label: "Alerts Setup", 
    text: "How do I configure gas level alerts?",
    icon: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
  }
]

// Computed properties
const messageCharsLeft = computed(() => {
  return 1000 - newMessage.value.length
})

const isMessageValid = computed(() => {
  return newMessage.value.trim().length > 0 && newMessage.value.length <= 1000
})

// Methods
const showNotificationMessage = (message, type = 'success') => {
  notificationMessage.value = message
  notificationType.value = type
  showNotification.value = true
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleTimeString([], { 
    hour: '2-digit', 
    minute: '2-digit',
    hour12: true
  }).toLowerCase()
}

const handleAttachmentClick = () => {
  // TODO: Implement file attachment functionality
  console.log('Attachment clicked')
  showNotificationMessage('Attachment feature not implemented yet', 'error')
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

const autoResizeTextarea = () => {
  const textarea = messageInput.value
  if (textarea) {
    textarea.style.height = 'auto'
    const newHeight = Math.min(textarea.scrollHeight, 150)
    textarea.style.height = `${newHeight}px`
    
    // Add a small delay to ensure the UI has updated
    setTimeout(() => {
      scrollToBottom('auto')
    }, 10)
  }
}

const handleEnterKey = (event) => {
  if (event.shiftKey) {
    // Insert new line if shift+enter is pressed
    const start = event.target.selectionStart
    const end = event.target.selectionEnd
    // Only allow new line if we're under character limit
    if (newMessage.value.length < 1000) {
      newMessage.value = newMessage.value.substring(0, start) + '\n' + newMessage.value.substring(end)
      nextTick(() => {
        event.target.selectionStart = event.target.selectionEnd = start + 1
        autoResizeTextarea()
      })
    }
  } else if (newMessage.value.trim() && !isLoading.value) {
    // Only send on enter if message is valid and not loading
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
  if (messageInput.value) {
    messageInput.value.style.height = 'auto'
  }
  scrollToBottom('auto')
  showNotificationMessage('Chat refreshed successfully')
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || isLoading.value || !isMessageValid.value) return

  // Create user message with sending state
  const userMessage = {
    role: 'user',
    content: newMessage.value.trim(),
    timestamp: new Date().toISOString(),
    status: 'sending'
  }

  // Add user message to chat
  messages.value.push(userMessage)
  
  // Store the message and clear input
  const messageToSend = newMessage.value
  newMessage.value = ''
  isLoading.value = true
  
  // Reset textarea height
  if (messageInput.value) {
    messageInput.value.style.height = 'auto'
  }
  
  // Scroll to bottom after a short delay to ensure the message is rendered
  setTimeout(() => {
    scrollToBottom('smooth')
  }, 50)

  try {
    // Update message status to sent
    const messageIndex = messages.value.length - 1
    messages.value[messageIndex].status = 'sent'
    
    // Create loading indicator for AI response
    const loadingMessage = {
      role: 'assistant',
      content: '',
      timestamp: new Date().toISOString(),
      isLoading: true
    }
    messages.value.push(loadingMessage)
    
    // Scroll to show loading indicator
    scrollToBottom('smooth')

    // Simulate API call (replace with actual API call)
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
        'HTTP-Referer': window.location.href,
        'X-Title': 'Gas Monitor AI Assistant'
      },
      body: JSON.stringify({
        model: selectedModel.value,
        messages: [
          {
            role: 'system',
            content: 'You are a highly experienced Gas Monitoring Analyst with expertise in LPG/propane systems, gas leak detection, and safety protocols. Your role is to provide professional, accurate, and helpful information about gas monitoring, consumption patterns, safety measures, and equipment maintenance. Use your knowledge to analyze gas usage data, identify potential issues, and offer practical recommendations. Be concise yet thorough in your explanations, and always prioritize safety. When discussing gas levels, use the standard 20kg tank capacity as reference unless specified otherwise.'
          },
          { role: 'user', content: messageToSend }
        ],
        temperature: 0.7,
        max_tokens: 1000
      })
    })

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`)
    }

    const data = await response.json()
    const assistantMessage = data.choices[0].message
    
    // Update the loading message with the actual response
    const loadingIndex = messages.value.findIndex(m => m.isLoading)
    if (loadingIndex !== -1) {
      // Remove loading indicator
      messages.value.splice(loadingIndex, 1)
      
      // Add actual response with animation
      messages.value.push({
        role: 'assistant',
        content: assistantMessage.content,
        timestamp: new Date().toISOString(),
        status: 'received'
      })
    }
    showNotificationMessage('Message sent successfully')
  } catch (error) {
    console.error('Error sending message:', error)
    
    // Update the loading message with an error
    const loadingIndex = messages.value.findIndex(m => m.isLoading)
    if (loadingIndex !== -1) {
      messages.value[loadingIndex] = {
        role: 'assistant',
        content: '⚠️ Sorry, I encountered an error processing your request. Please try again.',
        timestamp: new Date().toISOString(),
        isError: true
      }
    }
    showNotificationMessage('Failed to send message', 'error')
  } finally {
    isLoading.value = false
    
    // Scroll to bottom after a short delay to ensure the message is rendered
    setTimeout(() => {
      scrollToBottom('smooth')
    }, 100)
  }
}

// Watch for message input changes to auto-resize
watch(newMessage, (newVal) => {
  // Limit message length
  if (newVal.length > 1000) {
    newMessage.value = newVal.slice(0, 1000)
  }
  
  nextTick(() => {
    autoResizeTextarea()
  })
})

// Watch for theme changes to update scrollbar
watch(() => isDark.value, () => {
  // Re-apply scrollbar styles on theme change
  nextTick(() => {
    const style = document.createElement('style')
    style.id = 'custom-scrollbar'
    style.textContent = `
      .scrollbar-thin::-webkit-scrollbar {
        width: 6px;
        height: 6px;
      }
      .scrollbar-thin::-webkit-scrollbar-track {
        background: transparent;
      }
      .scrollbar-thin::-webkit-scrollbar-thumb {
        background-color: ${isDark.value ? '#4B5563' : '#D1D5DB'};
        border-radius: 3px;
      }
      .scrollbar-thin::-webkit-scrollbar-thumb:hover {
        background-color: ${isDark.value ? '#6B7280' : '#9CA3AF'};
      }
    `
    
    // Remove existing style if it exists
    const existingStyle = document.getElementById('custom-scrollbar')
    if (existingStyle) {
      existingStyle.remove()
    }
    
    document.head.appendChild(style)
  })
}, { immediate: true })

// Initialize
onMounted(() => {
  // Focus the input when the component mounts
  if (messageInput.value) {
    // Small delay to ensure the component is fully rendered
    setTimeout(() => {
      messageInput.value.focus()
    }, 300)
  }
  
  // Scroll to bottom initially
  scrollToBottom()
  
  // Add keyboard event listener for Cmd+Enter to send
  const handleKeyDown = (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'Enter' && newMessage.value.trim()) {
      sendMessage()
    }
  }
  
  window.addEventListener('keydown', handleKeyDown)
  
  // Cleanup
  return () => {
    window.removeEventListener('keydown', handleKeyDown)
  }
})
</script>

<style scoped>
/* Enhanced Animations */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

@keyframes gradientRotate {
  0% { transform: rotate(0deg) scale(1); }
  50% { transform: rotate(180deg) scale(1.05); }
  100% { transform: rotate(360deg) scale(1); }
}

@keyframes gradientFlow {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

@keyframes slideInRight {
  from { 
    opacity: 0;
    transform: translateX(20px);
  }
  to { 
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInLeft {
  from { 
    opacity: 0;
    transform: translateX(-20px);
  }
  to { 
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes bounceIn {
  0% { 
    opacity: 0;
    transform: scale(0.3);
  }
  50% { 
    opacity: 0.9;
    transform: scale(1.05);
  }
  80% { 
    opacity: 1;
    transform: scale(0.95);
  }
  100% { 
    opacity: 1;
    transform: scale(1);
  }
}

/* Pulse animation for success notification */
@keyframes pulse-success {
  0%, 100% { background-color: rgba(34, 197, 94, 0.95); }
  50% { background-color: rgba(22, 163, 74, 0.95); }
}

.animate-pulse-success {
  animation: pulse-success 2s ease-in-out infinite;
}

/* Pulse animation for error notification */
@keyframes pulse-error {
  0%, 100% { background-color: rgba(239, 68, 68, 0.95); }
  50% { background-color: rgba(220, 38, 38, 0.95); }
}

.animate-pulse-error {
  animation: pulse-error 2s ease-in-out infinite;
}

/* Gradient shift for card and message backgrounds */
@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.animate-gradient-shift {
  background-size: 200% 200%;
  animation: gradient-shift 10s ease infinite;
}

/* Pulse animation for card */
@keyframes pulse-card {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.01); }
}

.animate-pulse-card {
  animation: pulse-card 4s ease-in-out infinite;
}

/* Hover glow effect */
@keyframes hover-glow {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  50% { box-shadow: 0 0 15px 5px rgba(59, 130, 246, 0.3); }
  100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
}

.animate-hover-glow:hover {
  animation: hover-glow 1.5s ease-in-out infinite;
}

/* Scale effect for buttons on hover */
@keyframes hover-scale {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.animate-hover-scale:hover {
  animation: hover-scale 0.3s ease-in-out;
}

/* Input focus animation */
@keyframes input-focus {
  0% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.5); }
  100% { box-shadow: 0 0 8px 2px rgba(59, 130, 246, 0.3); }
}

.animate-input-focus:focus {
  animation: input-focus 0.3s ease-in-out forwards;
}

/* Transition effects */
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.chat-message-enter-active {
  animation: slideInRight 0.4s cubic-bezier(0.2, 0.8, 0.4, 1);
  will-change: transform, opacity;
}

.chat-message-leave-active {
  position: absolute;
  opacity: 0;
  transition: all 0.3s ease;
}

.chat-message-move {
  transition: transform 0.3s ease;
}

/* Custom scrollbar */
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .message-bubble {
    max-width: 85%;
  }
  
  .quick-actions {
    padding-bottom: 0.5rem;
    margin-bottom: 0.5rem;
  }
}

/* Animation classes */
.animate-fade-in {
  animation: fadeIn 0.5s cubic-bezier(0.2, 0.8, 0.4, 1) forwards;
  will-change: transform, opacity;
}

/* Enhanced message animations */
.message-enter-active {
  transition: all 0.4s cubic-bezier(0.2, 0.8, 0.4, 1);
  will-change: transform, opacity;
}

.message-enter-from {
  opacity: 0;
  transform: translateY(10px) scale(0.95);
}

/* Button hover effects */
.hover-scale {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.hover-scale:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* Ripple effect for buttons */
.ripple {
  position: relative;
  overflow: hidden;
  transform: translate3d(0, 0, 0);
}

.ripple:after {
  content: '';
  display: block;
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  pointer-events: none;
  background-image: radial-gradient(circle, #fff 10%, transparent 10.01%);
  background-repeat: no-repeat;
  background-position: 50%;
  transform: scale(10, 10);
  opacity: 0;
  transition: transform 0.5s, opacity 1s;
}

.ripple:active:after {
  transform: scale(0, 0);
  opacity: 0.2;
  transition: 0s;
}

.animate-slide-in-right {
  animation: slideInRight 0.3s ease-out forwards;
}

.animate-slide-in-left {
  animation: slideInLeft 0.3s ease-out forwards;
}

.animate-bounce-in {
  animation: bounceIn 0.5s ease-out forwards;
}

/* Smooth transitions */
.transition-all {
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: 200ms;
}

/* Custom scrollbar for WebKit browsers */
.scrollbar-thin::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.scrollbar-thin::-webkit-scrollbar-track {
  background: transparent;
}

.scrollbar-thin::-webkit-scrollbar-thumb {
  background-color: #D1D5DB;
  border-radius: 3px;
}

.dark .scrollbar-thin::-webkit-scrollbar-thumb {
  background-color: #4B5563;
}

.scrollbar-thin::-webkit-scrollbar-thumb:hover {
  background-color: #9CA3AF;
}

.dark .scrollbar-thin::-webkit-scrollbar-thumb:hover {
  background-color: #6B7280;
}

/* Smooth animations */
.transition-colors {
  transition: color 0.2s ease, background-color 0.2s ease;
}

/* Loading animation */
@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

.animate-bounce {
  animation: bounce 1.4s infinite ease-in-out both;
}

/* Auto-resize textarea */
textarea {
  min-height: 48px;
  max-height: 120px;
}

/* Ensure messages stay within frame */
/* .max-w-[85%], .max-w-[70%] {
  word-break: break-word;
  overflow-wrap: break-word;
  hyphens: auto;
} */
</style>