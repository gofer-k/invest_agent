
import 'package:flutter/foundation.dart';
import 'package:riverpod/src/framework.dart';

final class LoggerRiverpod extends ProviderObserver{
  const LoggerRiverpod();

  static const List<String> _loggingProviders = [
    // 'tradingServiceProvider',
    // "tradingClientProvider",
    // 'indicatorResultProvider',
    // 'multiChartProvider',
    // 'multiChartsByProvider',
  ];
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (kDebugMode && _loggingProviders.contains(context.provider.name)) {
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
    if (kDebugMode && _loggingProviders.contains(context.provider.name)) {
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
    if (kDebugMode && _loggingProviders.contains(context.provider.name)) {
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
    if (kDebugMode && _loggingProviders.contains(context.provider.name)) {
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