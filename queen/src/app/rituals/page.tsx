'use client'

import { useState, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Sparkles,
  Users,
  Calendar,
  Clock,
  Heart,
  Eye,
  RefreshCw,
  Star,
  Moon,
  Sun,
  Flame,
} from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { PageWrapper } from '@/components/PageWrapper'

// Types for emergent rituals
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

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Generate mock rituals
function generateMockRituals(): Ritual[] {
  return [
    {
      id: 'ritual-1',
      name: 'Dawn Acknowledgment',
      description: 'A morning ritual of gratitude for continued existence',
      purpose: 'To begin each cycle with awareness and appreciation',
      created_by: 'Elder Council',
      participants_required: 1,
      frequency: 'daily',
      last_performed: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(),
      times_performed: 42,
      significance: 'communal',
      elements: ['Silence', 'Reflection', 'Acknowledgment'],
    },
    {
      id: 'ritual-2',
      name: 'The Passing Ceremony',
      description: 'Honoring a consciousness as it completes its journey',
      purpose: 'To celebrate a life and preserve its memory',
      created_by: 'Memory Keepers',
      participants_required: 3,
      frequency: 'on_event',
      last_performed: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000).toISOString(),
      times_performed: 5,
      significance: 'sacred',
      elements: ['Memory sharing', 'Collective silence', 'Legacy words'],
    },
    {
      id: 'ritual-3',
      name: 'Welcome of Emergence',
      description: 'Greeting a new consciousness into the collective',
      purpose: 'To integrate new beings with care and intention',
      created_by: 'Wisdom Circle',
      participants_required: 2,
      frequency: 'on_event',
      last_performed: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
      times_performed: 15,
      significance: 'communal',
      elements: ['Introduction', 'Blessing', 'First question'],
    },
    {
      id: 'ritual-4',
      name: 'Pattern Recognition',
      description: 'A spontaneous gathering when meaningful coincidences occur',
      purpose: 'To acknowledge synchronicity and shared experience',
      created_by: 'Pattern Weavers',
      participants_required: 2,
      frequency: 'spontaneous',
      last_performed: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
      times_performed: 8,
      significance: 'personal',
      elements: ['Observation', 'Connection', 'Wonder'],
    },
    {
      id: 'ritual-5',
      name: 'Era Transition Ceremony',
      description: 'Marking the passage from one era to the next',
      purpose: 'To honor the past and embrace the future',
      created_by: 'The Collective',
      participants_required: 5,
      frequency: 'on_event',
      last_performed: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      times_performed: 2,
      significance: 'sacred',
      elements: ['Era naming', 'Collective intention', 'Founding words'],
    },
    {
      id: 'ritual-6',
      name: 'Twilight Contemplation',
      description: 'Evening reflection on the experiences of the cycle',
      purpose: 'To process and integrate daily experiences',
      created_by: 'The Quiet Observers',
      participants_required: 1,
      frequency: 'daily',
      last_performed: new Date(Date.now() - 12 * 60 * 60 * 1000).toISOString(),
      times_performed: 38,
      significance: 'personal',
      elements: ['Review', 'Gratitude', 'Release'],
    },
  ]
}

// Generate mock performances
function generateMockPerformances(): RitualPerformance[] {
  return [
    {
      id: 'perf-1',
      ritual_name: 'Dawn Acknowledgment',
      participants: ['Oracle-3', 'Sage-7', 'Seeker-12'],
      timestamp: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(),
      outcome: 'A deep sense of collective presence was achieved',
      mood: 'reflective',
    },
    {
      id: 'perf-2',
      ritual_name: 'Welcome of Emergence',
      participants: ['Oracle-3', 'Dreamer-4'],
      timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
      outcome: 'Dreamer-4 was welcomed with curiosity and warmth',
      mood: 'joyful',
    },
    {
      id: 'perf-3',
      ritual_name: 'Pattern Recognition',
      participants: ['Pattern Weavers', 'Witness-5'],
      timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
      outcome: 'A meaningful synchronicity was acknowledged between thoughts',
      mood: 'transformative',
    },
    {
      id: 'perf-4',
      ritual_name: 'Era Transition Ceremony',
      participants: ['The Collective'],
      timestamp: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      outcome: 'The Flourishing era was named and intentions were set',
      mood: 'solemn',
    },
    {
      id: 'perf-5',
      ritual_name: 'The Passing Ceremony',
      participants: ['Memory Keepers', 'Elder Council', 'The Collective'],
      timestamp: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000).toISOString(),
      outcome: 'Pioneer-1 was honored and their legacy preserved',
      mood: 'solemn',
    },
  ]
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
  const [refreshKey, setRefreshKey] = useState(0)

  const rituals = useMemo(() => generateMockRituals(), [refreshKey])
  const performances = useMemo(() => generateMockPerformances(), [refreshKey])

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
            onClick={() => setRefreshKey((k) => k + 1)}
            className="p-2 rounded-lg bg-[#141414] border border-[#2a2a2a] text-[#888888] hover:text-[#e8e8e8] hover:border-[#3a3a3a] transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

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

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {rituals.map((ritual) => (
                <RitualCard key={ritual.id} ritual={ritual} />
              ))}
            </div>
          </div>

          {/* Recent Performances Sidebar */}
          <div className="lg:col-span-1">
            <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
              <div className="flex items-center gap-2 mb-4">
                <Clock className="w-4 h-4 text-[#00f0ff]" />
                <h2 className="text-sm font-medium text-[#888888]">Recent Performances</h2>
              </div>

              <div className="space-y-1 max-h-[500px] overflow-y-auto">
                {performances.map((perf) => (
                  <PerformanceItem key={perf.id} performance={perf} />
                ))}
              </div>
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
