<template>
  <div class="contact-page min-h-screen pt-24 pb-16 sm:pt-48 sm:pb-40 overflow-hidden relative">
    <!-- Sophisticated 3D Background System -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-teal-500/10 blur-[150px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/10 blur-[180px] animate-pulse-slow" style="animation-delay: 1.5s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <div class="container mx-auto px-6">
      <!-- Page Header -->
            <div class="text-center mb-24">
        <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8 animate-fade-in">
          <span class="w-1.5 h-1.5 rounded-full bg-teal-400 animate-pulse"></span>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 italic">Direct Uplink</span>
        </div>

        <h1 class="text-4xl sm:text-7xl font-black text-white mb-6 tracking-tighter uppercase italic leading-none animate-title">
          Contact<br>
          <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent">Command</span>
        </h1>

        <p class="text-lg sm:text-xl text-white/40 max-w-2xl mx-auto font-medium italic tracking-tight animate-fade-in" style="animation-delay: 0.2s">
          Deploy a transmission to our architects. Zero-latency response guaranteed.
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 max-w-7xl mx-auto">
        <!-- Contact Form -->
        <div class="relative group">
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] opacity-0 group-hover:opacity-100 transition-opacity duration-1000"></div>
          <div class="relative bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 hover:border-white/10 transition-all duration-700">
            <h2 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 mb-10">Data Submission</h2>
            
            <form @submit.prevent="handleSubmit" class="space-y-8">
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 sm:gap-8">
                <div class="space-y-2">
                  <label for="name" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Identity</label>
                  <input
                    v-model="form.name"
                    type="text"
                    id="name"
                    placeholder="Subject Name"
                    required
                    class="w-full px-4 sm:px-6 py-4 sm:py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold"
                  >
                </div>
                <div class="space-y-2">
                  <label for="email" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Address</label>
                  <input
                    v-model="form.email"
                    type="email"
                    id="email"
                    placeholder="node@protocol.com"
                    required
                    class="w-full px-4 sm:px-6 py-4 sm:py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold"
                  >
                </div>
              </div>
              
              <div class="space-y-2">
                <label for="subject" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Protocol</label>
                <select
                  v-model="form.subject"
                  id="subject"
                  required
                  class="w-full px-4 sm:px-6 py-4 sm:py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white appearance-none cursor-pointer font-bold"
                >
                  <option value="" disabled selected>Select Transmission Type</option>
                  <option value="support">Technical Support</option>
                  <option value="sales">Commercial Uplink</option>
                  <option value="feedback">Network Feedback</option>
                  <option value="other">General Protocol</option>
                </select>
              </div>

              <div class="space-y-2">
                <label for="message" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Payload</label>
                <textarea
                  v-model="form.message"
                  id="message"
                  rows="5"
                  placeholder="Insert transmission content here..."
                  required
                  class="w-full px-4 sm:px-6 py-4 sm:py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 resize-none font-bold"
                ></textarea>
              </div>

              <div class="pt-4">
                <button
                  type="submit"
                  :disabled="isSubmitting"
                  class="group/btn relative w-full py-6 bg-teal-400 rounded-2xl overflow-hidden disabled:opacity-50 transition-all duration-500 hover:shadow-[0_0_40px_rgba(45,212,191,0.4)]"
                >
                  <div class="absolute inset-0 bg-gradient-to-r from-teal-400 to-blue-500 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-500"></div>
                  <span v-if="!isSubmitting" class="relative text-[11px] font-black uppercase tracking-[0.3em] text-gray-950">Transmit Pulse</span>
                  <div v-else class="relative flex items-center justify-center">
                    <svg class="animate-spin h-5 w-5 text-gray-950" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Contact Information -->
        <div class="flex flex-col space-y-10">
          <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10">
            <h2 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 mb-10">Node Locations</h2>
            
            <div class="space-y-12 text-left">
              <div v-for="info in contactInfo" :key="info.title" class="group/item flex items-start space-x-4 sm:space-x-6">
                <div class="w-12 h-12 sm:w-14 sm:h-14 bg-white/5 rounded-2xl border border-white/10 flex items-center justify-center group-hover/item:border-teal-400 group-hover/item:bg-teal-400/10 transition-all duration-500">
                  <component :is="info.icon" class="w-6 h-6 text-white group-hover/item:text-teal-400 transition-colors" v-html="info.iconTemplate" />
                </div>
                <div class="flex-1">
                  <h3 class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30 mb-1">{{ info.title }}</h3>
                  <p class="text-lg sm:text-xl font-black text-white italic tracking-tighter group-hover/item:translate-x-1 transition-transform inline-block">{{ info.value }}</p>
                  <p class="text-xs font-bold text-white/40 uppercase tracking-widest mt-1">{{ info.description }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- FAQ Link Card -->
          <div class="group bg-gradient-to-br from-teal-400/5 to-blue-500/5 backdrop-blur-3xl border border-teal-500/20 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 overflow-hidden relative">
            <div class="absolute -right-20 -top-20 w-64 h-64 bg-teal-400/10 blur-[100px] rounded-full group-hover:scale-150 transition-transform duration-1000"></div>
            <div class="relative z-10">
              <h3 class="text-2xl font-black text-white uppercase italic tracking-tighter mb-4">Autonomous<br>Support</h3>
              <p class="text-white/40 font-medium leading-relaxed mb-8 max-w-[280px]">Access our decentralized knowledge base for instantaneous resolution.</p>
              <router-link 
                to="/faq" 
                class="inline-flex items-center space-x-3 text-teal-400 font-black uppercase tracking-widest text-[10px] hover:translate-x-2 transition-transform duration-500"
              >
                <span>Access FAQ Center</span>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, h } from 'vue';

const form = ref({
  name: '',
  email: '',
  subject: '',
  message: ''
});

const isSubmitting = ref(false);

const contactInfo = [
  {
    title: 'Pulse Line',
    value: '+1 (800) CORE-GAS',
    description: 'Protocol active 09:00 - 17:00 EST',
    iconTemplate: `<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" /></svg>`
  },
  {
    title: 'Data Stream',
    value: 'uplink@gasmonitor.ai',
    description: 'Encrypted transmission layer 24/7',
    iconTemplate: `<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>`
  },
  {
    title: 'Command HQ',
    value: 'Boston Node Alpha',
    description: '123 Safety Way, MA 02108',
    iconTemplate: `<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" /></svg>`
  }
];

const handleSubmit = async () => {
  isSubmitting.value = true;
  try {
    await new Promise(resolve => setTimeout(resolve, 2000));
    form.value = { name: '', email: '', subject: '', message: '' };
    alert('Transmission Successful. Our architects have been notified.');
  } catch (error) {
    console.error('Transmission Failure:', error);
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<style scoped>
.contact-page {
  scroll-behavior: smooth;
}
@keyframes pulse-slow {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.15; transform: scale(1.05); }
}
.animate-pulse-slow { 
  animation: pulse-slow 8s ease-in-out infinite; 
}
select option {
  background: #020617;
  color: white;
  padding: 20px;
}


.contact-page {
  scroll-behavior: smooth;
}

/* --- Logic Overdrive Animations --- */
@keyframes fade-in { 
  from { opacity: 0; transform: translateY(30px); } 
  to { opacity: 1; transform: translateY(0); } 
}

@keyframes title-slide {
  from { 
    letter-spacing: -1.5em; 
    filter: blur(20px); 
    opacity: 0; 
    transform: scale(0.8);
  }
  to { 
    letter-spacing: -0.05em; 
    filter: blur(0); 
    opacity: 1; 
    transform: scale(1);
  }
}

@keyframes pulse-slow {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.15; transform: scale(1.05); }
}

.animate-fade-in { 
  animation: fade-in 1.2s cubic-bezier(0.16, 1, 0.3, 1) forwards; 
}

.animate-title { 
  animation: title-slide 1.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; 
}

.animate-pulse-slow { 
  animation: pulse-slow 8s ease-in-out infinite; 
}
/* --- End Animations --- */

select option {
  background: #020617;
  color: white;
  padding: 20px;
}

</style>
