'use client'

import IndicatorCard from './IndicatorCard'
import type { Config, Situation } from '@/lib/schemas'

interface IndicatorStackProps {
  config: Config
  situation: Situation
}

export default function IndicatorStack({ config, situation }: IndicatorStackProps) {
  const visible = config.indicators.slice(0, 6)

  return (
    <div className="flex flex-col border border-[#1f2937] h-full" style={{ borderRadius: 2 }}>
      <div className="px-3 py-2 border-b border-[#1f2937]">
        <span className="text-[9px] font-mono-ui text-[#d4d4d4]/40 tracking-widest uppercase">
          Indicators
        </span>
      </div>
      <div className="flex-1 flex flex-col divide-y divide-[#1f2937] overflow-hidden">
        {visible.map((indicatorConfig, idx) => {
          const state = situation.indicators[indicatorConfig.id]
          if (!state) return null
          return (
            <IndicatorCard
              key={indicatorConfig.id}
              config={indicatorConfig}
              state={state}
              isLast={idx === visible.length - 1}
            />
          )
        })}
      </div>
    </div>
  )
}
