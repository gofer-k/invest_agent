
import 'package:flutter/foundation.dart';
import 'package:riverpod/src/framework.dart';

final class LoggerRiverpod extends ProviderObserver{
  const LoggerRiverpod();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (kDebugMode) {
      print('''
    {
    "added": "${context.provider.name}",
    "argument:": "${context.provider.argument}",
    "value": "$value",
    }
    ''');
    }
  }

  @override
  void didUpdateProvider(
      ProviderObserverContext context, Object? previousValue, Object? newValue) {
    if (kDebugMode) {
      print('''
    {
    "update": "${context.provider.name}",
    "argument:": "${context.provider.argument}",
    mutation: "${context.mutation}"    
    }
    ''');
    }
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kDebugMode) {
      print('''
    {
    "disposal": "${context.provider.name}",
    "argument:": "${context.provider.argument}",
    }
    ''');
    }
  }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace _) {
    if (kDebugMode) {
      print('''
    {
    "fail": "${context.provider.name}",
    "argument:": "${context.provider.argument}",
    "error": "$error",
    }
    ''');
    }
  }
}