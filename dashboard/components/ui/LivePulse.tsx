'use client'

export default function LivePulse({ size = 8 }: { size?: number }) {
  return (
    <span className="relative inline-flex items-center justify-center" style={{ width: size * 3, height: size * 3 }}>
      {/* Halo */}
      <span
        className="absolute rounded-full bg-[#4fc3ff] opacity-0"
        style={{
          width: size,
          height: size,
          animation: 'pulse-halo 1.4s ease-out infinite',
        }}
      />
      {/* Core dot */}
      <span
        className="relative rounded-full bg-[#4fc3ff] z-10"
        style={{ width: size, height: size }}
      />
    </span>
  )
}
