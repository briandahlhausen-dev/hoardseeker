'use client'

import { useEffect, useState } from 'react'
import LivePulse from '@/components/ui/LivePulse'
import type { Config, Situation } from '@/lib/schemas'
import { getDayCount } from '@/lib/utils'

const SEVERITY_COLORS: Record<string, string> = {
  crit: '#ff2e4c',
  warn: '#ffb020',
  ok: '#2dd4a4',
  info: '#4fc3ff',
}

interface HeaderProps {
  config: Config
  situation: Situation
}

export default function Header({ config, situation }: HeaderProps) {
  const [clock, setClock] = useState('')
  const [dayCount] = useState(() => getDayCount(config.startDate))

  useEffect(() => {
    function tick() {
      const now = new Date()
      const hh = String(now.getUTCHours()).padStart(2, '0')
      const mm = String(now.getUTCMinutes()).padStart(2, '0')
      const ss = String(now.getUTCSeconds()).padStart(2, '0')
      setClock(`${hh}:${mm}:${ss}`)
    }
    tick()
    const id = setInterval(tick, 1000)
    return () => clearInterval(id)
  }, [])

  const badgeColor = SEVERITY_COLORS[config.status.severity] ?? '#d4d4d4'
  const lastUpdated = new Date(situation.lastUpdated)
  const lastUpdatedStr = lastUpdated.toLocaleString('en-GB', {
    timeZone: 'UTC',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  })

  return (
    <header
      className="flex items-center justify-between px-4 border-b border-[#1f2937] shrink-0"
      style={{ height: 48, background: '#0a0d12' }}
    >
      {/* Left: title + badge */}
      <div className="flex items-center gap-3 min-w-0">
        <h1
          className="text-[#ffffff] font-mono-ui text-sm font-bold tracking-widest uppercase truncate"
          style={{ letterSpacing: '0.12em' }}
        >
          {config.title}
        </h1>
        <span
          className="px-2 py-0.5 text-[10px] font-mono-ui font-bold tracking-widest uppercase border"
          style={{
            color: badgeColor,
            borderColor: badgeColor,
            borderRadius: 2,
            background: `${badgeColor}18`,
          }}
        >
          {config.status.label}
        </span>
      </div>

      {/* Center: Day counter */}
      <div className="absolute left-1/2 -translate-x-1/2 flex flex-col items-center">
        <span className="text-[9px] font-mono-ui text-[#d4d4d4]/50 tracking-widest uppercase">
          ELAPSED
        </span>
        <span className="font-mono-num text-[#ffffff] text-base font-bold tabular-nums">
          DAY {dayCount}
        </span>
      </div>

      {/* Right: last update + clock + live pulse */}
      <div className="flex items-center gap-2 text-[10px] font-mono-ui text-[#d4d4d4]/60 tracking-wide">
        <span className="hidden sm:block">
          UPD {lastUpdatedStr} UTC
        </span>
        <span className="text-[#ffffff] font-mono-num text-xs tabular-nums">
          {clock} UTC
        </span>
        <LivePulse size={8} />
      </div>
    </header>
  )
}
