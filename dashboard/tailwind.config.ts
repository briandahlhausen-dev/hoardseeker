import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        bg: '#0a0d12',
        fg: '#d4d4d4',
        headline: '#ffffff',
        border: '#1f2937',
        'border-hover': '#2d3748',
        crit: '#ff2e4c',
        warn: '#ffb020',
        ok: '#2dd4a4',
        info: '#4fc3ff',
        'crit-dim': 'rgba(255,46,76,0.15)',
        'warn-dim': 'rgba(255,176,32,0.15)',
        'ok-dim': 'rgba(45,212,164,0.15)',
        'info-dim': 'rgba(79,195,255,0.15)',
      },
      fontFamily: {
        mono: ['"Space Mono"', '"JetBrains Mono"', 'monospace'],
        'mono-num': ['"JetBrains Mono"', 'monospace'],
        sans: ['"IBM Plex Sans"', 'sans-serif'],
      },
      borderRadius: {
        DEFAULT: '2px',
        sm: '1px',
        md: '2px',
        lg: '2px',
      },
      backgroundImage: {
        'scanlines': 'repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(255,255,255,0.04) 3px, rgba(255,255,255,0.04) 4px)',
      },
      keyframes: {
        pulse_halo: {
          '0%': { transform: 'scale(1)', opacity: '1' },
          '100%': { transform: 'scale(3)', opacity: '0' },
        },
        digit_roll_in: {
          '0%': { transform: 'translateY(-100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        digit_flash: {
          '0%': { color: '#4fc3ff' },
          '100%': { color: 'inherit' },
        },
        ticker_scroll: {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
      },
      animation: {
        'pulse-halo': 'pulse_halo 1.4s ease-out infinite',
        'digit-roll': 'digit_roll_in 0.2s ease-out',
        'digit-flash': 'digit_flash 0.2s ease-out',
        'ticker': 'ticker_scroll 60s linear infinite',
      },
    },
  },
  plugins: [],
}

export default config
