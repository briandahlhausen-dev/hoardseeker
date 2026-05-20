'use client'

import { useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import type { NewsItem } from '@/lib/schemas'

const CATEGORY_COLORS: Record<string, string> = {
  official: '#4fc3ff',
  field: '#ffb020',
  response: '#2dd4a4',
  spread: '#ff2e4c',
  intelligence: '#a78bfa',
  milestone: '#ffffff',
}

interface NewsModalProps {
  item: NewsItem | null
  onClose: () => void
}

export default function NewsModal({ item, onClose }: NewsModalProps) {
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', handleKey)
    return () => window.removeEventListener('keydown', handleKey)
  }, [onClose])

  return (
    <AnimatePresence>
      {item && (
        <>
          <motion.div
            key="modal-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50"
            style={{ background: 'rgba(10,13,18,0.85)', backdropFilter: 'blur(2px)' }}
            onClick={onClose}
          />

          <motion.div
            key="modal-panel"
            initial={{ opacity: 0, scale: 0.97, y: 8 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.97, y: 8 }}
            transition={{ type: 'tween', duration: 0.15 }}
            className="fixed z-50 border border-[#2d3748] shadow-2xl overflow-hidden"
            style={{
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%)',
              width: 'min(560px, 90vw)',
              background: '#0f1318',
              borderRadius: 2,
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-start justify-between p-4 border-b border-[#1f2937]">
              <div className="flex-1 pr-4">
                <div className="flex items-center gap-2 mb-2">
                  <span
                    className="px-1.5 py-px text-[8px] font-mono-ui font-bold tracking-widest uppercase border"
                    style={{
                      color: CATEGORY_COLORS[item.category] ?? '#d4d4d4',
                      borderColor: `${CATEGORY_COLORS[item.category] ?? '#d4d4d4'}50`,
                      borderRadius: 1,
                    }}
                  >
                    {item.category}
                  </span>
                  <span className="text-[9px] font-mono-ui text-[#d4d4d4]/40">
                    {item.source}
                  </span>
                  <span className="text-[9px] font-mono-ui text-[#d4d4d4]/30">
                    {new Date(item.publishedAt).toLocaleString('en-GB', {
                      timeZone: 'UTC',
                      month: 'short',
                      day: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit',
                    })} UTC
                  </span>
                </div>
                <h2 className="text-[#ffffff] font-mono-ui text-sm font-bold leading-snug">
                  {item.headline}
                </h2>
              </div>
              <button
                onClick={onClose}
                className="text-[#d4d4d4]/30 hover:text-[#d4d4d4] transition-colors text-xl leading-none shrink-0"
                aria-label="Close"
              >
                ×
              </button>
            </div>

            {/* Summary */}
            <div className="p-4">
              <div className="text-[9px] font-mono-ui text-[#4fc3ff]/60 tracking-widest uppercase mb-2">
                AI Summary
              </div>
              <p className="text-[12px] font-body text-[#d4d4d4]/80 leading-relaxed">
                {item.summary}
              </p>
            </div>

            {/* Footer */}
            <div className="px-4 pb-4">
              <a
                href={item.sourceUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 text-[9px] font-mono-ui text-[#4fc3ff] hover:text-[#ffffff] transition-colors tracking-widest uppercase"
              >
                View Source
                <span>↗</span>
              </a>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
