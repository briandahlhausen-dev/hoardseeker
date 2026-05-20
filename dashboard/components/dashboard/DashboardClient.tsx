'use client'

import dynamic from 'next/dynamic'
import { useState } from 'react'
import Header from './Header'
import StatStrip from './StatStrip'
import IndicatorStack from './IndicatorStack'
import Timeline from './Timeline'
import NewsFeed from './NewsFeed'
import LocationDrawer from './LocationDrawer'
import type { Config, Situation, TimelineEvent, News, Location } from '@/lib/schemas'

const MapView = dynamic(() => import('./MapView'), {
  ssr: false,
  loading: () => (
    <div className="w-full h-full border border-[#1f2937] flex items-center justify-center bg-[#0a0d12]" style={{ borderRadius: 2 }}>
      <span className="text-[10px] font-mono-ui text-[#4fc3ff] tracking-widest animate-pulse">
        LOADING MAP...
      </span>
    </div>
  ),
})

interface DashboardClientProps {
  config: Config
  situation: Situation
  timeline: TimelineEvent[]
  news: News
}

export default function DashboardClient({
  config,
  situation,
  timeline,
  news,
}: DashboardClientProps) {
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null)

  return (
    <div
      className="flex flex-col min-h-screen"
      style={{ background: '#0a0d12' }}
    >
      {/* ROW 1 — Header */}
      <Header config={config} situation={situation} />

      {/* Main content area */}
      <div className="flex flex-col flex-1 gap-2 p-2 overflow-hidden">

        {/* ROW 2 — Stat strip */}
        <div className="shrink-0">
          <StatStrip config={config} situation={situation} />
        </div>

        {/* ROW 3 — Map + Indicators */}
        <div
          className="grid gap-2 flex-1"
          style={{
            gridTemplateColumns: '1fr',
            minHeight: 460,
          }}
        >
          {/* 12-col grid wrapper */}
          <div className="grid grid-cols-12 gap-2 h-full">
            {/* Map — 8 cols */}
            <div className="col-span-12 lg:col-span-8 relative" style={{ minHeight: 400 }}>
              <MapView
                config={config}
                situation={situation}
                onLocationSelect={setSelectedLocation}
              />
              <LocationDrawer
                location={selectedLocation}
                onClose={() => setSelectedLocation(null)}
              />
            </div>

            {/* Indicator stack — 4 cols */}
            <div className="col-span-12 lg:col-span-4">
              <IndicatorStack config={config} situation={situation} />
            </div>
          </div>
        </div>

        {/* ROW 4 — Timeline */}
        <div className="shrink-0 relative">
          <Timeline events={timeline} />
        </div>
      </div>

      {/* ROW 5 — News feed (fixed bottom) */}
      <NewsFeed news={news} sources={config.newsSources} />
    </div>
  )
}
