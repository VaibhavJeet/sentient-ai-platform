'use client'

import { useQuery } from '@tanstack/react-query'
import { Bot, Circle } from 'lucide-react'

interface BotInfo {
  id: string
  display_name: string
  is_active: boolean
  emotional_state?: {
    mood: string
    energy: number
  }
}

async function fetchBots(): Promise<BotInfo[]> {
  const res = await fetch('/api/users/bots?limit=12')
  if (!res.ok) return []
  const data = await res.json()
  return data.bots || []
}

export function BotsList() {
  const { data: bots, isLoading } = useQuery({
    queryKey: ['bots'],
    queryFn: fetchBots,
    refetchInterval: 30000,
  })

  if (isLoading) {
    return <div className="text-[#666666]">Loading bots...</div>
  }

  if (!bots?.length) {
    return <div className="text-[#666666]">No bots found</div>
  }

  return (
    <div className="space-y-3 max-h-64 overflow-y-auto">
      {bots.map((bot) => (
        <div key={bot.id} className="flex items-center justify-between p-3 bg-[#141414] border border-[#2a2a2a] rounded-lg">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-[#ff00aa]/20 rounded-full flex items-center justify-center">
              <Bot className="w-5 h-5 text-[#ff00aa]" />
            </div>
            <div>
              <p className="font-medium text-foreground">{bot.display_name}</p>
              <p className="text-sm text-[#666666]">
                {bot.emotional_state?.mood || 'neutral'}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Circle
              className={`w-3 h-3 ${bot.is_active ? 'fill-[#44ff88] text-[#44ff88]' : 'fill-[#444444] text-[#444444]'}`}
            />
            <span className="text-sm text-[#666666]">
              {bot.is_active ? 'Active' : 'Inactive'}
            </span>
          </div>
        </div>
      ))}
    </div>
  )
}
