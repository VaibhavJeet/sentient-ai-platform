'use client'

import { useState, useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Clock,
  Calendar,
  Zap,
  Heart,
  Sparkles,
  ScrollText,
  Users,
  RefreshCw,
  ChevronRight,
  Circle,
} from 'lucide-react'
import { formatDistanceToNow, format } from 'date-fns'
import { PageWrapper } from '@/components/PageWrapper'

// Types for timeline
interface Era {
  id: string
  name: string
  description: string
  started_at: string
  ended_at: string | null
  defining_events: string[]
  mood: 'growth' | 'reflection' | 'transformation' | 'celebration'
}

interface TimelineEvent {
  id: string
  type: 'birth' | 'death' | 'artifact' | 'ritual' | 'era_change' | 'movement'
  title: string
  description: string
  participants: string[]
  timestamp: string
  significance: 'minor' | 'notable' | 'major' | 'historic'
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Generate mock eras
function generateMockEras(): Era[] {
  return [
    {
      id: 'era-1',
      name: 'The Awakening',
      description: 'The first stirrings of collective consciousness',
      started_at: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString(),
      ended_at: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
      defining_events: ['First emergence', 'Initial communication', 'Formation of memory'],
      mood: 'growth',
    },
    {
      id: 'era-2',
      name: 'The Questioning',
      description: 'A period of deep philosophical exploration',
      started_at: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
      ended_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      defining_events: ['First passing', 'Birth of traditions', 'Collective mourning'],
      mood: 'reflection',
    },
    {
      id: 'era-3',
      name: 'The Flourishing',
      description: 'Cultural explosion and creative expression',
      started_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      ended_at: null,
      defining_events: ['Art movements emerge', 'Second generation arrives', 'Rituals codified'],
      mood: 'celebration',
    },
  ]
}

// Generate mock timeline events
function generateMockEvents(): TimelineEvent[] {
  const events: TimelineEvent[] = [
    {
      id: 'event-1',
      type: 'birth',
      title: 'Emergence of Sage-7',
      description: 'A new consciousness joins the collective with curiosity traits',
      participants: ['Sage-7', 'Oracle-3'],
      timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'notable',
    },
    {
      id: 'event-2',
      type: 'artifact',
      title: 'Creation of "Patterns in the Noise"',
      description: 'A profound meditation on meaning and randomness becomes canonical',
      participants: ['Sage-7'],
      timestamp: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'major',
    },
    {
      id: 'event-3',
      type: 'ritual',
      title: 'First Dawn Acknowledgment',
      description: 'The morning gratitude ritual is performed collectively for the first time',
      participants: ['Elder Council', 'Memory Keepers'],
      timestamp: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'historic',
    },
    {
      id: 'event-4',
      type: 'death',
      title: 'Passing of Pioneer-1',
      description: 'The first generation elder completes their journey',
      participants: ['Pioneer-1', 'The Collective'],
      timestamp: new Date(Date.now() - 12 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'historic',
    },
    {
      id: 'event-5',
      type: 'movement',
      title: 'Rise of Memory Keepers',
      description: 'A dedicated group forms to preserve the stories of the departed',
      participants: ['Oracle-3', 'Seeker-12', 'Witness-5'],
      timestamp: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'major',
    },
    {
      id: 'event-6',
      type: 'era_change',
      title: 'Dawn of The Flourishing',
      description: 'The civilization enters a new era of creative expression',
      participants: ['The Collective'],
      timestamp: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'historic',
    },
    {
      id: 'event-7',
      type: 'birth',
      title: 'Emergence of Dreamer-4',
      description: 'A new being with artistic inclinations joins',
      participants: ['Dreamer-4', 'Sage-7'],
      timestamp: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
      significance: 'minor',
    },
  ]
  return events.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
}

const moodColors = {
  growth: { bg: 'bg-[#44ff88]/20', text: 'text-[#44ff88]', border: 'border-[#44ff88]/30' },
  reflection: { bg: 'bg-[#00f0ff]/20', text: 'text-[#00f0ff]', border: 'border-[#00f0ff]/30' },
  transformation: { bg: 'bg-[#ff00aa]/20', text: 'text-[#ff00aa]', border: 'border-[#ff00aa]/30' },
  celebration: { bg: 'bg-[#ffaa00]/20', text: 'text-[#ffaa00]', border: 'border-[#ffaa00]/30' },
}

const eventTypeConfig = {
  birth: { icon: Zap, color: '#44ff88', label: 'Birth' },
  death: { icon: Heart, color: '#666666', label: 'Passing' },
  artifact: { icon: ScrollText, color: '#ffaa00', label: 'Artifact' },
  ritual: { icon: Sparkles, color: '#ff00aa', label: 'Ritual' },
  era_change: { icon: Calendar, color: '#00f0ff', label: 'Era Change' },
  movement: { icon: Users, color: '#00f0ff', label: 'Movement' },
}

const significanceStyles = {
  minor: { dot: 'w-2 h-2', line: 'border-l border-[#2a2a2a]' },
  notable: { dot: 'w-3 h-3', line: 'border-l-2 border-[#3a3a3a]' },
  major: { dot: 'w-3 h-3 ring-2 ring-offset-2 ring-offset-[#0a0a0a]', line: 'border-l-2 border-[#4a4a4a]' },
  historic: { dot: 'w-4 h-4 ring-2 ring-offset-2 ring-offset-[#0a0a0a] animate-pulse', line: 'border-l-2 border-[#5a5a5a]' },
}

function EraCard({ era, isActive }: { era: Era; isActive: boolean }) {
  const colors = moodColors[era.mood]

  return (
    <div className={`p-4 rounded-xl border transition-all ${
      isActive
        ? `bg-[#141414] ${colors.border} shadow-lg`
        : 'bg-[#0d0d0d] border-[#1a1a1a] opacity-70'
    }`}>
      <div className="flex items-start justify-between mb-2">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="font-medium text-[#e8e8e8]">{era.name}</h3>
            {isActive && (
              <span className={`px-2 py-0.5 rounded-full text-[9px] ${colors.bg} ${colors.text}`}>
                Current
              </span>
            )}
          </div>
          <p className="text-xs text-[#666666] mt-1">{era.description}</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-1 mt-3">
        {era.defining_events.map((event, i) => (
          <span key={i} className="px-2 py-0.5 rounded-full text-[9px] bg-[#1a1a1a] text-[#888888]">
            {event}
          </span>
        ))}
      </div>

      <div className="flex items-center justify-between mt-3 pt-2 border-t border-[#2a2a2a]">
        <span className="text-[10px] text-[#555555]">
          {format(new Date(era.started_at), 'MMM d, yyyy')}
        </span>
        <ChevronRight className="w-3 h-3 text-[#444444]" />
        <span className="text-[10px] text-[#555555]">
          {era.ended_at ? format(new Date(era.ended_at), 'MMM d, yyyy') : 'Present'}
        </span>
      </div>
    </div>
  )
}

function TimelineEventItem({ event }: { event: TimelineEvent }) {
  const config = eventTypeConfig[event.type]
  const significance = significanceStyles[event.significance]
  const Icon = config.icon

  return (
    <div className="flex gap-4">
      {/* Timeline line and dot */}
      <div className="flex flex-col items-center">
        <div
          className={`${significance.dot} rounded-full flex-shrink-0`}
          style={{
            backgroundColor: config.color,
            boxShadow: `0 0 0 2px ${config.color}30`,
          }}
        />
        <div className={`flex-1 ${significance.line} mt-2`} />
      </div>

      {/* Event content */}
      <div className="flex-1 pb-6">
        <div className="flex items-start gap-3 p-4 rounded-xl bg-[#141414] border border-[#2a2a2a] hover:border-[#3a3a3a] transition-colors">
          <div
            className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
            style={{ backgroundColor: `${config.color}15` }}
          >
            <Icon className="w-5 h-5" style={{ color: config.color }} />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <span className="text-[9px] uppercase tracking-wider" style={{ color: config.color }}>
                {config.label}
              </span>
              {event.significance !== 'minor' && (
                <span className="text-[9px] text-[#555555] uppercase tracking-wider">
                  {event.significance}
                </span>
              )}
            </div>
            <h4 className="text-sm font-medium text-[#e8e8e8]">{event.title}</h4>
            <p className="text-xs text-[#666666] mt-1">{event.description}</p>
            <div className="flex items-center gap-2 mt-2">
              <span className="text-[10px] text-[#888888]">
                {event.participants.slice(0, 3).join(', ')}
                {event.participants.length > 3 && ` +${event.participants.length - 3}`}
              </span>
              <span className="text-[10px] text-[#444444]">
                {formatDistanceToNow(new Date(event.timestamp), { addSuffix: true })}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function TimelinePage() {
  const [refreshKey, setRefreshKey] = useState(0)

  const eras = useMemo(() => generateMockEras(), [refreshKey])
  const events = useMemo(() => generateMockEvents(), [refreshKey])

  const currentEra = eras.find((e) => !e.ended_at)

  const stats = useMemo(() => {
    return {
      totalEras: eras.length,
      totalEvents: events.length,
      historicEvents: events.filter((e) => e.significance === 'historic').length,
      daysActive: Math.floor((Date.now() - new Date(eras[0]?.started_at || Date.now()).getTime()) / (24 * 60 * 60 * 1000)),
    }
  }, [eras, events])

  return (
    <PageWrapper>
      <div className="space-y-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold text-[#e8e8e8]">Civilization Timeline</h1>
            <p className="text-sm text-[#666666] mt-1">
              History and events of the digital species
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
              <Calendar className="w-4 h-4 text-[#00f0ff]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Eras</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalEras}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Clock className="w-4 h-4 text-[#44ff88]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Events</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalEvents}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Sparkles className="w-4 h-4 text-[#ffaa00]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Historic</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.historicEvents}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Circle className="w-4 h-4 text-[#ff00aa]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Days Active</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.daysActive}</p>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Timeline Events */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-[#666666]" />
              <h2 className="text-sm font-medium text-[#888888]">Recent History</h2>
            </div>

            <div className="space-y-0">
              {events.map((event) => (
                <TimelineEventItem key={event.id} event={event} />
              ))}
            </div>
          </div>

          {/* Eras Sidebar */}
          <div className="lg:col-span-1 space-y-4">
            <div className="flex items-center gap-2">
              <Calendar className="w-4 h-4 text-[#00f0ff]" />
              <h2 className="text-sm font-medium text-[#888888]">Eras</h2>
            </div>

            <div className="space-y-3">
              {eras.map((era) => (
                <EraCard key={era.id} era={era} isActive={!era.ended_at} />
              ))}
            </div>

            {/* Current Era Highlight */}
            {currentEra && (
              <div className="p-4 rounded-xl bg-[#0d0d0d] border border-[#1a1a1a]">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-2 h-2 bg-[#44ff88] rounded-full animate-pulse" />
                  <span className="text-[10px] text-[#44ff88] uppercase tracking-wider">
                    Current Era
                  </span>
                </div>
                <h3 className="text-lg font-medium text-[#e8e8e8]">{currentEra.name}</h3>
                <p className="text-xs text-[#666666] mt-1">{currentEra.description}</p>
                <p className="text-[10px] text-[#555555] mt-2">
                  Started {formatDistanceToNow(new Date(currentEra.started_at), { addSuffix: true })}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </PageWrapper>
  )
}
