<template>
  <div class="login-page min-h-screenbg-white/">
    <!-- Header -->


    <div class="flex flex-col lg:flex-row min-h-screen">
      <!-- Left Side - Welcome Back -->
      <div class="lg:w-1/2 bg/ text-white p-8 lg:p-12 flex flex-col justify-center">
        <div class="max-w-md mx-auto lg:mx-0">
          <h2 class="text-3xl lg:text-4xl font-bold mb-6">
            Welcome Back
          </h2>
          <p class="text-lg text-gray-300 mb-8">
            Sign in to your account to continue monitoring your gas levels and keeping your home safe.
          </p>

          <!-- Stats -->
          <div class="grid grid-cols-2 gap-6 mb-8">
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-400 mb-1">99.9%</div>
              <div class="text-sm text-gray-300">Uptime</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-400 mb-1">24/7</div>
              <div class="text-sm text-gray-300">Monitoring</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-400 mb-1">10k+</div>
              <div class="text-sm text-gray-300">Active Users</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-blue-400 mb-1">5★</div>
              <div class="text-sm text-gray-300">Average Rating</div>
            </div>
          </div>

          <!-- Recent Activity Preview -->
          <div class="bg-gray-800 rounded-lg p-6">
            <h3 class="font-semibold mb-4 flex items-center">
              <svg class="w-5 h-5 mr-2 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
              What's New
            </h3>
            <div class="space-y-3 text-sm">
              <!-- <div class="flex items-center justify-between">
                <span class="text-gray-300">Enhanced mobile alerts</span>
                <span class="text-blue-400 text-xs">NEW</span>
              </div> -->
              <div class="flex items-center justify-between">
                <span class="text-gray-300">Improved analytics dashboard</span>
                <span class="text-green-400 text-xs">UPDATED</span>
              </div>
              <!-- <div class="flex items-center justify-between">
                <span class="text-gray-300">Multi-device sync</span>
                <span class="text-blue-400 text-xs">BETA</span>
              </div> -->
            </div>
          </div>
        </div>
      </div>

      <!-- Right Side - Login Form -->
      <div class="lg:w-1/2 bg-blue-800/ p-8 lg:p-12 flex flex-col justify-center">
        <div class="max-w-md mx-auto w-full">
          <div class="text-center mb-8">
            <h2 class="text-2xl lg:text-3xl font-bold text-gray-100 mb-2">
              Sign In
            </h2>
            <p class="text-gray-700  ">
              Enter your credentials to access your dashboard
            </p>
          </div>

          <!-- Error Alert -->
          <div v-if="loginError" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
            <svg class="w-5 h-5 text-red-500 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor"
              viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <div>
              <h3 class="text-sm font-medium text-red-800">Sign In Failed</h3>
              <p class="text-sm text-red-700 mt-1">{{ loginError }}</p>
            </div>
          </div>

          <form @submit.prevent="handleLogin" class="space-y-6">
            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                Email Address
              </label>
              <input id="email" v-model="form.email" type="email" required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                :class="{ 'border-red-500': errors.email }" placeholder="john@example.com">
              <p v-if="errors.email" class="mt-1 text-sm text-red-600">{{ errors.email }}</p>
            </div>

            <!-- Password -->
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <div class="relative">
                <input id="password" v-model="form.password" :type="showPassword ? 'text' : 'password'" required
                  class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  :class="{ 'border-red-500': errors.password }" placeholder="••••••••">
                <button type="button" @click="showPassword = !showPassword"
                  class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700 transition-colors duration-200">
                  <svg v-if="showPassword" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                  </svg>
                  <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                </button>
              </div>
              <p v-if="errors.password" class="mt-1 text-sm text-red-600">{{ errors.password }}</p>
            </div>

            <!-- Remember Me & Forgot Password -->
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <input id="remember" v-model="form.rememberMe" type="checkbox"
                  class="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500  ">
                <label for="remember" class="ml-2 text-sm text-gray-600">
                  Remember me
                </label>
              </div>
              <button type="button" @click="showForgotPassword = true"
                class="text-sm text-blue-600 hover:text-blue-700 font-medium transition-colors duration-200">
                Forgot password?
              </button>
            </div>

            <!-- Submit Button -->
            <button type="submit" :disabled="isSubmitting"
              class="w-full py-3 px-4 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium rounded-lg transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
              <span v-if="!isSubmitting">Sign In</span>
              <span v-else class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none"
                  viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                  </path>
                </svg>
                Signing In...
              </span>
            </button>

            <div class="bg-white/ shadow-sm ">
              <div class="container mx-auto px-4 sm:px-6 py-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center">
                    <!-- <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center mr-3">
                      <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                      </svg>
                    </div> -->
                    <!-- <h1 class="text-xl font-bold text-gray-900">GasMonitor </h1> -->
                  </div>
                  <router-link to="/register"
                    class="text-gray-600 hover:text-gray-300 font-medium transition-colors duration-200">
                    Don't have an account? Sign Up
                  </router-link>
                </div>
              </div>
            </div>

            <!-- Divider -->
            <div class="relative">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-gray-300"></div>
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-2 bg-white text-gray-500">Or continue with</span>
              </div>
            </div>

            <!-- Social Login -->
            <div class="grid grid-cols-2 gap-3">
              <button type="button"
                class="w-full py-2 px-4 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors duration-200">
                <svg class="w-5 h-5 mx-auto" viewBox="0 0 24 24">
                  <path fill="#4285F4"
                    d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                  <path fill="#34A853"
                    d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                  <path fill="#FBBC05"
                    d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" />
                  <path fill="#EA4335"
                    d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" />
                </svg>
              </button>
              <button type="button"
                class="w-full py-2 px-4 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors duration-200">
                <svg class="w-5 h-5 mx-auto" fill="currentColor" viewBox="0 0 24 24">
                  <path
                    d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 5.079 3.158 9.417 7.618 11.174-.105-.949-.199-2.403.041-3.439.219-.937 1.406-5.957 1.406-5.957s-.359-.72-.359-1.781c0-1.663.967-2.911 2.168-2.911 1.024 0 1.518.769 1.518 1.688 0 1.029-.653 2.567-.992 3.992-.285 1.193.6 2.165 1.775 2.165 2.128 0 3.768-2.245 3.768-5.487 0-2.861-2.063-4.869-5.008-4.869-3.41 0-5.409 2.562-5.409 5.199 0 1.033.394 2.143.889 2.741.093.116.108.219.08.338-.09.375-.293 1.199-.334 1.363-.053.225-.172.271-.402.165-1.495-.69-2.433-2.878-2.433-4.646 0-3.776 2.748-7.252 7.92-7.252 4.158 0 7.392 2.967 7.392 6.923 0 4.135-2.607 7.462-6.233 7.462-1.214 0-2.357-.629-2.746-1.378l-.753 2.87c-.27 1.04-1.005 2.35-1.497 3.148C9.57 23.812 10.763 24.009 12.017 24.009c6.624 0 11.99-5.367 11.99-11.988C24.007 5.367 18.641.001 12.017.001z" />
                </svg>
              </button>
            </div>

            <!-- Security Note -->
            <div class="text-center pt-4">
              <p class="text-xs text-gray-500">
                <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
                Secure SSL connection. Your data is protected.
              </p>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Forgot Password Modal -->
    <div v-if="showForgotPassword"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
      @click="showForgotPassword = false">
      <div class="bg-white rounded-lg p-6 w-full max-w-md" @click.stop>
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">Reset Password</h3>
          <button @click="showForgotPassword = false" class="text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <p class="text-gray-600 mb-4">
          Enter your email address and we'll send you a link to reset your password.
        </p>

        <form @submit.prevent="handleForgotPassword">
          <div class="mb-4">
            <label for="resetEmail" class="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <input id="resetEmail" v-model="resetEmail" type="email" required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="john@example.com">
          </div>

          <div class="flex gap-3">
            <button type="button" @click="showForgotPassword = false"
              class="flex-1 py-2 px-4 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors duration-200">
              Cancel
            </button>
            <button type="submit" :disabled="isResettingPassword"
              class="flex-1 py-2 px-4 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white rounded-lg transition-colors duration-200">
              <span v-if="!isResettingPassword">Send Reset Link</span>
              <span v-else>Sending...</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
  
  <script setup>
  import { ref, watch } from 'vue';
  import { useRouter } from 'vue-router';
  import api from './api'
  const router = useRouter()
  const form = ref({
    email: '',
    password: '',
    rememberMe: false
  });
  
  const errors = ref({});
  const loginError = ref('');
  const isSubmitting = ref(false);
  const showPassword = ref(false);
  const showForgotPassword = ref(false);
  const resetEmail = ref('');
  const isResettingPassword = ref(false);
  
  // Validation functions
  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };
  
  // Real-time validation
  watch(() => form.value.email, (newEmail) => {
    if (newEmail && !validateEmail(newEmail)) {
      errors.value.email = 'Please enter a valid email address';
    } else {
      delete errors.value.email;
    }
  });
  
  const handleLogin = async () => {
    // Clear previous errors
    errors.value = {};
    loginError.value = '';
  
    // Validate fields
    if (!form.value.email) {
      errors.value.email = 'Email is required';
    } else if (!validateEmail(form.value.email)) {
      errors.value.email = 'Please enter a valid email address';
    }
  
    if (!form.value.password) {
      errors.value.password = 'Password is required';
    }
  
    // If there are validation errors, stop submission
    if (Object.keys(errors.value).length > 0) {
      return;
    }
  
    isSubmitting.value = true;
  
   
  try {
    const response = await api.post("users/login/", {
      email: form.value.email,
      password: form.value.password
    });

    // Store token if using JWT
    localStorage.setItem('authToken', response.data.token);
    
    // Redirect to dashboard or home
    await router.push('admin/analytics');
    
  } catch (error) {
  console.error('Login error:', error);

  const errorData = error.response?.data;

  if (error.response?.status === 401) {
    loginError.value = 'Invalid email or password';
  } else if (error.response?.status === 400 && errorData) {
    // Handle field-specific errors from 400 response
    for (const field in errorData) {
      const messages = errorData[field];
      const camelCaseField = field.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());

      if (Array.isArray(messages)) {
        errors.value[camelCaseField] = messages.join(' ');
      } else if (typeof messages === 'string') {
        errors.value[camelCaseField] = messages;
      } else {
        loginError.value = 'Invalid input. Please check your data.';
      }
    }
  } else if (errorData?.message) {
    loginError.value = errorData.message;
  } else if (error.request) {
    loginError.value = 'No response from server. Please check your connection.';
  } else {
    console.error('Unexpected error', error);
   
  }
}

 finally {
    isSubmitting.value = false;
  }
};
  
  const handleForgotPassword = async () => {
    if (!resetEmail.value || !validateEmail(resetEmail.value)) {
      return;
    }
  
    isResettingPassword.value = true;
  
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      console.log('Password reset email sent to:', resetEmail.value);
      
      // Show success message
      alert('Password reset link sent to your email!');
      
      // Close modal
      showForgotPassword.value = false;
      resetEmail.value = '';
      
    } catch (error) {
      console.error('Password reset failed:', error);
      alert('Failed to send reset email. Please try again.');
    } finally {
      isResettingPassword.value = false;
    }
  };
  </script>
  
  <style >
  .login-page {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  }
  
  /* Custom focus styles */
  input:focus, button:focus ,textarea:focus {
    outline: none;
  }
  
  /* Loading animation */
  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }
  
  .animate-spin {
    animation: spin 1s linear infinite;
  }
  
  /* Modal backdrop blur effect */
  .fixed.inset-0 {
    backdrop-filter: blur(4px);
  }
  </style>