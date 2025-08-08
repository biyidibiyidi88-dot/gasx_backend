<template>
  <div class="about-page min-h-[calc(100vh-7rem)]">
    <!-- Hero Section -->
    <section class="relative py-16 sm:py-24 bg-gradient-to-b">
      <div class="container mx-auto px-4 sm:px-6 text-center">
        <h1 class="text-3xl sm:text-5xl font-bold text-gray-300 mb-4">About GasMonitor</h1>
        <p class="text-xl text-gray-400 max-w-3xl mx-auto">
          Innovative solutions for smarter gas monitoring and home safety
        </p>
      </div>
    </section>

    <!-- Our Story -->
    <section class="py-16 sm:py-24">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="flex flex-col lg:flex-row items-center gap-12">
          <div class="lg:w-1/2">
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-300 mb-6">Our Story</h2>
            <div class="prose text-gray-400 space-y-4">
              <p>
                Founded in 2023, GasMonitor began with a simple mission: to make home gas monitoring 
                accessible, reliable, and intelligent. After experiencing a gas leak incident firsthand, 
                our founder set out to create a better solution.
              </p>
              <p>
                What started as a small startup has grown into a trusted platform serving thousands of 
                homes across the country. We combine cutting-edge sensor technology with intuitive 
                software to give homeowners peace of mind.
              </p>
            </div>
          </div>
          <div class="lg:w-1/2">
            <img 
              src="https://images.unsplash.com/photo-1529156069898-49953e39b3ac?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1632&q=80" 
              alt="Community service" 
              class="rounded-lg shadow-xl w-full h-auto border border-gray-700/30"
            >
          </div>
        </div>
      </div>
    </section>

    <!-- Mission and Values -->
    <section class="py-16 sm:py-24 bg-gradient-to-b from-transparent to-gray-900/50">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="text-center mb-16">
          <h2 class="text-3xl sm:text-4xl font-bold text-gray-300">Our Mission & Values</h2>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div 
            v-for="(value, index) in values"
            :key="index"
            class="bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl p-6 hover:border-blue-500/50 transition-all duration-300"
          >
            <div class="text-blue-400 mb-4">
              <component 
                :is="value.icon" 
                class="w-8 h-8"
              />
            </div>
            <h3 class="text-xl font-semibold text-gray-300 mb-2">
              {{ value.title }}
            </h3>
            <p class="text-gray-400">
              {{ value.description }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Team Section -->
    <section class="py-16 sm:py-24">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="text-center mb-16">
          <h2 class="text-3xl sm:text-4xl font-bold text-gray-300">Meet Our Team</h2>
          <p class="text-lg text-gray-400 mt-4 max-w-2xl mx-auto">
            The passionate people behind GasMonitor's success
          </p>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
          <div 
            v-for="(member, index) in team"
            :key="index"
            class="text-center bg-white/5 backdrop-blur-sm border border-gray-700/30 rounded-xl p-6 hover:border-blue-500/50 transition-all duration-300"
          >
            <div class="w-32 h-32 mx-auto mb-4 rounded-full overflow-hidden border-4 border-gray-700/30 shadow-lg">
              <img 
                :src="member.image" 
                :alt="member.name"
                class="w-full h-full object-cover"
              >
            </div>
            <h3 class="text-xl font-semibold text-gray-300">{{ member.name }}</h3>
            <p class="text-blue-400 mb-2">{{ member.position }}</p>
            <p class="text-gray-400 text-sm">{{ member.bio }}</p>
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
  shield: {
    template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
    </svg>`
  },
  lightbulb: {
    template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
    </svg>`
  },
  users: {
    template: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>`
  }
};

const values = ref([
  {
    title: "Safety First",
    description: "We prioritize your family's safety above all else in our product design.",
    icon: icons.shield
  },
  {
    title: "Innovation",
    description: "Continually pushing boundaries to deliver smarter monitoring solutions.",
    icon: icons.lightbulb
  },
  {
    title: "Community",
    description: "Building products that connect and protect households everywhere.",
    icon: icons.users
  }
]);

const team = ref([
  {
    name: "Alex Johnson",
    position: "Founder & CEO",
    bio: "10+ years in IoT and home automation",
    image: "https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80"
  },
  {
    name: "Maria Garcia",
    position: "Lead Engineer",
    bio: "Specialist in sensor technology",
    image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=776&q=80"
  },
  {
    name: "Sam Wilson",
    position: "Product Designer",
    bio: "User experience expert",
    image: "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1740&q=80"
  },
  {
    name: "Taylor Chen",
    position: "Customer Success",
    bio: "Dedicated to your satisfaction",
    image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=774&q=80"
  }
]);
</script>

<style scoped>


.prose {
  line-height: 1.75;
}

/* Smooth transitions for glass cards */

</style>