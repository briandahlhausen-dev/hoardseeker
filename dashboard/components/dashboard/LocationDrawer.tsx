'use client'

import { useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import type { Location } from '@/lib/schemas'

const STATUS_COLORS: Record<string, string> = {
  active: '#ff2e4c',
  cluster: '#ffb020',
  imported: '#4fc3ff',
  monitoring: '#6b7280',
}

interface LocationDrawerProps {
  location: Location | null
  onClose: () => void
}

export default function LocationDrawer({ location, onClose }: LocationDrawerProps) {
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [onClose])

  return (
    <AnimatePresence>
      {location && (
        <>
          {/* Backdrop */}
          <motion.div
            key="backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-20"
            style={{ background: 'rgba(10,13,18,0.4)' }}
            onClick={onClose}
          />

          {/* Drawer */}
          <motion.div
            key="drawer"
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'tween', duration: 0.2 }}
            className="absolute top-0 right-0 bottom-0 z-30 w-64 border-l border-[#1f2937] flex flex-col overflow-hidden"
            style={{ background: '#0a0d12', borderRadius: '0 2px 2px 0' }}
          >
            {/* Header */}
            <div
              className="flex items-center justify-between px-3 py-2 border-b border-[#1f2937]"
              style={{
                borderLeft: `3px solid ${STATUS_COLORS[location.status] ?? '#d4d4d4'}`,
              }}
            >
              <div>
                <div className="text-[9px] font-mono-ui tracking-widest uppercase" style={{ color: STATUS_COLORS[location.status] }}>
                  {location.status}
                </div>
                <div className="text-[#ffffff] font-mono-ui text-sm font-bold mt-0.5 leading-tight">
                  {location.name}
                </div>
              </div>
              <button
                onClick={onClose}
                className="text-[#d4d4d4]/40 hover:text-[#d4d4d4] transition-colors text-lg leading-none"
                aria-label="Close drawer"
              >
                ×
              </button>
            </div>

            {/* Case count */}
            <div className="px-3 py-2 border-b border-[#1f2937]">
              <div className="text-[9px] font-mono-ui text-[#d4d4d4]/50 tracking-widest uppercase">Confirmed</div>
              <div
                className="font-mono-num text-2xl font-bold tabular-nums mt-0.5"
                style={{ color: STATUS_COLORS[location.status] }}
              >
                {location.caseCount.toLocaleString()}
              </div>
            </div>

            {/* Details */}
            {location.details && (
              <div className="flex-1 overflow-y-auto px-3 py-2 space-y-3">
                {[
                  ['First Reported', location.details.firstReported],
                  ['Last Updated', location.details.lastUpdate],
                  ['Population', location.details.population],
                  ['Health Capacity', location.details.healthCapacity],
                ].filter(([, v]) => v).map(([label, value]) => (
                  <div key={label}>
                    <div className="text-[9px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase">{label}</div>
                    <div className="text-[11px] font-mono-ui text-[#d4d4d4] mt-0.5">{value}</div>
                  </div>
                ))}

                {location.details.notes && (
                  <div>
                    <div className="text-[9px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase">Notes</div>
                    <div className="text-[11px] font-body text-[#d4d4d4]/80 mt-0.5 leading-relaxed">
                      {location.details.notes}
                    </div>
                  </div>
                )}

                {/* Coordinates */}
                <div>
                  <div className="text-[9px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase">Coordinates</div>
                  <div className="text-[10px] font-mono-num text-[#d4d4d4]/60 mt-0.5 tabular-nums">
                    {location.lat.toFixed(4)}°, {location.lng.toFixed(4)}°
                  </div>
                </div>
              </div>
            )}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
