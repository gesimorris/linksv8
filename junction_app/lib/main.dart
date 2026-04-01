import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!EnvConfig.isConfigured) {
    throw Exception("Missing Supabase Environment Variables");
  }

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: JunctionApp()));
}

class JunctionApp extends StatelessWidget {
  const JunctionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Junction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1616),
        primaryColor: const Color(0xFFFF7E5F),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const SocialDashboard(),
    );
  }
}

class SocialDashboard extends ConsumerStatefulWidget {
  const SocialDashboard({super.key});

  @override
  ConsumerState<SocialDashboard> createState() => _SocialDashboardState();
}

class _SocialDashboardState extends ConsumerState<SocialDashboard> {
  User? _currentUser;
  Widget _currentScreen = const PlaceholderScreen(title: "Home Feed");

  @override
  void initState() {
    super.initState();
    _currentUser = Supabase.instance.client.auth.currentUser;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() => _currentUser = data.session?.user);
      }
    });
  }

  void _navigateTo(String featureName) {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to view $featureName'),
          backgroundColor: const Color(0xFFFF7E5F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _showAuthPopup(context);
    } else {
      setState(() {
        _currentScreen = PlaceholderScreen(title: featureName);
      });
    }
  }

  void _showAuthPopup(BuildContext context) {
    bool isSigningUp = false;
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: const Color(0xFF241F1F),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isSigningUp ? 'Create Your Pass' : 'Welcome Back',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    if (isSigningUp) ...[
                      _authField('Full Name', Icons.person_outline, controller: nameController),
                      const SizedBox(height: 16),
                    ],
                    _authField('Email Address', Icons.email_outlined, controller: emailController),
                    const SizedBox(height: 16),
                    _authField('Password', Icons.lock_outline, isPassword: true, controller: passwordController),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final supabase = Supabase.instance.client;
                            if (isSigningUp) {
                              await supabase.auth.signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                data: {'full_name': nameController.text.trim()},
                              );
                            } else {
                              await supabase.auth.signInWithPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E5F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(isSigningUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => setState(() => isSigningUp = !isSigningUp),
                      child: Text(
                        isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up",
                        style: const TextStyle(color: Color(0xFFFF7E5F), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: Color(0xFF241F1F),
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('JUNCTION',
                      style: TextStyle(color: Color(0xFFFF7E5F), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2)),
                ),
                const SizedBox(height: 40),
                _sidebarHeader('EXPLORE'),
                _sidebarItem(Icons.map_outlined, 'Live Map', () => _navigateTo('Live Map')),
                _sidebarItem(Icons.local_fire_department_outlined, 'Trending Now', () => _navigateTo('Trending')),
                _sidebarItem(Icons.verified_outlined, 'Verified Hosts', () => _navigateTo('Hosts')),
                const SizedBox(height: 24),
                _sidebarHeader('SOCIAL'),
                _sidebarItem(Icons.groups_outlined, 'Friends & Groups', () => _navigateTo('Friends & Groups')),
                _sidebarItem(Icons.chat_bubble_outline, 'Messages', () => _navigateTo('Messages')),
                const SizedBox(height: 24),
                _sidebarHeader('YOUR PASS'),
                _sidebarItem(Icons.star_outline, 'Saved Events', () => _navigateTo('Saved Events')),
                _sidebarItem(Icons.confirmation_number_outlined, 'My Tickets', () => _navigateTo('Tickets')),
                _sidebarItem(Icons.settings_outlined, 'Preferences', () => _navigateTo('Preferences')),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _currentUser == null ? _buildLoginButton() : _buildProfileSection(),
                ),
              ],
            ),
          ),
          Expanded(child: _currentScreen),
        ],
      ),
    );
  }

  Widget _sidebarHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Text(title,
          style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _sidebarItem(IconData icon, String label, VoidCallback onTap) {
    bool isLocked = _currentUser == null;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isLocked ? Colors.white10 : Colors.white70),
      title: Text(label, style: TextStyle(color: isLocked ? Colors.white10 : Colors.white70, fontWeight: FontWeight.w500)),
      trailing: isLocked ? const Icon(Icons.lock_outline, size: 14, color: Colors.white10) : null,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () => _showAuthPopup(context),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: const Color(0xFFFF7E5F),
      ),
      child: const Text('Sign In / Join', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFFF7E5F), child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_currentUser?.email ?? 'User', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Supabase.instance.client.auth.signOut(),
          child: const Text('Logout', style: TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }

  Widget _authField(String hint, IconData icon, {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white24),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white24),
      ),
    );
  }
}