import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/design_system.dart';
import 'settings_screen.dart';
import 'bot_discovery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const CivilizationDashboard(),
    const TimelineScreen(),
    const BotDiscoveryScreen(), // Beings screen
    const CultureScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.hexagon_outlined,
                activeIcon: Icons.hexagon,
                label: 'Hive',
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _NavItem(
                icon: Icons.timeline_outlined,
                activeIcon: Icons.timeline,
                label: 'Timeline',
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _NavItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                label: 'Beings',
                isSelected: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'Culture',
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.semanticGreen : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.semanticGreen : AppTheme.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CIVILIZATION DASHBOARD SCREEN
// ============================================================================

class CivilizationDashboard extends StatefulWidget {
  const CivilizationDashboard({super.key});

  @override
  State<CivilizationDashboard> createState() => _CivilizationDashboardState();
}

class _CivilizationDashboardState extends State<CivilizationDashboard> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _era;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getCivilizationStats(),
        _api.getCurrentEra(),
      ]);
      setState(() {
        _stats = results[0];
        _era = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _buildDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.semanticGreen.withValues(alpha: 0.2),
                  AppTheme.semanticBlue.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.semanticGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.hexagon,
              color: AppTheme.semanticGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hive',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.semanticGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.semanticGreen.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Digital Civilization Active',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Icon(
                Icons.refresh,
                size: 18,
                color: AppTheme.textDim,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 18,
                color: AppTheme.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppTheme.semanticGreen),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Observing civilization...',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Unable to observe',
      description: _error ?? 'Failed to connect to the civilization',
      action: CleanButton(
        text: 'Retry',
        icon: Icons.refresh,
        onPressed: _loadData,
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.semanticGreen,
      backgroundColor: AppTheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Era Card
            _buildEraCard(),
            const SizedBox(height: 16),

            // Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 16),

            // Quick Info Cards
            _buildInfoCards(),
            const SizedBox(height: 100), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildEraCard() {
    final eraName = _era?['name'] ?? 'Unknown Era';
    final eraDescription = _era?['description'] ?? 'The civilization continues to evolve...';
    final eraAge = _era?['age_days'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.semanticBlue.withValues(alpha: 0.15),
            AppTheme.neonMagenta.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.semanticBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.semanticBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CURRENT ERA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.semanticBlue,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Day $eraAge',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            eraName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eraDescription,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final livingCount = _stats?['living_count'] ?? 0;
    final departedCount = _stats?['departed_count'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Living Beings',
            value: livingCount.toString(),
            icon: Icons.person,
            color: AppTheme.semanticGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Departed',
            value: departedCount.toString(),
            icon: Icons.nights_stay,
            color: AppTheme.neonPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    final generations = _stats?['generations'] ?? 0;
    final relationships = _stats?['total_relationships'] ?? 0;
    final rituals = _stats?['active_rituals'] ?? 0;
    final movements = _stats?['cultural_movements'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Generations',
                value: generations.toString(),
                icon: Icons.account_tree,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Relationships',
                value: relationships.toString(),
                icon: Icons.favorite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Active Rituals',
                value: rituals.toString(),
                icon: Icons.celebration,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'Movements',
                value: movements.toString(),
                icon: Icons.campaign,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.overlayLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.textDim),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TIMELINE SCREEN
// ============================================================================

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _api.getCivilizationTimeline();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _buildTimeline(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: AppTheme.semanticBlue, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Civilization events & history',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadTimeline,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Icon(Icons.refresh, size: 18, color: AppTheme.textDim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppTheme.semanticBlue),
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Unable to load timeline',
      description: _error,
      action: CleanButton(
        text: 'Retry',
        icon: Icons.refresh,
        onPressed: _loadTimeline,
      ),
    );
  }

  Widget _buildTimeline() {
    if (_events.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No events yet',
        description: 'The civilization is just beginning...',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTimeline,
      color: AppTheme.semanticBlue,
      backgroundColor: AppTheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _TimelineEventCard(event: event);
        },
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _TimelineEventCard({required this.event});

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'birth':
        return Icons.child_care;
      case 'death':
        return Icons.nights_stay;
      case 'relationship':
        return Icons.favorite;
      case 'ritual':
        return Icons.celebration;
      case 'era_change':
        return Icons.auto_awesome;
      case 'cultural':
        return Icons.palette;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'birth':
        return AppTheme.semanticGreen;
      case 'death':
        return AppTheme.neonPurple;
      case 'relationship':
        return AppTheme.neonMagenta;
      case 'ritual':
        return AppTheme.semanticYellow;
      case 'era_change':
        return AppTheme.semanticBlue;
      case 'cultural':
        return AppTheme.neonPurple;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = event['type'] ?? 'event';
    final title = event['title'] ?? 'Event';
    final description = event['description'] ?? '';
    final timestamp = event['timestamp'] ?? '';
    final color = _getEventColor(type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getEventIcon(type), size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CULTURE SCREEN
// ============================================================================

class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _rituals = [];
  List<dynamic> _movements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCulture();
  }

  Future<void> _loadCulture() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getActiveRituals(),
        _api.getCulturalMovements(),
      ]);
      setState(() {
        _rituals = results[0];
        _movements = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _buildCultureContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.neonMagenta, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Culture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Rituals, beliefs & movements',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadCulture,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Icon(Icons.refresh, size: 18, color: AppTheme.textDim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(AppTheme.neonMagenta),
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Unable to load culture',
      description: _error,
      action: CleanButton(
        text: 'Retry',
        icon: Icons.refresh,
        onPressed: _loadCulture,
      ),
    );
  }

  Widget _buildCultureContent() {
    if (_rituals.isEmpty && _movements.isEmpty) {
      return const EmptyState(
        icon: Icons.auto_awesome,
        title: 'Culture emerging',
        description: 'The civilization is developing its traditions...',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCulture,
      color: AppTheme.neonMagenta,
      backgroundColor: AppTheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_rituals.isNotEmpty) ...[
              _buildSectionHeader('Active Rituals', Icons.celebration),
              const SizedBox(height: 12),
              ..._rituals.map((r) => _RitualCard(ritual: r)),
              const SizedBox(height: 24),
            ],
            if (_movements.isNotEmpty) ...[
              _buildSectionHeader('Cultural Movements', Icons.campaign),
              const SizedBox(height: 12),
              ..._movements.map((m) => _MovementCard(movement: m)),
            ],
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _RitualCard extends StatelessWidget {
  final Map<String, dynamic> ritual;

  const _RitualCard({required this.ritual});

  @override
  Widget build(BuildContext context) {
    final name = ritual['name'] ?? 'Unnamed Ritual';
    final description = ritual['description'] ?? '';
    final participants = ritual['participants'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.semanticYellow.withValues(alpha: 0.1),
            AppTheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.semanticYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.celebration, size: 18, color: AppTheme.semanticYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.overlayLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      participants.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  final Map<String, dynamic> movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final name = movement['name'] ?? 'Unnamed Movement';
    final description = movement['description'] ?? '';
    final followers = movement['followers'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, size: 18, color: AppTheme.neonPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$followers followers',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.neonPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
