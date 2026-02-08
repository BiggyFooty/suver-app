import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class ProfileScreen extends StatelessWidget {
  final double waterSaved;
  final int level;
  final int points;
  final VoidCallback onOpenNotifications;

  const ProfileScreen({
    super.key,
    required this.waterSaved,
    required this.level,
    required this.points,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatsPanel(context),
            _buildBadgesPreview(context),
            _buildSettingsMenu(context),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceHighlight,
                  border: Border.all(color: AppColors.backgroundDark, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(Icons.person, size: 40, color: Colors.white.withValues(alpha: 0.5)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.backgroundDark, width: 3),
                  ),
                  child: const Icon(Icons.edit, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Ahmet Yılmaz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('@ahmetyilmaz', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Üyelik: 15 Ocak 2026', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Expanded(child: _StatItem(value: '${waterSaved.toStringAsFixed(1)}L', label: 'Su Tasarrufu')),
            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1)),
            Expanded(child: _StatItem(value: 'Level $level', label: 'Üyelik')),
            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1)),
            Expanded(child: _StatItem(value: '$points', label: 'Puan')),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Son Rozetler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Tümünü Gör', style: TextStyle(color: AppColors.primary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _BadgePreviewCard(icon: Icons.water_drop, color: Colors.blue, label: 'İlk Damla')),
              const SizedBox(width: 8),
              Expanded(child: _BadgePreviewCard(icon: Icons.eco, color: Colors.green, label: 'Çevre Dostu')),
              const SizedBox(width: 8),
              Expanded(child: _BadgePreviewCard(icon: Icons.loyalty, color: Colors.purple, label: 'Sadık')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    // Removed payment-related item
    final menuItems = [
      {'icon': Icons.person, 'title': 'Hesap Bilgileri', 'desc': 'Profil ve kişisel bilgiler', 'color': Colors.blue},
      {'icon': Icons.notifications, 'title': 'Bildirimler', 'desc': 'Uygulama bildirim ayarları', 'color': Colors.amber, 'action': onOpenNotifications},
      {'icon': Icons.language, 'title': 'Dil Seçimi', 'desc': 'Türkçe', 'color': Colors.purple},
      {'icon': Icons.help, 'title': 'Yardım & Destek', 'desc': 'SSS ve iletişim', 'color': Colors.orange},
      {'icon': Icons.policy, 'title': 'Gizlilik Politikası', 'desc': 'Kullanım koşulları', 'color': Colors.cyan},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          ...menuItems.map((item) => _SettingsMenuItem(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            desc: item['desc'] as String,
            iconColor: item['color'] as Color,
            onTap: item['action'] as VoidCallback? ?? () {},
          )),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {},
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 14),
          borderColor: Colors.red.withValues(alpha: 0.2),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
      ],
    );
  }
}

class _BadgePreviewCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _BadgePreviewCard({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color iconColor;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: GlassPanel(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(desc, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
