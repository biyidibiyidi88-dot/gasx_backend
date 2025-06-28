<template>
    <div class="p-6 flex flex-col items-center min-h-screen bg-gradient-to-b from-blue-50 to-gray-100">
      <h2 class="text-3xl font-bold text-gray-800 mb-6">Professional Gas Cylinder</h2>
      
      <div class="flex flex-col lg:flex-row w-full max-w-6xl gap-8">
        <!-- Gas Bottle Visualization (Left Column) -->
        <div class="relative w-full lg:w-1/2 h-[70vh]">
          <!-- Gas Bottle Container -->
          <div class="absolute inset-0 w-full h-full">
            <!-- Collar with improved 3D effect -->
            <div class="absolute top-0 w-full h-20 bg-gradient-to-r from-blue-900 to-blue-800 rounded-t-lg shadow-xl z-10 overflow-hidden">
              <!-- Safety Cap with metallic shine -->
              <div class="absolute -top-6 left-1/2 transform -translate-x-1/2 w-12 h-6 bg-gradient-to-b from-gray-800 to-gray-700 rounded-t-lg shadow-inner">
                <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"></div>
              </div>
              <!-- Collar ridges -->
              <div class="absolute bottom-0 left-0 right-0 h-4 bg-blue-950/30"></div>
            </div>
            
            <!-- Nozzle with more realistic details -->
            <div class="absolute top-4 left-1/2 transform -translate-x-1/2 w-10 h-10 bg-gradient-to-b from-gray-700 to-gray-600 rounded-full flex items-center justify-center shadow-lg z-20">
              <div class="w-4 h-4 bg-gray-900 rounded-full shadow-inner">
                <div class="absolute inset-0 rounded-full bg-gradient-to-br from-gray-600 to-gray-900 opacity-70"></div>
              </div>
              <div class="absolute top-1 left-1 w-2 h-2 rounded-full bg-white/30"></div>
            </div>
            
            <!-- Gas Bottle Body with enhanced 3D effect -->
            <div class="absolute top-20 bottom-10 w-full bg-gradient-to-r from-blue-800 to-blue-900 rounded-lg overflow-hidden shadow-2xl z-0">
              <!-- Metallic highlights with animation -->
              <div class="absolute top-0 left-0 w-full h-full opacity-30 bg-gradient-to-br from-white to-transparent animate-shine"></div>
              
              <!-- Horizontal bands for 3D effect -->
              <div class="absolute top-8 left-6 right-6 h-1 bg-blue-700/70 rounded-full"></div>
              <div class="absolute top-1/3 left-6 right-6 h-1 bg-blue-700/70 rounded-full"></div>
              <div class="absolute bottom-1/3 left-6 right-6 h-1 bg-blue-700/70 rounded-full"></div>
              <div class="absolute bottom-8 left-6 right-6 h-1 bg-blue-700/70 rounded-full"></div>
              
              <!-- Gas Level Container with improved liquid effects -->
              <div class="absolute inset-x-0 bottom-0 w-full overflow-hidden transition-all duration-1000 ease-out" 
                   :style="{ height: `${tank.level}%` }">
                <div :class="`w-full h-full ${getStatusColor()} relative overflow-hidden`">
                  <!-- Bubbles Animation with different sizes and speeds -->
                  <div
                    v-for="bubble in bubbles"
                    :key="bubble.id"
                    class="absolute rounded-full bg-white/70"
                    :style="{
                      left: bubble.left,
                      width: bubble.size,
                      height: bubble.size,
                      filter: 'blur(1px)',
                      animation: `rise ${bubble.animationDuration} ${bubble.delay} ease-in infinite`
                    }"
                  ></div>
                  
                  <!-- Liquid surface with more dynamic wobble -->
                  <div class="absolute top-0 inset-x-0 h-8 bg-white/40 wobble-animation">
                    <div class="absolute bottom-0 inset-x-0 h-4 bg-gradient-to-b from-white/60 to-transparent"></div>
                  </div>
                  
                  <!-- Liquid shimmer effect -->
                  <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-shimmer"></div>
                </div>
              </div>
              
              <!-- Enhanced Labels with glow effect -->
              <div class="absolute top-1/3 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-center z-20">
                <div class="text-3xl font-bold text-white drop-shadow-lg glow">CALOR</div>
                <div class="text-lg font-medium text-blue-200 mt-1 drop-shadow-md">6kg Propane</div>
              </div>
              
              <!-- Improved Gas Level Indicator Window -->
              <div class="absolute right-6 inset-y-1/4 w-8 h-60 bg-white/20 backdrop-blur-sm border-2 border-blue-300/50 rounded-lg overflow-hidden shadow-inner">
                <!-- Graduation marks inside the window -->
                <div class="absolute left-0 right-0 h-px bg-blue-300/80" style="top: 0%"></div>
                <div class="absolute left-0 right-0 h-px bg-blue-300/80" style="top: 25%"></div>
                <div class="absolute left-0 right-0 h-px bg-blue-300/80" style="top: 50%"></div>
                <div class="absolute left-0 right-0 h-px bg-blue-300/80" style="top: 75%"></div>
                <div class="absolute left-0 right-0 h-px bg-blue-300/80" style="top: 100%"></div>
                
                <div 
                  :class="`absolute bottom-0 w-full transition-all duration-1000 ease-out ${getStatusColor()}`"
                  :style="{ height: `${tank.level}%` }"
                >
                  <div class="absolute top-0 inset-x-0 h-4 bg-gradient-to-b from-white/50 to-transparent"></div>
                </div>
              </div>
              
              <!-- Enhanced Measurement markings with numbers -->
              <div class="absolute right-20 inset-y-1/4 flex flex-col justify-between py-4 h-60">
                <div class="flex items-center h-0">
                  <div class="w-4 h-0.5 bg-blue-300/90"></div>
                  <span class="text-xs font-bold text-blue-100 ml-1">100%</span>
                </div>
                <div class="flex items-center h-0">
                  <div class="w-4 h-0.5 bg-blue-300/90"></div>
                  <span class="text-xs font-bold text-blue-100 ml-1">75%</span>
                </div>
                <div class="flex items-center h-0">
                  <div class="w-4 h-0.5 bg-blue-300/90"></div>
                  <span class="text-xs font-bold text-blue-100 ml-1">50%</span>
                </div>
                <div class="flex items-center h-0">
                  <div class="w-4 h-0.5 bg-blue-300/90"></div>
                  <span class="text-xs font-bold text-blue-100 ml-1">25%</span>
                </div>
                <div class="flex items-center h-0">
                  <div class="w-4 h-0.5 bg-blue-300/90"></div>
                  <span class="text-xs font-bold text-blue-100 ml-1">0%</span>
                </div>
              </div>
              
              <!-- Reflection overlay with animation -->
              <div class="absolute inset-0 bg-gradient-to-br from-transparent via-white/10 to-transparent animate-shine-slow"></div>
            </div>
            
            <!-- Base with improved 3D effect -->
            <div class="absolute bottom-0 w-full h-10 bg-gradient-to-r from-blue-900 to-blue-800 rounded-b-lg shadow-xl z-10 overflow-hidden">
              <div class="absolute inset-0 bg-gradient-to-b from-blue-950/40 to-transparent"></div>
              <div class="absolute top-0 left-0 right-0 h-2 bg-blue-950/40"></div>
            </div>
          </div>
        </div>
        
        <!-- Bottle Information Panel (Right Column) -->
        <div class="w-full lg:w-1/2">
          <div class="bg-white p-6 rounded-xl shadow-xl h-full flex flex-col">
            <!-- Bottle Information Header -->
            <div class="flex justify-between items-center mb-6 pb-4 border-b border-gray-200">
              <h3 class="text-2xl font-bold text-gray-800">Cylinder Details</h3>
              <span class="px-3 py-1 text-xs font-bold rounded-full" 
                    :class="statusBadgeClass">
                {{ tank.status }}
                <span class="ml-1" v-if="tank.status === 'Critical'">⚠️</span>
              </span>
            </div>
            
            <!-- Bottle Specifications -->
            <div class="grid grid-cols-2 gap-4 mb-6">
              <div class="bg-gray-50 p-3 rounded-lg">
                <p class="text-xs text-gray-500 uppercase font-medium">Gas Type</p>
                <p class="text-lg font-bold">Propane</p>
              </div>
              <div class="bg-gray-50 p-3 rounded-lg">
                <p class="text-xs text-gray-500 uppercase font-medium">Capacity</p>
                <p class="text-lg font-bold">6 kg</p>
              </div>
              <div class="bg-gray-50 p-3 rounded-lg">
                <p class="text-xs text-gray-500 uppercase font-medium">Serial No.</p>
                <p class="text-lg font-bold">CAL-{{ Math.floor(Math.random() * 9000) + 1000 }}</p>
              </div>
              <div class="bg-gray-50 p-3 rounded-lg">
                <p class="text-xs text-gray-500 uppercase font-medium">Manufacturer</p>
                <p class="text-lg font-bold">Calor Gas Ltd</p>
              </div>
            </div>
            
            <!-- Current Status Card -->
            <div class="mb-6 p-4 rounded-lg" :class="statusCardClass">
              <div class="flex items-center gap-3">
                <div class="p-2 rounded-full bg-white/20">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                          :d="statusIconPath" />
                  </svg>
                </div>
                <div>
                  <h4 class="font-bold" :class="statusTextClass">{{ statusMessage }}</h4>
                  <p class="text-sm mt-1" :class="statusSubtextClass">
                    {{ statusSubmessage }}
                  </p>
                </div>
              </div>
            </div>
            
            <!-- Usage Statistics -->
            <div class="mb-6">
              <h4 class="text-sm font-medium text-gray-500 mb-3">Usage Statistics</h4>
              <div class="space-y-3">
                <div class="flex justify-between items-center">
                  <span class="text-gray-600">Current Level</span>
                  <div class="flex items-center gap-2">
                    <span class="font-bold" :class="levelTextClass">{{ tank.level }}%</span>
                    <div class="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                      <div class="h-full rounded-full transition-all duration-500" 
                           :class="levelColorClass" 
                           :style="{ width: `${tank.level}%` }"></div>
                    </div>
                  </div>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-gray-600">Estimated Remaining</span>
                  <span class="font-medium">{{ estimatedRemaining }} hours</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-gray-600">Daily Consumption</span>
                  <span class="font-medium">1.2 kg/day</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-gray-600">Last Refill</span>
                  <span class="font-medium">3 days ago</span>
                </div>
              </div>
            </div>
            
            <!-- Safety Information -->
            <div class="mt-auto pt-4 border-t border-gray-200">
              <h4 class="text-sm font-medium text-gray-500 mb-2">Safety Information</h4>
              <ul class="text-sm text-gray-600 space-y-1.5">
                <li class="flex items-start gap-2">
                  <svg class="w-4 h-4 mt-0.5 flex-shrink-0 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <span>Store upright in a well-ventilated area</span>
                </li>
                <li class="flex items-start gap-2">
                  <svg class="w-4 h-4 mt-0.5 flex-shrink-0 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <span>Keep away from heat sources and flames</span>
                </li>
                <li class="flex items-start gap-2">
                  <svg class="w-4 h-4 mt-0.5 flex-shrink-0 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                  <span>Check for leaks regularly with soapy water</span>
                </li>
              </ul>
            </div>
            
            <!-- Action Buttons -->
            <div class="mt-6 flex gap-3">
              <button 
                @click="refillTank"
                class="flex-1 px-4 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-lg hover:from-blue-700 hover:to-blue-800 transition-all duration-300 shadow-md hover:shadow-lg active:scale-95 flex items-center justify-center gap-2"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
                </svg>
                Order Refill
              </button>
              <button 
                class="px-4 py-3 bg-white border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all duration-300 shadow-md hover:shadow-lg active:scale-95 flex items-center justify-center gap-2"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Details
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// Tank state
const tank = ref({ 
  level: 75, 
  status: 'Normal' 
});

// Bubbles animation
const bubbles = ref([]);
let bubbleInterval = null;
let animationFrameId = null;

// Generate bubbles with safety checks
const generateBubbles = () => {
  if (!tank.value || tank.value.level <= 0) return;
  
  const newBubbles = [];
  const bubbleCount = Math.floor(tank.value.level / 5) + 5;
  
  for (let i = 0; i < bubbleCount; i++) {
    newBubbles.push({
      id: `bubble-${Date.now()}-${i}`,
      left: `${Math.random() * 80 + 10}%`,
      size: `${Math.random() * 12 + 4}px`,
      animationDuration: `${Math.random() * 5 + 3}s`,
      delay: `${Math.random() * 4}s`,
      opacity: Math.random() * 0.6 + 0.3
    });
  }
  
  bubbles.value = newBubbles;
};

// Cleanup all animations
const cleanupAnimations = () => {
  if (bubbleInterval) {
    clearInterval(bubbleInterval);
    bubbleInterval = null;
  }
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
    animationFrameId = null;
  }
};

// Update tank status
const updateTankStatus = () => {
  if (!tank.value) return;
  
  let newStatus = 'Normal';
  if (tank.value.level <= 15) {
    newStatus = 'Critical';
  } else if (tank.value.level <= 40) {
    newStatus = 'Low';
  }
  
  if (tank.value.status !== newStatus) {
    tank.value.status = newStatus;
    if (newStatus === 'Critical') {
      generateBubbleBurst();
    }
  }
};

// Bubble burst effect
const generateBubbleBurst = () => {
  const burstBubbles = [];
  for (let i = 0; i < 15; i++) {
    burstBubbles.push({
      id: `burst-${Date.now()}-${i}`,
      left: `${Math.random() * 60 + 20}%`,
      size: `${Math.random() * 6 + 2}px`,
      animationDuration: `${Math.random() * 1 + 0.5}s`,
      delay: '0s',
      opacity: Math.random() * 0.8 + 0.2
    });
  }
  bubbles.value = [...bubbles.value, ...burstBubbles];
};

// Refill tank animation
const refillTank = () => {
  const startLevel = tank.value.level;
  const duration = 1500;
  const startTime = performance.now();
  
  const animateRefill = (timestamp) => {
    const progress = Math.min(1, (timestamp - startTime) / duration);
    tank.value.level = startLevel + (100 - startLevel) * progress;
    
    if (progress < 0.5) {
      generateBubbles();
    }
    
    if (progress < 1) {
      animationFrameId = requestAnimationFrame(animateRefill);
    } else {
      tank.value.status = 'Normal';
    }
  };
  
  animationFrameId = requestAnimationFrame(animateRefill);
};

// Status color helpers
const getStatusColor = () => {
  switch (tank.value.status) {
    case 'Normal': return 'bg-gradient-to-b from-green-400/90 to-green-600/90';
    case 'Low': return 'bg-gradient-to-b from-yellow-400/90 to-yellow-600/90';
    case 'Critical': return 'bg-gradient-to-b from-red-400/90 to-red-600/90';
    default: return 'bg-gradient-to-b from-green-400/90 to-green-600/90';
  }
};

// Computed properties
const statusBadgeClass = computed(() => ({
  'Normal': 'bg-green-100 text-green-800',
  'Low': 'bg-yellow-100 text-yellow-800',
  'Critical': 'bg-red-100 text-red-800'
}[tank.value.status]));

const statusCardClass = computed(() => ({
  'Normal': 'bg-green-50 border border-green-200',
  'Low': 'bg-yellow-50 border border-yellow-200',
  'Critical': 'bg-red-50 border border-red-200'
}[tank.value.status]));

const statusMessage = computed(() => ({
  'Normal': 'Normal Operation',
  'Low': 'Low Gas Level',
  'Critical': 'Critical Level - Refill Needed!'
}[tank.value.status]));

const estimatedRemaining = computed(() => Math.round((tank.value.level / 100) * 48));

// Watch for level changes
watch(() => tank.value.level, updateTankStatus);

// Component lifecycle
onMounted(() => {
  updateTankStatus();
  generateBubbles();
  bubbleInterval = setInterval(generateBubbles, 2000);
});

onUnmounted(() => {
  cleanupAnimations();
});
</script>
  
  <style scoped>
  /* Base Styles */
  .glow {
    animation: glow-pulse 2s ease-in-out infinite alternate;
  }
  
  .wobble-animation {
    animation: wobble 4s ease-in-out infinite;
  }
  
  .animate-shine {
    animation: shine 8s linear infinite;
  }
  
  .animate-shine-slow {
    animation: shine-slow 6s ease-in-out infinite;
  }
  
  .animate-shimmer {
    animation: shimmer 3s linear infinite;
  }
  
  /* Keyframe Animations */
  @keyframes rise {
    0% {
      transform: translateY(0) scale(0.8);
      opacity: 0;
    }
    10% {
      opacity: v-bind('bubble.opacity');
    }
    90% {
      opacity: v-bind('bubble.opacity');
    }
    100% {
      transform: translateY(-100vh) scale(1.2);
      opacity: 0;
    }
  }
  
  @keyframes wobble {
    0%, 100% {
      border-radius: 60% 40% 40% 60% / 60% 40% 60% 40%;
      transform: translateX(0px);
    }
    25% {
      border-radius: 50% 50% 40% 60% / 40% 50% 50% 60%;
      transform: translateX(-3px);
    }
    50% {
      border-radius: 40% 60% 50% 50% / 50% 40% 60% 50%;
      transform: translateX(3px);
    }
    75% {
      border-radius: 50% 50% 60% 40% / 60% 50% 50% 40%;
      transform: translateX(-2px);
    }
  }
  
  @keyframes shine {
    0% {
      transform: translateX(-100%) skewX(-15deg);
    }
    100% {
      transform: translateX(100%) skewX(-15deg);
    }
  }
  
  @keyframes shine-slow {
    0%, 100% {
      opacity: 0.1;
    }
    50% {
      opacity: 0.3;
    }
  }
  
  @keyframes shimmer {
    0% {
      transform: translateX(-100%);
    }
    100% {
      transform: translateX(100%);
    }
  }
  
  @keyframes glow-pulse {
    0%, 100% {
      text-shadow: 0 0 5px rgba(255, 255, 255, 0.3);
    }
    50% {
      text-shadow: 0 0 15px rgba(255, 255, 255, 0.7);
    }
  }
  
  @keyframes bubble-burst {
    0% {
      transform: scale(0.5);
      opacity: 0;
    }
    50% {
      transform: scale(1.2);
      opacity: 0.8;
    }
    100% {
      transform: scale(1.5);
      opacity: 0;
    }
  }
  
  /* Transition Effects */
  .transition-all {
    transition-property: all;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .duration-300 {
    transition-duration: 300ms;
  }
  
  .duration-700 {
    transition-duration: 700ms;
  }
  
  .duration-1000 {
    transition-duration: 1000ms;
  }
  
  .ease-out {
    transition-timing-function: ease-out;
  }
  
  /* Custom Scrollbar */
  ::-webkit-scrollbar {
    width: 6px;
  }
  
  ::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.05);
  }
  
  ::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.1);
    border-radius: 3px;
  }
  
  ::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 0, 0, 0.2);
  }
  
  /* Bubble Styles */
  .bubble {
    position: absolute;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.7);
    filter: blur(1px);
    will-change: transform;
  }
  
  /* Liquid Surface Effect */
  .liquid-surface {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 12px;
    background: linear-gradient(
      to bottom,
      rgba(255, 255, 255, 0.4),
      rgba(255, 255, 255, 0.2)
    );
    border-radius: 50% 50% 0 0 / 20% 20% 0 0;
  }
  
  /* Status Indicator Pulses */
  .status-pulse {
    animation: status-pulse 2s infinite;
  }
  
  @keyframes status-pulse {
    0%, 100% {
      box-shadow: 0 0 0 0 rgba(74, 222, 128, 0.7); /* Green */
    }
    50% {
      box-shadow: 0 0 0 10px rgba(74, 222, 128, 0);
    }
  }
  
  .status-pulse-warning {
    animation: status-pulse-warning 2s infinite;
  }
  
  @keyframes status-pulse-warning {
    0%, 100% {
      box-shadow: 0 0 0 0 rgba(234, 179, 8, 0.7); /* Yellow */
    }
    50% {
      box-shadow: 0 0 0 10px rgba(234, 179, 8, 0);
    }
  }
  
  .status-pulse-critical {
    animation: status-pulse-critical 1s infinite;
  }
  
  @keyframes status-pulse-critical {
    0%, 100% {
      box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); /* Red */
    }
    50% {
      box-shadow: 0 0 0 10px rgba(239, 68, 68, 0);
    }
  }
  
  /* Graduation Mark Enhancements */
  .graduation-mark {
    position: absolute;
    left: 0;
    right: 0;
    height: 1px;
    background: linear-gradient(
      to right,
      transparent,
      rgba(147, 197, 253, 0.8),
      transparent
    );
  }
  
  .graduation-label {
    position: absolute;
    right: 0;
    transform: translateX(120%);
    font-size: 0.65rem;
    font-weight: 600;
    color: rgba(191, 219, 254, 0.9);
    text-shadow: 0 1px 1px rgba(0, 0, 0, 0.3);
  }
  
  /* Responsive Adjustments */
  @media (max-width: 1024px) {
    .flex-col-lg {
      flex-direction: column;
    }
    
    .w-full-lg {
      width: 100%;
    }
    
    .h-auto-lg {
      height: auto;
    }
    
    .relative {
      height: 60vh;
    }
  }
  
  @media (max-width: 640px) {
    .liquid-surface {
      height: 8px;
    }
    
    .graduation-label {
      font-size: 0.55rem;
    }
    
    .relative {
      height: 50vh;
    }
  }
  </style>