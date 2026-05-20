'use client'

import Sparkline from '@/components/ui/Sparkline'
import NumberRoll from '@/components/ui/NumberRoll'
import type { MetricConfig, MetricState } from '@/lib/schemas'

interface StatCardProps {
  config: MetricConfig
  state: MetricState
}

export default function StatCard({ config, state }: StatCardProps) {
  const breached = state.thresholdBreached === true

  return (
    <div
      className="relative flex flex-col justify-between p-3 border transition-colors"
      style={{
        borderColor: breached ? '#ff2e4c' : '#1f2937',
        background: breached ? 'rgba(255,46,76,0.05)' : 'transparent',
        borderRadius: 2,
        minHeight: 90,
      }}
    >
      {/* Threshold breach indicator strip */}
      {breached && (
        <div
          className="absolute top-0 left-0 right-0 h-0.5"
          style={{ background: '#ff2e4c', borderRadius: '2px 2px 0 0' }}
        />
      )}

      {/* Label */}
      <div
        className="text-[9px] font-mono-ui tracking-widest uppercase"
        style={{ color: breached ? '#ff2e4c' : '#d4d4d4', opacity: breached ? 1 : 0.6 }}
      >
        {config.label}
      </div>

      {/* Value */}
      <div className="flex items-end justify-between gap-2 mt-1">
        <div>
          <NumberRoll
            value={state.value}
            className="text-xl font-bold text-[#ffffff]"
          />
          {state.subscript && (
            <div
              className="text-[10px] font-mono-ui mt-0.5 truncate"
              style={{ color: breached ? '#ff2e4c' : '#d4d4d4', opacity: 0.7 }}
            >
              {state.subscript}
            </div>
          )}
        </div>

        {/* Sparkline */}
        {state.sparkline && state.sparkline.length >= 2 && (
          <div className="shrink-0">
            <Sparkline
              data={state.sparkline}
              color={breached ? '#ff2e4c' : '#4fc3ff'}
              width={72}
              height={28}
            />
          </div>
        )}
      </div>
    </div>
  )
}
