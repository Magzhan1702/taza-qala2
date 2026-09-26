import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'alibek@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'Taza Qala',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Қалалық мәселелерді тез тіркеп, балл жинаңыз.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSoft),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Құпиясөз'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(authRepositoryProvider)
                      .signInWithEmail(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                  if (!context.mounted) return;
                  context.go(AppRoutes.home);
                },
                child: const Text('Кіру'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signInWithGoogle();
                  if (!context.mounted) return;
                  context.go(AppRoutes.home);
                },
                icon: const Icon(Icons.login),
                label: const Text('Google арқылы кіру'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('Тіркелу'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
