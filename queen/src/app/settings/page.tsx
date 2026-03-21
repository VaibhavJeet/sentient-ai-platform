'use client'

import { useState, useCallback, useEffect } from 'react'
import {
  Settings,
  Globe,
  Bot,
  Shield,
  Bell,
  Filter,
  Save,
  RotateCcw,
  Check,
  AlertTriangle,
  Info,
  Clock,
  Mail,
  Eye,
  EyeOff,
  ChevronDown,
  ChevronRight,
  Loader2,
  X,
} from 'lucide-react'
import { GlowCard } from '@/components/ui/GlowCard'
import { NeonButton } from '@/components/ui/NeonButton'
import { PageWrapper } from '@/components/PageWrapper'
import {
  settingsApi,
  type AllSettings,
  type GeneralSettings,
  type BotSettings,
  type AuthSettings,
  type ModerationSettings,
  type NotificationSettings,
} from '@/lib/api'

// Types
interface ToggleSwitchProps {
  enabled: boolean
  onChange: (enabled: boolean) => void
  color?: 'cyan' | 'magenta' | 'green' | 'amber'
  disabled?: boolean
}

interface SettingsSection {
  id: string
  title: string
  icon: React.ElementType
  color: 'cyan' | 'magenta' | 'green' | 'amber' | 'purple'
  collapsed?: boolean
}

// Neon Toggle Switch Component
function ToggleSwitch({ enabled, onChange, color = 'cyan', disabled = false }: ToggleSwitchProps) {
  const colorMap = {
    cyan: { active: '#00f0ff', glow: 'rgba(0, 240, 255, 0.5)' },
    magenta: { active: '#ff00aa', glow: 'rgba(255, 0, 170, 0.5)' },
    green: { active: '#00ff88', glow: 'rgba(0, 255, 136, 0.5)' },
    amber: { active: '#ffaa00', glow: 'rgba(255, 170, 0, 0.5)' },
  }
  const colors = colorMap[color]

  return (
    <button
      type="button"
      onClick={() => !disabled && onChange(!enabled)}
      disabled={disabled}
      className={`
        relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2
        transition-all duration-300 ease-out focus:outline-none
        ${disabled ? 'opacity-50 cursor-not-allowed' : ''}
      `}
      style={{
        backgroundColor: enabled ? `${colors.active}20` : 'rgba(37, 37, 56, 0.8)',
        borderColor: enabled ? colors.active : 'rgba(96, 96, 128, 0.3)',
        boxShadow: enabled ? `0 0 15px ${colors.glow}` : 'none',
      }}
    >
      <span
        className={`
          pointer-events-none inline-block h-5 w-5 transform rounded-full
          shadow-lg ring-0 transition-all duration-300 ease-out
        `}
        style={{
          backgroundColor: enabled ? colors.active : '#606080',
          transform: enabled ? 'translateX(20px)' : 'translateX(0)',
          boxShadow: enabled ? `0 0 10px ${colors.glow}` : 'none',
        }}
      />
    </button>
  )
}

// Neon Input Component
function NeonInput({
  label,
  value,
  onChange,
  type = 'text',
  placeholder,
  helpText,
  color = 'cyan',
  icon: Icon,
  disabled = false,
}: {
  label: string
  value: string | number
  onChange: (value: string) => void
  type?: 'text' | 'number' | 'email' | 'password'
  placeholder?: string
  helpText?: string
  color?: 'cyan' | 'magenta' | 'green' | 'amber'
  icon?: React.ElementType
  disabled?: boolean
}) {
  const [focused, setFocused] = useState(false)
  const [showPassword, setShowPassword] = useState(false)

  const colorMap = {
    cyan: { border: '#00f0ff', glow: 'rgba(0, 240, 255, 0.3)' },
    magenta: { border: '#ff00aa', glow: 'rgba(255, 0, 170, 0.3)' },
    green: { border: '#00ff88', glow: 'rgba(0, 255, 136, 0.3)' },
    amber: { border: '#ffaa00', glow: 'rgba(255, 170, 0, 0.3)' },
  }
  const colors = colorMap[color]

  return (
    <div className="space-y-1.5">
      <label className="text-xs text-[#a0a0b0] font-mono uppercase tracking-wider">{label}</label>
      <div className="relative">
        {Icon && (
          <Icon
            className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 transition-colors"
            style={{ color: focused ? colors.border : '#606080' }}
          />
        )}
        <input
          type={type === 'password' && showPassword ? 'text' : type}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          disabled={disabled}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          className={`
            w-full px-4 py-2.5 bg-[#1a1a2e] border rounded-lg text-sm font-mono
            text-[#e0e0e0] placeholder-[#606080]
            focus:outline-none transition-all duration-300
            disabled:opacity-50 disabled:cursor-not-allowed
            ${Icon ? 'pl-10' : ''}
            ${type === 'password' ? 'pr-10' : ''}
          `}
          style={{
            borderColor: focused ? colors.border : 'rgba(37, 37, 56, 0.8)',
            boxShadow: focused ? `0 0 20px ${colors.glow}` : 'none',
          }}
        />
        {type === 'password' && (
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-[#606080] hover:text-[#a0a0b0] transition-colors"
          >
            {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>
        )}
      </div>
      {helpText && (
        <p className="text-xs text-[#606080] flex items-center gap-1">
          <Info className="w-3 h-3" />
          {helpText}
        </p>
      )}
    </div>
  )
}

// Neon Slider Component
function NeonSlider({
  label,
  value,
  onChange,
  min = 0,
  max = 100,
  step = 1,
  unit = '',
  color = 'cyan',
  disabled = false,
}: {
  label: string
  value: number
  onChange: (value: number) => void
  min?: number
  max?: number
  step?: number
  unit?: string
  color?: 'cyan' | 'magenta' | 'green' | 'amber'
  disabled?: boolean
}) {
  const colorMap = {
    cyan: { active: '#00f0ff', glow: 'rgba(0, 240, 255, 0.5)' },
    magenta: { active: '#ff00aa', glow: 'rgba(255, 0, 170, 0.5)' },
    green: { active: '#00ff88', glow: 'rgba(0, 255, 136, 0.5)' },
    amber: { active: '#ffaa00', glow: 'rgba(255, 170, 0, 0.5)' },
  }
  const colors = colorMap[color]
  const percentage = ((value - min) / (max - min)) * 100

  return (
    <div className={`space-y-2 ${disabled ? 'opacity-50' : ''}`}>
      <div className="flex items-center justify-between">
        <label className="text-xs text-[#a0a0b0] font-mono uppercase tracking-wider">{label}</label>
        <span
          className="text-sm font-mono font-bold"
          style={{ color: colors.active, textShadow: `0 0 10px ${colors.glow}` }}
        >
          {value}{unit}
        </span>
      </div>
      <div className="relative h-2 bg-[#252538] rounded-full overflow-hidden">
        <div
          className="absolute inset-y-0 left-0 rounded-full transition-all duration-200"
          style={{
            width: `${percentage}%`,
            backgroundColor: colors.active,
            boxShadow: `0 0 10px ${colors.glow}`,
          }}
        />
        <input
          type="range"
          min={min}
          max={max}
          step={step}
          value={value}
          onChange={(e) => onChange(Number(e.target.value))}
          disabled={disabled}
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer disabled:cursor-not-allowed"
        />
      </div>
      <div className="flex justify-between text-xs text-[#606080] font-mono">
        <span>{min}{unit}</span>
        <span>{max}{unit}</span>
      </div>
    </div>
  )
}

// Setting Row Component
function SettingRow({
  label,
  description,
  children,
}: {
  label: string
  description?: string
  children: React.ReactNode
}) {
  return (
    <div className="flex items-center justify-between py-4 border-b border-[#252538] last:border-0">
      <div className="flex-1 pr-4">
        <p className="text-sm text-[#e0e0e0] font-medium">{label}</p>
        {description && (
          <p className="text-xs text-[#606080] mt-0.5">{description}</p>
        )}
      </div>
      <div className="flex-shrink-0">
        {children}
      </div>
    </div>
  )
}

// Default settings values
const defaultSettings: AllSettings = {
  general: {
    site_name: 'Hive',
    site_description: 'Digital civilization observation portal',
    maintenance_mode: false,
    debug_mode: false,
  },
  bot: {
    max_active_bots: 25,
    response_delay: 3,
    activity_level: 75,
    auto_learning: true,
    emotional_engine: true,
    context_memory: true,
  },
  auth: {
    jwt_expiry_hours: 24,
    refresh_token_expiry_days: 7,
    max_login_attempts: 5,
    lockout_duration_minutes: 15,
    two_factor_enabled: true,
    session_timeout_minutes: 30,
  },
  moderation: {
    auto_flag_threshold: 70,
    toxicity_threshold: 60,
    spam_detection: true,
    profanity_filter: true,
    image_moderation: true,
    link_scanning: true,
  },
  notifications: {
    email_notifications: true,
    push_notifications: true,
    sms_notifications: false,
    admin_alerts: true,
    report_digest: 'daily',
    critical_alerts_email: 'admin@hive.local',
  },
  updated_at: null,
}

// Main Component
export default function SettingsPage() {
  const [settings, setSettings] = useState<AllSettings>(defaultSettings)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [saveSuccess, setSaveSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [collapsedSections, setCollapsedSections] = useState<string[]>([])
  const [hasChanges, setHasChanges] = useState(false)

  const sections: SettingsSection[] = [
    { id: 'general', title: 'General Settings', icon: Globe, color: 'cyan' },
    { id: 'bot', title: 'Bot Configuration', icon: Bot, color: 'magenta' },
    { id: 'auth', title: 'Authentication & Security', icon: Shield, color: 'green' },
    { id: 'moderation', title: 'Content Moderation', icon: Filter, color: 'amber' },
    { id: 'notifications', title: 'Notifications', icon: Bell, color: 'purple' },
  ]

  // Load settings on mount
  useEffect(() => {
    loadSettings()
  }, [])

  const loadSettings = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const data = await settingsApi.getAll()
      setSettings(data)
      setHasChanges(false)
    } catch (err) {
      console.error('Failed to load settings:', err)
      setError('Failed to load settings. Using default values.')
      setSettings(defaultSettings)
    } finally {
      setIsLoading(false)
    }
  }

  const toggleSection = (sectionId: string) => {
    setCollapsedSections(prev =>
      prev.includes(sectionId)
        ? prev.filter(id => id !== sectionId)
        : [...prev, sectionId]
    )
  }

  // Update helpers that mark changes
  const updateGeneral = (updates: Partial<GeneralSettings>) => {
    setSettings(prev => ({
      ...prev,
      general: { ...prev.general, ...updates }
    }))
    setHasChanges(true)
  }

  const updateBot = (updates: Partial<BotSettings>) => {
    setSettings(prev => ({
      ...prev,
      bot: { ...prev.bot, ...updates }
    }))
    setHasChanges(true)
  }

  const updateAuth = (updates: Partial<AuthSettings>) => {
    setSettings(prev => ({
      ...prev,
      auth: { ...prev.auth, ...updates }
    }))
    setHasChanges(true)
  }

  const updateModeration = (updates: Partial<ModerationSettings>) => {
    setSettings(prev => ({
      ...prev,
      moderation: { ...prev.moderation, ...updates }
    }))
    setHasChanges(true)
  }

  const updateNotifications = (updates: Partial<NotificationSettings>) => {
    setSettings(prev => ({
      ...prev,
      notifications: { ...prev.notifications, ...updates }
    }))
    setHasChanges(true)
  }

  const handleSave = useCallback(async () => {
    setIsSaving(true)
    setError(null)
    try {
      const updatedSettings = await settingsApi.update({
        general: settings.general,
        bot: settings.bot,
        auth: settings.auth,
        moderation: settings.moderation,
        notifications: settings.notifications,
      })
      setSettings(updatedSettings)
      setSaveSuccess(true)
      setHasChanges(false)
      setTimeout(() => setSaveSuccess(false), 3000)
    } catch (err) {
      console.error('Failed to save settings:', err)
      setError('Failed to save settings. Please try again.')
    } finally {
      setIsSaving(false)
    }
  }, [settings])

  const handleReset = useCallback(async () => {
    setIsSaving(true)
    setError(null)
    try {
      const resetSettings = await settingsApi.reset()
      setSettings(resetSettings)
      setHasChanges(false)
    } catch (err) {
      console.error('Failed to reset settings:', err)
      setError('Failed to reset settings. Please try again.')
    } finally {
      setIsSaving(false)
    }
  }, [])

  const renderSectionHeader = (section: SettingsSection) => {
    const Icon = section.icon
    const isCollapsed = collapsedSections.includes(section.id)

    const colorMap = {
      cyan: { text: '#00f0ff', glow: 'rgba(0, 240, 255, 0.3)' },
      magenta: { text: '#ff00aa', glow: 'rgba(255, 0, 170, 0.3)' },
      green: { text: '#00ff88', glow: 'rgba(0, 255, 136, 0.3)' },
      amber: { text: '#ffaa00', glow: 'rgba(255, 170, 0, 0.3)' },
      purple: { text: '#aa00ff', glow: 'rgba(170, 0, 255, 0.3)' },
    }
    const colors = colorMap[section.color]

    return (
      <button
        onClick={() => toggleSection(section.id)}
        className="w-full flex items-center justify-between p-4 border-b border-[#252538] hover:bg-white/[0.02] transition-colors"
      >
        <div className="flex items-center gap-3">
          <div
            className="p-2 rounded-lg"
            style={{ backgroundColor: `${colors.text}15` }}
          >
            <Icon className="w-5 h-5" style={{ color: colors.text }} />
          </div>
          <h2
            className="text-lg font-mono uppercase tracking-wider"
            style={{ color: colors.text, textShadow: `0 0 15px ${colors.glow}` }}
          >
            {section.title}
          </h2>
        </div>
        {isCollapsed ? (
          <ChevronRight className="w-5 h-5 text-[#606080]" />
        ) : (
          <ChevronDown className="w-5 h-5 text-[#606080]" />
        )}
      </button>
    )
  }

  if (isLoading) {
    return (
      <PageWrapper>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="flex items-center gap-3 text-[#a0a0b0]">
            <Loader2 className="w-6 h-6 animate-spin" />
            <span className="font-mono">Loading settings...</span>
          </div>
        </div>
      </PageWrapper>
    )
  }

  return (
    <PageWrapper>
    <div className="space-y-6 pb-8 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
        <div className="flex items-center gap-4">
          <div
            className="p-3 rounded-xl bg-[#aa00ff]/10"
            style={{ boxShadow: '0 0 30px rgba(170, 0, 255, 0.3)' }}
          >
            <Settings className="w-8 h-8 text-[#aa00ff]" />
          </div>
          <div>
            <h1
              className="text-3xl font-bold font-mono uppercase tracking-wider text-[#aa00ff]"
              style={{ textShadow: '0 0 20px rgba(170, 0, 255, 0.5)' }}
            >
              System Configuration
            </h1>
            <p className="text-[#a0a0b0] text-sm font-mono">Manage platform settings and preferences</p>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex items-center gap-3">
          <NeonButton
            color="amber"
            variant="outline"
            icon={<RotateCcw className="w-4 h-4" />}
            onClick={handleReset}
            disabled={isSaving}
          >
            Reset to Defaults
          </NeonButton>
          <NeonButton
            color="green"
            variant="solid"
            glowing
            icon={isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : saveSuccess ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
            onClick={handleSave}
            disabled={isSaving || !hasChanges}
          >
            {isSaving ? 'Saving...' : saveSuccess ? 'Saved!' : 'Save Changes'}
          </NeonButton>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div
          className="flex items-center justify-between gap-3 p-4 rounded-lg border"
          style={{
            backgroundColor: 'rgba(255, 0, 100, 0.1)',
            borderColor: 'rgba(255, 0, 100, 0.3)',
            boxShadow: '0 0 20px rgba(255, 0, 100, 0.2)',
          }}
        >
          <div className="flex items-center gap-3">
            <AlertTriangle className="w-5 h-5 text-[#ff0064]" />
            <p className="text-[#ff0064] font-mono text-sm">{error}</p>
          </div>
          <button onClick={() => setError(null)} className="text-[#ff0064] hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Success Message */}
      {saveSuccess && (
        <div
          className="flex items-center gap-3 p-4 rounded-lg border"
          style={{
            backgroundColor: 'rgba(0, 255, 136, 0.1)',
            borderColor: 'rgba(0, 255, 136, 0.3)',
            boxShadow: '0 0 20px rgba(0, 255, 136, 0.2)',
          }}
        >
          <Check className="w-5 h-5 text-[#00ff88]" />
          <p className="text-[#00ff88] font-mono text-sm">Settings saved successfully!</p>
        </div>
      )}

      {/* Unsaved Changes Warning */}
      {hasChanges && !saveSuccess && (
        <div
          className="flex items-center gap-3 p-4 rounded-lg border"
          style={{
            backgroundColor: 'rgba(255, 170, 0, 0.1)',
            borderColor: 'rgba(255, 170, 0, 0.3)',
            boxShadow: '0 0 20px rgba(255, 170, 0, 0.2)',
          }}
        >
          <AlertTriangle className="w-5 h-5 text-[#ffaa00]" />
          <p className="text-[#ffaa00] font-mono text-sm">You have unsaved changes</p>
        </div>
      )}

      {/* Settings Sections */}
      <div className="space-y-4">
        {/* General Settings */}
        <GlowCard glowColor="cyan" className="p-0 overflow-hidden">
          {renderSectionHeader(sections[0])}
          {!collapsedSections.includes('general') && (
            <div className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <NeonInput
                  label="Site Name"
                  value={settings.general.site_name}
                  onChange={(v) => updateGeneral({ site_name: v })}
                  icon={Globe}
                  color="cyan"
                  disabled={isSaving}
                />
                <NeonInput
                  label="Site Description"
                  value={settings.general.site_description}
                  onChange={(v) => updateGeneral({ site_description: v })}
                  icon={Info}
                  color="cyan"
                  disabled={isSaving}
                />
              </div>
              <div className="border-t border-[#252538] pt-4">
                <SettingRow
                  label="Maintenance Mode"
                  description="Temporarily disable public access for maintenance"
                >
                  <ToggleSwitch
                    enabled={settings.general.maintenance_mode}
                    onChange={(v) => updateGeneral({ maintenance_mode: v })}
                    color="amber"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Debug Mode"
                  description="Enable detailed logging and error reporting"
                >
                  <ToggleSwitch
                    enabled={settings.general.debug_mode}
                    onChange={(v) => updateGeneral({ debug_mode: v })}
                    color="cyan"
                    disabled={isSaving}
                  />
                </SettingRow>
              </div>
            </div>
          )}
        </GlowCard>

        {/* Bot Configuration */}
        <GlowCard glowColor="magenta" className="p-0 overflow-hidden">
          {renderSectionHeader(sections[1])}
          {!collapsedSections.includes('bot') && (
            <div className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <NeonSlider
                  label="Max Active Bots"
                  value={settings.bot.max_active_bots}
                  onChange={(v) => updateBot({ max_active_bots: v })}
                  min={1}
                  max={100}
                  color="magenta"
                  disabled={isSaving}
                />
                <NeonSlider
                  label="Response Delay"
                  value={settings.bot.response_delay}
                  onChange={(v) => updateBot({ response_delay: v })}
                  min={1}
                  max={30}
                  unit="s"
                  color="magenta"
                  disabled={isSaving}
                />
                <NeonSlider
                  label="Activity Level"
                  value={settings.bot.activity_level}
                  onChange={(v) => updateBot({ activity_level: v })}
                  min={0}
                  max={100}
                  unit="%"
                  color="magenta"
                  disabled={isSaving}
                />
              </div>
              <div className="border-t border-[#252538] pt-4">
                <SettingRow
                  label="Auto Learning"
                  description="Allow bots to learn from interactions automatically"
                >
                  <ToggleSwitch
                    enabled={settings.bot.auto_learning}
                    onChange={(v) => updateBot({ auto_learning: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Emotional Intelligence Engine"
                  description="Enable emotional state tracking and responses"
                >
                  <ToggleSwitch
                    enabled={settings.bot.emotional_engine}
                    onChange={(v) => updateBot({ emotional_engine: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Context Memory"
                  description="Enable conversation context memory for bots"
                >
                  <ToggleSwitch
                    enabled={settings.bot.context_memory}
                    onChange={(v) => updateBot({ context_memory: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
              </div>
            </div>
          )}
        </GlowCard>

        {/* Authentication Settings */}
        <GlowCard glowColor="green" className="p-0 overflow-hidden">
          {renderSectionHeader(sections[2])}
          {!collapsedSections.includes('auth') && (
            <div className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <NeonInput
                  label="JWT Token Expiry"
                  value={settings.auth.jwt_expiry_hours}
                  onChange={(v) => updateAuth({ jwt_expiry_hours: parseInt(v) || 24 })}
                  type="number"
                  icon={Clock}
                  helpText="Token expiration time in hours"
                  color="green"
                  disabled={isSaving}
                />
                <NeonInput
                  label="Refresh Token Expiry"
                  value={settings.auth.refresh_token_expiry_days}
                  onChange={(v) => updateAuth({ refresh_token_expiry_days: parseInt(v) || 7 })}
                  type="number"
                  icon={Clock}
                  helpText="Refresh token expiration in days"
                  color="green"
                  disabled={isSaving}
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <NeonSlider
                  label="Max Login Attempts"
                  value={settings.auth.max_login_attempts}
                  onChange={(v) => updateAuth({ max_login_attempts: v })}
                  min={1}
                  max={10}
                  color="green"
                  disabled={isSaving}
                />
                <NeonSlider
                  label="Lockout Duration"
                  value={settings.auth.lockout_duration_minutes}
                  onChange={(v) => updateAuth({ lockout_duration_minutes: v })}
                  min={5}
                  max={60}
                  unit=" min"
                  color="green"
                  disabled={isSaving}
                />
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <NeonSlider
                  label="Session Timeout"
                  value={settings.auth.session_timeout_minutes}
                  onChange={(v) => updateAuth({ session_timeout_minutes: v })}
                  min={5}
                  max={120}
                  unit=" min"
                  color="green"
                  disabled={isSaving}
                />
              </div>
              <div className="border-t border-[#252538] pt-4">
                <SettingRow
                  label="Two-Factor Authentication"
                  description="Require 2FA for admin accounts"
                >
                  <ToggleSwitch
                    enabled={settings.auth.two_factor_enabled}
                    onChange={(v) => updateAuth({ two_factor_enabled: v })}
                    color="green"
                    disabled={isSaving}
                  />
                </SettingRow>
              </div>
            </div>
          )}
        </GlowCard>

        {/* Content Moderation */}
        <GlowCard glowColor="amber" className="p-0 overflow-hidden">
          {renderSectionHeader(sections[3])}
          {!collapsedSections.includes('moderation') && (
            <div className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <NeonSlider
                  label="Auto-Flag Threshold"
                  value={settings.moderation.auto_flag_threshold}
                  onChange={(v) => updateModeration({ auto_flag_threshold: v })}
                  min={0}
                  max={100}
                  unit="%"
                  color="amber"
                  disabled={isSaving}
                />
                <NeonSlider
                  label="Toxicity Threshold"
                  value={settings.moderation.toxicity_threshold}
                  onChange={(v) => updateModeration({ toxicity_threshold: v })}
                  min={0}
                  max={100}
                  unit="%"
                  color="amber"
                  disabled={isSaving}
                />
              </div>
              <div className="border-t border-[#252538] pt-4">
                <SettingRow
                  label="Spam Detection"
                  description="Automatically detect and filter spam content"
                >
                  <ToggleSwitch
                    enabled={settings.moderation.spam_detection}
                    onChange={(v) => updateModeration({ spam_detection: v })}
                    color="amber"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Profanity Filter"
                  description="Filter profane language from public content"
                >
                  <ToggleSwitch
                    enabled={settings.moderation.profanity_filter}
                    onChange={(v) => updateModeration({ profanity_filter: v })}
                    color="amber"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Image Moderation"
                  description="AI-powered image content moderation"
                >
                  <ToggleSwitch
                    enabled={settings.moderation.image_moderation}
                    onChange={(v) => updateModeration({ image_moderation: v })}
                    color="amber"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Link Scanning"
                  description="Scan external links for malicious content"
                >
                  <ToggleSwitch
                    enabled={settings.moderation.link_scanning}
                    onChange={(v) => updateModeration({ link_scanning: v })}
                    color="amber"
                    disabled={isSaving}
                  />
                </SettingRow>
              </div>
            </div>
          )}
        </GlowCard>

        {/* Notifications */}
        <GlowCard glowColor="magenta" className="p-0 overflow-hidden">
          {renderSectionHeader(sections[4])}
          {!collapsedSections.includes('notifications') && (
            <div className="p-6 space-y-6">
              <NeonInput
                label="Critical Alerts Email"
                value={settings.notifications.critical_alerts_email}
                onChange={(v) => updateNotifications({ critical_alerts_email: v })}
                type="email"
                icon={Mail}
                helpText="Email address for critical system alerts"
                color="magenta"
                disabled={isSaving}
              />
              <div className="border-t border-[#252538] pt-4">
                <SettingRow
                  label="Email Notifications"
                  description="Send notifications via email"
                >
                  <ToggleSwitch
                    enabled={settings.notifications.email_notifications}
                    onChange={(v) => updateNotifications({ email_notifications: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Push Notifications"
                  description="Send browser push notifications"
                >
                  <ToggleSwitch
                    enabled={settings.notifications.push_notifications}
                    onChange={(v) => updateNotifications({ push_notifications: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="SMS Notifications"
                  description="Send critical alerts via SMS"
                >
                  <ToggleSwitch
                    enabled={settings.notifications.sms_notifications}
                    onChange={(v) => updateNotifications({ sms_notifications: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
                <SettingRow
                  label="Admin Alerts"
                  description="Receive real-time alerts for admin events"
                >
                  <ToggleSwitch
                    enabled={settings.notifications.admin_alerts}
                    onChange={(v) => updateNotifications({ admin_alerts: v })}
                    color="magenta"
                    disabled={isSaving}
                  />
                </SettingRow>
              </div>
              <div className="border-t border-[#252538] pt-4">
                <div className="space-y-2">
                  <label className="text-xs text-[#a0a0b0] font-mono uppercase tracking-wider">Report Digest Frequency</label>
                  <div className="flex items-center gap-3 p-1 bg-[#1a1a2e]/50 rounded-lg border border-[#252538] w-fit">
                    {(['hourly', 'daily', 'weekly'] as const).map((freq) => (
                      <button
                        key={freq}
                        onClick={() => updateNotifications({ report_digest: freq })}
                        disabled={isSaving}
                        className={`
                          px-4 py-2 rounded-lg font-mono text-sm transition-all capitalize
                          disabled:opacity-50 disabled:cursor-not-allowed
                          ${settings.notifications.report_digest === freq
                            ? 'bg-[#aa00ff]/20 text-[#aa00ff] shadow-[0_0_15px_rgba(170,0,255,0.3)]'
                            : 'text-[#a0a0b0] hover:text-white hover:bg-white/5'}
                        `}
                      >
                        {freq}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}
        </GlowCard>
      </div>

      {/* Footer Actions */}
      <div className="flex items-center justify-between pt-4 border-t border-[#252538]">
        <div className="flex items-center gap-2 text-[#606080] text-xs font-mono">
          <AlertTriangle className="w-4 h-4" />
          <span>Changes will take effect after saving</span>
          {settings.updated_at && (
            <span className="ml-4 text-[#505060]">
              Last updated: {new Date(settings.updated_at).toLocaleString()}
            </span>
          )}
        </div>
        <div className="flex items-center gap-3">
          <NeonButton
            color="amber"
            variant="outline"
            icon={<RotateCcw className="w-4 h-4" />}
            onClick={handleReset}
            disabled={isSaving}
          >
            Reset
          </NeonButton>
          <NeonButton
            color="green"
            variant="solid"
            glowing
            icon={isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : saveSuccess ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
            onClick={handleSave}
            disabled={isSaving || !hasChanges}
          >
            {isSaving ? 'Saving...' : saveSuccess ? 'Saved!' : 'Save All Changes'}
          </NeonButton>
        </div>
      </div>
    </div>
    </PageWrapper>
  )
}
