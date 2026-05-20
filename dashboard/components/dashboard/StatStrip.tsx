'use client'

import StatCard from './StatCard'
import type { Config, Situation } from '@/lib/schemas'

interface StatStripProps {
  config: Config
  situation: Situation
}

export default function StatStrip({ config, situation }: StatStripProps) {
  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-[1px] border border-[#1f2937]" style={{ borderRadius: 2 }}>
      {config.metrics.map((metricConfig, idx) => {
        const state = situation.metrics[metricConfig.id]
        if (!state) return null
        return (
          <div
            key={metricConfig.id}
            className="border-[#1f2937]"
            style={{
              borderRight: idx < config.metrics.length - 1 ? '1px solid #1f2937' : 'none',
            }}
          >
            <StatCard config={metricConfig} state={state} />
          </div>
        )
      })}
    </div>
  )
}
