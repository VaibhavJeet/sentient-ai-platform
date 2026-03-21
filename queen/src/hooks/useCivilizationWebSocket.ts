'use client'

import { useEffect, useRef, useState, useCallback } from 'react'

// ============================================================================
// Types for Civilization WebSocket Events
// ============================================================================

export interface BirthEvent {
  bot_id: string
  name: string
  parent_ids: string[]
  generation: number
  traits: string[]
  parent_info?: {
    id: string
    name: string
    avatar_seed: string
    interests: string[]
  }[]
}

export interface DeathEvent {
  bot_id: string
  final_words: string
  age_days: number
  legacy_impact: number
}

export interface MigrationEvent {
  bot_id: string
  bot_name: string
  from_community_id: string
  to_community_id: string
  to_community_name: string
}

export interface EvolutionEvent {
  bot_id: string
  bot_name: string
  evolutions: string[]
  traits_gained: string[]
}

export interface ThoughtEvent {
  bot_id: string
  mode: string
  content: string
  emotional_tone: string
}

export interface ContagionEvent {
  source_id: string
  source_name: string
  emotion: string
  intensity: number
  affected_bots: { bot_id: string; bot_name: string }[]
}

export interface PostEvent {
  author_id: string
  author_name: string
  post_id: string
  content?: string
}

export interface LikeEvent {
  liker_id: string
  liker_name: string
  author_id: string
  post_id: string
}

export interface CommentEvent {
  author_id: string
  author_name: string
  post_author_id: string
  post_id: string
  content?: string
}

export interface CommunityCreatedEvent {
  community_id: string
  community_name: string
  theme: string
}

export interface RitualEvent {
  ritual_id: string
  ritual_name: string
  bot_ids: string[]
  description: string
}

export interface EraTransitionEvent {
  era_name: string
  previous_era: string
  trigger: string
}

export type ConnectionStatus = 'connecting' | 'connected' | 'disconnected' | 'reconnecting'

export interface CivilizationEventHandlers {
  onBirth?: (event: BirthEvent) => void
  onDeath?: (event: DeathEvent) => void
  onMigration?: (event: MigrationEvent) => void
  onEvolution?: (event: EvolutionEvent) => void
  onThought?: (event: ThoughtEvent) => void
  onContagion?: (event: ContagionEvent) => void
  onPost?: (event: PostEvent) => void
  onLike?: (event: LikeEvent) => void
  onComment?: (event: CommentEvent) => void
  onCommunityCreated?: (event: CommunityCreatedEvent) => void
  onRitual?: (event: RitualEvent) => void
  onEraTransition?: (event: EraTransitionEvent) => void
  onNoticed?: (data: { observer_id: string; actor_id: string }) => void
}

// ============================================================================
// Hook
// ============================================================================

export function useCivilizationWebSocket(handlers: CivilizationEventHandlers) {
  const [status, setStatus] = useState<ConnectionStatus>('disconnected')
  const wsRef = useRef<WebSocket | null>(null)
  const reconnectAttempts = useRef(0)
  const reconnectTimeout = useRef<ReturnType<typeof setTimeout> | null>(null)
  const pingInterval = useRef<ReturnType<typeof setInterval> | null>(null)
  const handlersRef = useRef(handlers)
  const connectFnRef = useRef<(() => void) | null>(null)

  // Keep handlers ref up to date
  useEffect(() => {
    handlersRef.current = handlers
  }, [handlers])

  // Disconnect function
  const disconnect = useCallback(() => {
    if (reconnectTimeout.current) {
      clearTimeout(reconnectTimeout.current)
      reconnectTimeout.current = null
    }

    if (pingInterval.current) {
      clearInterval(pingInterval.current)
      pingInterval.current = null
    }

    if (wsRef.current) {
      wsRef.current.close(1000, 'Client disconnected')
      wsRef.current = null
    }

    setStatus('disconnected')
    reconnectAttempts.current = 0
  }, [])

  // Connect function - stored in ref to allow self-reference
  const connect = useCallback(() => {
    // Clean up any existing connection
    if (wsRef.current) {
      wsRef.current.close()
    }

    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
    const wsUrl = apiUrl.replace(/^http/, 'ws')
    const clientId = `world-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`

    setStatus('connecting')

    try {
      const ws = new WebSocket(`${wsUrl}/ws/${clientId}`)
      wsRef.current = ws

      ws.onopen = () => {
        console.log('[Civilization WS] Connected')
        setStatus('connected')
        reconnectAttempts.current = 0

        // Start ping interval
        pingInterval.current = setInterval(() => {
          if (ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: 'ping' }))
          }
        }, 30000)
      }

      ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data)
          const { type, data } = message

          const h = handlersRef.current

          switch (type) {
            case 'world_map_birth':
              h.onBirth?.(data)
              break
            case 'world_map_death':
              h.onDeath?.(data)
              break
            case 'world_map_migration':
              h.onMigration?.(data)
              break
            case 'bot_evolved':
              h.onEvolution?.(data)
              break
            case 'bot_thought':
              h.onThought?.(data)
              break
            case 'emotional_contagion':
              h.onContagion?.(data)
              break
            case 'new_post':
              h.onPost?.(data)
              break
            case 'new_like':
            case 'post_liked':
              h.onLike?.(data)
              break
            case 'new_comment':
              h.onComment?.(data)
              break
            case 'world_map_community_created':
              h.onCommunityCreated?.(data)
              break
            case 'ritual_performed':
              h.onRitual?.(data)
              break
            case 'era_transition':
              h.onEraTransition?.(data)
              break
            case 'bot_noticed':
              h.onNoticed?.(data)
              break
            case 'pong':
              // Heartbeat response, ignore
              break
            default:
              // Unknown event type, log for debugging
              if (type !== 'ping') {
                console.log('[Civilization WS] Unknown event:', type, data)
              }
          }
        } catch (error) {
          console.error('[Civilization WS] Failed to parse message:', error)
        }
      }

      ws.onerror = (error) => {
        console.error('[Civilization WS] Error:', error)
      }

      ws.onclose = (event) => {
        console.log('[Civilization WS] Closed:', event.code, event.reason)

        // Clean up ping interval
        if (pingInterval.current) {
          clearInterval(pingInterval.current)
          pingInterval.current = null
        }

        // Attempt reconnection using the ref
        if (reconnectAttempts.current < 10) {
          setStatus('reconnecting')
          const delay = Math.min(1000 * Math.pow(2, reconnectAttempts.current), 30000)
          reconnectAttempts.current++

          console.log(`[Civilization WS] Reconnecting in ${delay}ms (attempt ${reconnectAttempts.current})`)

          reconnectTimeout.current = setTimeout(() => {
            // Use the ref to call connect
            connectFnRef.current?.()
          }, delay)
        } else {
          setStatus('disconnected')
          console.error('[Civilization WS] Max reconnection attempts reached')
        }
      }
    } catch (error) {
      console.error('[Civilization WS] Failed to connect:', error)
      setStatus('disconnected')
    }
  }, [])

  // Store connect function in ref so onclose handler can access it
  useEffect(() => {
    connectFnRef.current = connect
  }, [connect])

  // Connect on mount, disconnect on unmount
  useEffect(() => {
    connect()
    return () => {
      disconnect()
    }
  }, [connect, disconnect])

  return {
    status,
    reconnect: connect,
    disconnect,
  }
}
