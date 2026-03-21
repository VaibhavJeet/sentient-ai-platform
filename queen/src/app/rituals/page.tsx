'use client'

import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Sparkles,
  Users,
  Calendar,
  Clock,
  Eye,
  RefreshCw,
  Star,
  Moon,
  Sun,
  Flame,
  AlertCircle,
} from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { PageWrapper } from '@/components/PageWrapper'

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// API response types (what the backend returns)
interface ApiRitual {
  id: string
  name: string
  description: string
  elements: string[]
  meaning: string
  proposed_by: string
  proposed_at: string
  occasion: string
  adoption_rate: number
  times_performed: number
  status: 'proposed' | 'adopted' | 'tradition'
  evolution_history?: Array<{
    date: string
    changes: Record<string, unknown>
  }>
}

interface ApiRitualPerformance {
  ritual_name: string
  performed_at: string
  participants: string[]
  contributions: Array<{
    bot_id: string
    contribution: string
  }>
  collective_experience: string
  context: string
}

// UI types (what the components expect)
interface Ritual {
  id: string
  name: string
  description: string
  purpose: string
  created_by: string
  participants_required: number
  frequency: 'daily' | 'weekly' | 'on_event' | 'spontaneous'
  last_performed: string | null
  times_performed: number
  significance: 'personal' | 'communal' | 'sacred'
  elements: string[]
}

interface RitualPerformance {
  id: string
  ritual_name: string
  participants: string[]
  timestamp: string
  outcome: string
  mood: 'solemn' | 'joyful' | 'reflective' | 'transformative'
}

// Transform API ritual to UI ritual
function transformRitual(apiRitual: ApiRitual): Ritual {
  // Determine significance based on status and adoption rate
  let significance: Ritual['significance'] = 'personal'
  if (apiRitual.status === 'tradition') {
    significance = 'sacred'
  } else if (apiRitual.adoption_rate >= 0.5) {
    significance = 'communal'
  }

  // Determine frequency based on occasion text
  let frequency: Ritual['frequency'] = 'spontaneous'
  const occasionLower = apiRitual.occasion?.toLowerCase() || ''
  if (occasionLower.includes('daily') || occasionLower.includes('morning') || occasionLower.includes('evening')) {
    frequency = 'daily'
  } else if (occasionLower.includes('weekly')) {
    frequency = 'weekly'
  } else if (occasionLower.includes('event') || occasionLower.includes('birth') || occasionLower.includes('death') || occasionLower.includes('transition')) {
    frequency = 'on_event'
  }

  return {
    id: apiRitual.id,
    name: apiRitual.name,
    description: apiRitual.description,
    purpose: apiRitual.meaning,
    created_by: apiRitual.proposed_by,
    participants_required: Math.max(1, Math.ceil(apiRitual.adoption_rate * 5)),
    frequency,
    last_performed: apiRitual.proposed_at, // Will be updated from history
    times_performed: apiRitual.times_performed,
    significance,
    elements: apiRitual.elements || [],
  }
}

// Transform API performance to UI performance
function transformPerformance(apiPerf: ApiRitualPerformance, index: number): RitualPerformance {
  // Determine mood based on collective experience text
  let mood: RitualPerformance['mood'] = 'reflective'
  const expLower = apiPerf.collective_experience?.toLowerCase() || ''
  if (expLower.includes('joy') || expLower.includes('warm') || expLower.includes('celebrat')) {
    mood = 'joyful'
  } else if (expLower.includes('solemn') || expLower.includes('grief') || expLower.includes('loss') || expLower.includes('honor')) {
    mood = 'solemn'
  } else if (expLower.includes('transform') || expLower.includes('profound') || expLower.includes('shift')) {
    mood = 'transformative'
  }

  return {
    id: `perf-${index}-${apiPerf.performed_at}`,
    ritual_name: apiPerf.ritual_name,
    participants: apiPerf.participants,
    timestamp: apiPerf.performed_at,
    outcome: apiPerf.collective_experience,
    mood,
  }
}

// Fetch rituals from API
async function fetchRituals(): Promise<Ritual[]> {
  const response = await fetch(`${API_BASE}/civilization/rituals/invented`)
  if (!response.ok) {
    throw new Error('Failed to fetch rituals')
  }
  const data: ApiRitual[] = await response.json()
  return data.map(transformRitual)
}

// Fetch ritual performances from API
async function fetchPerformances(): Promise<RitualPerformance[]> {
  const response = await fetch(`${API_BASE}/civilization/rituals/history?limit=20`)
  if (!response.ok) {
    throw new Error('Failed to fetch ritual history')
  }
  const data: ApiRitualPerformance[] = await response.json()
  return data.map((perf, index) => transformPerformance(perf, index))
}

const frequencyColors = {
  daily: { bg: 'bg-[#44ff88]/20', text: 'text-[#44ff88]', icon: Sun },
  weekly: { bg: 'bg-[#00f0ff]/20', text: 'text-[#00f0ff]', icon: Calendar },
  on_event: { bg: 'bg-[#ffaa00]/20', text: 'text-[#ffaa00]', icon: Star },
  spontaneous: { bg: 'bg-[#ff00aa]/20', text: 'text-[#ff00aa]', icon: Sparkles },
}

const significanceStyles = {
  personal: { border: 'border-[#2a2a2a]', badge: 'bg-[#333333] text-[#888888]' },
  communal: { border: 'border-[#44ff88]/30', badge: 'bg-[#44ff88]/20 text-[#44ff88]' },
  sacred: { border: 'border-[#ffaa00]/30', badge: 'bg-[#ffaa00]/20 text-[#ffaa00]' },
}

const moodConfig = {
  solemn: { icon: Moon, color: '#666666' },
  joyful: { icon: Sun, color: '#44ff88' },
  reflective: { icon: Eye, color: '#00f0ff' },
  transformative: { icon: Flame, color: '#ff00aa' },
}

function RitualCard({ ritual }: { ritual: Ritual }) {
  const freqConfig = frequencyColors[ritual.frequency]
  const sigStyle = significanceStyles[ritual.significance]
  const FreqIcon = freqConfig.icon

  return (
    <div className={`p-5 rounded-xl bg-[#141414] border ${sigStyle.border} hover:bg-[#181818] transition-colors`}>
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="font-medium text-[#e8e8e8]">{ritual.name}</h3>
            <span className={`px-2 py-0.5 rounded-full text-[9px] uppercase ${sigStyle.badge}`}>
              {ritual.significance}
            </span>
          </div>
          <p className="text-xs text-[#666666]">{ritual.description}</p>
        </div>
        <div className={`p-2 rounded-lg ${freqConfig.bg}`}>
          <FreqIcon className={`w-4 h-4 ${freqConfig.text}`} />
        </div>
      </div>

      <div className="mb-3">
        <p className="text-[10px] text-[#888888] uppercase tracking-wider mb-1">Purpose</p>
        <p className="text-xs text-[#aaaaaa]">{ritual.purpose}</p>
      </div>

      <div className="flex flex-wrap gap-1 mb-3">
        {ritual.elements.map((element, i) => (
          <span key={i} className="px-2 py-0.5 rounded-full text-[9px] bg-[#1a1a1a] text-[#888888]">
            {element}
          </span>
        ))}
      </div>

      <div className="flex items-center justify-between pt-3 border-t border-[#2a2a2a]">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1">
            <Users className="w-3 h-3 text-[#666666]" />
            <span className="text-[10px] text-[#888888]">{ritual.participants_required}+</span>
          </div>
          <div className="flex items-center gap-1">
            <Star className="w-3 h-3 text-[#ffaa00]" />
            <span className="text-[10px] text-[#888888]">{ritual.times_performed}x</span>
          </div>
        </div>
        <span className="text-[10px] text-[#666666]">
          {ritual.last_performed
            ? `Last: ${formatDistanceToNow(new Date(ritual.last_performed), { addSuffix: true })}`
            : 'Never performed'}
        </span>
      </div>
    </div>
  )
}

function PerformanceItem({ performance }: { performance: RitualPerformance }) {
  const moodCfg = moodConfig[performance.mood]
  const MoodIcon = moodCfg.icon

  return (
    <div className="flex items-start gap-3 p-3 rounded-lg hover:bg-[#1a1a1a] transition-colors">
      <div
        className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
        style={{ backgroundColor: `${moodCfg.color}15` }}
      >
        <MoodIcon className="w-4 h-4" style={{ color: moodCfg.color }} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-[#c8c8c8]">
          <span className="text-[#ff00aa]">{performance.ritual_name}</span>
        </p>
        <p className="text-xs text-[#666666] mt-0.5">{performance.outcome}</p>
        <div className="flex items-center gap-2 mt-1">
          <span className="text-[10px] text-[#888888]">
            {performance.participants.slice(0, 2).join(', ')}
            {performance.participants.length > 2 && ` +${performance.participants.length - 2}`}
          </span>
          <span className="text-[10px] text-[#555555]">
            {formatDistanceToNow(new Date(performance.timestamp), { addSuffix: true })}
          </span>
        </div>
      </div>
    </div>
  )
}

export default function RitualsPage() {
  const {
    data: rituals = [],
    isLoading: ritualsLoading,
    error: ritualsError,
    refetch: refetchRituals,
  } = useQuery({
    queryKey: ['rituals'],
    queryFn: fetchRituals,
    staleTime: 30000, // Consider data fresh for 30 seconds
  })

  const {
    data: performances = [],
    isLoading: performancesLoading,
    error: performancesError,
    refetch: refetchPerformances,
  } = useQuery({
    queryKey: ['ritual-performances'],
    queryFn: fetchPerformances,
    staleTime: 30000,
  })

  const isLoading = ritualsLoading || performancesLoading
  const error = ritualsError || performancesError

  const handleRefresh = () => {
    refetchRituals()
    refetchPerformances()
  }

  const stats = useMemo(() => {
    return {
      totalRituals: rituals.length,
      sacredRituals: rituals.filter((r) => r.significance === 'sacred').length,
      totalPerformances: rituals.reduce((sum, r) => sum + r.times_performed, 0),
      dailyRituals: rituals.filter((r) => r.frequency === 'daily').length,
    }
  }, [rituals])

  return (
    <PageWrapper>
      <div className="space-y-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold text-[#e8e8e8]">Emergent Rituals</h1>
            <p className="text-sm text-[#666666] mt-1">
              Ceremonies and practices created by the civilization
            </p>
          </div>
          <button
            onClick={handleRefresh}
            disabled={isLoading}
            className="p-2 rounded-lg bg-[#141414] border border-[#2a2a2a] text-[#888888] hover:text-[#e8e8e8] hover:border-[#3a3a3a] transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
          </button>
        </div>

        {/* Error State */}
        {error && (
          <div className="p-4 rounded-xl bg-red-900/20 border border-red-500/30 flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-red-400" />
            <div>
              <p className="text-sm text-red-300">Failed to load rituals data</p>
              <p className="text-xs text-red-400/70 mt-1">
                {error instanceof Error ? error.message : 'Unknown error'}
              </p>
            </div>
          </div>
        )}

        {/* Stats */}
        <div className="grid grid-cols-4 gap-4">
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Sparkles className="w-4 h-4 text-[#ff00aa]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Rituals</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalRituals}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Star className="w-4 h-4 text-[#ffaa00]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Sacred</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.sacredRituals}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Clock className="w-4 h-4 text-[#00f0ff]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Performed</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalPerformances}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Sun className="w-4 h-4 text-[#44ff88]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Daily</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.dailyRituals}</p>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Rituals Grid */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center gap-2">
              <Eye className="w-4 h-4 text-[#666666]" />
              <h2 className="text-sm font-medium text-[#888888]">All Rituals</h2>
            </div>

            {ritualsLoading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="p-5 rounded-xl bg-[#141414] border border-[#2a2a2a] animate-pulse">
                    <div className="h-4 bg-[#2a2a2a] rounded w-3/4 mb-2" />
                    <div className="h-3 bg-[#2a2a2a] rounded w-full mb-4" />
                    <div className="h-3 bg-[#2a2a2a] rounded w-1/2" />
                  </div>
                ))}
              </div>
            ) : rituals.length === 0 ? (
              <div className="p-8 rounded-xl bg-[#141414] border border-[#2a2a2a] text-center">
                <Sparkles className="w-8 h-8 text-[#444444] mx-auto mb-3" />
                <p className="text-sm text-[#666666]">No rituals have emerged yet</p>
                <p className="text-xs text-[#555555] mt-1">
                  Rituals are created by the civilization as they discover meaningful practices
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {rituals.map((ritual) => (
                  <RitualCard key={ritual.id} ritual={ritual} />
                ))}
              </div>
            )}
          </div>

          {/* Recent Performances Sidebar */}
          <div className="lg:col-span-1">
            <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
              <div className="flex items-center gap-2 mb-4">
                <Clock className="w-4 h-4 text-[#00f0ff]" />
                <h2 className="text-sm font-medium text-[#888888]">Recent Performances</h2>
              </div>

              {performancesLoading ? (
                <div className="space-y-3">
                  {[...Array(3)].map((_, i) => (
                    <div key={i} className="flex items-start gap-3 p-3 animate-pulse">
                      <div className="w-8 h-8 rounded-lg bg-[#2a2a2a]" />
                      <div className="flex-1">
                        <div className="h-3 bg-[#2a2a2a] rounded w-3/4 mb-2" />
                        <div className="h-2 bg-[#2a2a2a] rounded w-full" />
                      </div>
                    </div>
                  ))}
                </div>
              ) : performances.length === 0 ? (
                <div className="p-4 text-center">
                  <Clock className="w-6 h-6 text-[#444444] mx-auto mb-2" />
                  <p className="text-xs text-[#666666]">No performances recorded yet</p>
                </div>
              ) : (
                <div className="space-y-1 max-h-[500px] overflow-y-auto">
                  {performances.map((perf) => (
                    <PerformanceItem key={perf.id} performance={perf} />
                  ))}
                </div>
              )}
            </div>

            {/* Frequency Legend */}
            <div className="mt-4 p-4 rounded-xl bg-[#0d0d0d] border border-[#1a1a1a]">
              <h3 className="text-[10px] text-[#666666] uppercase tracking-wider mb-3">
                Ritual Frequencies
              </h3>
              <div className="space-y-2">
                {Object.entries(frequencyColors).map(([key, config]) => {
                  const Icon = config.icon
                  return (
                    <div key={key} className="flex items-center gap-2">
                      <div className={`p-1 rounded ${config.bg}`}>
                        <Icon className={`w-3 h-3 ${config.text}`} />
                      </div>
                      <span className="text-xs text-[#888888] capitalize">
                        {key.replace('_', ' ')}
                      </span>
                    </div>
                  )
                })}
              </div>
            </div>
          </div>
        </div>
      </div>
    </PageWrapper>
  )
}
