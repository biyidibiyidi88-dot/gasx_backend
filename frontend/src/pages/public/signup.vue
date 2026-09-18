<template>
  <div class="signup-page min-h-screen pt-24 pb-16 sm:pt-48 sm:pb-40 overflow-hidden relative font-['Inter',-apple-system,BlinkMacSystemFont,sans-serif]">
    <!-- Sophisticated 3D Background System -->
    <div class="fixed inset-0 pointer-events-none -z-10">
      <div class="absolute top-0 left-1/4 w-[500px] h-[500px] bg-teal-500/10 blur-[150px] animate-pulse-slow"></div>
      <div class="absolute bottom-0 right-1/4 w-[600px] h-[600px] bg-blue-600/10 blur-[180px] animate-pulse-slow" style="animation-delay: 1.5s"></div>
      <div class="absolute inset-0 opacity-[0.05]" style="background-image: radial-gradient(circle, #2dd4bf 1px, transparent 1px); background-size: 60px 60px;"></div>
    </div>

    <div class="container mx-auto px-6">
      <div class="flex flex-col lg:flex-row gap-20 items-center justify-center max-w-7xl mx-auto">
        <!-- Left Side - Benefits -->
        <div class="lg:w-1/2 text-left hidden lg:block">
          <div class="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-teal-500/10 border border-teal-500/20 mb-8">
            <span class="w-1.5 h-1.5 rounded-full bg-teal-400"></span>
            <span class="text-[10px] font-black uppercase tracking-[0.3em] text-teal-400">Join the Network</span>
          </div>
          <h2 class="text-3xl sm:text-7xl font-black text-white mb-8 tracking-tighter uppercase italic leading-[0.9]">
            Register<br>
            <span class="bg-gradient-to-r from-teal-400 to-blue-500 bg-clip-text text-transparent italic">Account</span>
          </h2>
          <p class="text-xl text-white/40 mb-12 font-medium leading-relaxed max-w-md">
            Create your account to start monitoring your gas sensors and receiving real-time alerts.
          </p>

          <!-- Benefits Grid -->
          <div class="space-y-8 mb-12">
            <div v-for="(benefit, index) in benefits" :key="index" class="group/item flex items-start space-x-6">
              <div class="w-12 h-12 bg-white/5 rounded-2xl border border-white/10 flex items-center justify-center group-hover/item:border-teal-400 group-hover/item:bg-teal-400/10 transition-all duration-500">
                <svg class="w-5 h-5 text-white group-hover/item:text-teal-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <h3 class="text-[11px] font-black uppercase tracking-[0.2em] text-white/40 mb-1">{{ benefit.title }}</h3>
                <p class="text-lg font-black text-white italic tracking-tighter">{{ benefit.description }}</p>
              </div>
            </div>
          </div>

          <!-- Testimonial -->
          <div class="bg-white/[0.02] backdrop-blur-3xl border border-white/5 rounded-3xl sm:rounded-[2.5rem] p-8 sm:p-10 shadow-2xl relative overflow-hidden group">
            <div class="absolute -right-10 -bottom-10 w-32 h-32 bg-teal-400/10 blur-[50px] rounded-full group-hover/test:scale-150 transition-transform duration-1000"></div>
            <div class="flex items-center mb-6">
              <div class="flex text-teal-400 space-x-1">
                <svg v-for="i in 5" :key="i" class="w-3 h-3 fill-current" viewBox="0 0 24 24"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" /></svg>
              </div>
              <span class="ml-3 text-[10px] font-black uppercase tracking-widest text-white/20">Verified User</span>
            </div>
            <p class="text-sm font-bold text-white/60 italic leading-relaxed mb-4">
              "The registration was quick, and the dashboard is incredibly helpful for tracking my home safety."
            </p>
            <div class="text-[10px] font-black text-teal-400 uppercase tracking-widest">— Sarah M., Home Owner</div>
          </div>
        </div>

        <!-- Right Side - Signup Form -->
        <div class="w-full lg:w-[550px] relative group">
          <div class="absolute inset-0 bg-teal-400/5 blur-[100px] opacity-0 group-hover:opacity-100 transition-opacity duration-1000"></div>
          <div class="relative bg-white/[0.02] backdrop-blur-3xl border border-white/10 rounded-3xl sm:rounded-[4rem] p-8 sm:p-14 hover:border-white/20 transition-all duration-700">
            <div class="text-center mb-12">
              <h2 class="text-xs font-black uppercase tracking-[0.3em] text-white/40 mb-2">New Account</h2>
              <h1 class="text-3xl font-black text-white uppercase italic tracking-tighter">Sign Up</h1>
            </div>

            <!-- Error Message -->
            <transition name="fade">
              <div v-if="errors.general" class="mb-8 p-4 bg-red-500/10 border border-red-500/20 rounded-2xl">
                 <p class="text-[10px] font-black text-red-400 uppercase tracking-widest">{{ errors.general }}</p>
              </div>
            </transition>

            <form @submit.prevent="handleSubmit" class="space-y-8">
              <!-- Account Type Selection -->
              <div class="space-y-4 border-b border-white/5 pb-8 mb-8">
                <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Account Type</label>
                <div class="grid grid-cols-3 gap-3">
                  <button type="button" @click="form.accountType = 'user'" :class="form.accountType === 'user' ? 'bg-teal-400/20 border-teal-400 text-teal-400 shadow-[0_0_15px_rgba(45,212,191,0.2)]' : 'bg-white/[0.03] border-white/5 text-white/40 hover:bg-white/[0.05]'" class="py-4 rounded-2xl border font-black uppercase tracking-widest text-[10px] transition-all duration-300">
                    Regular User
                  </button>
                  <button type="button" @click="form.accountType = 'vendor'" :class="form.accountType === 'vendor' ? 'bg-teal-400/20 border-teal-400 text-teal-400 shadow-[0_0_15px_rgba(45,212,191,0.2)]' : 'bg-white/[0.03] border-white/5 text-white/40 hover:bg-white/[0.05]'" class="py-4 rounded-2xl border font-black uppercase tracking-widest text-[10px] transition-all duration-300">
                    Gas Supplier
                  </button>
                  <button type="button" @click="form.accountType = 'delivery'" :class="form.accountType === 'delivery' ? 'bg-orange-400/20 border-orange-400 text-orange-400 shadow-[0_0_15px_rgba(251,146,60,0.2)]' : 'bg-white/[0.03] border-white/5 text-white/40 hover:bg-white/[0.05]'" class="py-4 rounded-2xl border font-black uppercase tracking-widest text-[10px] transition-all duration-300">
                    Delivery Person
                  </button>
                </div>
              </div>

              <transition name="fade">
                <div v-if="form.accountType === 'vendor'" class="space-y-2 pb-4">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Commercial Store Name (Required)</label>
                  <input v-model="form.storeName" type="text" placeholder="e.g. TotalEnergies Bonamoussadi" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.storeName }">
                </div>
              </transition>

              <!-- Name Fields -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 sm:gap-8">
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">First Name</label>
                  <input v-model="form.firstName" type="text" required placeholder="John" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.firstName }">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Last Name</label>
                  <input v-model="form.lastName" type="text" required placeholder="Doe" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.lastName }">
                </div>
              </div>

              <!-- Contact Info -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 sm:gap-8">
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Email Address</label>
                  <input v-model="form.email" type="email" required placeholder="john@example.com" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.email }">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Phone Number</label>
                  <input v-model="form.phone" type="tel" required placeholder="+237 000 000 000" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.phone }">
                </div>
              </div>

              <!-- Location Info -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 sm:gap-8">
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">City</label>
                  <input v-model="form.city" type="text" placeholder="Yaoundé" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Country</label>
                  <select v-model="form.country" required class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white appearance-none cursor-pointer font-bold">
                    <option value="" disabled>Select Country</option>
                    <option value="CM">Cameroon</option>
                    <option value="US">United States</option>
                    <option value="FR">France</option>
                    <option value="UK">United Kingdom</option>
                  </select>
                </div>
              </div>

              <!-- Password Setup -->
              <div class="space-y-8">
                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Password</label>
                  <div class="relative">
                    <input v-model="form.password" :type="showPassword ? 'text' : 'password'" required placeholder="••••••••" class="w-full px-6 py-5 pr-14 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.password }">
                    <button type="button" @click="showPassword = !showPassword" class="absolute right-5 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors p-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                    </button>
                  </div>
                  <div class="flex flex-wrap gap-4 mt-4 ml-4">
                    <div v-for="req in passwordRequirements" :key="req.text" class="flex items-center space-x-2 transition-all duration-500" :class="req.met ? 'opacity-100' : 'opacity-20'">
                      <div class="w-1 h-1 rounded-full bg-teal-400 shadow-[0_0_8px_rgba(45,212,191,0.8)]"></div>
                      <span class="text-[8px] font-black uppercase tracking-widest text-teal-400">{{ req.text }}</span>
                    </div>
                  </div>
                </div>

                <div class="space-y-2">
                  <label class="text-[10px] font-black uppercase tracking-widest text-white/30 ml-4">Confirm Password</label>
                  <input v-model="form.confirmPassword" type="password" required placeholder="••••••••" class="w-full px-6 py-5 bg-white/[0.03] border border-white/5 rounded-2xl focus:border-teal-400/50 focus:bg-white/[0.05] focus:outline-none transition-all duration-500 text-white placeholder:text-white/10 font-bold" :class="{ 'border-red-500/50': errors.confirmPassword }">
                </div>
              </div>

              <!-- Agreements -->
              <div class="space-y-4 px-2">
                <div class="flex items-start group/check cursor-pointer" @click="form.acceptTerms = !form.acceptTerms">
                  <div class="w-5 h-5 mt-0.5 rounded-md border border-white/10 bg-white/5 flex items-center justify-center group-hover/check:border-teal-400/50 transition-colors">
                    <div v-if="form.acceptTerms" class="w-2 h-2 rounded-full bg-teal-400 shadow-[0_0_10px_rgba(45,212,191,0.5)]"></div>
                  </div>
                  <div class="ml-4 flex-1 text-[10px] font-black uppercase tracking-widest text-white/30 leading-relaxed">
                    I agree to the <span class="text-teal-400 italic">Terms and Conditions</span> & <span class="text-teal-400 italic">Privacy Policy</span>
                  </div>
                </div>
              </div>

              <div class="pt-8">
                <button type="submit" :disabled="isSubmitting" class="group/btn relative w-full py-6 bg-teal-400 rounded-2xl overflow-hidden disabled:opacity-50 transition-all duration-500 hover:shadow-[0_0_40px_rgba(45,212,191,0.4)]">
                  <div class="absolute inset-0 bg-gradient-to-r from-teal-400 to-blue-500 opacity-0 group-hover/btn:opacity-100 transition-opacity duration-500"></div>
                  <span v-if="!isSubmitting" class="relative text-[11px] font-black uppercase tracking-[0.3em] text-gray-950">Create Account</span>
                  <div v-else class="relative flex items-center justify-center">
                    <svg class="animate-spin h-5 w-5 text-gray-950" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                  </div>
                </button>
              </div>

              <div class="text-center pt-8 border-t border-white/5">
                <router-link to="/login" class="text-[10px] font-black uppercase tracking-[0.2em] text-white/30 hover:text-white transition-colors">
                  Already have an account? <span class="text-teal-400 ml-1">Sign In</span>
                </router-link>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import api from '../../config/api';

const router = useRouter();
const form = ref({
  accountType: 'user',
  storeName: '',
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  address: '',
  city: '',
  state_province: '',
  country: '',
  acceptTerms: false,
  newsletter: false
});

const errors = ref({});
const isSubmitting = ref(false);
const showPassword = ref(false);

const benefits = [
  { title: "Smart Safety", description: "Receive instant alerts for any leakage detection." },
  { title: "Deep Insights", description: "Visualize your gas consumption patterns over time." },
  { title: "Real-time Alerts", description: "Notifications sent via Email and Push channels." },
  { title: "Global Mesh", description: "Secure your infrastructure from anywhere." }
];

const passwordRequirements = computed(() => [
  { text: "8+ characters", met: form.value.password.length >= 8 },
  { text: "One Uppercase", met: /[A-Z]/.test(form.value.password) },
  { text: "One Number", met: /\d/.test(form.value.password) }
]);

const validateEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
const validatePhone = (phone) => phone.length >= 8; 
const validatePassword = (password) => password.length >= 8 && /[A-Z]/.test(password) && /\d/.test(password);

watch(() => form.value.email, (val) => { if (val && !validateEmail(val)) errors.value.email = 'Invalid email'; else delete errors.value.email; });
watch(() => form.value.password, (val) => { if (val && !validatePassword(val)) errors.value.password = 'Insecure password'; else delete errors.value.password; });
watch(() => form.value.confirmPassword, (val) => { if (val && val !== form.value.password) errors.value.confirmPassword = 'Passwords do not match'; else delete errors.value.confirmPassword; });

const handleSubmit = async () => {
  errors.value = {};
  if (form.value.accountType === 'vendor' && !form.value.storeName.trim()) {
    errors.value.storeName = 'Required for Suppliers';
  }
  if (!form.value.firstName.trim()) errors.value.firstName = 'Required';
  if (!form.value.lastName.trim()) errors.value.lastName = 'Required';
  if (!validateEmail(form.value.email)) errors.value.email = 'Required';
  if (!form.value.country) errors.value.country = 'Required';
  if (!validatePhone(form.value.phone)) errors.value.phone = 'Required';
  if (!validatePassword(form.value.password)) errors.value.password = 'Too weak';
  if (form.value.password !== form.value.confirmPassword) errors.value.confirmPassword = 'Mismatch';
  if (!form.value.acceptTerms) errors.value.general = 'Please accept the terms';

  if (Object.keys(errors.value).length > 0) return;
  isSubmitting.value = true;
  
  try {
    const payload = {
      first_name: form.value.firstName,
      last_name: form.value.lastName,
      email: form.value.email,
      phone_number: form.value.phone, 
      password: form.value.password,
      address: form.value.address || '',
      city: form.value.city || '',
      state_province: form.value.state_province || '',
      country: form.value.country,
      accept_terms: form.value.acceptTerms,
      newsletter_subscription: form.value.newsletter,
      is_delivery_person: form.value.accountType === 'delivery',
    };
    
    const response = await api.post("auth/register/", payload);
    
    // Auto-login after registration
    if (response.data.token) {
      localStorage.setItem('authToken', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
      api.defaults.headers.common['Authorization'] = `Token ${response.data.token}`;
      
      if (form.value.accountType === 'vendor') {
         const fullAddress = [form.value.address, form.value.city, form.value.state_province, form.value.country].filter(Boolean).join(', ');
         const formData = new FormData();
         formData.append('store_name', form.value.storeName);
         formData.append('address', fullAddress);
         try {
           await api.post("vendor/register/", formData, {
             headers: { 'Content-Type': 'multipart/form-data' }
           });
         } catch(vendorErr) {
           console.error('Failed creating vendor profile', vendorErr);
         }
      }
      
      await router.push('/admin');
    } else {
      await router.push('/login');
    }
  } catch (error) {
    console.error('Registration failed:', error);
    if (error.response?.data?.errors) {
       const backendErrors = error.response.data.errors;
       if (backendErrors.email) errors.value.general = 'Account with this email already exists.';
       else errors.value.general = 'Registration failed. Please check your details.';
    } else {
       errors.value.general = 'Connection error. Please try again.';
    }
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<style scoped>
.signup-page {
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
</style>