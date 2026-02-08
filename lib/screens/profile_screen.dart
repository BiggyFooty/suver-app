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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          _buildHeader(context),
          _buildStatsPanel(context),
          _buildBadgesPreview(context),
          _buildSettingsMenu(context),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceHighlight,
                        border: Border.all(color: AppColors.backgroundDark, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(Icons.person, size: 48, color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.backgroundDark, width: 4),
                        ),
                        child: const Icon(Icons.edit, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Ahmet Yılmaz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('@ahmetyilmaz', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('Üyelik: 15 Ocak 2026', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _StatItem(value: '${waterSaved.toStringAsFixed(1)}L', label: 'Su Tasarrufu')),
            Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
            Expanded(child: _StatItem(value: 'Level $level', label: 'Üyelik')),
            Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
            Expanded(child: _StatItem(value: '$points', label: 'Puan')),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Son Rozetler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () {},
                child: Text('Tümünü Gör', style: TextStyle(color: AppColors.primary, fontSize: 12)),
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
    final menuItems = [
      {'icon': Icons.person, 'title': 'Hesap Bilgileri', 'desc': 'Profil ve kişisel bilgiler', 'color': Colors.blue},
      {'icon': Icons.notifications, 'title': 'Bildirimler', 'desc': 'Uygulama bildirim ayarları', 'color': Colors.amber, 'action': onOpenNotifications},
      {'icon': Icons.credit_card, 'title': 'Ödeme Yöntemleri', 'desc': 'Kayıtlı kartlar ve cüzdan', 'color': Colors.green},
      {'icon': Icons.language, 'title': 'Dil Seçimi', 'desc': 'Türkçe', 'color': Colors.purple},
      {'icon': Icons.help, 'title': 'Yardım & Destek', 'desc': 'SSS ve iletişim', 'color': Colors.orange},
      {'icon': Icons.policy, 'title': 'Gizlilik Politikası', 'desc': 'Kullanım koşulları', 'color': Colors.cyan},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GlassPanel(
        borderColor: Colors.red.withValues(alpha: 0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            const Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
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
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1)),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white), textAlign: TextAlign.center),
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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(desc, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
