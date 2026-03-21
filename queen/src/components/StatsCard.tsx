import { LucideIcon } from 'lucide-react'

interface StatsCardProps {
  title: string
  value: number | string
  icon: LucideIcon
  trend?: string
  subtitle?: string
  loading?: boolean
  compact?: boolean
}

export function StatsCard({
  title,
  value,
  icon: Icon,
  trend,
  subtitle,
  loading,
  compact
}: StatsCardProps) {
  if (compact) {
    return (
      <div className="bg-[#141414] border border-[#2a2a2a] rounded-lg p-4">
        <div className="flex items-center gap-2 text-[#666666] mb-1">
          <Icon className="w-4 h-4" />
          <span className="text-sm">{title}</span>
        </div>
        <p className="text-2xl font-bold text-foreground">
          {loading ? '...' : typeof value === 'number' ? value.toLocaleString() : value}
        </p>
      </div>
    )
  }

  return (
    <div className="bg-[#141414] border border-[#2a2a2a] rounded-xl p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-[#666666]">{title}</p>
          <p className="text-3xl font-bold mt-1 text-foreground">
            {loading ? '...' : typeof value === 'number' ? value.toLocaleString() : value}
          </p>
          {subtitle && (
            <p className="text-sm text-[#555555] mt-1">{subtitle}</p>
          )}
          {trend && (
            <p className={`text-sm mt-1 ${
              trend.startsWith('+') ? 'text-[#44ff88]' : 'text-[#ff4444]'
            }`}>
              {trend} from yesterday
            </p>
          )}
        </div>
        <div className="w-12 h-12 bg-[#ff00aa]/20 rounded-full flex items-center justify-center">
          <Icon className="w-6 h-6 text-[#ff00aa]" />
        </div>
      </div>
    </div>
  )
}
