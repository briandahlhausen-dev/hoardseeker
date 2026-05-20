'use client'

interface SparklineProps {
  data: number[]
  width?: number
  height?: number
  color?: string
  strokeWidth?: number
}

export default function Sparkline({
  data,
  width = 80,
  height = 24,
  color = '#4fc3ff',
  strokeWidth = 1.5,
}: SparklineProps) {
  if (!data || data.length < 2) return null

  const min = Math.min(...data)
  const max = Math.max(...data)
  const range = max - min || 1

  const pad = 2
  const w = width - pad * 2
  const h = height - pad * 2

  const points = data
    .map((v, i) => {
      const x = pad + (i / (data.length - 1)) * w
      const y = pad + h - ((v - min) / range) * h
      return `${x},${y}`
    })
    .join(' ')

  return (
    <svg
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      fill="none"
      className="overflow-visible"
      aria-hidden="true"
    >
      <polyline
        points={points}
        stroke={color}
        strokeWidth={strokeWidth}
        strokeLinejoin="round"
        strokeLinecap="round"
        fill="none"
        opacity={0.7}
      />
      {/* Latest value dot */}
      {(() => {
        const last = data[data.length - 1]
        const x = pad + w
        const y = pad + h - ((last - min) / range) * h
        return <circle cx={x} cy={y} r={2} fill={color} />
      })()}
    </svg>
  )
}
