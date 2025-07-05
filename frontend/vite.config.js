import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    vue(),
    tailwindcss(),
  ],
  server: {
    host: '0.0.0.0', // ← Allow external access
    port: 5173,       // (Optional) choose your dev port
    proxy: {
      '/api': {
        target: 'http://172.20.10.6:8000', // ← Use your PC's IP, not localhost
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
