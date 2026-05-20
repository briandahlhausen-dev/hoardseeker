'use client'

import { useRef, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import type { TimelineEvent } from '@/lib/schemas'

const SEVERITY_COLORS: Record<string, string> = {
  crit: '#ff2e4c',
  warn: '#ffb020',
  ok: '#2dd4a4',
  info: '#4fc3ff',
}

interface TimelineProps {
  events: TimelineEvent[]
}

interface TooltipState {
  event: TimelineEvent
  x: number
}

export default function Timeline({ events }: TimelineProps) {
  const scrollRef = useRef<HTMLDivElement>(null)
  const [tooltip, setTooltip] = useState<TooltipState | null>(null)

  const sorted = [...events].sort((a, b) => a.date.localeCompare(b.date))
  const today = new Date().toISOString().slice(0, 10)

  const firstDate = new Date(sorted[0]?.date ?? today)
  const lastDate = new Date(sorted[sorted.length - 1]?.date ?? today)
  const totalDays = Math.max(1, (lastDate.getTime() - firstDate.getTime()) / (1000 * 60 * 60 * 24))

  function dayFraction(dateStr: string): number {
    const d = new Date(dateStr)
    return Math.max(0, Math.min(1, (d.getTime() - firstDate.getTime()) / (totalDays * 1000 * 60 * 60 * 24)))
  }

  const todayFraction = dayFraction(today)
  const TRACK_WIDTH = 1200
  const SIDE_PAD = 24

  return (
    <div
      className="border border-[#1f2937] overflow-hidden"
      style={{ borderRadius: 2, background: '#0a0d12' }}
    >
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2 border-b border-[#1f2937]">
        <span className="text-[9px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase">
          Event Timeline
        </span>
        <div className="flex items-center gap-3">
          {Object.entries(SEVERITY_COLORS).map(([sev, color]) => (
            <span key={sev} className="flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full" style={{ background: color }} />
              <span className="text-[8px] font-mono-ui text-[#d4d4d4]/40 uppercase">{sev}</span>
            </span>
          ))}
        </div>
      </div>

      {/* Scrollable track */}
      <div
        ref={scrollRef}
        className="overflow-x-auto overflow-y-hidden"
        style={{ height: 100 }}
      >
        <div className="relative" style={{ width: TRACK_WIDTH + SIDE_PAD * 2, height: 100 }}>
          {/* Baseline */}
          <div
            className="absolute"
            style={{
              left: SIDE_PAD,
              right: SIDE_PAD,
              top: 50,
              height: 1,
              background: '#1f2937',
            }}
          />

          {/* Today line */}
          {todayFraction >= 0 && todayFraction <= 1 && (
            <div
              className="absolute z-10 flex flex-col items-center"
              style={{ left: SIDE_PAD + todayFraction * TRACK_WIDTH, top: 8 }}
            >
              <span className="text-[8px] font-mono-ui text-[#4fc3ff] mb-1">TODAY</span>
              <div
                className="w-px"
                style={{
                  height: 60,
                  background: '#4fc3ff',
                  boxShadow: '0 0 6px #4fc3ff',
                  animation: 'pulse-halo 1.4s ease-out infinite',
                }}
              />
            </div>
          )}

          {/* Events */}
          {sorted.map((evt) => {
            const frac = dayFraction(evt.date)
            const x = SIDE_PAD + frac * TRACK_WIDTH
            const color = SEVERITY_COLORS[evt.severity] ?? '#d4d4d4'
            const isAbove = sorted.indexOf(evt) % 2 === 0

            return (
              <div
                key={evt.id}
                className="absolute flex flex-col items-center cursor-pointer group"
                style={{ left: x, top: 0, transform: 'translateX(-50%)' }}
                onMouseEnter={(e) => {
                  const rect = e.currentTarget.getBoundingClientRect()
                  const parentRect = scrollRef.current?.getBoundingClientRect()
                  setTooltip({ event: evt, x: rect.left - (parentRect?.left ?? 0) })
                }}
                onMouseLeave={() => setTooltip(null)}
              >
                {isAbove && (
                  <div className="flex flex-col items-center" style={{ paddingTop: 4 }}>
                    <span className="text-[8px] font-mono-ui whitespace-nowrap mb-0.5 opacity-0 group-hover:opacity-100 transition-opacity" style={{ color }}>
                      {evt.date.slice(5)}
                    </span>
                    <div style={{ height: 22, width: 1, background: `${color}60` }} />
                    <div className="rounded-full border-2 z-10" style={{ width: 8, height: 8, background: color, borderColor: '#0a0d12' }} />
                    <div style={{ height: 22, width: 1, background: 'transparent' }} />
                  </div>
                )}
                {!isAbove && (
                  <div className="flex flex-col items-center" style={{ paddingTop: 4 }}>
                    <div style={{ height: 22, width: 1, background: 'transparent' }} />
                    <div className="rounded-full border-2 z-10" style={{ width: 8, height: 8, background: color, borderColor: '#0a0d12' }} />
                    <div style={{ height: 22, width: 1, background: `${color}60` }} />
                    <span className="text-[8px] font-mono-ui whitespace-nowrap mt-0.5 opacity-0 group-hover:opacity-100 transition-opacity" style={{ color }}>
                      {evt.date.slice(5)}
                    </span>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {/* Tooltip (portal-like, absolute at bottom of component) */}
      <AnimatePresence>
        {tooltip && (
          <motion.div
            key="timeline-tooltip"
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 4 }}
            className="absolute z-50 w-56 border border-[#2d3748] shadow-xl pointer-events-none"
            style={{
              left: Math.min(tooltip.x, window.innerWidth - 240),
              bottom: '100%',
              marginBottom: 4,
              background: '#0f1318',
              borderRadius: 2,
            }}
          >
            <div className="px-3 py-2">
              <div className="text-[8px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase mb-0.5">
                {tooltip.event.date} · {tooltip.event.category}
              </div>
              <div className="text-[11px] font-mono-ui text-[#ffffff] font-bold leading-tight mb-1">
                {tooltip.event.title}
              </div>
              <div className="text-[10px] font-body text-[#d4d4d4]/70 leading-relaxed">
                {tooltip.event.description}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
