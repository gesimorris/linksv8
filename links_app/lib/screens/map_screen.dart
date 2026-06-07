import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart'; // For bottomNav

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _kamloopsCenter = const LatLng(50.6745, -120.3273);
  
  static const Color kPrimary = Color(0xFFFF5C4D);   // Coral/Red for LIVE
  static const Color kSecondary = Color(0xFF00D2FF); // Blue for VENUES
  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBackground = Color(0xFFFDFCF9);

  // Hybrid Data: Venues (Permanent) and Groups (Live)
  final List<Map<String, dynamic>> _mapPoints = [
    {
      'type': 'venue',
      'name': 'EXIT Kamloops',
      'pos': const LatLng(50.6750, -120.3320),
      'icon': Icons.vpn_key,
      'color': kSecondary,
      'desc': 'Escape rooms for all skill levels. Great for groups of 4-6.',
    },
    {
      'type': 'live',
      'hostName': 'Marcus',
      'hostRating': 4.9,
      'title': 'Skate Session @ McArthur',
      'pos': const LatLng(50.6890, -120.3600),
      'icon': Icons.skateboarding,
      'color': kPrimary,
      'spots': '3 spots left',
    },
    {
      'type': 'venue',
      'name': 'The Blue Grotto',
      'pos': const LatLng(50.6740, -120.3280),
      'icon': Icons.music_note,
      'color': Colors.purpleAccent,
      'desc': 'Live music home. 21+ on weekends, all ages for special shows.',
    },
    {
      'type': 'live',
      'hostName': 'Sarah',
      'hostRating': 4.7,
      'title': 'Board Games at The Den',
      'pos': const LatLng(50.6690, -120.3650),
      'icon': Icons.casino,
      'color': kPrimary,
      'spots': '2 people needed',
    },
  ];

  // --- UNIFIED MODAL LOGIC ---
  void _showDetailModal(Map<String, dynamic> point) {
    bool isLive = point['type'] == 'live';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isLive ? point['title'] : point['name'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark),
                    ),
                  ),
                  Icon(point['icon'], color: point['color'], size: 28),
                ],
              ),
              const SizedBox(height: 8),
              if (isLive) ...[
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    Text(" ${point['hostRating']} reliability · Hosted by ${point['hostName']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 15),
                Text(point['spots'], style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w900)),
              ] else ...[
                Text(point['desc'], style: const TextStyle(color: Colors.black54, height: 1.4)),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive ? kPrimary : kDark,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(isLive ? "I'm Down!" : "See Groups Here", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LONG PRESS TO PLAN ---
  void _handleLongPress(LatLng point) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Plan something at this coordinate?"),
        backgroundColor: kDark,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "YES", 
          textColor: kPrimary,
          onPressed: () => print("Navigating to create with: $point"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.04), BlendMode.saturation),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _kamloopsCenter,
                initialZoom: 14.0,
                onLongPress: (tapPos, point) => _handleLongPress(point),
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(
                  markers: _mapPoints.map((p) => _buildMarker(p)).toList(),
                ),
              ],
            ),
          ),

          // TOP OVERLAY
          SafeArea(
            child: Column(
              children: [
                _searchBar(),
                _categoryChips(),
              ],
            ),
          ),

          Align(alignment: Alignment.bottomCenter, child: bottomNav(context, 1)),
        ],
      ),
    );
  }

  Marker _buildMarker(Map<String, dynamic> p) {
    bool isLive = p['type'] == 'live';
    return Marker(
      point: p['pos'],
      width: 120,
      height: 80,
      child: GestureDetector(
        onTap: () => _showDetailModal(p),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLive ? kPrimary : Colors.white,
                shape: BoxShape.circle,
                border: isLive ? Border.all(color: Colors.white, width: 2) : null,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Icon(p['icon'], color: isLive ? Colors.white : p['color'], size: 20),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isLive ? p['hostName'] : p['name'],
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: const Row(
          children: [
            Icon(Icons.search, color: kPrimary, size: 20),
            SizedBox(width: 12),
            Text("What are you looking for?", style: TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _categoryChips() {
    final tags = ['🔥 Hot', '🛹 Skate', '🎨 Art', '🍔 Food', '🎓 TRU'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.05))),
          alignment: Alignment.center,
          child: Text(tags[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}