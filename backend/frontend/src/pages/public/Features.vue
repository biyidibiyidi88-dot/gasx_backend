<template>
    <div class="features-page min-h-[calc(100vh-7rem)]">
      <!-- Hero Section -->
      <section class="relative py-16 sm:py-24">
        <div class="container mx-auto px-4 sm:px-6 text-center">
          <h1 class="text-3xl sm:text-5xl font-bold text-gray-300 mb-4">Powerful Features</h1>
          <p class="text-lg text-gray-400 max-w-3xl mx-auto">
            Discover how our gas monitoring system keeps your home safe and efficient
          </p>
        </div>
      </section>
  
      <!-- Main Features Grid -->
      <section class="pb-16 sm:pb-24">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div 
              v-for="(feature, index) in features"
              :key="index"
              class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl p-6 hover:border-blue-500/50 transition-all duration-300"
            >
              <div class="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center mb-4">
                <component 
                  :is="feature.icon" 
                  class="w-6 h-6 text-blue-400"
                />
              </div>
              <h3 class="text-xl font-semibold text-gray-300 mb-2">
                {{ feature.title }}
              </h3>
              <p class="text-gray-400">
                {{ feature.description }}
              </p>
            </div>
          </div>
        </div>
      </section>
  
      <!-- Feature Details -->
      <section class="py-16 sm:py-24 bg-gradient-to-b from-transparent to-gray-900/50">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="flex flex-col lg:flex-row items-center gap-12 mb-16">
            <div class="lg:w-1/2">
              <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl p-1 inline-block mb-6">
                <span class="text-xs font-medium text-blue-400 px-3 py-1">REALTIME MONITORING</span>
              </div>
              <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-6">
                Instant Alerts & Notifications
              </h2>
              <p class="text-gray-400 mb-6">
                Get immediate warnings when gas levels approach dangerous thresholds, with multiple notification channels including:
              </p>
              <ul class="space-y-3">
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">Push notifications to your mobile device</span>
                </li>
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">Email alerts with detailed reports</span>
                </li>
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">SMS text messages for critical alerts</span>
                </li>
              </ul>
            </div>
            <div class="lg:w-1/2">
              <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl overflow-hidden">
                <img 
                  src="../../assets/images/notification.png" 
                  alt="Alert notifications preview" 
                  class="w-full h-auto"
                >
              </div>
            </div>
          </div>
  
          <div class="flex flex-col lg:flex-row-reverse items-center gap-12">
            <div class="lg:w-1/2">
              <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl p-1 inline-block mb-6">
                <span class="text-xs font-medium text-blue-400 px-3 py-1">DATA ANALYSIS</span>
              </div>
              <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-6">
                Historical Data & Trends
              </h2>
              <p class="text-gray-400 mb-6">
                Our system tracks and analyzes your gas usage patterns to help you:
              </p>
              <ul class="space-y-3">
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">Identify unusual consumption patterns</span>
                </li>
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">Predict when you'll need refills</span>
                </li>
                <li class="flex items-start">
                  <svg class="w-5 h-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-300">Optimize your gas usage efficiency</span>
                </li>
              </ul>
            </div>
            <div class="lg:w-1/2">
              <div class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl overflow-hidden">
                <img 
                  src="../../assets/images/dashboard preview.png" 
                  alt="Analytics dashboard preview" 
                  class="w-full h-auto"
                >
              </div>
            </div>
          </div>
        </div>
      </section>
  
      <!-- CTA Section -->
      <section class="py-16 sm:py-24">
        <div class="container mx-auto px-4 sm:px-6 text-center">
          <div class="max-w-3xl mx-auto bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl py-12 px-6 sm:px-8">
            <h2 class="text-2xl sm:text-3xl font-bold text-gray-300 mb-6">Ready to experience smart gas monitoring?</h2>
            <p class="text-gray-400 mb-8 max-w-2xl mx-auto">
              Join thousands of satisfied customers who trust our system for their safety.
            </p>
            <div class="flex flex-col sm:flex-row justify-center gap-4">
              <router-link 
                to="/register" 
                class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200"
              >
                Get Started - It's Free
              </router-link>
              <router-link 
                to="/contact" 
                class="px-6 py-3 bg-white/10 hover:bg-white/20 text-gray-300 font-medium rounded-lg transition-colors duration-200 border border-gray-700/30"
              >
                Contact Sales
              </router-link>
            </div>
          </div>
        </div>
      </section>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  // Icons - import from your icon library or use inline SVGs
  const icons = {
    alert: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>`
    },
    chart: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>`
    },
    device: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
      </svg>`
    },
    cloud: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
      </svg>`
    },
    shield: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
      </svg>`
    },
    integration: {
      template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
      </svg>`
    }
  };
  
  const features = ref([
    {
      title: "Real-time Monitoring",
      description: "24/7 tracking of gas levels with instant updates every 30 seconds",
      icon: icons.device
    },
    {
      title: "Smart Alerts",
      description: "Customizable notifications when levels are low or unsafe",
      icon: icons.alert
    },
    {
      title: "Usage Analytics",
      description: "Detailed reports and consumption patterns analysis",
      icon: icons.chart
    },
    {
      title: "Cloud Backup",
      description: "Secure storage of all your historical data",
      icon: icons.cloud
    },
    {
      title: "Safety Features",
      description: "Automatic emergency protocols when danger detected",
      icon: icons.shield
    },
    {
      title: "Smart Home Integration",
      description: "Works with Alexa, Google Home and other platforms",
      icon: icons.integration
    }
  ]);
  </script>
  
  <style scoped>
  /* .features-page {
    background: radial-gradient(ellipse at top, #1e293b80, transparent),
                radial-gradient(ellipse at bottom, #0f172a80, #0f172a);
  } */
  
  /* Smooth transitions for hover effects */
  /* .bg-white\\/5 {
    transition: all 0.3s ease;
  } */
  </style>