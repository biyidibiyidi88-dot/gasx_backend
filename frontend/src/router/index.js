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
        path: 'analytics',
        name: 'analytics',
        component: () => import('../pages/private/Analitics.vue'),
      },
      {
        path: 'tanks',
        name: 'tanks',
        component: () => import('../pages/private/GasTank.vue'),
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
        path: 'profile',
        name: 'profile',
        component: () => import('../pages/private/Profile.vue'),
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
