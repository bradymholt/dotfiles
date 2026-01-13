import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/ynab-recurring-charges-finder/',
  resolve: {
    alias: {
      ynab: 'ynab/dist/browser/ynab.js',
    },
  },
})
