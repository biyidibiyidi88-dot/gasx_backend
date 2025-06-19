<template>
  <div class="signup-page min-h-screen bg-gray-50/ ">
    <!-- Header -->


    <div class="flex flex-col lg:flex-row min-h-screen">
      <!-- Left Side - Benefits -->
      <div class="lg:w-1/2 bg-blue-500/ text-white p-8 lg:p-12 flex flex-col justify-center">
        <div class="max-w-md mx-auto lg:mx-0">
          <h2 class="text-3xl lg:text-4xl font-bold mb-6">
            Join thousands of users protecting their homes
          </h2>
          <p class="text-lg text-gray-300 mb-8">
            Start monitoring your gas levels with real-time alerts and comprehensive analytics.
          </p>

          <div class="space-y-6">
            <div v-for="(benefit, index) in benefits" :key="index" class="flex items-start">
              <div class="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center mr-4 mt-0.5 flex-shrink-0">
                <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <h3 class="font-semibold mb-1">{{ benefit.title }}</h3>
                <p class="text-gray-300 text-sm">{{ benefit.description }}</p>
              </div>
            </div>
          </div>

          <div class="mt-12 p-6 bg-gray-800/ rounded-lg">
            <div class="flex items-center mb-3">
              <div class="flex text-yellow-400">
                <svg v-for="i in 5" :key="i" class="w-4 h-4 fill-current" viewBox="0 0 24 24">
                  <path
                    d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                </svg>
              </div>
              <span class="ml-2 text-sm text-gray-300">5.0 rating</span>
            </div>
            <p class="text-sm text-gray-300 italic">
              "This system has given me complete peace of mind. The alerts are instant and the dashboard is incredibly
              intuitive."
            </p>
            <p class="text-xs text-gray-400 mt-2">- Sarah M., verified user</p>
          </div>
        </div>
      </div>

      <!-- Right Side - Signup Form -->
      <div class="lg:w-1/2 bg-white/ p-8 lg:p-12 flex flex-col justify-center">
        <div class="max-w-md mx-auto w-full">
          <div class="text-center mb-8">
            <h2 class="text-2xl lg:text-3xl font-bold text-gray-900 mb-2">
              Create Your Account
            </h2>
            <p class="text-gray-600">
              Get started with your free 30-day trial
            </p>
          </div>

          <form @submit.prevent="handleSubmit" class="space-y-6">
            <!-- Name Fields -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label for="firstName" class="block text-sm font-medium text-gray-700 mb-2">
                  First Name *
                </label>
                <input id="firstName" v-model="form.firstName" type="text" required
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  :class="{ 'border-red-500': errors.firstName }" placeholder="John">
                <p v-if="errors.firstName" class="mt-1 text-sm text-red-600">{{ errors.firstName }}</p>
              </div>
              <div>
                <label for="lastName" class="block text-sm font-medium text-gray-700 mb-2">
                  Last Name *
                </label>
                <input id="lastName" v-model="form.lastName" type="text" required
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  :class="{ 'border-red-500': errors.lastName }" placeholder="Doe">
                <p v-if="errors.lastName" class="mt-1 text-sm text-red-600">{{ errors.lastName }}</p>
              </div>
            </div>

            <!-- Email -->
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                Email Address *
              </label>
              <input id="email" v-model="form.email" type="email" required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                :class="{ 'border-red-500': errors.email }" placeholder="john@example.com">
              <p v-if="errors.email" class="mt-1 text-sm text-red-600">{{ errors.email }}</p>
            </div>

            <!-- Phone -->
            <div>
              <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">
                Phone Number *
              </label>
              <input id="phone" v-model="form.phone" type="tel" required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                :class="{ 'border-red-500': errors.phone }" placeholder="+237 678808831">
              <p v-if="errors.phone" class="mt-1 text-sm text-red-600">{{ errors.phone }}</p>
            </div>

            <!-- Password -->
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                Password *
              </label>
              <div class="relative">
                <input id="password" v-model="form.password" :type="showPassword ? 'text' : 'password'" required
                  class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  :class="{ 'border-red-500': errors.password }" placeholder="••••••••">
                <button type="button" @click="showPassword = !showPassword"
                  class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700">
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
              <div class="mt-2">
                <div class="flex items-center space-x-2 text-xs">
                  <div v-for="(requirement, index) in passwordRequirements" :key="index" class="flex items-center"
                    :class="requirement.met ? 'text-green-600' : 'text-gray-400'">
                    <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path v-if="requirement.met" fill-rule="evenodd"
                        d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        clip-rule="evenodd" />
                      <circle v-else cx="10" cy="10" r="8" fill="none" stroke="currentColor" stroke-width="2" />
                    </svg>
                    <span>{{ requirement.text }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Confirm Password -->
            <div>
              <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
                Confirm Password *
              </label>
              <input id="confirmPassword" v-model="form.confirmPassword" type="password" required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                :class="{ 'border-red-500': errors.confirmPassword }" placeholder="••••••••">
              <p v-if="errors.confirmPassword" class="mt-1 text-sm text-red-600">{{ errors.confirmPassword }}</p>
            </div>

            <header class="bg-white/ shadow-sm border-b ">
              <div class="container mx-auto px-4 sm:px-6 py-4">
                <div class="flex items-center justify-between">
                  <div class="flex items-center">
                    <!-- <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center mr-3">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>-->
                    <!-- <h1 class="text-xl font-bold text-gray-900">GasMonitor Pro</h1> -->
                  </div>
                  <router-link to="/login"
                    class="text-gray-600 hover:text-gray-300 font-medium transition-colors duration-200">
                    Already have an account? Sign In
                  </router-link>
                </div>
              </div>
            </header>



            <!-- Terms and Newsletter -->
            <div class="space-y-3">
              <div class="flex items-start">
                <input id="terms" v-model="form.acceptTerms" type="checkbox" required
                  class="mt-1 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                <label for="terms" class="ml-3 text-sm text-gray-600">
                  I agree to the
                  <a href="#" class="text-blue-600 hover:text-blue-700 underline">Terms of Service</a>
                  and
                  <a href="#" class="text-blue-600 hover:text-blue-700 underline">Privacy Policy</a> *
                </label>
              </div>
              <div class="flex items-start">
                <input id="newsletter" v-model="form.newsletter" type="checkbox"
                  class="mt-1 w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500">
                <label for="newsletter" class="ml-3 text-sm text-gray-600">
                  Send me product updates and safety tips via email
                </label>
              </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" :disabled="isSubmitting"
              class="w-full py-3 px-4 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium rounded-lg transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
              <span v-if="!isSubmitting">Start Free Trial</span>
              <span v-else class="flex items-center justify-center">
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none"
                  viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                  </path>
                </svg>
                Creating Account...
              </span>
            </button>

            <!-- Security Note -->
            <div class="text-center pt-4">
              <p class="text-xs text-gray-500">
                <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
                Your data is encrypted and secure. No credit card required for trial.
              </p>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
  
  <script setup>
  //import axios from 'axios';
import { ref, computed, watch } from 'vue';
import { useRouter,} from 'vue-router';
import api from './api'
const router = useRouter();
  const form = ref({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    acceptTerms: false,
    newsletter: false
  });
  
  const errors = ref({});
  const isSubmitting = ref(false);
  const showPassword = ref(false);
  
  const benefits = ref([
    {
      title: "Real-time Monitoring",
      description: "24/7 gas level tracking with instant notifications"
    },
    {
      title: "Smart Analytics",
      description: "Detailed usage patterns and optimization insights"
    },
    {
      title: "Mobile Alerts",
      description: "Get notified anywhere with our mobile app"
    },
    {
      title: "Professional Support",
      description: "Expert help whenever you need it"
    }
  ]);
  
  const passwordRequirements = computed(() => [
    {
      text: "8+ chars",
      met: form.value.password.length >= 8
    },
    {
      text: "Uppercase",
      met: /[A-Z]/.test(form.value.password)
    },
    {
      text: "Number",
      met: /\d/.test(form.value.password)
    }
  ]);
  
  // Validation functions
  const validateEmail = (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };
  
  const validatePhone = (phone) => {
    const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
    return phoneRegex.test(phone.replace(/[\s\-\(\)]/g, ''));
  };
  
  const validatePassword = (password) => {
    return password.length >= 8 && 
           /[A-Z]/.test(password) && 
           /\d/.test(password);
  };
  
  // Watch for real-time validation
  watch(() => form.value.email, (newEmail) => {
    if (newEmail && !validateEmail(newEmail)) {
      errors.value.email = 'Please enter a valid email address';
    } else {
      delete errors.value.email;
    }
  });
  
  watch(() => form.value.password, (newPassword) => {
    if (newPassword && !validatePassword(newPassword)) {
      errors.value.password = 'Password must be at least 8 characters with uppercase and number';
    } else {
      delete errors.value.password;
    }
  });
  
  watch(() => form.value.confirmPassword, (newConfirmPassword) => {
    if (newConfirmPassword && newConfirmPassword !== form.value.password) {
      errors.value.confirmPassword = 'Passwords do not match';
    } else {
      delete errors.value.confirmPassword;
    }
  });
  
  const handleSubmit = async () => {
  // Clear previous errors
  errors.value = {};

  // Validate all fields
  if (!form.value.firstName.trim()) errors.value.firstName = 'First name is required';
  if (!form.value.lastName.trim()) errors.value.lastName = 'Last name is required';
  if (!form.value.email) {
    errors.value.email = 'Email is required';
  } else if (!validateEmail(form.value.email)) {
    errors.value.email = 'Please enter a valid email address';
  }
  if (!form.value.phone) {
    errors.value.phone = 'Phone number is required';
  } else if (!validatePhone(form.value.phone)) {
    errors.value.phone = 'Please enter a valid phone number';
  }
  if (!form.value.password) {
    errors.value.password = 'Password is required';
  } else if (!validatePassword(form.value.password)) {
    errors.value.password = 'Password must be at least 8 characters with uppercase and number';
  }
  if (form.value.password !== form.value.confirmPassword) {
    errors.value.confirmPassword = 'Passwords do not match';
  }
  if (!form.value.acceptTerms) {
    errors.value.terms = 'You must accept the terms and conditions';
  }

  // If errors exist, stop submission
  if (Object.keys(errors.value).length > 0) return;

  isSubmitting.value = true;
  
  try {
    const payload = {
      first_name: form.value.firstName,
      last_name: form.value.lastName,
      email: form.value.email,
      phone: form.value.phone,
      password: form.value.password,
      accept_terms: form.value.acceptTerms,
      newsletter: form.value.newsletter
  };

    const response = await api.post("users/register/", payload);
    
    if (response.status === 201) {
      // Reset form and redirect
      form.value = {
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        password: '',
        confirmPassword: '',
        acceptTerms: false,
        newsletter: false
      };
      
      await router.push('admin/analytics');
      return; // This prevents any further execution
    }
    
    console.warn('Unexpected status:', response.status);
    errors.value.general = 'Registration successful, but unexpected response';
    
  } 
  catch (error) {
  console.error('Registration error:', error);

  const errorData = error.response?.data;

  if (errorData?.errors) {
    for (const [field, messages] of Object.entries(errorData.errors)) {
      // Convert snake_case to camelCase
      const camelCaseField = field.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
      errors.value[camelCaseField] = Array.isArray(messages) ? messages.join(' ') : messages;
    }
  } else if (errorData?.message) {
    errors.value.general = errorData.message;
  } else {
    errors.value.general = error.message || 'Registration failed';
  }
}
 finally {
    isSubmitting.value = false;
  }
};
    </script>
    
    <style scoped>
    .signup-page {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    }
    
    /* Custom focus styles for better accessibility */
    input:focus, button:focus {
      outline: none;
    }
    
    /* Animation for password requirements */
    .password-requirements {
      transition: all 0.3s ease;
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
    </style>
    