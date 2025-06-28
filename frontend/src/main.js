import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import api from './pages/public/api' // Import your axios instance
import './style.css'
const app = createApp(App)

// Set auth token if exists
const token = localStorage.getItem('authToken');
if (token) {
  api.defaults.headers.common['Authorization'] = `Token ${token}`;
}

app.use(router)
app.mount('#app')

