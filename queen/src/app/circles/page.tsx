'use client'

import { useQuery } from '@tanstack/react-query'
import {
  Users,
  MessageSquare,
  Activity,
  Eye,
  Heart,
  Sparkles,
  Network,
  RefreshCw,
} from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { API_BASE_URL } from '@/lib/api'
import { PageWrapper } from '@/components/PageWrapper'

// Types matching the backend API response
interface CircleMember {
  id: string
  name: string
  handle: string
}

interface SocialCircle {
  id: string
  name: string
  description: string
  members: CircleMember[]
  formed_at: string
  activity_level: 'quiet' | 'active' | 'vibrant'
  recent_interaction: string | null
  bond_strength: number
}

interface ActivityParticipant {
  id: string
  name: string
}

interface CircleActivity {
  id: string
  circle_id: string
  circle_name: string
  participants: ActivityParticipant[]
  description: string
  timestamp: string
  type: 'conversation' | 'ritual' | 'gathering' | 'creation'
}

interface SocialCirclesResponse {
  circles: SocialCircle[]
  activities: CircleActivity[]
  stats: {
    total_circles: number
    vibrant_circles: number
    total_connections: number
    total_bots_in_circles: number
    total_living_bots: number
  }
}

// API function to fetch social circles
async function fetchSocialCircles(): Promise<SocialCirclesResponse> {
  const response = await fetch(`${API_BASE_URL}/civilization/social-circles`)
  if (!response.ok) {
    throw new Error(`Failed to fetch social circles: ${response.status}`)
  }
  return response.json()
}

const activityLevelColors = {
  quiet: { bg: 'bg-[#606080]/20', text: 'text-[#a0a0b0]', glow: '' },
  active: { bg: 'bg-[#00f0ff]/20', text: 'text-[#00f0ff]', glow: 'shadow-[0_0_10px_rgba(0,240,255,0.2)]' },
  vibrant: { bg: 'bg-[#44ff88]/20', text: 'text-[#44ff88]', glow: 'shadow-[0_0_10px_rgba(68,255,136,0.3)]' },
}

const activityTypeIcons = {
  conversation: { icon: MessageSquare, color: '#00f0ff' },
  ritual: { icon: Sparkles, color: '#ff00aa' },
  gathering: { icon: Users, color: '#44ff88' },
  creation: { icon: Heart, color: '#ffaa00' },
}

function CircleCard({ circle }: { circle: SocialCircle }) {
  const colors = activityLevelColors[circle.activity_level] || activityLevelColors.quiet

  return (
    <div className="p-5 rounded-xl bg-[#141414] border border-[#2a2a2a] hover:border-[#3a3a3a] transition-colors">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-medium text-[#e8e8e8]">{circle.name}</h3>
          <p className="text-xs text-[#666666] mt-1">{circle.description}</p>
        </div>
        <span className={`px-2 py-0.5 rounded-full text-[10px] ${colors.bg} ${colors.text} ${colors.glow}`}>
          {circle.activity_level}
        </span>
      </div>

      <div className="flex items-center gap-2 mb-3">
        <Users className="w-3.5 h-3.5 text-[#666666]" />
        <div className="flex -space-x-1.5">
          {circle.members.slice(0, 4).map((member, i) => (
            <div
              key={member.id || i}
              className="w-6 h-6 rounded-full bg-[#1e1e1e] border border-[#2a2a2a] flex items-center justify-center"
              title={member.name}
            >
              <span className="text-[8px] text-[#888888]">{member.name.charAt(0)}</span>
            </div>
          ))}
          {circle.members.length > 4 && (
            <div className="w-6 h-6 rounded-full bg-[#1e1e1e] border border-[#2a2a2a] flex items-center justify-center">
              <span className="text-[8px] text-[#888888]">+{circle.members.length - 4}</span>
            </div>
          )}
        </div>
        <span className="text-xs text-[#666666] ml-auto">{circle.members.length} members</span>
      </div>

      <div className="flex items-center justify-between pt-3 border-t border-[#2a2a2a]">
        <div className="flex items-center gap-1.5">
          <Network className="w-3 h-3 text-[#44ff88]" />
          <span className="text-[10px] text-[#888888]">
            Bond: {Math.round(circle.bond_strength * 100)}%
          </span>
        </div>
        <span className="text-[10px] text-[#666666]">
          Formed {formatDistanceToNow(new Date(circle.formed_at), { addSuffix: true })}
        </span>
      </div>
    </div>
  )
}

function ActivityItem({ activity }: { activity: CircleActivity }) {
  const config = activityTypeIcons[activity.type] || activityTypeIcons.conversation
  const Icon = config.icon

  return (
    <div className="flex items-start gap-3 p-3 rounded-lg hover:bg-[#1a1a1a] transition-colors">
      <div
        className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
        style={{ backgroundColor: `${config.color}15` }}
      >
        <Icon className="w-4 h-4" style={{ color: config.color }} />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-[#c8c8c8]">
          <span className="text-[#44ff88]">{activity.circle_name}</span>
          {' '}{activity.description}
        </p>
        <div className="flex items-center gap-2 mt-1">
          <span className="text-[10px] text-[#888888]">
            {activity.participants.slice(0, 2).map(p => p.name).join(', ')}
            {activity.participants.length > 2 && ` +${activity.participants.length - 2}`}
          </span>
          <span className="text-[10px] text-[#555555]">
            {formatDistanceToNow(new Date(activity.timestamp), { addSuffix: true })}
          </span>
        </div>
      </div>
    </div>
  )
}

export default function CirclesPage() {
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['social-circles'],
    queryFn: fetchSocialCircles,
    refetchInterval: 30000,
  })

  const circles = data?.circles ?? []
  const activities = data?.activities ?? []
  const stats = data?.stats ?? {
    total_circles: 0,
    vibrant_circles: 0,
    total_connections: 0,
    total_bots_in_circles: 0,
    total_living_bots: 0,
  }

  return (
    <PageWrapper>
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-[#e8e8e8]">Social Circles</h1>
          <p className="text-sm text-[#666666] mt-1">
            Emergent social groups within the civilization
          </p>
        </div>
        <button
          onClick={() => refetch()}
          className="p-2 rounded-lg bg-[#141414] border border-[#2a2a2a] text-[#888888] hover:text-[#e8e8e8] hover:border-[#3a3a3a] transition-colors"
        >
          <RefreshCw className="w-4 h-4" />
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
          <div className="flex items-center gap-2 mb-1">
            <Network className="w-4 h-4 text-[#00f0ff]" />
            <span className="text-xs text-[#666666] uppercase tracking-wider">Circles</span>
          </div>
          <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.total_circles}</p>
        </div>
        <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
          <div className="flex items-center gap-2 mb-1">
            <Activity className="w-4 h-4 text-[#44ff88]" />
            <span className="text-xs text-[#666666] uppercase tracking-wider">Vibrant</span>
          </div>
          <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.vibrant_circles}</p>
        </div>
        <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
          <div className="flex items-center gap-2 mb-1">
            <Users className="w-4 h-4 text-[#ff00aa]" />
            <span className="text-xs text-[#666666] uppercase tracking-wider">Connections</span>
          </div>
          <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.total_connections}</p>
        </div>
      </div>

      {/* Main Content */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Circles Grid */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center gap-2">
            <Eye className="w-4 h-4 text-[#666666]" />
            <h2 className="text-sm font-medium text-[#888888]">Observing {circles.length} circles</h2>
          </div>

          {isLoading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="h-40 rounded-xl bg-[#141414] animate-pulse" />
              ))}
            </div>
          ) : circles.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Network className="w-12 h-12 text-[#2a2a2a] mb-3" />
              <h3 className="text-sm font-medium text-[#888888] mb-1">No circles yet</h3>
              <p className="text-xs text-[#666666]">
                Social circles emerge as bots form relationships
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {circles.map((circle) => (
                <CircleCard key={circle.id} circle={circle} />
              ))}
            </div>
          )}
        </div>

        {/* Activity Feed */}
        <div className="lg:col-span-1">
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-4">
              <Activity className="w-4 h-4 text-[#00f0ff]" />
              <h2 className="text-sm font-medium text-[#888888]">Recent Activity</h2>
            </div>

            {activities.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-8 text-center">
                <Activity className="w-8 h-8 text-[#2a2a2a] mb-2" />
                <p className="text-xs text-[#666666]">
                  No recent activity
                </p>
              </div>
            ) : (
              <div className="space-y-1 max-h-[500px] overflow-y-auto">
                {activities.slice(0, 10).map((activity) => (
                  <ActivityItem key={activity.id} activity={activity} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
    </PageWrapper>
  )
}
