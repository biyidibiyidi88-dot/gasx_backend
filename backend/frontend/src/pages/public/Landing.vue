<template>
    <div class="home-page">
      <!-- Hero Section -->
      <section class="relative bg-white/   text-white pt-24 pb-20 sm:pt-32 sm:pb-28">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="max-w-3xl mx-auto text-center">
            <h1 class="text-4xl sm:text-5xl md:text-6xl font-bold leading-tight mb-6">
              Smart Gas Monitoring <br>
              <span class="text-blue-400">Made Simple</span>
            </h1>
            <p class="text-lg sm:text-xl text-gray-300 mb-10 max-w-2xl mx-auto">
              Real-time gas level tracking and alerts to keep your home safe and efficient.
            </p>
            <div class="flex flex-col sm:flex-row justify-center gap-4">
              <router-link 
                to="/register" 
                class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200 text-sm sm:text-base"
              >
                Get Started - It's Free
              </router-link>
              <router-link 
                to="/features" 
                class="px-6 py-3 bg-gray-800 hover:bg-gray-700 text-white font-medium rounded-lg transition-colors duration-200 text-sm sm:text-base"
              >
                Learn More
              </router-link>
            </div>
          </div>
        </div>
        <div class="absolute inset-x-0 bottom-0 h-16 bg-gradient-to-t from-gray-900 to-transparent"></div>
      </section>
  
      <!-- Features Grid -->
      <section class="py-16 sm:py-24 bg-white/ ">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="text-center mb-16">
            <h2 class="text-3xl sm:text-4xl font-bold text-white mb-4">
              Protect What Matters Most
            </h2>
            <p class="text-lg text-blue-400 max-w-2xl mx-auto">
              Our system gives you peace of mind with these powerful features
            </p>
          </div>
          
              <!-- Main Features Grid -->
            <div class="pb-16 sm:pb-24">
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
            </div>
        </div>
      </section>
  
      <!-- Demo Section -->
      <section class="py-16 sm:py-24 bg-white/ ">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="flex flex-col lg:flex-row items-center gap-12">
            <div class="lg:w-1/2">
              <h2 class="text-3xl sm:text-4xl font-bold text-white mb-6">
                Real-time Monitoring <br>
                <span class="text-blue-600">At Your Fingertips</span>
              </h2>
              <p class="text-lg text-gray-600 mb-8">
                Our intuitive dashboard gives you complete visibility of your gas levels from anywhere, at any time.
              </p>
              <ul class="space-y-4">
                <li 
                  v-for="(item, index) in demoFeatures"
                  :key="index"
                  class="flex items-start"
                >
                  <svg class="w-5 h-5 text-green-500 mt-0.5 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span class="text-gray-700">{{ item }}</span>
                </li>
              </ul>
            </div>
            <div class="lg:w-1/2">
              <div class="bg-white p-2 rounded-xl shadow-xl border border-gray-200">
                 <img 
                  src="../../assets/images/dashboard preview.png" 
                  alt="Dashboard Preview" 
                  class="rounded-lg w-full h-auto"
                > 
              </div>
            </div>
          </div>
        </div>
      </section>
  
      <!-- CTA Section -->
      <section class="py-16 sm:py-24 bg-white/  text-white">
        <div class="container mx-auto px-4 sm:px-6">
          <div class="max-w-4xl mx-auto text-center">
            <h2 class="text-3xl sm:text-4xl font-bold mb-6">
              Ready to take control of your gas monitoring?
            </h2>
            <p class="text-lg text-gray-300 mb-10 max-w-2xl mx-auto">
              Join thousands of happy customers who trust our system for their safety.
            </p>
            <router-link 
              to="/register" 
              class="inline-block px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200 text-lg"
            >
              Start Your Free Trial
            </router-link>
          </div>
        </div>
      </section>
    </div>
  </template>
  
  <script setup>
  import { ref } from 'vue';
  
  // Icons (import these from your icon library or use inline SVGs)
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
    }
  };
  
  const features = ref([
    {
      title: "Instant Alerts",
      description: "Get immediate notifications when gas levels reach dangerous thresholds.",
      icon: icons.alert
    },
    {
      title: "Detailed Analytics",
      description: "Track usage patterns and optimize your gas consumption over time.",
      icon: icons.chart
    },
    {
      title: "Smart Integration",
      description: "Works with all major smart home systems and mobile devices.",
      icon: icons.device
    }
  ]);
  
  const demoFeatures = ref([
    "Live gas level monitoring with 99.9% accuracy",
    "Customizable alert thresholds for different scenarios",
    "Historical data tracking with interactive charts",
    "Multi-user access with different permission levels",
    "24/7 monitoring with no downtime"
  ]);
  </script>
  
  <style scoped>
  .home-page {
    scroll-behavior: smooth;
  }
  </style>