<template>
    <div class="pricing-page min-h-[calc(100vh-7rem)]">
      <!-- Hero Section -->
      <section class="relative py-16 sm:py-24 ">
        <div class="container mx-auto px-4 sm:px-6 text-center">
          <h1 class="text-3xl sm:text-5xl font-bold text-gray-300 mb-4">Simple, Transparent Pricing</h1>
          <p class="text-xl text-gray-400 max-w-3xl mx-auto">
            Choose the perfect plan for your home or business
          </p>
        </div>
      </section>
  
      <!-- Pricing Toggle -->
      <div class="py-8 backdrop-blur-sm">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="flex justify-center">
            <div class="inline-flex rounded-md shadow-sm bg-white/5 border border-gray-700/30">
              <button
                @click="billingCycle = 'monthly'"
                :class="{
                  'bg-blue-600/80 text-white': billingCycle === 'monthly',
                  'bg-transparent text-gray-300 hover:bg-white/10': billingCycle !== 'monthly'
                }"
                class="px-6 py-3 text-sm font-medium rounded-l-md focus:z-10 focus:outline-none focus:ring-1 focus:ring-blue-500 transition-colors duration-200"
              >
                Monthly Billing
              </button>
              <button
                @click="billingCycle = 'annually'"
                :class="{
                  'bg-blue-600/80 text-white': billingCycle === 'annually',
                  'bg-transparent text-gray-300 hover:bg-white/10': billingCycle !== 'annually'
                }"
                class="px-6 py-3 text-sm font-medium rounded-r-md focus:z-10 focus:outline-none focus:ring-1 focus:ring-blue-500 transition-colors duration-200"
              >
                Annual Billing (Save 20%)
              </button>
            </div>
          </div>
        </div>
      </div>
  
      <!-- Pricing Plans -->
      <section class="py-16 sm:py-24">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 max-w-5xl mx-auto">
            <!-- Basic Plan -->
            <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl shadow-sm overflow-hidden hover:border-blue-500/50 transition-all duration-300">
              <div class="px-6 py-8">
                <h2 class="text-lg font-medium text-gray-300">Basic</h2>
                <p class="mt-4 text-gray-400">For small homes with basic monitoring needs</p>
                <div class="mt-6">
                  <p class="text-4xl font-bold text-gray-300">
                    <span v-if="billingCycle === 'monthly'">$9.99</span>
                    <span v-else>$7.99</span>
                    <span class="text-base font-medium text-gray-400">/month</span>
                  </p>
                  <p v-if="billingCycle === 'annually'" class="mt-1 text-sm text-gray-400">
                    Billed annually at $95.88
                  </p>
                </div>
                <router-link
                  to="/register"
                  class="mt-8 block w-full py-3 px-6 border border-transparent rounded-md text-center font-medium text-white bg-blue-600/80 hover:bg-blue-700/90 transition-colors duration-200"
                >
                  Get Started
                </router-link>
              </div>
              <div class="border-t border-gray-700/30 px-6 pt-6 pb-8 bg-white/5">
                <h3 class="text-sm font-medium text-gray-300">Features</h3>
                <ul class="mt-6 space-y-4">
                  <li v-for="feature in basicFeatures" :key="feature" class="flex">
                    <svg class="h-5 w-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    <span class="ml-3 text-gray-400">{{ feature }}</span>
                  </li>
                </ul>
              </div>
            </div>
  
            <!-- Pro Plan (Featured) -->
            <div class="bg-white/5 backdrop-blur-sm border-2 border-blue-500/70 rounded-xl shadow-lg overflow-hidden hover:border-blue-400 transition-all duration-300">
              <div class="px-6 py-8">
                <div class="flex justify-between">
                  <h2 class="text-lg font-medium text-gray-300">Professional</h2>
                  <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-500/20 text-blue-400">
                    Most Popular
                  </span>
                </div>
                <p class="mt-4 text-gray-400">For complete home monitoring and analytics</p>
                <div class="mt-6">
                  <p class="text-4xl font-bold text-gray-300">
                    <span v-if="billingCycle === 'monthly'">$19.99</span>
                    <span v-else>$15.99</span>
                    <span class="text-base font-medium text-gray-400">/month</span>
                  </p>
                  <p v-if="billingCycle === 'annually'" class="mt-1 text-sm text-gray-400">
                    Billed annually at $191.88
                  </p>
                </div>
                <router-link
                  to="/register"
                  class="mt-8 block w-full py-3 px-6 border border-transparent rounded-md text-center font-medium text-white bg-blue-600/80 hover:bg-blue-700/90 transition-colors duration-200"
                >
                  Get Started
                </router-link>
              </div>
              <div class="border-t border-gray-700/30 px-6 pt-6 pb-8 bg-white/5">
                <h3 class="text-sm font-medium text-gray-300">Everything in Basic, plus:</h3>
                <ul class="mt-6 space-y-4">
                  <li v-for="feature in proFeatures" :key="feature" class="flex">
                    <svg class="h-5 w-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    <span class="ml-3 text-gray-400">{{ feature }}</span>
                  </li>
                </ul>
              </div>
            </div>
  
            <!-- Enterprise Plan -->
            <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl shadow-sm overflow-hidden hover:border-blue-500/50 transition-all duration-300">
              <div class="px-6 py-8">
                <h2 class="text-lg font-medium text-gray-300">Enterprise</h2>
                <p class="mt-4 text-gray-400">For businesses with multiple locations</p>
                <div class="mt-6">
                  <p class="text-4xl font-bold text-gray-300">
                    <span v-if="billingCycle === 'monthly'">$49.99</span>
                    <span v-else>$39.99</span>
                    <span class="text-base font-medium text-gray-400">/month</span>
                  </p>
                  <p v-if="billingCycle === 'annually'" class="mt-1 text-sm text-gray-400">
                    Billed annually at $479.88
                  </p>
                </div>
                <router-link
                  to="/contact"
                  class="mt-8 block w-full py-3 px-6 border border-transparent rounded-md text-center font-medium text-white bg-blue-600/80 hover:bg-blue-700/90 transition-colors duration-200"
                >
                  Contact Sales
                </router-link>
              </div>
              <div class="border-t border-gray-700/30 px-6 pt-6 pb-8 bg-white/5">
                <h3 class="text-sm font-medium text-gray-300">Everything in Professional, plus:</h3>
                <ul class="mt-6 space-y-4">
                  <li v-for="feature in enterpriseFeatures" :key="feature" class="flex">
                    <svg class="h-5 w-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                    <span class="ml-3 text-gray-400">{{ feature }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </section>
  
      <!-- Comparison Table -->
      <section class="py-16 sm:py-24">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-4">
              Plan Comparison
            </h2>
            <p class="text-lg text-gray-400 max-w-2xl mx-auto">
              See how our plans stack up against each other
            </p>
          </div>
          
          <div class="overflow-x-auto bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl">
            <table class="min-w-full divide-y divide-gray-700/30">
              <thead class="bg-white/5">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Feature
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Basic
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Professional
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Enterprise
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-700/30">
                <tr v-for="feature in comparisonFeatures" :key="feature.name">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-300">
                    {{ feature.name }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    <span v-if="feature.basic" class="text-green-400">✓</span>
                    <span v-else class="text-gray-500">✗</span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    <span v-if="feature.pro" class="text-green-400">✓</span>
                    <span v-else class="text-gray-500">✗</span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    <span v-if="feature.enterprise" class="text-green-400">✓</span>
                    <span v-else class="text-gray-500">✗</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>
  
      <!-- FAQ Section -->
      <section class="py-16 sm:py-24">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-4">
              Frequently Asked Questions
            </h2>
            <p class="text-lg text-gray-400 max-w-2xl mx-auto">
              Common questions about our pricing and plans
            </p>
          </div>
          
          <div class="max-w-3xl mx-auto divide-y divide-gray-700/30">
            <div v-for="(faq, index) in faqs" :key="index" class="py-6">
              <h3 class="text-lg font-medium text-gray-300">{{ faq.question }}</h3>
              <p class="mt-2 text-gray-400">{{ faq.answer }}</p>
            </div>
          </div>
        </div>
      </section>
  
      <!-- CTA Section -->
      <section class="py-16 sm:py-24 bg-gradient-to-b ">
        <div class="container mx-auto px-4 sm:px-6 text-center">
          <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-6">Ready to Get Started?</h2>
          <p class="text-xl text-gray-400 mb-10 max-w-2xl mx-auto">
            Choose the plan that's right for you and start monitoring today
          </p>
          <router-link 
            to="/register" 
            class="inline-block px-8 py-3 bg-blue-600/80 hover:bg-blue-700/90 text-white font-medium rounded-lg transition-colors duration-200 text-lg"
          >
            Sign Up Now
          </router-link>
        </div>
      </section>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  
  const billingCycle = ref('monthly');
  
  const basicFeatures = ref([
    'Real-time gas level monitoring',
    'Basic alerts via email',
    '1 device connection',
    '7-day history',
    'Community support'
  ]);
  
  const proFeatures = ref([
    'Push notifications & SMS alerts',
    'Advanced analytics dashboard',
    'Up to 5 device connections',
    '30-day history',
    'Priority email support'
  ]);
  
  const enterpriseFeatures = ref([
    'Unlimited device connections',
    'Multi-user access',
    'Custom reporting',
    '90-day history',
    '24/7 phone support',
    'Dedicated account manager'
  ]);
  
  const comparisonFeatures = ref([
    { name: 'Real-time Monitoring', basic: true, pro: true, enterprise: true },
    { name: 'Email Alerts', basic: true, pro: true, enterprise: true },
    { name: 'Push Notifications', basic: false, pro: true, enterprise: true },
    { name: 'SMS Alerts', basic: false, pro: true, enterprise: true },
    { name: 'Analytics Dashboard', basic: false, pro: true, enterprise: true },
    { name: 'Multiple Devices', basic: false, pro: true, enterprise: true },
    { name: 'Custom Reports', basic: false, pro: false, enterprise: true },
    { name: 'Phone Support', basic: false, pro: false, enterprise: true }
  ]);
  
  const faqs = ref([
    {
      question: 'Can I change plans later?',
      answer: 'Yes, you can upgrade or downgrade your plan at any time from your account settings.'
    },
    {
      question: 'Is there a free trial available?',
      answer: 'Yes, we offer a 14-day free trial for all plans with no credit card required.'
    },
    {
      question: 'What payment methods do you accept?',
      answer: 'We accept all major credit cards (Visa, Mastercard, American Express) as well as PayPal.'
    },
    {
      question: 'How do I cancel my subscription?',
      answer: 'You can cancel your subscription at any time from your account settings. No cancellation fees.'
    }
  ]);
  </script>
  
  <style scoped>
  /* .pricing-page {
    background: radial-gradient(ellipse at top, #1e293b80, transparent),
                radial-gradient(ellipse at bottom, #0f172a80, #0f172a);
  } */
  
  /* Smooth transitions for interactive elements */
  /* button, a, .bg-white\\/5 {
    transition: all 0.3s ease;
  } */
  </style>