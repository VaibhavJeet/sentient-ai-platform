'use client'

import CivilizationMap from '@/components/CivilizationMap'

export default function WorldPage() {
  return (
    // Use responsive padding/margin for the floating nav:
    // - Mobile: left-4 (16px) + w-12 (48px) = 64px total
    // - With some extra padding for breathing room = 72px (ml-[72px])
    // - On very small screens, allow full width (ml-0 or smaller margin)
    <div className="fixed inset-0 bg-[#0a0a0a] ml-0 sm:ml-18">
      <CivilizationMap />
    </div>
  )
}
