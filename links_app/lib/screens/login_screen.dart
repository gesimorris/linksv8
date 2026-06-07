import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_provider.dart'; // Adjust path to your provider

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color kPrimary = Color(0xFFFF5C4D);
  static const Color kDark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful! Redirecting..."),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () => context.go('/home'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password. Try again!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back! ✨",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kDark),
            ),
            const SizedBox(height: 10),
            const Text(
              "Log in to see who's heading to the Cat Cafe or the gym today.",
              style: TextStyle(fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // Email Field
            _buildLabel("EMAIL"),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputStyle("name@email.com", Icons.email_outlined),
            ),
            
            const SizedBox(height: 25),

            // Password Field
            _buildLabel("PASSWORD"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputStyle("••••••••", Icons.lock_outline),
            ),

            const SizedBox(height: 40),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
              ),
            ),

            const SizedBox(height: 20),
            
            Center(
              child: TextButton(
                onPressed: () => context.push('/home/register'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1.2),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kPrimary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
    );
  }
}