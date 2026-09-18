import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/admin',
    component: () => import('../layouts/Defaultlayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: () => import('../pages/private/dashboard.vue'),
      },
      {
        path: 'pricing',
        name: 'analytics',
        component: () => import('../pages/private/pricing.vue'),
      },
      {
        path: 'tanks',
        name: 'tanks',
        component: () => import('../pages/private/GasTank.vue'),
      },
      {
        path: 'buy-gas',
        name: 'buy-gas',
        component: () => import('../pages/private/BuyGas.vue'),
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('../pages/private/Systemsetting.vue'),
      },
      {
        path: 'users',
        name: 'users',
        component: () => import('../pages/private/Usermanagment.vue'),
      },
      {
        path: 'alerts',
        name: 'alerts',
        component: () => import('../pages/private/notification.vue'),
      },
            
      {
        path: 'pricing',
        name: 'pricing',
        component: () => import('../pages/private/pricing.vue'),
      },

      {
        path: 'profile',
        name: 'profile',
        component: () => import('../pages/private/Profile.vue'),
      },
      {
        path: 'ai-chat',
        name: 'ai-chat',
        component: () => import('../pages/AiChatPage.vue'),
      },
      {
        path: 'gas-map',
        name: 'gas-map',
        component: () => import('../pages/private/GasMap.vue'),
      },
      {
        path: 'vendor-inventory',
        name: 'vendor-inventory',
        component: () => import('../pages/private/vendor/VendorInventory.vue'),
      },
      {
        path: 'vendor-profile',
        name: 'vendor-profile',
        component: () => import('../pages/private/vendor/VendorProfile.vue'),
      },
      {
        path: 'vendor-validation',
        name: 'vendor-validation',
        component: () => import('../pages/private/admin/VendorValidation.vue'),
      },
      {
        path: 'delivery-dashboard',
        name: 'delivery-dashboard',
        component: () => import('../pages/private/delivery/DeliveryDashboard.vue'),
      },
      {
        path: 'delivery-route/:id',
        name: 'delivery-route',
        component: () => import('../pages/private/delivery/DeliveryRoute.vue'),
      },
    ],
  },
  {
    path: '/',
    component: () => import('../layouts/PublicLayout.vue'),
    children: [
      {
        path: '',
        name: 'landing',
        component: () => import('../pages/public/Landing.vue'),
      },
      {
        path: 'about',
        name: 'about',
        component: () => import('../pages/public/About.vue'),
      },
      {
        path: 'register',
        name: 'signup',
        component: () => import('../pages/public/signup.vue'),
      },
      {
        path: 'login',
        name: 'login',
        component: () => import('../pages/public/Login.vue'),
      },
      {
        path: 'contact',
        name: 'contact',
        component: () => import('../pages/public/Contact.vue'),
      },
      {
        path: 'features',
        name: 'features',
        component: () => import('../pages/public/Features.vue'),
      },
      {
        path: 'pricing',
        name: 'pricing',
        component: () => import('../pages/public/Pricing.vue'),
      },
     
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  },
})

// Authentication guard
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('authToken');
  
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!isAuthenticated) {
      next({
        name: 'login',
        query: { redirect: to.fullPath } // Store the attempted URL for redirect after login
      });
    } else {
      next();
    }
  } else {
    next(); // Always call next()!
  }
});

export default router;
