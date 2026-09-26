import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Runs with local mock repositories until Firebase is configured.
  }

  runApp(const ProviderScope(child: TazaQalaApp()));
}

class TazaQalaApp extends ConsumerWidget {
  const TazaQalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Taza Qala',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
