import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Event Monitoring Dashboard',
  description: 'Configurable event tracking and intelligence dashboard',
  robots: { index: false, follow: false },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-[#0a0d12] text-[#d4d4d4] overflow-x-hidden">
        {children}
      </body>
    </html>
  )
}
