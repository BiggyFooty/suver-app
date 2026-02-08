import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class ScannerOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onScanComplete;

  const ScannerOverlay({
    super.key,
    required this.onClose,
    required this.onScanComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Simulate scan after 3 seconds
    Future.delayed(const Duration(seconds: 3), onScanComplete);

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // Dark overlay with cutout
          Container(color: Colors.black54),
          
          // Header
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QR Tara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
          
          // Scanner frame
          Center(
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Animated scan line
                  _ScanLine(),
                ],
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Otomat üzerindeki kodu okutun',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * 240,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const AdOverlay({super.key, required this.onComplete});

  @override
  State<AdOverlay> createState() => _AdOverlayState();
}

class _AdOverlayState extends State<AdOverlay> {
  VideoPlayerController? _controller;
  int _timeLeft = 15;
  Timer? _timer;
  bool _isVideoReady = false;
  String _currentVideoPath = '';

  static const _adVideos = [
    'assets/ads/BeyogluOtomatAds.mp4',
    'assets/ads/SuVerAdsmascot.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Pick random video
    final random = Random();
    _currentVideoPath = _adVideos[random.nextInt(_adVideos.length)];
    
    _controller = VideoPlayerController.asset(_currentVideoPath);
    
    try {
      await _controller!.initialize();
      await _controller!.setLooping(false);
      await _controller!.play();
      
      setState(() {
        _isVideoReady = true;
        // Use video duration or default 15s
        _timeLeft = _controller!.value.duration.inSeconds > 0 
            ? _controller!.value.duration.inSeconds 
            : 15;
      });
      
      _startTimer();
      
      // Listen for video completion
      _controller!.addListener(() {
        if (_controller!.value.position >= _controller!.value.duration) {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    } catch (e) {
      // If video fails, fall back to countdown
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        widget.onComplete();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or gradient background
          if (_isVideoReady && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.purple.shade900,
                    Colors.black,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Reklam yükleniyor...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ),
          
          // Timer badge
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'Sponsor Reklamı • ${_timeLeft}s',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
          
          // Progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.white.withValues(alpha: 0.2),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _controller != null && _controller!.value.duration.inSeconds > 0
                    ? _controller!.value.position.inSeconds / _controller!.value.duration.inSeconds
                    : (15 - _timeLeft) / 15,
                child: Container(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const SuccessOverlay({super.key, required this.onDismiss});

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(Icons.water_drop, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Su Hazırlanıyor!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Afiyet Olsun.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '+10 Puan & 330ml Eklendi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
