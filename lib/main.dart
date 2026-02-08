import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/bottom_nav.dart';
import 'overlays/overlays.dart';

void main() {
  runApp(const SuverApp());
}

class SuverApp extends StatelessWidget {
  const SuverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuVer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigator(),
    );
  }
}

enum FlowState { idle, scanning, playingAd, success }

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  FlowState _flowState = FlowState.idle;
  bool _showNotifications = false;
  
  // User stats
  double _waterSaved = 12.5;
  int _level = 3;
  int _points = 85;

  void _onScan() {
    setState(() => _flowState = FlowState.scanning);
  }

  void _onScanComplete() {
    setState(() => _flowState = FlowState.playingAd);
  }

  void _onAdComplete() {
    setState(() {
      _flowState = FlowState.success;
      _waterSaved += 0.33;
      _points += 10;
    });
  }

  void _onSuccessDismiss() {
    setState(() {
      _flowState = FlowState.idle;
      _currentIndex = 0;
    });
  }

  void _openNotifications() {
    setState(() => _showNotifications = true);
  }

  void _closeNotifications() {
    setState(() => _showNotifications = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Main content
          if (_showNotifications)
            NotificationsScreen(onBack: _closeNotifications)
          else
            IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  onScan: _onScan,
                  onOpenNotifications: _openNotifications,
                ),
                const AchievementsScreen(),
                const MapScreen(),
                ProfileScreen(
                  waterSaved: _waterSaved,
                  level: _level,
                  points: _points,
                  onOpenNotifications: _openNotifications,
                ),
              ],
            ),
          
          // Bottom navigation (only when idle)
          if (_flowState == FlowState.idle && !_showNotifications)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                onScan: _onScan,
              ),
            ),
          
          // Overlays
          if (_flowState == FlowState.scanning)
            ScannerOverlay(
              onClose: () => setState(() => _flowState = FlowState.idle),
              onScanComplete: _onScanComplete,
            ),
          if (_flowState == FlowState.playingAd)
            AdOverlay(onComplete: _onAdComplete),
          if (_flowState == FlowState.success)
            SuccessOverlay(onDismiss: _onSuccessDismiss),
        ],
      ),
    );
  }
}
