import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/auth_provider.dart'; 
import '../services/event_provider.dart'; // Import your new logic file

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final DraggableScrollableController _sheetController = DraggableScrollableController();

  static const Color kBackground = Color(0xFFFDFCF9);
  static const Color kPrimary = Color(0xFFFF5C4D);
  static const Color kSecondary = Color(0xFF00D2FF);
  static const Color kDark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (next.isNotEmpty) {
        // Expand to full screen (1.0) when typing
        _sheetController.animateTo(
          0.8, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      } else {
        // Snap back to original size (0.35) when cleared
        _sheetController.animateTo(
          0.35, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeIn
        );
      }
    });

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          if (searchQuery.isEmpty) _mapLayer(),
          _topOverlay(context, ref, authState),
          _draggableEventSheet(context, ref),
        ],
      ),
      bottomNavigationBar: bottomNav(context, 0),
    );
  }

  // --- FROSTED GLASS PROFILE MODAL ---
  void _showProfileModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Profile",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 35),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 45, 
                      backgroundColor: kDark, 
                      child: Text('G', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(height: 20),
                    const Text('Gesi Morris-Odubo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const Text('Kamloops, BC', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 25),
                    _profileStat('Joined', 'April 2026'),
                    _profileStat('Groups', '12 Active'),
                    _profileStat('Friends', '48 Connections'),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: const Text('Return to Explore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        AuthNotifier().logout();
                        Navigator.pop(context);
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _profileStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black45)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: kDark)),
        ],
      ),
    );
  }

  // --- MAP ---
  Widget _mapLayer() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(50.6712, -120.3638),
        initialZoom: 14.0,
        interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.links.app',
        ),
        MarkerLayer(
          markers: [
            _buildMapMarker(LatLng(50.6761, -120.3408), Icons.pets, kSecondary),
            _buildMapMarker(LatLng(50.6720, -120.3300), Icons.palette, kPrimary),
          ],
        ),
      ],
    );
  }

  Marker _buildMapMarker(LatLng point, IconData icon, Color color) {
    return Marker(
      point: point,
      width: 45,
      height: 45,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // --- SEARCH OVERLAY ---
  Widget _topOverlay(BuildContext context, WidgetRef ref, bool authState) {
    final searchQuery = ref.watch(searchQueryProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                ),
                child: TextField(
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,

                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, size: 20, color: Colors.black26),
                    hintText: 'Search venues or groups...',
                    hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.black26),
                            onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            authState ? _memberActions(context) : _guestActions(context),
            
          ],
        ),
      ),
    );
  }

  Widget _guestActions(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/register'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(25)),
        child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _memberActions(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showProfileModal(context),
          child: const CircleAvatar(radius: 24, backgroundColor: kDark, child: Text('G', style: TextStyle(color: Colors.white))),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  // --- EVENT SHEET ---
Widget _draggableEventSheet(BuildContext context, WidgetRef ref) {
    final events = ref.watch(filteredEventsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return DraggableScrollableSheet(
      controller: _sheetController, // ATTACH THE CONTROLLER
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.7, // Allow it to cover the whole screen
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: kBackground,
            // Only show rounded corners if not full screen
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(searchQuery.isNotEmpty ? 0 : 32)
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            itemCount: events.length + 2,
            itemBuilder: (context, index) {
              // Header logic...
              if (index == 0) return _dragHandle(searchQuery.isEmpty);
              if (index == 1) return _sectionHeader(searchQuery.isNotEmpty ? 'RESULTS' : 'HAPPENING SOON');
              
              final group = events[index - 2];
              return _buddyCard(context, group);
            },
          ),
        );
      },
    );
  }

  Widget _dragHandle(bool show) {
    if (!show) return const SizedBox(height: 10); // Minimal space when full screen
    return Center(
      child: Container(
        width: 45, 
        height: 6, 
        margin: const EdgeInsets.only(bottom: 25), 
        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10))
      )
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), 
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.black26))
    );
  }


Widget _buddyCard(BuildContext context, Map<String, dynamic> group) {
  final accent = group['color'] as Color;
  
  return GestureDetector(
    onTap: () => _showGroupDetailModal(context, group),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: kDark,
                child: Text(group['hostName'][0], style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Text(group['hostName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              const Icon(Icons.star, color: Colors.orange, size: 14),
              Text(" ${group['hostRating']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(group['venue'], style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 4),
          Text(group['desc'], style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(group['date'], style: const TextStyle(fontSize: 12, color: Colors.black38)),
          Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: accent),
              const SizedBox(width: 4),
              Text(group['spots'], style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );
}

void _showGroupDetailModal(BuildContext context, Map<String, dynamic> group) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "GroupDetail",
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${group['hostName']} is looking for ${group['spots']} to go with on ${group['day']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text("${group['hostRating']} Reliability Rating", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black45)),
                    ],
                  ),
                  const Divider(height: 32),
                  _modalInfoRow(Icons.location_on, "Venue", group['venue']),
                  _modalInfoRow(Icons.info_outline, "About", group['venueDescription']),
                  _modalInfoRow(Icons.calendar_today, "Time", "${group['day']} at ${group['time']}"),
                  _modalInfoRow(Icons.people, "Capacity", "Max ${group['maxAttendees']} attendees"),
                  _modalInfoRow(
                    group['isPublic'] ? Icons.public : Icons.lock, 
                    "Privacy", 
                    group['isPublic'] ? "Open to Public" : "Invite Only"
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => print("Joined group!"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("I'm Interested!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _modalInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}
}
// --- BOTTOM NAV (Shared) ---
Widget bottomNav(BuildContext context, int active) {
  final items = [
    {'icon': Icons.explore_outlined, 'label': 'Explore', 'route': '/home'},
    {'icon': Icons.map_outlined, 'label': 'Map', 'route': '/map'},
    {'icon': Icons.group_outlined, 'label': 'Groups', 'route': '/groups'},
    {'icon': Icons.people_outline, 'label': 'Friends', 'route': '/friends'},
  ];

  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
    ),
    child: SafeArea(
      top: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == active;
          return GestureDetector(
            onTap: () => context.go(item['route'] as String),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, size: 24, color: isActive ? const Color(0xFFFF5C4D) : Colors.black26),
                  const SizedBox(height: 4),
                  Text(item['label'] as String, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? const Color(0xFFFF5C4D) : Colors.black26)),
                ],
              ),
            ),
          );
        }),
      ),
    ),
  );
}
