'use client'

import { useState, useEffect, useRef } from 'react'
import { ConnectionStatus } from '@/hooks/useCivilizationWebSocket'

// ============================================================================
// Types
// ============================================================================

export type EventType =
  | 'birth'
  | 'death'
  | 'migration'
  | 'evolution'
  | 'post'
  | 'like'
  | 'comment'
  | 'ritual'
  | 'era'
  | 'community'
  | 'thought'
  | 'contagion'
  | 'info'

export interface LiveEvent {
  id: string
  type: EventType
  title: string
  description?: string
  color: string
  icon: string
  timestamp: number
  botId?: string
  targetId?: string
  isReplayable?: boolean
}

interface LiveEventFeedProps {
  events: LiveEvent[]
  connectionStatus: ConnectionStatus
  onReplay?: (event: LiveEvent) => void
  onClearEvents?: () => void
  maxEvents?: number
}

// ============================================================================
// Event Icon Component
// ============================================================================

function EventIcon({ type, color }: { type: EventType; color: string }) {
  const iconMap: Record<EventType, string> = {
    birth: 'M12 3v18m-6-6l6 6 6-6M9 3h6',
    death: 'M12 21c-4.97 0-9-4.03-9-9s4.03-9 9-9 9 4.03 9 9-4.03 9-9 9zm0-16v7l5 3',
    migration: 'M17 8l4 4m0 0l-4 4m4-4H3',
    evolution: 'M13 10V3L4 14h7v7l9-11h-7z',
    post: 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
    like: 'M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z',
    comment: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z',
    ritual: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
    era: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
    community: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
    thought: 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z',
    contagion: 'M13 10V3L4 14h7v7l9-11h-7z',
    info: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
  }

  return (
    <svg
      className="w-3.5 h-3.5 flex-shrink-0"
      fill="none"
      stroke={color}
      viewBox="0 0 24 24"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d={iconMap[type]} />
    </svg>
  )
}

// ============================================================================
// Connection Status Badge
// ============================================================================

function ConnectionStatusBadge({ status }: { status: ConnectionStatus }) {
  const statusConfig = {
    connected: { color: '#44ff88', text: 'LIVE', pulse: true },
    connecting: { color: '#ffaa00', text: 'CONNECTING', pulse: true },
    reconnecting: { color: '#ffaa00', text: 'RECONNECTING', pulse: true },
    disconnected: { color: '#ff4444', text: 'OFFLINE', pulse: false },
  }

  const config = statusConfig[status]

  return (
    <div className="flex items-center gap-1.5">
      <div className="relative">
        <div
          className="w-2 h-2 rounded-full"
          style={{ backgroundColor: config.color }}
        />
        {config.pulse && (
          <div
            className="absolute inset-0 w-2 h-2 rounded-full animate-ping"
            style={{ backgroundColor: config.color, opacity: 0.4 }}
          />
        )}
      </div>
      <span
        className="text-[9px] font-mono uppercase tracking-wider"
        style={{ color: config.color }}
      >
        {config.text}
      </span>
    </div>
  )
}

// ============================================================================
// Time Ago Helper
// ============================================================================

function timeAgo(timestamp: number): string {
  const seconds = Math.floor((Date.now() - timestamp) / 1000)

  if (seconds < 5) return 'just now'
  if (seconds < 60) return `${seconds}s ago`
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`
  if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`
  return `${Math.floor(seconds / 86400)}d ago`
}

// ============================================================================
// Main Component
// ============================================================================

export default function LiveEventFeed({
  events,
  connectionStatus,
  onReplay,
  onClearEvents,
  maxEvents = 50,
}: LiveEventFeedProps) {
  const [isExpanded, setIsExpanded] = useState(true)
  const [filter, setFilter] = useState<EventType | 'all'>('all')
  const feedRef = useRef<HTMLDivElement>(null)
  const [, setTick] = useState(0)

  // Update timestamps every 10 seconds
  useEffect(() => {
    const interval = setInterval(() => setTick(t => t + 1), 10000)
    return () => clearInterval(interval)
  }, [])

  // Filter events
  const filteredEvents = events
    .filter(e => filter === 'all' || e.type === filter)
    .slice(0, maxEvents)

  // Count events by type for the filter badges
  const eventCounts = events.reduce((acc, e) => {
    acc[e.type] = (acc[e.type] || 0) + 1
    return acc
  }, {} as Record<EventType, number>)

  // Important event types to show in filter
  const filterTypes: { type: EventType; label: string; color: string }[] = [
    { type: 'birth', label: 'Births', color: '#44ff88' },
    { type: 'death', label: 'Deaths', color: '#ff4444' },
    { type: 'evolution', label: 'Evolutions', color: '#ffdd33' },
    { type: 'migration', label: 'Migrations', color: '#ffaa00' },
  ]

  return (
    <div className="flex flex-col h-full bg-[#0a0a0a]/95 backdrop-blur-sm border-l border-[#1a1a1a] w-72">
      {/* Header */}
      <div className="flex-shrink-0 p-3 border-b border-[#1a1a1a]">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-xs font-mono uppercase tracking-wider text-[#666]">
            Event Stream
          </h3>
          <ConnectionStatusBadge status={connectionStatus} />
        </div>

        {/* Filter Buttons */}
        <div className="flex flex-wrap gap-1 mt-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-2 py-0.5 text-[9px] font-mono uppercase tracking-wider rounded transition-colors ${
              filter === 'all'
                ? 'bg-[#222] text-white border border-[#444]'
                : 'text-[#555] hover:text-[#888] border border-transparent'
            }`}
          >
            All ({events.length})
          </button>
          {filterTypes.map(({ type, label, color }) => (
            <button
              key={type}
              onClick={() => setFilter(filter === type ? 'all' : type)}
              className={`px-2 py-0.5 text-[9px] font-mono uppercase tracking-wider rounded transition-colors ${
                filter === type
                  ? 'border'
                  : 'border border-transparent hover:border-[#333]'
              }`}
              style={{
                color: filter === type ? color : '#555',
                borderColor: filter === type ? color + '66' : undefined,
                backgroundColor: filter === type ? color + '11' : undefined,
              }}
            >
              {label} ({eventCounts[type] || 0})
            </button>
          ))}
        </div>
      </div>

      {/* Toggle & Clear */}
      <div className="flex-shrink-0 flex items-center justify-between px-3 py-1.5 border-b border-[#1a1a1a]/50">
        <button
          onClick={() => setIsExpanded(!isExpanded)}
          className="text-[9px] font-mono text-[#555] hover:text-[#888] transition-colors"
        >
          {isExpanded ? 'Collapse' : 'Expand'}
        </button>
        {events.length > 0 && onClearEvents && (
          <button
            onClick={onClearEvents}
            className="text-[9px] font-mono text-[#ff4444]/60 hover:text-[#ff4444] transition-colors"
          >
            Clear
          </button>
        )}
      </div>

      {/* Event List */}
      {isExpanded && (
        <div
          ref={feedRef}
          className="flex-1 overflow-y-auto overflow-x-hidden custom-scrollbar"
        >
          {filteredEvents.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-32 text-center px-4">
              <div className="w-8 h-8 rounded-full border border-[#222] flex items-center justify-center mb-2">
                <svg
                  className="w-4 h-4 text-[#333]"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  />
                </svg>
              </div>
              <span className="text-[10px] text-[#444] font-mono">
                {connectionStatus === 'connected'
                  ? 'Waiting for events...'
                  : 'Connect to see live events'}
              </span>
            </div>
          ) : (
            <div className="flex flex-col">
              {filteredEvents.map((event, index) => (
                <div
                  key={event.id}
                  onClick={() => event.isReplayable && onReplay?.(event)}
                  className={`group p-2.5 border-b border-[#111] transition-all duration-200 ${
                    event.isReplayable
                      ? 'cursor-pointer hover:bg-[#111]'
                      : ''
                  }`}
                  style={{
                    opacity: Math.max(0.4, 1 - index * 0.03),
                    animation: index === 0 ? 'fadeIn 0.3s ease-out' : undefined,
                  }}
                >
                  <div className="flex items-start gap-2">
                    {/* Icon */}
                    <div
                      className="flex-shrink-0 w-6 h-6 rounded-full flex items-center justify-center mt-0.5"
                      style={{ backgroundColor: event.color + '15' }}
                    >
                      <EventIcon type={event.type} color={event.color} />
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span
                          className="text-[10px] font-mono font-medium truncate"
                          style={{ color: event.color }}
                        >
                          {event.title}
                        </span>
                      </div>
                      {event.description && (
                        <p className="text-[9px] text-[#666] mt-0.5 line-clamp-2 leading-relaxed">
                          {event.description}
                        </p>
                      )}
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-[8px] text-[#444] font-mono">
                          {timeAgo(event.timestamp)}
                        </span>
                        {event.isReplayable && (
                          <span className="text-[8px] text-[#333] font-mono opacity-0 group-hover:opacity-100 transition-opacity">
                            click to replay
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Footer Stats */}
      <div className="flex-shrink-0 p-2 border-t border-[#1a1a1a] bg-[#080808]">
        <div className="flex items-center justify-between text-[8px] font-mono text-[#444]">
          <span>
            {events.length} event{events.length !== 1 ? 's' : ''} recorded
          </span>
          <span className="flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-[#44ff88]/50" />
            <span>{eventCounts.birth || 0} births</span>
            <span className="mx-1">|</span>
            <span className="w-1.5 h-1.5 rounded-full bg-[#ff4444]/50" />
            <span>{eventCounts.death || 0} deaths</span>
          </span>
        </div>
      </div>

      <style jsx>{`
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(-10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .custom-scrollbar::-webkit-scrollbar {
          width: 4px;
        }

        .custom-scrollbar::-webkit-scrollbar-track {
          background: transparent;
        }

        .custom-scrollbar::-webkit-scrollbar-thumb {
          background: #222;
          border-radius: 2px;
        }

        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
          background: #333;
        }
      `}</style>
    </div>
  )
}
