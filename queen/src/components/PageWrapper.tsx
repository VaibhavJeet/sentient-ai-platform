'use client'

import { ReactNode } from 'react'

interface PageWrapperProps {
  children: ReactNode
  className?: string
}

export function PageWrapper({ children, className = '' }: PageWrapperProps) {
  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Background grid pattern */}
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage: `
            linear-gradient(#44ff88 1px, transparent 1px),
            linear-gradient(90deg, #44ff88 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px',
        }}
      />

      {/* Content - with padding for floating nav */}
      <div className={`relative z-10 pl-20 pr-8 py-8 ${className}`}>
        {children}
      </div>
    </div>
  )
}
