import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class ExpiredScreen extends StatelessWidget {
  final DateTime expirationDate;

  const ExpiredScreen({super.key, required this.expirationDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassPanel(
            padding: const EdgeInsets.all(24),
            borderColor: Colors.red.withValues(alpha: 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Süre Doldu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bu uygulama sürümünün kullanım süresi\n${expirationDate.day}.${expirationDate.month}.${expirationDate.year} tarihinde dolmuştur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lütfen uygulamanın güncel sürümünü yükleyiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
