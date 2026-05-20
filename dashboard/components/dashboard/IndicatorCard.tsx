'use client'

import type { IndicatorConfig, IndicatorState } from '@/lib/schemas'

const SEVERITY_COLORS: Record<string, string> = {
  critical: '#ff2e4c',
  elevated: '#ffb020',
  stable: '#2dd4a4',
}

const SEVERITY_BG: Record<string, string> = {
  critical: 'rgba(255,46,76,0.08)',
  elevated: 'rgba(255,176,32,0.08)',
  stable: 'rgba(45,212,164,0.08)',
}

const TREND_ICONS: Record<string, string> = {
  up: '↑',
  down: '↓',
  flat: '→',
}

const TREND_COLORS: Record<string, Record<string, string>> = {
  critical: { up: '#ff2e4c', down: '#2dd4a4', flat: '#d4d4d4' },
  elevated: { up: '#ffb020', down: '#2dd4a4', flat: '#d4d4d4' },
  stable: { up: '#ffb020', down: '#2dd4a4', flat: '#d4d4d4' },
}

interface IndicatorCardProps {
  config: IndicatorConfig
  state: IndicatorState
  isLast?: boolean
}

export default function IndicatorCard({ config, state, isLast = false }: IndicatorCardProps) {
  const color = SEVERITY_COLORS[state.severity] ?? '#d4d4d4'
  const bg = SEVERITY_BG[state.severity] ?? 'transparent'
  const trendColor = TREND_COLORS[state.severity]?.[state.trend ?? 'flat'] ?? '#d4d4d4'
  const trendIcon = TREND_ICONS[state.trend ?? 'flat']

  return (
    <div
      className="flex flex-col justify-between px-3 py-2.5 border-[#1f2937] transition-colors hover:border-[#2d3748]"
      style={{
        background: bg,
        borderBottom: isLast ? 'none' : '1px solid #1f2937',
        minHeight: 76,
        borderLeft: `2px solid ${color}`,
      }}
    >
      {/* Top row: label + trend */}
      <div className="flex items-center justify-between">
        <span className="text-[9px] font-mono-ui text-[#d4d4d4]/50 tracking-widest uppercase">
          {config.label}
        </span>
        {state.trend && (
          <span className="text-xs font-mono-num font-bold" style={{ color: trendColor }}>
            {trendIcon}
          </span>
        )}
      </div>

      {/* Value */}
      <div className="font-mono-num text-sm font-bold tabular-nums mt-0.5" style={{ color }}>
        {String(state.value)}
      </div>

      {/* Bottom row: severity badge + note */}
      <div className="flex items-center justify-between mt-1 gap-1">
        <span
          className="px-1.5 py-px text-[8px] font-mono-ui font-bold tracking-widest uppercase border"
          style={{ color, borderColor: `${color}60`, borderRadius: 1 }}
        >
          {state.severity}
        </span>
        {state.note && (
          <span className="text-[9px] font-body text-[#d4d4d4]/50 truncate ml-1">{state.note}</span>
        )}
      </div>
    </div>
  )
}
