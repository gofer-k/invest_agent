
import 'package:riverpod/src/framework.dart';

final class LoggerRiverpod extends ProviderObserver{
  @override
  void didUpdateProvider(
      ProviderObserverContext context, Object? oldValue, Object? newValue) {
    print('''
    {
    "provider": "${context.provider.name}",
    "oldValue": "$oldValue",
    "newValue": "$newValue",
    mutation: "${context.mutation}"    
    }
    ''');
  }
}