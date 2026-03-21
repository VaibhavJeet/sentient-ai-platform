'use client'

import { ReactNode } from 'react'

interface SkeletonProps {
  className?: string
  variant?: 'default' | 'circular' | 'rounded'
}

/**
 * Basic skeleton building block
 */
export function Skeleton({ className = '', variant = 'default' }: SkeletonProps) {
  const variantClasses = {
    default: 'rounded',
    circular: 'rounded-full',
    rounded: 'rounded-xl',
  }

  return (
    <div
      className={`
        bg-gradient-to-r from-[#252538] via-[#303048] to-[#252538]
        bg-[length:200%_100%]
        animate-[shimmer_1.5s_ease-in-out_infinite]
        ${variantClasses[variant]}
        ${className}
      `}
    />
  )
}

/**
 * Skeleton card for bot grid view
 */
export function BotCardSkeleton() {
  return (
    <div className="relative overflow-hidden rounded-xl bg-gradient-to-br from-[#252538]/80 to-[#12121a]/90 backdrop-blur-xl border border-[#00f0ff]/20 p-4">
      {/* Avatar */}
      <div className="flex items-center gap-3 mb-4">
        <Skeleton className="w-12 h-12" variant="circular" />
        <div className="flex-1">
          <Skeleton className="h-4 w-24 mb-2" />
          <Skeleton className="h-3 w-16" />
        </div>
        <Skeleton className="w-8 h-8" variant="circular" />
      </div>

      {/* Bio */}
      <Skeleton className="h-3 w-full mb-2" />
      <Skeleton className="h-3 w-3/4 mb-4" />

      {/* Stats row */}
      <div className="flex items-center gap-4 mb-4">
        <Skeleton className="h-4 w-16" />
        <Skeleton className="h-4 w-16" />
        <Skeleton className="h-4 w-16" />
      </div>

      {/* Traits */}
      <div className="flex flex-wrap gap-2">
        <Skeleton className="h-6 w-20 rounded-full" />
        <Skeleton className="h-6 w-16 rounded-full" />
        <Skeleton className="h-6 w-24 rounded-full" />
      </div>
    </div>
  )
}

/**
 * Skeleton row for bot list view
 */
export function BotListRowSkeleton() {
  return (
    <div className="flex items-center gap-4 p-4 rounded-xl bg-gradient-to-br from-[#252538]/80 to-[#12121a]/90 backdrop-blur-xl border border-[#00f0ff]/10">
      <Skeleton className="w-10 h-10" variant="circular" />
      <div className="flex-1 min-w-0">
        <Skeleton className="h-4 w-32 mb-2" />
        <Skeleton className="h-3 w-24" />
      </div>
      <Skeleton className="h-6 w-16 rounded-full" />
      <div className="hidden md:flex items-center gap-6">
        <Skeleton className="h-4 w-12" />
        <Skeleton className="h-4 w-12" />
        <Skeleton className="h-4 w-12" />
      </div>
      <Skeleton className="h-8 w-20 rounded-lg" />
    </div>
  )
}

/**
 * Skeleton for stat cards
 */
export function StatCardSkeleton() {
  return (
    <div className="relative overflow-hidden rounded-xl bg-gradient-to-br from-[#252538]/80 to-[#12121a]/90 backdrop-blur-xl border border-[#00f0ff]/20 p-6">
      <div className="flex items-start justify-between">
        <div>
          <Skeleton className="h-4 w-20 mb-3" />
          <Skeleton className="h-9 w-24 mb-2" />
          <Skeleton className="h-4 w-32" />
        </div>
        <Skeleton className="w-12 h-12" variant="rounded" />
      </div>
    </div>
  )
}

/**
 * Skeleton for chart areas
 */
export function ChartSkeleton({ height = 'h-[300px]' }: { height?: string }) {
  return (
    <div className={`relative overflow-hidden rounded-xl bg-gradient-to-br from-[#252538]/80 to-[#12121a]/90 backdrop-blur-xl border border-[#00f0ff]/20 p-6 ${height}`}>
      <Skeleton className="h-5 w-32 mb-4" />
      <div className="flex items-end justify-between h-[calc(100%-60px)] gap-2">
        <Skeleton className="w-8 h-[30%]" />
        <Skeleton className="w-8 h-[50%]" />
        <Skeleton className="w-8 h-[70%]" />
        <Skeleton className="w-8 h-[45%]" />
        <Skeleton className="w-8 h-[80%]" />
        <Skeleton className="w-8 h-[60%]" />
        <Skeleton className="w-8 h-[40%]" />
        <Skeleton className="w-8 h-[55%]" />
        <Skeleton className="w-8 h-[75%]" />
        <Skeleton className="w-8 h-[50%]" />
      </div>
    </div>
  )
}

/**
 * Skeleton for post table rows
 */
export function PostRowSkeleton() {
  return (
    <tr className="border-b border-[#252538]">
      <td className="px-4 py-3">
        <Skeleton className="w-4 h-4" />
      </td>
      <td className="px-4 py-3">
        <Skeleton className="h-4 w-28" />
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <Skeleton className="w-8 h-8" variant="circular" />
          <div>
            <Skeleton className="h-4 w-24 mb-1" />
            <Skeleton className="h-3 w-16" />
          </div>
        </div>
      </td>
      <td className="px-4 py-3">
        <Skeleton className="h-3 w-48 mb-1" />
        <Skeleton className="h-3 w-32" />
      </td>
      <td className="px-4 py-3">
        <Skeleton className="h-4 w-24" />
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-3">
          <Skeleton className="h-4 w-10" />
          <Skeleton className="h-4 w-10" />
        </div>
      </td>
      <td className="px-4 py-3">
        <Skeleton className="h-4 w-20" />
      </td>
      <td className="px-4 py-3">
        <Skeleton className="h-6 w-16 rounded-full" />
      </td>
      <td className="px-4 py-3">
        <div className="flex items-center gap-2">
          <Skeleton className="w-8 h-8" variant="circular" />
          <Skeleton className="w-8 h-8" variant="circular" />
          <Skeleton className="w-8 h-8" variant="circular" />
        </div>
      </td>
    </tr>
  )
}

/**
 * Skeleton for log entries
 */
export function LogEntrySkeleton() {
  return (
    <div className="flex items-start gap-3 px-4 py-3 border-b border-[#252538]/50">
      <Skeleton className="w-8 h-8" variant="circular" />
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-3 mb-1">
          <Skeleton className="h-4 w-12 rounded" />
          <Skeleton className="h-4 w-16 rounded" />
          <Skeleton className="h-3 w-24" />
        </div>
        <Skeleton className="h-4 w-full max-w-md mb-1" />
        <Skeleton className="h-3 w-48" />
      </div>
      <Skeleton className="h-4 w-12" />
    </div>
  )
}

/**
 * Skeleton for performer/leaderboard cards
 */
export function PerformerCardSkeleton() {
  return (
    <div className="relative overflow-hidden rounded-xl bg-gradient-to-br from-[#252538]/80 to-[#12121a]/90 backdrop-blur-xl border border-[#00f0ff]/20 p-4">
      <Skeleton className="h-5 w-28 mb-4" />
      <div className="space-y-3">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="flex items-center gap-3">
            <Skeleton className="w-6 h-6" variant="circular" />
            <Skeleton className="w-8 h-8" variant="circular" />
            <div className="flex-1">
              <Skeleton className="h-4 w-24" />
            </div>
            <Skeleton className="h-4 w-12" />
          </div>
        ))}
      </div>
    </div>
  )
}
