import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _defaultCenter = LatLng(41.0082, 28.9784); // Istanbul

  static final _otomatLocations = [
    {'id': 1, 'lat': 41.0284, 'lng': 28.9736, 'name': 'Beyoğlu'},
    {'id': 2, 'lat': 41.0370, 'lng': 28.9850, 'name': 'Taksim'},
    {'id': 3, 'lat': 41.0428, 'lng': 29.0075, 'name': 'Beşiktaş'},
    {'id': 4, 'lat': 40.9922, 'lng': 29.0237, 'name': 'Kadıköy'},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.suver.suver_app',
            ),
            MarkerLayer(
              markers: _otomatLocations.map((loc) {
                return Marker(
                  point: LatLng(loc['lat'] as double, loc['lng'] as double),
                  width: 40,
                  height: 40,
                  child: _buildMarker(loc['name'] as String),
                );
              }).toList(),
            ),
          ],
        ),
        // Overlay card
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassPanel(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "İstanbul'da ${_otomatLocations.length} aktif otomat var.",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarker(String name) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.water_drop,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
