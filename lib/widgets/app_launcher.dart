import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/load_database_provider.dart';

class AppLauncher extends ConsumerWidget{
  final WidgetBuilder onLoaded;

  const AppLauncher({super.key, required this.onLoaded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSource = ref.watch(loadDatabaseProvider);
    return dataSource.when(
      data: (_) => onLoaded(context),
      error: (Object error, StackTrace stackTrace) {
        return Text(error.toString());
      },
      loading: () {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Loading...'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ]
        );
      }
    );
  }
}
