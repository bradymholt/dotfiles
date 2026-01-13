import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/ynab-recurring-charges-finder/',
  optimizeDeps: {
    include: ['ynab'],
  },
  build: {
    commonjsOptions: {
      transformMixedEsModules: true,
    },
  },
})
