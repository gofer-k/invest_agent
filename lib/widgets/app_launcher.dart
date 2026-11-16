import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invest_agent/widgets/app_logo.dart';

import '../providers/load_database_provider.dart';

class AppLauncher extends ConsumerWidget{
  final WidgetBuilder onLoaded;

  const AppLauncher({super.key, required this.onLoaded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.watch(loadDatabaseProvider(CacheKeyType.priceCache));
    return dataSource.when(
      data: (_) => onLoaded(context),
      error: (Object error, StackTrace stackTrace) {
        return Scaffold(
          body: Center(
            child: Text(error.toString(), style: const TextStyle(color: Colors.red)),
          ),
        );
      },
      loading: () {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 120),
                const SizedBox(height: 24),
                const Text(
                  'Invest Agent',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Initializing financial data...',
                  style: TextStyle(color: Colors.grey),
                ),
              ]
            ),
          ),
        );
      }
    );
  }
}
