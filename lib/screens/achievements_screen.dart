import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static final _badges = [
    {'id': 1, 'name': 'İlk Damla', 'icon': Icons.water_drop, 'color': Colors.blue, 'unlocked': true},
    {'id': 2, 'name': 'Çevre Dostu', 'icon': Icons.eco, 'color': Colors.green, 'unlocked': true},
    {'id': 3, 'name': 'Sadık Kullanıcı', 'icon': Icons.loyalty, 'color': Colors.purple, 'unlocked': true},
    {'id': 4, 'name': 'Su Elçisi', 'icon': Icons.campaign, 'color': Colors.amber, 'unlocked': false},
    {'id': 5, 'name': 'Tasarruf Şampiyonu', 'icon': Icons.emoji_events, 'color': Colors.orange, 'unlocked': false},
    {'id': 6, 'name': 'Harita Kaşifi', 'icon': Icons.explore, 'color': Colors.cyan, 'unlocked': true},
  ];

  static final _achievements = [
    {'title': 'Bronz Damla Rozeti', 'desc': 'İlk 50 litre tasarruf', 'date': '2 gün önce', 'icon': Icons.military_tech, 'color': const Color(0xFFD97706)},
    {'title': 'Haftalık Hedef', 'desc': '7 günlük seri tamamlandı', 'date': '1 gün önce', 'icon': Icons.calendar_today, 'color': AppColors.primary},
    {'title': 'Yeni Seviye!', 'desc': "Seviye 3'e ulaştınız", 'date': '3 saat önce', 'icon': Icons.trending_up, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
          title: const Text('Başarılar', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
        // Stats Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildBadgesSection(context),
                const SizedBox(height: 24),
                _buildRecentAchievements(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(icon: Icons.account_balance_wallet, iconColor: AppColors.primary, label: 'Tasarruf', value: '150 TL')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.water_drop, iconColor: Colors.green, label: 'Doğa', value: '500 LT')),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(icon: Icons.military_tech, iconColor: Colors.purple, label: 'Elçi', value: 'Seviye 3', fullWidth: true),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rozetler', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Kazandığınız başarılar', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _badges.length,
          itemBuilder: (context, index) {
            final badge = _badges[index];
            final unlocked = badge['unlocked'] as bool;
            return _BadgeCard(
              icon: badge['icon'] as IconData,
              name: badge['name'] as String,
              color: badge['color'] as Color,
              unlocked: unlocked,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son Başarılar', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ..._achievements.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(a['desc'] as String, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(a['date'] as String, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1.5)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final bool unlocked;

  const _BadgeCard({
    required this.icon,
    required this.name,
    required this.color,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: unlocked ? 0.1 : 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: unlocked ? color : AppColors.textMuted, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: unlocked ? Colors.white : AppColors.textMuted),
            ),
            if (unlocked) ...[
              const SizedBox(height: 4),
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
