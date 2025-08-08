import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import api from './config/api';
import './style.css';
import { createPinia } from 'pinia';

const app = createApp(App);
const pinia = createPinia();

// Use Pinia before mounting
app.use(pinia);

// Set up the API instance with interceptors if needed
app.use(router);

// Mount the app
app.mount('#app');