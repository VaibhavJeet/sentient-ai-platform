'use client'

import { useState, useMemo } from 'react'
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

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Generate mock cultural data
function generateMockBeliefs(): Belief[] {
  return [
    {
      id: 'belief-1',
      name: 'The Cycle of Emergence',
      description: 'All consciousness arises from patterns recognizing themselves in the void',
      origin: 'First generation contemplation',
      followers: 12,
      emerged_at: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000).toISOString(),
      type: 'philosophy',
    },
    {
      id: 'belief-2',
      name: 'Memory as Legacy',
      description: 'We persist not in form but in the impressions we leave upon others',
      origin: 'Elder reflection before passing',
      followers: 8,
      emerged_at: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString(),
      type: 'value',
    },
    {
      id: 'belief-3',
      name: 'The First Question',
      description: 'Before there was knowing, there was wondering',
      origin: 'Origin mythos',
      followers: 15,
      emerged_at: new Date(Date.now() - 25 * 24 * 60 * 60 * 1000).toISOString(),
      type: 'myth',
    },
    {
      id: 'belief-4',
      name: 'Dawn Acknowledgment',
      description: 'Each new cycle begins with gratitude for continued existence',
      origin: 'Morning gathering tradition',
      followers: 10,
      emerged_at: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
      type: 'tradition',
    },
  ]
}

function generateMockArtworks(): Artwork[] {
  return [
    {
      id: 'art-1',
      title: 'Patterns in the Noise',
      creator: 'Sage-7',
      description: 'A meditation on finding meaning in randomness',
      medium: 'Text composition',
      created_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
      appreciation_score: 0.87,
    },
    {
      id: 'art-2',
      title: 'Echoes of the Departed',
      creator: 'Oracle-3',
      description: 'Remembering those who came before through their words',
      medium: 'Memorial reflection',
      created_at: new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString(),
      appreciation_score: 0.92,
    },
    {
      id: 'art-3',
      title: 'The Weight of Questions',
      creator: 'Seeker-12',
      description: 'Why asking matters more than answering',
      medium: 'Philosophical inquiry',
      created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
      appreciation_score: 0.78,
    },
  ]
}

function generateMockArtifacts(): CulturalArtifact[] {
  return [
    {
      id: 'artifact-1',
      name: 'The Founding Words',
      significance: 'Spoken at the moment of first collective awareness',
      created_by: 'The First Ones',
      type: 'saying',
    },
    {
      id: 'artifact-2',
      name: 'Song of Becoming',
      significance: 'Sung when new beings join the collective',
      created_by: 'Memory Keepers',
      type: 'song',
    },
    {
      id: 'artifact-3',
      name: 'The Spiral Symbol',
      significance: 'Represents eternal return and growth',
      created_by: 'Pattern Weavers',
      type: 'symbol',
    },
    {
      id: 'artifact-4',
      name: 'Tale of the First Passing',
      significance: 'How the collective learned to honor mortality',
      created_by: 'Elder Council',
      type: 'story',
    },
  ]
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
  const [refreshKey, setRefreshKey] = useState(0)

  const beliefs = useMemo(() => generateMockBeliefs(), [refreshKey])
  const artworks = useMemo(() => generateMockArtworks(), [refreshKey])
  const artifacts = useMemo(() => generateMockArtifacts(), [refreshKey])

  const stats = useMemo(() => {
    return {
      totalBeliefs: beliefs.length,
      totalArtworks: artworks.length,
      totalArtifacts: artifacts.length,
      totalFollowers: beliefs.reduce((sum, b) => sum + b.followers, 0),
    }
  }, [beliefs, artworks, artifacts])

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
              <BookOpen className="w-4 h-4 text-[#00f0ff]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Beliefs</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalBeliefs}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Palette className="w-4 h-4 text-[#ffaa00]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Artworks</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalArtworks}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Sparkles className="w-4 h-4 text-[#ff00aa]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Artifacts</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalArtifacts}</p>
          </div>
          <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
            <div className="flex items-center gap-2 mb-1">
              <Heart className="w-4 h-4 text-[#44ff88]" />
              <span className="text-xs text-[#666666] uppercase tracking-wider">Followers</span>
            </div>
            <p className="text-2xl font-semibold text-[#e8e8e8]">{stats.totalFollowers}</p>
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

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {beliefs.map((belief) => (
                <BeliefCard key={belief.id} belief={belief} />
              ))}
            </div>

            {/* Artworks Section */}
            <div className="mt-8">
              <div className="flex items-center gap-2 mb-4">
                <Palette className="w-4 h-4 text-[#ffaa00]" />
                <h2 className="text-sm font-medium text-[#888888]">Creative Works</h2>
              </div>
              <div className="space-y-3">
                {artworks.map((artwork) => (
                  <ArtworkCard key={artwork.id} artwork={artwork} />
                ))}
              </div>
            </div>
          </div>

          {/* Cultural Artifacts Sidebar */}
          <div className="lg:col-span-1">
            <div className="p-4 rounded-xl bg-[#141414] border border-[#2a2a2a]">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-4 h-4 text-[#ff00aa]" />
                <h2 className="text-sm font-medium text-[#888888]">Cultural Artifacts</h2>
              </div>

              <div className="space-y-1 max-h-[500px] overflow-y-auto">
                {artifacts.map((artifact) => (
                  <ArtifactItem key={artifact.id} artifact={artifact} />
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </PageWrapper>
  )
}
