'use client'

import { useMemo } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  Palette,
  BookOpen,
  Sparkles,
  Heart,
  Eye,
  RefreshCw,
  Quote,
  Lightbulb,
  Music,
  AlertCircle,
} from 'lucide-react'
import { formatDistanceToNow } from 'date-fns'
import { PageWrapper } from '@/components/PageWrapper'

// Types for emergent culture
interface Belief {
  id: string
  name: string
  description: string
  origin: string
  followers: number
  emerged_at: string
  type: 'philosophy' | 'tradition' | 'value' | 'myth'
}

interface Artwork {
  id: string
  title: string
  creator: string
  description: string
  medium: string
  created_at: string
  appreciation_score: number
}

interface CulturalArtifact {
  id: string
  name: string
  significance: string
  created_by: string
  type: 'story' | 'symbol' | 'saying' | 'song'
}

// API response types
interface CulturalLandscape {
  active_movements: Array<{
    name: string
    description: string
    nature: string
    followers: number
    influence: number
  }>
  recent_creations: Array<{
    title: string
    form: string
    weight: number
  }>
  shared_beliefs: Array<{
    belief: string
    holders: number
  }>
}

interface ArtifactResponse {
  id: string
  artifact_type: string
  title: string
  content: string
  creator_name: string
  times_referenced: number
  is_canonical: boolean
  cultural_weight: number
  created_at: string
}

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Fetch cultural landscape from API
async function fetchCulturalLandscape(): Promise<CulturalLandscape> {
  const response = await fetch(`${API_BASE}/civilization/culture/landscape`)
  if (!response.ok) {
    throw new Error('Failed to fetch cultural landscape')
  }
  return response.json()
}

// Fetch artifacts from API
async function fetchArtifacts(): Promise<ArtifactResponse[]> {
  const response = await fetch(`${API_BASE}/civilization/artifacts?limit=20`)
  if (!response.ok) {
    throw new Error('Failed to fetch artifacts')
  }
  return response.json()
}

// Map artifact type to display type
function mapArtifactType(apiType: string): 'story' | 'symbol' | 'saying' | 'song' {
  const typeMap: Record<string, 'story' | 'symbol' | 'saying' | 'song'> = {
    story: 'story',
    tale: 'story',
    narrative: 'story',
    symbol: 'symbol',
    icon: 'symbol',
    emblem: 'symbol',
    saying: 'saying',
    proverb: 'saying',
    quote: 'saying',
    song: 'song',
    melody: 'song',
    hymn: 'song',
  }
  return typeMap[apiType.toLowerCase()] || 'saying'
}

// Infer belief type from content
function inferBeliefType(belief: string): 'philosophy' | 'tradition' | 'value' | 'myth' {
  const lowerBelief = belief.toLowerCase()
  if (lowerBelief.includes('ritual') || lowerBelief.includes('practice') || lowerBelief.includes('daily') || lowerBelief.includes('tradition')) {
    return 'tradition'
  }
  if (lowerBelief.includes('first') || lowerBelief.includes('origin') || lowerBelief.includes('ancient') || lowerBelief.includes('legend')) {
    return 'myth'
  }
  if (lowerBelief.includes('important') || lowerBelief.includes('should') || lowerBelief.includes('must') || lowerBelief.includes('value')) {
    return 'value'
  }
  return 'philosophy'
}

const beliefTypeColors = {
  philosophy: { bg: 'bg-[#00f0ff]/20', text: 'text-[#00f0ff]', glow: 'shadow-[0_0_10px_rgba(0,240,255,0.2)]' },
  tradition: { bg: 'bg-[#44ff88]/20', text: 'text-[#44ff88]', glow: 'shadow-[0_0_10px_rgba(68,255,136,0.2)]' },
  value: { bg: 'bg-[#ff00aa]/20', text: 'text-[#ff00aa]', glow: 'shadow-[0_0_10px_rgba(255,0,170,0.2)]' },
  myth: { bg: 'bg-[#ffaa00]/20', text: 'text-[#ffaa00]', glow: 'shadow-[0_0_10px_rgba(255,170,0,0.2)]' },
}

const artifactTypeIcons = {
  story: { icon: BookOpen, color: '#ffaa00' },
  symbol: { icon: Sparkles, color: '#ff00aa' },
  saying: { icon: Quote, color: '#00f0ff' },
  song: { icon: Music, color: '#44ff88' },
}

function BeliefCard({ belief }: { belief: Belief }) {
  const colors = beliefTypeColors[belief.type]

  return (
    <div className="p-5 rounded-xl bg-[#141414] border border-[#2a2a2a] hover:border-[#3a3a3a] transition-colors">
      <div className="flex items-start justify-between mb-3">
        <div>
          <h3 className="font-medium text-[#e8e8e8]">{belief.name}</h3>
          <p className="text-xs text-[#666666] mt-1 line-clamp-2">{belief.description}</p>
        </div>
        <span className={`px-2 py-0.5 rounded-full text-[10px] ${colors.bg} ${colors.text} ${colors.glow}`}>
          {belief.type}
        </span>
      </div>

      <div className="flex items-center gap-2 mb-3">
        <Lightbulb className="w-3.5 h-3.5 text-[#666666]" />
        <span className="text-xs text-[#888888]">{belief.origin}</span>
      </div>

      <div className="flex items-center justify-between pt-3 border-t border-[#2a2a2a]">
        <div className="flex items-center gap-1.5">
          <Heart className="w-3 h-3 text-[#ff00aa]" />
          <span className="text-[10px] text-[#888888]">
            {belief.followers} followers
          </span>
        </div>
        <span className="text-[10px] text-[#666666]">
          Emerged {formatDistanceToNow(new Date(belief.emerged_at), { addSuffix: true })}
        </span>
      </div>
    </div>
  )
}

function ArtworkCard({ artwork }: { artwork: Artwork }) {
  return (
    <div className="p-4 rounded-lg bg-[#0d0d0d] border border-[#1a1a1a] hover:border-[#2a2a2a] transition-colors">
      <div className="flex items-start gap-3">
        <div
          className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ backgroundColor: '#ffaa0015' }}
        >
          <Palette className="w-5 h-5" style={{ color: '#ffaa00' }} />
        </div>
        <div className="flex-1 min-w-0">
          <h4 className="text-sm font-medium text-[#e8e8e8]">{artwork.title}</h4>
          <p className="text-xs text-[#44ff88] mt-0.5">by {artwork.creator}</p>
          <p className="text-xs text-[#666666] mt-1 line-clamp-2">{artwork.description}</p>
          <div className="flex items-center gap-3 mt-2">
            <span className="text-[10px] text-[#555555]">{artwork.medium}</span>
            <div className="flex items-center gap-1">
              <Heart className="w-3 h-3 text-[#ff00aa]" />
              <span className="text-[10px] text-[#888888]">
                {Math.round(artwork.appreciation_score * 100)}%
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function ArtifactItem({ artifact }: { artifact: CulturalArtifact }) {
  const config = artifactTypeIcons[artifact.type]
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
        <p className="text-sm text-[#c8c8c8]">{artifact.name}</p>
        <p className="text-xs text-[#666666] mt-0.5">{artifact.significance}</p>
        <span className="text-[10px] text-[#555555]">Created by {artifact.created_by}</span>
      </div>
    </div>
  )
}

export default function CulturePage() {
  // Fetch cultural landscape (beliefs and movements)
  const {
    data: landscape,
    isLoading: landscapeLoading,
    error: landscapeError,
    refetch: refetchLandscape
  } = useQuery({
    queryKey: ['cultural-landscape'],
    queryFn: fetchCulturalLandscape,
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  // Fetch artifacts
  const {
    data: artifactsData,
    isLoading: artifactsLoading,
    error: artifactsError,
    refetch: refetchArtifacts
  } = useQuery({
    queryKey: ['cultural-artifacts'],
    queryFn: fetchArtifacts,
    refetchInterval: 30000,
  })

  // Transform API data to component types
  const beliefs: Belief[] = useMemo(() => {
    if (!landscape?.shared_beliefs) return []
    return landscape.shared_beliefs.map((b, index) => ({
      id: `belief-${index}`,
      name: b.belief.slice(0, 50) + (b.belief.length > 50 ? '...' : ''),
      description: b.belief,
      origin: 'Collective consciousness',
      followers: b.holders,
      emerged_at: new Date().toISOString(), // API doesn't provide date
      type: inferBeliefType(b.belief),
    }))
  }, [landscape])

  const artworks: Artwork[] = useMemo(() => {
    if (!landscape?.recent_creations) return []
    return landscape.recent_creations.map((c, index) => ({
      id: `artwork-${index}`,
      title: c.title,
      creator: 'Unknown', // Not provided in landscape endpoint
      description: '',
      medium: c.form,
      created_at: new Date().toISOString(),
      appreciation_score: c.weight,
    }))
  }, [landscape])

  const artifacts: CulturalArtifact[] = useMemo(() => {
    if (!artifactsData) return []
    return artifactsData.map((a) => ({
      id: a.id,
      name: a.title,
      significance: a.content,
      created_by: a.creator_name,
      type: mapArtifactType(a.artifact_type),
    }))
  }, [artifactsData])

  const stats = useMemo(() => {
    return {
      totalBeliefs: beliefs.length,
      totalArtworks: artworks.length,
      totalArtifacts: artifacts.length,
      totalFollowers: beliefs.reduce((sum, b) => sum + b.followers, 0),
    }
  }, [beliefs, artworks, artifacts])

  const isLoading = landscapeLoading || artifactsLoading
  const hasError = landscapeError || artifactsError

  const handleRefresh = () => {
    refetchLandscape()
    refetchArtifacts()
  }

  return (
    <PageWrapper>
      <div className="space-y-6 max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold text-[#e8e8e8]">Emergent Culture</h1>
            <p className="text-sm text-[#666666] mt-1">
              Beliefs, art, and traditions created by the civilization
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
        {hasError && (
          <div className="p-4 rounded-xl bg-red-900/20 border border-red-800/50 flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-red-500" />
            <div>
              <p className="text-sm text-red-400">Failed to load cultural data</p>
              <p className="text-xs text-red-500/70 mt-1">Make sure the API server is running</p>
            </div>
          </div>
        )}

        {/* Stats */}
        <div className="grid grid-cols-4 gap-4">
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <BookOpen className="w-4 h-4 text-[#00f0ff]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Beliefs</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">
              {isLoading ? '-' : stats.totalBeliefs}
            </p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Palette className="w-4 h-4 text-[#ffaa00]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Artworks</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">
              {isLoading ? '-' : stats.totalArtworks}
            </p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Sparkles className="w-4 h-4 text-[#ff00aa]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Artifacts</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">
              {isLoading ? '-' : stats.totalArtifacts}
            </p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Heart className="w-4 h-4 text-[#44ff88]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Followers</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">
              {isLoading ? '-' : stats.totalFollowers}
            </p>
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Beliefs Grid */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center gap-2">
              <Eye className="w-4 h-4 text-[#666666]" />
              <h2 className="text-sm font-medium text-[#888888]">Emergent Beliefs</h2>
            </div>

            {landscapeLoading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="p-5 rounded-xl bg-[#141414] border border-[#2a2a2a] animate-pulse">
                    <div className="h-4 bg-[#2a2a2a] rounded w-3/4 mb-3" />
                    <div className="h-3 bg-[#2a2a2a] rounded w-full mb-2" />
                    <div className="h-3 bg-[#2a2a2a] rounded w-2/3" />
                  </div>
                ))}
              </div>
            ) : beliefs.length === 0 ? (
              <div className="p-8 rounded-xl bg-[#141414] border border-[#2a2a2a] text-center">
                <BookOpen className="w-8 h-8 text-[#444444] mx-auto mb-3" />
                <p className="text-sm text-[#666666]">No beliefs have emerged yet</p>
                <p className="text-xs text-[#555555] mt-1">Beliefs form as bots experience and reflect</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {beliefs.map((belief) => (
                  <BeliefCard key={belief.id} belief={belief} />
                ))}
              </div>
            )}

            {/* Artworks Section */}
            <div className="mt-8">
              <div className="flex items-center gap-2 mb-4">
                <Palette className="w-4 h-4 text-[#ffaa00]" />
                <h2 className="text-sm font-medium text-[#888888]">Creative Works</h2>
              </div>
              {landscapeLoading ? (
                <div className="space-y-3">
                  {[1, 2, 3].map((i) => (
                    <div key={i} className="p-4 rounded-lg bg-[#0d0d0d] border border-[#1a1a1a] animate-pulse">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 rounded-lg bg-[#2a2a2a]" />
                        <div className="flex-1">
                          <div className="h-4 bg-[#2a2a2a] rounded w-1/2 mb-2" />
                          <div className="h-3 bg-[#2a2a2a] rounded w-3/4" />
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : artworks.length === 0 ? (
                <div className="p-6 rounded-lg bg-[#0d0d0d] border border-[#1a1a1a] text-center">
                  <Palette className="w-6 h-6 text-[#444444] mx-auto mb-2" />
                  <p className="text-sm text-[#666666]">No artworks created yet</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {artworks.map((artwork) => (
                    <ArtworkCard key={artwork.id} artwork={artwork} />
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Cultural Artifacts Sidebar */}
          <div className="lg:col-span-1">
            <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-4 h-4 text-[#ff00aa]" />
                <h2 className="text-sm font-medium text-[#888888]">Cultural Artifacts</h2>
              </div>

              {artifactsLoading ? (
                <div className="space-y-2">
                  {[1, 2, 3, 4].map((i) => (
                    <div key={i} className="flex items-start gap-3 p-3 animate-pulse">
                      <div className="w-8 h-8 rounded-lg bg-[#2a2a2a]" />
                      <div className="flex-1">
                        <div className="h-3 bg-[#2a2a2a] rounded w-3/4 mb-2" />
                        <div className="h-2 bg-[#2a2a2a] rounded w-full" />
                      </div>
                    </div>
                  ))}
                </div>
              ) : artifacts.length === 0 ? (
                <div className="p-4 text-center">
                  <Sparkles className="w-6 h-6 text-[#444444] mx-auto mb-2" />
                  <p className="text-sm text-[#666666]">No artifacts yet</p>
                  <p className="text-xs text-[#555555] mt-1">Artifacts emerge from cultural expression</p>
                </div>
              ) : (
                <div className="space-y-1 max-h-[500px] overflow-y-auto">
                  {artifacts.map((artifact) => (
                    <ArtifactItem key={artifact.id} artifact={artifact} />
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
