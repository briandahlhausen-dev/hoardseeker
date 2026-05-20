'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import NewsModal from './NewsModal'
import SourcesPanel from './SourcesPanel'
import type { News, NewsItem, NewsSource } from '@/lib/schemas'

const CATEGORY_COLORS: Record<string, string> = {
  official: '#4fc3ff',
  field: '#ffb020',
  response: '#2dd4a4',
  spread: '#ff2e4c',
  intelligence: '#a78bfa',
  milestone: '#ffffff',
}

interface NewsFeedProps {
  news: News
  sources: NewsSource[]
}

export default function NewsFeed({ news, sources }: NewsFeedProps) {
  const [activeIndex, setActiveIndex] = useState(0)
  const [selectedItem, setSelectedItem] = useState<NewsItem | null>(null)
  const [sourcesOpen, setSourcesOpen] = useState(false)
  const items = news.items

  // Rotate items every 8 seconds
  useEffect(() => {
    if (items.length <= 1) return
    const id = setInterval(() => {
      setActiveIndex((i) => (i + 1) % items.length)
    }, 8000)
    return () => clearInterval(id)
  }, [items.length])

  const activeItem = items[activeIndex]
  const marqueItems = items.slice(0, 5)

  const marqueText = marqueItems
    .map((item) => `${item.source.toUpperCase()}: ${item.headline}`)
    .join('    ·    ')

  return (
    <>
      <div
        className="border-t border-[#1f2937] shrink-0"
        style={{ background: '#0a0d12' }}
      >
        {/* Top sub-row: rotating featured item */}
        <div className="flex items-center border-b border-[#1f2937]" style={{ height: 52 }}>
          {/* Source badge */}
          <div
            className="shrink-0 flex items-center justify-center px-3 border-r border-[#1f2937] h-full"
            style={{ minWidth: 100 }}
          >
            <div className="text-center">
              <div className="text-[8px] font-mono-ui text-[#d4d4d4]/30 tracking-widest uppercase">
                SOURCE
              </div>
              <div
                className="text-[10px] font-mono-ui font-bold mt-0.5"
                style={{ color: CATEGORY_COLORS[activeItem?.category ?? 'official'] ?? '#4fc3ff' }}
              >
                {activeItem?.source ?? '—'}
              </div>
            </div>
          </div>

          {/* Rotating headline */}
          <div className="flex-1 overflow-hidden px-4 cursor-pointer" onClick={() => activeItem && setSelectedItem(activeItem)}>
            <AnimatePresence mode="wait">
              <motion.div
                key={activeIndex}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8 }}
                transition={{ duration: 0.3 }}
              >
                <div className="text-[10px] font-mono-ui text-[#ffffff] font-bold leading-snug line-clamp-2 hover:text-[#4fc3ff] transition-colors">
                  {activeItem?.headline}
                </div>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right: timestamp + sources link + index */}
          <div className="shrink-0 flex flex-col items-end justify-center px-3 border-l border-[#1f2937] h-full gap-1">
            <div className="text-[9px] font-mono-num text-[#d4d4d4]/40 tabular-nums">
              {activeItem && new Date(activeItem.publishedAt).toLocaleString('en-GB', {
                timeZone: 'UTC',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
              })}
            </div>
            <button
              onClick={() => setSourcesOpen(true)}
              className="text-[8px] font-mono-ui text-[#4fc3ff]/60 hover:text-[#4fc3ff] tracking-widest uppercase transition-colors"
            >
              SOURCES
            </button>
            <div className="text-[8px] font-mono-ui text-[#d4d4d4]/20">
              {activeIndex + 1}/{items.length}
            </div>
          </div>
        </div>

        {/* Bottom sub-row: marquee */}
        <div
          className="flex items-center overflow-hidden"
          style={{ height: 28 }}
        >
          <div
            className="shrink-0 px-2 border-r border-[#1f2937] h-full flex items-center"
            style={{ background: 'rgba(79,195,255,0.08)' }}
          >
            <span className="text-[8px] font-mono-ui text-[#4fc3ff] tracking-widest uppercase">
              LIVE
            </span>
          </div>
          <div className="flex-1 overflow-hidden">
            <div
              className="flex items-center whitespace-nowrap text-[10px] font-body text-[#d4d4d4]/60"
              style={{
                animation: 'ticker-scroll 80s linear infinite',
                width: 'max-content',
              }}
            >
              <span>{marqueText}&nbsp;&nbsp;&nbsp;·&nbsp;&nbsp;&nbsp;{marqueText}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      <NewsModal item={selectedItem} onClose={() => setSelectedItem(null)} />
      <SourcesPanel sources={sources} isOpen={sourcesOpen} onClose={() => setSourcesOpen(false)} />
    </>
  )
}
