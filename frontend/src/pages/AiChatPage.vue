<template>
  <div :class="[themeClasses.bg.primary, 'min-h-screen p-4 sm:p-6']">
    <!-- Header -->
    <div class="mb-4 sm:mb-6">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between space-y-4 sm:space-y-0">
        <div class="flex items-center space-x-3">
          <div class="p-2 sm:p-3 rounded-lg bg-blue-500">
            <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>
          <div>
            <h1 :class="[themeClasses.text.primary, 'text-xl sm:text-2xl font-bold']">AI Assistant</h1>
            <p :class="[themeClasses.text.muted, 'text-xs sm:text-sm']">Your intelligent gas monitoring companion</p>
          </div>
        </div>
        
        <!-- Model Selection -->
        <div class="flex items-center space-x-2 sm:space-x-3">
          <label :class="[themeClasses.text.muted, 'text-xs sm:text-sm font-medium']">Model:</label>
          <select 
            v-model="selectedModel"
            :class="[
              themeClasses.bg.secondary,
              themeClasses.text.primary,
              themeClasses.border.primary,
              'px-2 sm:px-3 py-1 sm:py-2 text-xs sm:text-sm border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500'
            ]"
          >
            <option value="anthropic/claude-3-haiku">Claude 3 Haiku</option>
            <option value="mistralai/mistral-7b-instruct:free">Mistral 7B (Free)</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Chat Container -->
    <div :class="[
      themeClasses.bg.secondary,
      themeClasses.border.primary,
      'rounded-lg border shadow-lg h-[calc(100vh-160px)] sm:h-[calc(100vh-200px)] flex flex-col'
    ]">
      <!-- Chat Messages -->
      <div 
        ref="messagesContainer"
        :class="[
          themeClasses.bg.primary,
          'flex-1 overflow-y-auto p-4 sm:p-6 space-y-3 sm:space-y-4'
        ]"
      >
        <div v-if="messages.length === 0" :class="[themeClasses.text.muted, 'text-center py-12']">
          <div class="max-w-md mx-auto">
            <svg class="w-16 h-16 mx-auto mb-4 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <h3 class="text-lg font-semibold mb-2">Welcome to your AI Assistant!</h3>
            <p class="text-sm">Ask me anything about your gas monitoring system, safety protocols, analytics, or system management.</p>
          </div>
        </div>
        
        <div 
          v-for="(message, index) in messages" 
          :key="index"
          class="flex"
          :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
        >
          <div 
            :class="[
              'max-w-[70%] rounded-lg px-4 py-3',
              message.role === 'user' 
                ? 'bg-blue-500 text-white' 
                : isDark 
                  ? 'bg-gray-700 text-gray-100' 
                  : 'bg-gray-100 text-gray-900'
            ]"
          >
            <div class="whitespace-pre-wrap">{{ message.content }}</div>
            <div :class="[
              'text-xs mt-2 opacity-70',
              message.role === 'user' ? 'text-blue-100' : themeClasses.text.muted
            ]">
              {{ formatTime(message.timestamp) }}
            </div>
          </div>
        </div>
        
        <!-- Loading indicator -->
        <div v-if="isLoading" class="flex justify-start">
          <div :class="[
            'rounded-lg px-4 py-3',
            isDark ? 'bg-gray-700 text-gray-100' : 'bg-gray-100 text-gray-900'
          ]">
            <div class="flex items-center space-x-2">
              <div class="flex space-x-1">
                <div class="w-2 h-2 bg-current rounded-full animate-bounce"></div>
                <div class="w-2 h-2 bg-current rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
                <div class="w-2 h-2 bg-current rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
              </div>
              <span class="text-sm">AI is thinking...</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Input Area -->
      <div :class="[
        themeClasses.bg.secondary,
        themeClasses.border.primary,
        'border-t p-4'
      ]">
        <div class="flex space-x-3">
          <div class="flex-1">
            <textarea
              v-model="newMessage"
              @keydown.enter.prevent="handleEnterKey"
              :placeholder="isLoading ? 'AI is thinking...' : 'Type your message... (Shift+Enter for new line, Enter to send)'"
              :disabled="isLoading"
              rows="1"
              :class="[
                themeClasses.bg.primary,
                themeClasses.text.primary,
                themeClasses.border.primary,
                'w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none',
                { 'opacity-50 cursor-not-allowed': isLoading }
              ]"
              ref="messageInput"
            ></textarea>
          </div>
          <button
            @click="sendMessage"
            :disabled="isLoading || !newMessage.trim()"
            :class="[
              'px-6 py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors flex items-center space-x-2',
              { 'opacity-50 cursor-not-allowed': isLoading || !newMessage.trim() }
            ]"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
            </svg>
            <span>Send</span>
          </button>
        </div>
        
        <!-- Quick Actions -->
        <div class="mt-3 flex flex-wrap gap-2">
          <button
            v-for="quickAction in quickActions"
            :key="quickAction.text"
            @click="sendQuickMessage(quickAction.text)"
            :disabled="isLoading"
            :class="[
              themeClasses.bg.tertiary,
              themeClasses.text.secondary,
              themeClasses.border.primary,
              'px-3 py-1 text-sm border rounded-full hover:bg-blue-500 hover:text-white transition-colors',
              { 'opacity-50 cursor-not-allowed': isLoading }
            ]"
          >
            {{ quickAction.label }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, watch } from 'vue'
import { useTheme } from '../composables/useTheme'

// Theme composable
const { isDark, themeClasses } = useTheme()

// Component state
const messages = ref([])
const newMessage = ref('')
const isLoading = ref(false)
const selectedModel = ref('anthropic/claude-3-haiku')
const messagesContainer = ref(null)
const messageInput = ref(null)

// API configuration
const API_URL = "https://openrouter.ai/api/v1/chat/completions"
const API_KEY = "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"

// Quick actions for common queries
const quickActions = [
  { label: "System Status", text: "What's the current status of my gas monitoring system?" },
  { label: "Safety Tips", text: "Give me some gas safety tips and best practices." },
  { label: "Analytics Help", text: "How can I interpret my gas consumption analytics?" },
  { label: "Troubleshooting", text: "Help me troubleshoot common gas monitoring issues." },
  { label: "Alerts Setup", text: "How do I configure gas level alerts?" }
]

// Methods
const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

const autoResizeTextarea = () => {
  if (messageInput.value) {
    messageInput.value.style.height = 'auto'
    messageInput.value.style.height = Math.min(messageInput.value.scrollHeight, 120) + 'px'
  }
}

const handleEnterKey = (event) => {
  if (event.shiftKey) {
    // Allow new line with Shift+Enter
    return
  } else {
    // Send message with Enter
    event.preventDefault()
    sendMessage()
  }
}

const sendQuickMessage = (message) => {
  newMessage.value = message
  sendMessage()
}

const sendMessage = async () => {
  if (!newMessage.value.trim() || isLoading.value) return

  const userMessage = newMessage.value.trim()
  const timestamp = Date.now()
  
  // Add user message
  messages.value.push({
    role: 'user',
    content: userMessage,
    timestamp
  })

  newMessage.value = ''
  if (messageInput.value) {
    messageInput.value.style.height = 'auto'
  }

  await scrollToBottom()

  // Set loading state
  isLoading.value = true

  try {
    // Prepare messages for API
    const apiMessages = messages.value.map(msg => ({
      role: msg.role,
      content: msg.content
    }))

    // Add system message for context
    const systemMessage = {
      role: 'system',
      content: `You are an AI assistant specialized in gas monitoring systems. You help users with:
      - Gas safety protocols and best practices
      - System analytics and data interpretation
      - Troubleshooting gas monitoring equipment
      - Alert configuration and management
      - Consumption pattern analysis
      - Maintenance recommendations
      
      Provide helpful, accurate, and concise responses. Focus on practical advice and actionable insights.`
    }

    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`,
        'HTTP-Referer': window.location.origin,
        'X-Title': 'Gas Monitor AI Assistant'
      },
      body: JSON.stringify({
        model: selectedModel.value,
        messages: [systemMessage, ...apiMessages],
        max_tokens: 500,
        temperature: 0.7,
        stream: false
      })
    })

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`)
    }

    const data = await response.json()
    
    if (data.choices && data.choices.length > 0) {
      const aiResponse = data.choices[0].message.content.trim()
      
      // Add AI response
      messages.value.push({
        role: 'assistant',
        content: aiResponse,
        timestamp: Date.now()
      })
    } else {
      throw new Error('No response from AI')
    }

  } catch (error) {
    console.error('AI Chat Error:', error)
    
    // Add error message
    messages.value.push({
      role: 'assistant',
      content: 'Sorry, I encountered an error while processing your request. Please try again or check your internet connection.',
      timestamp: Date.now()
    })
  } finally {
    isLoading.value = false
    await scrollToBottom()
  }
}

// Watch for message input changes to auto-resize
watch(newMessage, () => {
  nextTick(() => {
    autoResizeTextarea()
  })
})

// Add welcome message on mount
onMounted(() => {
  messages.value.push({
    role: 'assistant',
    content: 'Hello! I\'m your AI assistant for the gas monitoring system. I can help you with system analysis, safety protocols, troubleshooting, and more. How can I assist you today?',
    timestamp: Date.now()
  })
})
</script>

<style scoped>
/* Custom scrollbar for messages */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 6px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
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
</style>
