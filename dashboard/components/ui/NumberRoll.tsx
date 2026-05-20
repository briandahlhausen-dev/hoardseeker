'use client'

import { useEffect, useRef, useState } from 'react'

interface NumberRollProps {
  value: string | number
  className?: string
}

export default function NumberRoll({ value, className = '' }: NumberRollProps) {
  const [displayValue, setDisplayValue] = useState(value)
  const [isAnimating, setIsAnimating] = useState(false)
  const prevValue = useRef(value)

  useEffect(() => {
    if (prevValue.current !== value) {
      setIsAnimating(true)
      setDisplayValue(value)
      prevValue.current = value
      const t = setTimeout(() => setIsAnimating(false), 300)
      return () => clearTimeout(t)
    }
  }, [value])

  return (
    <span
      className={`inline-block overflow-hidden font-mono-num tabular-nums ${className}`}
      style={{
        animation: isAnimating ? 'digit-roll-in 0.2s ease-out, digit-flash 0.2s ease-out' : 'none',
      }}
    >
      {displayValue}
    </span>
  )
}
