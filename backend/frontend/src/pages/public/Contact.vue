<template>
    <div class="  min-h-[calc(100vh-7rem)]">
      <div class="container bg-transparent mx-auto px-4 sm:px-6 py-12">
        <!-- Page Header -->
        <div class="text-center mb-12 bg/">
          <h1 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-4">Contact Us</h1>
          <p class="text-lg text-gray-600 max-w-2xl mx-auto">
            Have questions or need support? We're here to help.
          </p>
        </div>
  
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <!-- Contact Form -->
          <div class="bg-white/ rounded-xl shadow-md overflow-hidden p-6 sm:p-8">
            <h2 class="text-2xl font-semibold text-gray-300 mb-6">Send Us a Message</h2>
            
            <form @submit.prevent="handleSubmit" class="space-y-6">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                  <input
                    v-model="form.name"
                    type="text"
                    id="name"
                    required
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  >
                </div>
                <div>
                  <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                  <input
                    v-model="form.email"
                    type="email"
                    id="email"
                    required
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                  >
                </div>
              </div>
              <div>
            <label for="subject" class="block text-sm font-medium text-gray-700 mb-1">Subject</label>
            <select
                v-model="form.subject"
                id="subject"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50 bg-transparent"
            >
                <option value="" disabled selected class="bg-gray-800 text-amber-50">Select a subject</option>
                <option value="support" class="bg-gray-800 text-amber-50">Technical Support</option>
                <option value="sales" class="bg-gray-800 text-amber-50">Sales Inquiry</option>
                <option value="feedback" class="bg-gray-800 text-amber-50">Product Feedback</option>
                <option value="other" class="bg-gray-800 text-amber-50">Other</option>
            </select>
            </div>
  
              <div>
                <label for="message" class="block text-sm font-medium text-gray-700 mb-1">Message</label>
                <textarea
                  v-model="form.message"
                  id="message"
                  rows="5"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors duration-200 text-amber-50"
                ></textarea>
              </div>
  
              <div>
                <button
                  type="submit"
                  :disabled="isSubmitting"
                  class="w-full sm:w-auto px-6 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <span v-if="!isSubmitting">Send Message</span>
                  <span v-else class="flex items-center justify-center">
                    <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Sending...
                  </span>
                </button>
              </div>
            </form>
          </div>
  
          <!-- Contact Information -->
          <div class="space-y-8">
            <div class=" rounded-xl shadow-md overflow-hidden p-6 sm:p-8">
              <h2 class="text-2xl font-semibold text-gray-300 mb-6">Contact Information</h2>
              
              <div class="space-y-6">
                <div class="flex items-start">
                  <div class="flex-shrink-0 bg-blue-100 p-2 rounded-lg">
                    <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                    </svg>
                  </div>
                  <div class="ml-4">
                    <h3 class="text-lg font-medium text-gray-300">Phone Support</h3>
                    <p class="mt-1 text-gray-600">Monday - Friday, 9am - 5pm EST</p>
                    <p class="mt-2 text-blue-600 font-medium">+1 (800) 123-4567</p>
                  </div>
                </div>
  
                <div class="flex items-start">
                  <div class="flex-shrink-0 bg-blue-100 p-2 rounded-lg">
                    <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                  </div>
                  <div class="ml-4">
                    <h3 class="text-lg font-medium text-gray-300">Email Us</h3>
                    <p class="mt-1 text-gray-600">We typically respond within 24 hours</p>
                    <p class="mt-2 text-blue-600 font-medium">support@gasmonitor.com</p>
                  </div>
                </div>
  
                <div class="flex items-start">
                  <div class="flex-shrink-0 bg-blue-100 p-2 rounded-lg">
                    <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  </div>
                  <div class="ml-4">
                    <h3 class="text-lg font-medium text-gray-300">Headquarters</h3>
                    <p class="mt-1 text-gray-600">123 Safety Way<br>Boston, MA 02108<br>United States</p>
                  </div>
                </div>
              </div>
            </div>
  
            <!-- FAQ Link -->
            <div class=" rounded-xl p-6 border border-blue-100">
              <h3 class="text-lg font-medium text-blue-800 mb-3">Looking for quick answers?</h3>
              <p class="text-blue-700 mb-4">Check out our frequently asked questions for instant help.</p>
              <router-link 
                to="/faq" 
                class="inline-flex items-center text-blue-600 font-medium hover:underline"
              >
                Visit FAQ Center
                <svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  
  const form = ref({
    name: '',
    email: '',
    subject: '',
    message: ''
  });
  
  const isSubmitting = ref(false);
  
  const handleSubmit = async () => {
    isSubmitting.value = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // Reset form after successful submission
      form.value = {
        name: '',
        email: '',
        subject: '',
        message: ''
      };
      
      // Show success message (you could use a toast notification here)
      alert('Thank you for your message! We will get back to you soon.');
    } catch (error) {
      console.error('Error submitting form:', error);
    } finally {
      isSubmitting.value = false;
    }
  };
  </script>
  
  <style scoped>
  
  
  /* Smooth transitions for form elements */
  input, textarea, select, button {
    transition: all 0.2s ease;
  }
  </style>