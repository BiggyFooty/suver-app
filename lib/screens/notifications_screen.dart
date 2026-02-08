import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onBack});

  static final _notifications = [
    {'id': 1, 'title': 'Hoşgeldiniz!', 'message': 'SuVer ailesine katıldığınız için teşekkürler.', 'time': '2 gün önce', 'read': true, 'type': 'system'},
    {'id': 2, 'title': 'Yeni Rozet', 'message': 'Bronz Damla rozetini kazandınız!', 'time': '1 gün önce', 'read': false, 'type': 'reward'},
    {'id': 3, 'title': 'Güncelleme', 'message': 'Harita modülüne yeni otomatlar eklendi.', 'time': '2 saat önce', 'read': false, 'type': 'info'},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
          title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack ?? () => Navigator.of(context).pop(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notif = _notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(
                    title: notif['title'] as String,
                    message: notif['message'] as String,
                    time: notif['time'] as String,
                    isRead: notif['read'] as bool,
                    type: notif['type'] as String,
                  ),
                );
              },
              childCount: _notifications.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String type;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });

  IconData get _icon {
    switch (type) {
      case 'reward':
        return Icons.emoji_events;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'reward':
        return Colors.amber;
      case 'info':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  Color get _iconBgColor {
    switch (type) {
      case 'reward':
        return Colors.amber.withValues(alpha: 0.2);
      case 'info':
        return Colors.blue.withValues(alpha: 0.2);
      default:
        return Colors.white.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isRead ? 0.7 : 1.0,
      child: GlassPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(time, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
