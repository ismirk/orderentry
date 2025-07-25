import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

console.log('Loading Vite configuration...');

// Get the API URL from environment or use default
const apiUrl = process.env.VITE_API_URL || 'http://localhost:8080';
const isProduction = process.env.NODE_ENV === 'production';

console.log(`API URL: ${apiUrl}`);
console.log(`Environment: ${isProduction ? 'production' : 'development'}`);

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  server: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
    proxy: {
      '/api': {
        target: apiUrl,
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, '/api')
      }
    }
  },
  preview: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 3000,
    host: '0.0.0.0'
  },
  // Build configuration for production
  build: {
    outDir: 'dist',
    sourcemap: !isProduction,
    rollupOptions: {
      output: {
        manualChunks: undefined
      }
    }
  },
  // Environment variables
  define: {
    __API_URL__: JSON.stringify(apiUrl),
    __IS_PRODUCTION__: JSON.stringify(isProduction)
  }
})