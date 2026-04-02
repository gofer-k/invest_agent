
import 'package:flutter/foundation.dart';
import 'package:riverpod/src/framework.dart';

final class LoggerRiverpod extends ProviderObserver{
  const LoggerRiverpod();

  @override
  void didUpdateProvider(
      ProviderObserverContext context, Object? previousValue, Object? newValue) {
    if (kDebugMode) {
      print('''
    {
    "provider": "${context.provider.name}",
    "oldValue": "$previousValue",
    "newValue": "$newValue",
    mutation: "${context.mutation}"    
    }
    ''');
    }
  }
}