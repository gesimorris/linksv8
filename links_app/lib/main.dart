import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:links_app/screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/friends_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ],
    ),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
    GoRoute(path: '/groups', builder: (context, state) => const GroupsScreen()),
    GoRoute(path: '/friends', builder: (context, state) => const FriendsScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  ],
);

void main() {
  runApp(const ProviderScope(child: LinksApp()));
}

class LinksApp extends StatelessWidget {
  const LinksApp({super.key});

  // Global Color Constants
  static const Color kPrimary = Color(0xFFFF5C4D);    // Electric Coral
  static const Color kBackground = Color(0xFFFDFCF9); // Warm Cream/Paper
  static const Color kDark = Color(0xFF1A1A1A);       // Deep Charcoal

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Links',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, // Change to Light
        scaffoldBackgroundColor: kBackground,
        primaryColor: kPrimary,
        // Using 'Outfit' is a great choice—it's very bubbly and modern
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
        
        // Bubbly Elevated Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // Extra rounded
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Modern Outlined Buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kDark,
            side: BorderSide(color: kDark.withOpacity(0.1), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // Clean Input Fields for Light Mode
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: kDark.withOpacity(0.3)),
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kDark.withOpacity(0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: kDark.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
        ),
      ),
    );
  }
}