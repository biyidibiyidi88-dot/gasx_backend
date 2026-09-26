import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const ADMIN = ['admin']
const CLIENT = ['client', 'user']
const SUPPLIER = ['gas_supplier', 'vendor']
const DRIVER = ['delivery_person', 'driver']
const routes = [
  {
    path: '/admin',
    component: () => import('../layouts/Defaultlayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', name: 'dashboard', component: () => import('../pages/private/dashboard.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'client-dashboard', name: 'client-dashboard', component: () => import('../pages/private/ClientDashboard.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'pricing', name: 'pricing', component: () => import('../pages/private/pricing.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'tanks', name: 'tanks', component: () => import('../pages/private/GasTank.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'admin-sensors', name: 'admin-sensors', component: () => import('../pages/private/admin/AdminSensors.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'buy-gas', name: 'buy-gas', component: () => import('../pages/private/BuyGas.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'client-orders', name: 'client-orders', component: () => import('../pages/private/ClientOrders.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'settings', name: 'settings', component: () => import('../pages/private/Systemsetting.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'users', name: 'users', component: () => import('../pages/private/Usermanagment.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'alerts', name: 'alerts', component: () => import('../pages/private/notification.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'system-alerts', name: 'system-alerts', component: () => import('../pages/private/admin/AdminAlerts.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'profile', name: 'profile', component: () => import('../pages/private/Profile.vue'), meta: { allowedRoles: [...CLIENT, ...SUPPLIER, ...DRIVER] } },
      { path: 'ai-chat', name: 'ai-chat', component: () => import('../pages/AiChatPage.vue'), meta: { allowedRoles: CLIENT } },
      { path: 'gas-map', name: 'gas-map', component: () => import('../pages/private/GasMap.vue'), meta: { allowedRoles: [...CLIENT, ...DRIVER] } },
      { path: 'vendor-inventory', name: 'vendor-inventory', component: () => import('../pages/private/vendor/VendorInventory.vue'), meta: { allowedRoles: SUPPLIER } },
      { path: 'vendor-profile', name: 'vendor-profile', component: () => import('../pages/private/vendor/VendorProfile.vue'), meta: { allowedRoles: SUPPLIER } },
      { path: 'vendor-validation', name: 'vendor-validation', component: () => import('../pages/private/admin/VendorValidation.vue'), meta: { allowedRoles: ADMIN } },
      { path: 'delivery-dashboard', name: 'delivery-dashboard', component: () => import('../pages/private/delivery/DeliveryDashboard.vue'), meta: { allowedRoles: [...ADMIN, ...DRIVER, ...SUPPLIER] } },
      { path: 'delivery-route/:id', name: 'delivery-route', component: () => import('../pages/private/delivery/DeliveryRoute.vue'), meta: { allowedRoles: [...ADMIN, ...DRIVER] } },
    ],
  },
  {
    path: '/', component: () => import('../layouts/PublicLayout.vue'),
    children: [
      { path: '', name: 'landing', component: () => import('../pages/public/Landing.vue') },
      { path: 'about', name: 'about', component: () => import('../pages/public/About.vue') },
      { path: 'register', name: 'signup', component: () => import('../pages/public/signup.vue') },
      { path: 'login', name: 'login', component: () => import('../pages/public/Login.vue') },
      { path: 'contact', name: 'contact', component: () => import('../pages/public/Contact.vue') },
      { path: 'features', name: 'features', component: () => import('../pages/public/Features.vue') },
      { path: 'pricing', name: 'public-pricing', component: () => import('../pages/public/Pricing.vue') },
    ],
  },
]

const router = createRouter({ history: createWebHistory(), routes, scrollBehavior: () => ({ top: 0 }) })

function normalizedRole(profile) {
  if (profile?.is_admin || profile?.is_staff || profile?.is_superuser) return 'admin'
  const role = String(profile?.role || '').toLowerCase().replaceAll(' ', '_')
  if (['admin', 'super_admin'].includes(role)) return 'admin'
  if (['vendor', 'gas_supplier', 'supplier'].includes(role)) return 'gas_supplier'
  if (['delivery_person', 'driver'].includes(role)) return 'delivery_person'
  return 'client'
}

function homeFor(role) {
  if (role === 'admin') return '/admin'
  if (role === 'gas_supplier') return '/admin/vendor-profile'
  if (role === 'delivery_person') return '/admin/delivery-dashboard'
  return '/admin/client-dashboard'
}

router.beforeEach(async (to) => {
  const token = localStorage.getItem('authToken')
  if (to.matched.some(record => record.meta.requiresAuth) && !token) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (!token) return true

  const userStore = useUserStore()
  if (!userStore.userProfile?.role) {
    try {
      await userStore.fetchUserProfile()
    } catch {
      userStore.clearAuth()
      return { name: 'login', query: { redirect: to.fullPath } }
    }
  }
  const role = normalizedRole(userStore.userProfile)
  const allowed = to.matched.flatMap(record => record.meta.allowedRoles || [])
  if (to.name === 'dashboard' && role !== 'admin') return homeFor(role)
  if (to.name === 'client-dashboard' && role !== 'client') return homeFor(role)
  if (allowed.length && !allowed.includes(role)) return homeFor(role)
  if (['login', 'signup', 'landing'].includes(to.name)) return homeFor(role)
  return true
})

export default router
