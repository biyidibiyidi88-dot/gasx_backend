<template>
  <div class="login-page min-h-screen pt-24 pb-16 sm:pt-48 sm:pb-40 overflow-hidden relative font-['Inter',-apple-system,BlinkMacSystemFont,sans-serif]">
    <!-- Sophisticated 3D Background System -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-teal-500/10 blur-[150px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/10 blur-[180px] animate-pulse-slow" style="animation-delay: 1.5s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <div class="container mx-auto px-6">
      <div class="flex flex-col lg:flex-row gap-20 items-center justify-center max-w-7xl mx-auto">
        <!-- Left Side - Info Section -->
        <div class="lg:w-1/2 text-left hidden lg:block">
          <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8">
            <span class="w-1.5 h-1.5 rounded-full bg-teal-400"></span>
            <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">Welcome Back</span>
          </div>
          <h2 class="text-3xl sm:text-7xl font-black text-white mb-8 tracking-tighter uppercase italic leading-[0.9]">
            Access<br>
            <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent italic">Dashboard</span>
          </h2>
          <p class="text-xl text-white/40 mb-12 font-medium leading-relaxed max-w-md">
            Sign in to monitor your consumption and manage your hardware nodes efficiently.
          </p>

          <!-- Stats Grid -->
          <div class="grid grid-cols-2 gap-8 mb-12">
            <div v-for="stat in stats" :key="stat.label" class="group/stat">
              <div class="text-3xl font-black text-white italic tracking-tighter group-hover/stat:text-teal-400 transition-colors">{{ stat.value }}</div>
              <div class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30 mt-1">{{ stat.label }}</div>
            </div>
          </div>

          <!-- Intelligence Log -->
          <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-[2.5rem] p-8 max-w-sm">
            <h3 class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400 mb-6 flex items-center">
              <span class="w-1 h-1 bg-teal-400 rounded-full mr-2"></span>
              System Status
            </h3>
            <div class="space-y-4">
              <div v-for="log in logs" :key="log.text" class="flex items-center justify-between group/log pointer-events-none">
                <span class="text-xs font-bold text-white/60 group-hover/log:text-white transition-colors uppercase tracking-widest">{{ log.text }}</span>
                <span :class="[log.color, 'text-[8px] font-black uppercase tracking-[0.2em] px-2 py-0.5 rounded-full bg-white/5 border border-white/5']">{{ log.tag }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Right Side - Login Form -->
        <div class="w-full lg:w-[500px] relative group">
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] opacity-0 group-hover:opacity-100 transition-opacity duration-1000"></div>
          <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-12 shadow-2xl relative overflow-hidden group">
            <div class="text-center mb-12">
              <h2 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 mb-2">Member Login</h2>
              <h1 class="text-3xl font-black text-white uppercase italic tracking-tighter">Sign In</h1>
            </div>

            <!-- Error Alert -->
            <transition name="fade">
              <div v-if="loginError" class="mb-8 p-5 bg-red-500/10 border border-red-500/20 rounded-2xl flex items-start gap-4">
                <div class="w-6 h-6 rounded-lg bg-red-500/20 flex items-center justify-center flex-shrink-0">
                  <svg class="w-4 h-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div>
                  <h3 class="text-[10px] font-black uppercase tracking-widest text-red-400">Login Failed</h3>
                  <p class="text-xs font-bold text-red-300/60 mt-1 uppercase leading-relaxed">{{ loginError }}</p>
                </div>
              </div>
            </transition>

            <form @submit.prevent="handleLogin" class="space-y-8">
              <div class="space-y-2">
                <label for="email" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Email Address</label>
                <div class="relative">
                  <input id="email" v-model="form.email" type="email" required
                    class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold"
                    :class="{ 'border-red-500/50': errors.email }" placeholder="you@example.com">
                  <transition name="fade">
                    <p v-if="errors.email" class="text-[9px] font-black text-red-400 uppercase tracking-widest mt-2 ml-4">{{ errors.email }}</p>
                  </transition>
                </div>
              </div>

              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <label for="password" class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Password</label>
                </div>
                <div class="relative">
                  <input id="password" v-model="form.password" :type="showPassword ? 'text' : 'password'" required
                    class="w-full px-6 py-5 pr-14 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold"
                    :class="{ 'border-red-500/50': errors.password }" placeholder="••••••••">
                  <button type="button" @click="showPassword = !showPassword"
                    class="absolute right-5 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors p-2">
                    <svg v-if="showPassword" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                    </svg>
                    <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </button>
                </div>
                <transition name="fade">
                  <p v-if="errors.password" class="text-[9px] font-black text-red-400 uppercase tracking-widest mt-2 ml-4">{{ errors.password }}</p>
                </transition>
              </div>

              <div class="flex items-center justify-between px-2">
                <div class="flex items-center group/check cursor-pointer" @click="form.rememberMe = !form.rememberMe">
                  <div class="w-5 h-5 rounded-md border border-white/10 bg-white/5 flex items-center justify-center group-hover/check:border-teal-400/50 transition-colors">
                    <div v-if="form.rememberMe" class="w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
                  </div>
                  <span class="ml-3 text-[10px] font-black uppercase tracking-widest text-white/30 group-hover/check:text-white/60 transition-colors">Remember Me</span>
                </div>
                <button type="button" @click="showForgotPassword = true"
                  class="text-[10px] font-black uppercase tracking-widest text-teal-400 hover:text-teal-300 transition-colors">
                  Forgot Password?
                </button>
              </div>

              <div class="pt-4">
                <button type="submit" :disabled="isSubmitting"
                  class="group/btn relative w-full py-6 bg-teal-400 rounded-2xl overflow-hidden disabled:opacity-50 transition-all duration-500 hover:shadow-[0_0_40px_rgba(45,212,191,0.4)]">
                  <div class="absolute inset-0 bg-gradient-to-r from-teal-400 to-blue-500 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-500"></div>
                  <span v-if="!isSubmitting" class="relative text-[11px] font-black uppercase tracking-[0.3em] text-gray-950">Sign In</span>
                  <div v-else class="relative flex items-center justify-center">
                    <svg class="animate-spin h-5 w-5 text-gray-950" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </button>
              </div>

              <!-- Social Login -->
              <div class="space-y-6 pt-4">
                <div class="relative flex items-center justify-center">
                  <div class="absolute inset-0 flex items-center"><div class="w-full border-t border-white/5"></div></div>
                  <span class="relative px-4 bg-transparent text-[10px] font-black uppercase tracking-widest text-white/20 italic">Alternative Login</span>
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <button type="button" class="group/social py-4 bg-white/5 border border-white/5 rounded-2xl flex items-center justify-center hover:bg-white/10 hover:border-white/20 transition-all duration-300">
                    <svg class="w-5 h-5 opacity-40 group-hover:opacity-100 transition-opacity" viewBox="0 0 24 24">
                      <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
                      <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
                    </svg>
                  </button>
                  <button type="button" class="group/social py-4 bg-white/5 border border-white/5 rounded-2xl flex items-center justify-center hover:bg-white/10 hover:border-white/20 transition-all duration-300">
                    <svg class="w-5 h-5 opacity-40 group-hover:opacity-100 transition-opacity" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 5.079 3.158 9.417 7.618 11.174-.105-.949-.199-2.403.041-3.439.219-.937 1.406-5.957 1.406-5.957s-.359-.72-.359-1.781c0-1.663.967-2.911 2.168-2.911 1.024 0 1.518.769 1.518 1.688 0 1.029-.653 2.567-.992 3.992-.285 1.193.6 2.165 1.775 2.165 2.128 0 3.768-2.245 3.768-5.487 0-2.861-2.063-4.869-5.008-4.869-3.41 0-5.409 2.562-5.409 5.199 0 1.033.394 2.143.889 2.741.093.116.108.219.08.338-.09.375-.293 1.199-.334 1.363-.053.225-.172.271-.402.165-1.495-.69-2.433-2.878-2.433-4.646 0-3.776 2.748-7.252 7.92-7.252 4.158 0 7.392 2.967 7.392 6.923 0 4.135-2.607 7.462-6.233 7.462-1.214 0-2.357-.629-2.746-1.378l-.753 2.87c-.27 1.04-1.005 2.35-1.497 3.148C9.57 23.812 10.763 24.009 12.017 24.009c6.624 0 11.99-5.367 11.99-11.988C24.007 5.367 18.641.001 12.017.001z" />
                    </svg>
                  </button>
                </div>
              </div>

              <div class="text-center pt-8">
                <router-link to="/register" class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30 hover:text-white transition-colors">
                  Don't have an account? <span class="text-teal-400 ml-1">Sign Up</span>
                </router-link>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Forgot Password Modal -->
    <transition name="modal">
      <div v-if="showForgotPassword" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-gray-950/80 backdrop-blur-xl" @click="showForgotPassword = false">
        <div class="bg-gray-900 border border-white/5 rounded-3xl sm:rounded-[3rem] p-8 sm:p-10 max-w-md w-full relative group/modal" @click.stop>
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] rounded-full opacity-50"></div>
          <div class="relative z-10">
            <h3 class="text-2xl font-black text-white uppercase italic tracking-tighter mb-4">Reset Password</h3>
            <p class="text-white/40 font-medium mb-10 text-sm leading-relaxed uppercase tracking-widest">Enter your email address to receive a recovery link.</p>
            
            <form @submit.prevent="handleForgotPassword" class="space-y-8">
              <div class="space-y-2">
                <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Email Address</label>
                <input v-model="resetEmail" type="email" required class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white font-bold" placeholder="you@example.com">
              </div>
              <div class="flex gap-4">
                <button type="button" @click="showForgotPassword = false" class="flex-1 py-5 bg-white/5 border border-white/10 text-[10px] font-black uppercase text-white tracking-widest rounded-2xl hover:bg-white/10 transition-all">Cancel</button>
                <button type="submit" :disabled="isResettingPassword" class="flex-1 py-5 bg-teal-400 text-[11px] font-black uppercase text-gray-950 tracking-[0.2em] rounded-2xl hover:shadow-[0_0_30px_rgba(45,212,191,0.3)] transition-all">
                  <span v-if="!isResettingPassword">Reset</span>
                  <span v-else>Sending...</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import api from '../../config/api';

const router = useRouter();
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

const stats = [
  { label: 'Uptime', value: '99.9%' },
  { label: 'Users', value: '14,204' },
  { label: 'Rating', value: '#1' },
  { label: 'Latency', value: '0.03s' }
];

const logs = [
  { text: 'Auth Service Online', tag: 'OK', color: 'text-teal-400' },
  { text: 'Encryption Active', tag: 'SECURE', color: 'text-teal-400/60' },
  { text: 'Mesh Network Node', tag: 'SYNCED', color: 'text-blue-400' }
];

const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

watch(() => form.value.email, (newEmail) => {
  if (newEmail && !validateEmail(newEmail)) {
    errors.value.email = 'Invalid email address';
  } else {
    delete errors.value.email;
  }
});

const handleLogin = async () => {
  errors.value = {};
  loginError.value = '';

  if (!form.value.email) {
    errors.value.email = 'Email required';
  } else if (!validateEmail(form.value.email)) {
    errors.value.email = 'Invalid email format';
  }

  if (!form.value.password) {
    errors.value.password = 'Password required';
  }

  if (Object.keys(errors.value).length > 0) return;

  isSubmitting.value = true;

  try {
    const response = await api.post("auth/login/", {
      email: form.value.email,
      password: form.value.password
    });

    localStorage.setItem('authToken', response.data.token);
    localStorage.setItem('user', JSON.stringify(response.data.user));
    
    if (response.data.user && response.data.user.role) {
      localStorage.setItem('userRole', response.data.user.role);
    } else {
      localStorage.setItem('userRole', 'user');
    }
   
    api.defaults.headers.common['Authorization'] = `Token ${response.data.token}`;
    await router.push('/admin');
    
  } catch (error) {
    console.error('Login failed:', error);
    if (error.response?.status === 400) {
      loginError.value = 'Invalid email or password';
    } else {
      loginError.value = 'Server connection error. Please try again.';
    }
  } finally {
    isSubmitting.value = false;
  }
};

const handleForgotPassword = async () => {
  if (!resetEmail.value || !validateEmail(resetEmail.value)) return;
  isResettingPassword.value = true;
  try {
    await new Promise(resolve => setTimeout(resolve, 2000));
    alert('Reset link sent to your email.');
    showForgotPassword.value = false;
    resetEmail.value = '';
  } catch (error) {
    console.error('Reset failed:', error);
  } finally {
    isResettingPassword.value = false;
  }
};
</script>

<style scoped>
.login-page {
  scroll-behavior: smooth;
}
@keyframes pulse-slow {
  0%, 100% { opacity: 0.1; transform: scale(1); }
  50% { opacity: 0.15; transform: scale(1.05); }
}
.animate-pulse-slow { 
  animation: pulse-slow 8s ease-in-out infinite; 
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.modal-enter-active, .modal-leave-active { transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1); }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.95); }
</style>