import { ref, computed, watch } from 'vue'

// Global theme state
const isDark = ref(false)

// Initialize theme from localStorage or system preference
const initializeTheme = () => {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme) {
    isDark.value = savedTheme === 'dark'
  } else {
    // Check system preference
    isDark.value = window.matchMedia('(prefers-color-scheme: dark)').matches
  }
  
  // Apply theme to document
  updateDocumentTheme()
}

// Update document class and localStorage
const updateDocumentTheme = () => {
  if (isDark.value) {
    document.documentElement.classList.add('dark')
    localStorage.setItem('theme', 'dark')
  } else {
    document.documentElement.classList.remove('dark')
    localStorage.setItem('theme', 'light')
  }
}

// Watch for theme changes
watch(isDark, updateDocumentTheme)

export const useTheme = () => {
  const toggleTheme = () => {
    isDark.value = !isDark.value
  }

  const setTheme = (theme) => {
    isDark.value = theme === 'dark'
  }

  // Theme-aware classes
  const themeClasses = computed(() => ({
    // Background classes
    bg: {
      primary: isDark.value ? 'bg-gray-900' : 'bg-gray-50',
      secondary: isDark.value ? 'bg-gray-800' : 'bg-white',
      tertiary: isDark.value ? 'bg-gray-700' : 'bg-gray-100',
      card: isDark.value ? 'bg-gray-800' : 'bg-white',
      modal: isDark.value ? 'bg-gray-800' : 'bg-white',
      input: isDark.value ? 'bg-gray-700' : 'bg-white',
      hover: isDark.value ? 'hover:bg-gray-700' : 'hover:bg-gray-50',
      selected: isDark.value ? 'bg-gray-700' : 'bg-blue-50'
    },
    
    // Text classes - Enhanced for maximum visibility
    text: {
      primary: isDark.value ? 'text-white' : 'text-gray-900',
      secondary: isDark.value ? 'text-white' : 'text-gray-800',
      tertiary: isDark.value ? 'text-white' : 'text-gray-700',
      muted: isDark.value ? 'text-gray-300' : 'text-gray-600',
      inverse: isDark.value ? 'text-gray-900' : 'text-white',
      accent: isDark.value ? 'text-blue-300' : 'text-blue-700',
      success: isDark.value ? 'text-green-300' : 'text-green-700',
      warning: isDark.value ? 'text-orange-300' : 'text-orange-700',
      error: isDark.value ? 'text-red-300' : 'text-red-700',
      // Additional readable text variants
      heading: isDark.value ? 'text-white' : 'text-gray-900',
      body: isDark.value ? 'text-white' : 'text-gray-800',
      caption: isDark.value ? 'text-gray-300' : 'text-gray-700',
      disabled: isDark.value ? 'text-gray-500' : 'text-gray-400'
    },
    
    // Border classes
    border: {
      primary: isDark.value ? 'border-gray-700' : 'border-gray-200',
      secondary: isDark.value ? 'border-gray-600' : 'border-gray-300',
      accent: isDark.value ? 'border-blue-500' : 'border-blue-500',
      success: isDark.value ? 'border-green-500' : 'border-green-500',
      warning: isDark.value ? 'border-orange-500' : 'border-orange-500',
      error: isDark.value ? 'border-red-500' : 'border-red-500'
    },
    
    // Button classes - Enhanced for better text contrast
    button: {
      primary: isDark.value 
        ? 'bg-blue-600 hover:bg-blue-700 text-white font-medium' 
        : 'bg-blue-600 hover:bg-blue-700 text-white font-medium',
      secondary: isDark.value 
        ? 'bg-gray-700 hover:bg-gray-600 text-gray-100 font-medium' 
        : 'bg-gray-200 hover:bg-gray-300 text-gray-900 font-medium',
      ghost: isDark.value 
        ? 'text-gray-200 hover:bg-gray-700 hover:text-white' 
        : 'text-gray-700 hover:bg-gray-100 hover:text-gray-900',
      danger: isDark.value 
        ? 'bg-red-600 hover:bg-red-700 text-white' 
        : 'bg-red-600 hover:bg-red-700 text-white'
    },
    
    // Alert/Status classes - Enhanced for better readability
    alert: {
      success: isDark.value 
        ? 'bg-green-900/60 border-green-400/60 text-green-200' 
        : 'bg-green-50 border-green-300 text-green-800',
      warning: isDark.value 
        ? 'bg-orange-900/60 border-orange-400/60 text-orange-200' 
        : 'bg-orange-50 border-orange-300 text-orange-800',
      error: isDark.value 
        ? 'bg-red-900/60 border-red-400/60 text-red-200' 
        : 'bg-red-50 border-red-300 text-red-800',
      info: isDark.value 
        ? 'bg-blue-900/60 border-blue-400/60 text-blue-200' 
        : 'bg-blue-50 border-blue-300 text-blue-800'
    },
    
    // Shadow classes - Enhanced for better depth perception
    shadow: isDark.value ? 'shadow-xl shadow-black/30' : 'shadow-lg shadow-gray-200/50'
  }))

  // Initialize theme on first use
  if (typeof window !== 'undefined') {
    initializeTheme()
  }

  return {
    isDark: computed(() => isDark.value),
    toggleTheme,
    setTheme,
    themeClasses
  }
}
