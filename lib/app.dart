import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'screens/clock_screen.dart';
import 'theme/app_theme.dart';

class NdClockApp extends ConsumerWidget {
  const NdClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Prism',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(settings),
      home: const ClockScreen(),
    );
  }
}
