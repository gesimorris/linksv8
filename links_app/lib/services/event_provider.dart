import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// 1. SEARCH QUERY PROVIDER
// This stores the string the user types into the search bar.
final searchQueryProvider = StateProvider<String>((ref) => "");

final filteredEventsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();

  final allGroups = [
    {
      'id': '1',
      'hostName': 'Gesi',
      'hostRating': 4.8,
      'venue': 'Cat Cafe',
      'desc': 'Looking for 2 people to grab lattes and pet cats!',
      'spots': '2 spots left',
      'maxAttendees': 4,
      'date': 'April 17, 2:30 PM',
      'isPublic': true,
      'color': const Color(0xFF00D2FF),
      'venueDescription': 'A cozy spot in downtown Kamloops with rescue cats and great coffee.',
    },
    {
      'id': '2',
      'hostName': 'Shalom',
      'hostRating': 4.9,
      'venue': 'Art Party',
      'desc': 'Painting crew! No experience needed, just vibes.',
      'spots': '4 spots left',
      'maxAttendees': 6,
      'date': 'April 20, 2:30 PM',
      'isPublic': true,
      'color': const Color(0xFFFF5C4D),
      'venueDescription': 'Kamloops local creative studio for paint nights and workshops.',
    },
  ];

  if (query.isEmpty) return allGroups;

  return allGroups.where((g) {
    return g['venue'].toString().toLowerCase().contains(query) || 
           g['desc'].toString().toLowerCase().contains(query);
  }).toList();
});