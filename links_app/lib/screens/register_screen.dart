import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

@override
Widget build(BuildContext context){
  return Scaffold(
    backgroundColor: const Color(0xFFFDFCF9),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(),
            const SizedBox(height: 20),
            const Text('Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),
            registerFields(),
          ],
        ),
      ),
    ),
  );
}
// Back button to home
  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => context.go('/home'),
      ),
    );
  }
// login fields

  Widget registerFields() {
    return Column(
      children: [
        TextField(
          controller: firstNameController,
          decoration: const InputDecoration(labelText: 'First Name'),
        ),
        TextField(
          controller: lastNameController,
          decoration: const InputDecoration(labelText: 'Last Name'),
        ),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final authNotifier = AuthNotifier();
            authNotifier.register(
              firstNameController.text,
              lastNameController.text,
              emailController.text,
              passwordController.text,
            ).then((success) {
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration successful! Logging you in...')),
                );
                authNotifier.login(
                  emailController.text,
                  passwordController.text,
                ).then((loginSuccess) {
                  if (loginSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful! Redirecting to homepage...')),
                    );
                  }
                }
                );
                context.go('/groups');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration failed. Please try again.')),
                );
              }
            });
          },
          child: const Text('Register'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Already have an account? Log in'),
        ),
      ],
    );
  }
}