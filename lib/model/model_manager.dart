import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers.dart';
import 'user_account.dart';

part 'model_manager.g.dart';

/// The state for ModelManager, holding in-memory cache of different models.
@immutable
class ModelManagerState {
  final Map<Type, List<Cache>> cache;

  const ModelManagerState({this.cache = const {}});

  ModelManagerState copyWith({Map<Type, List<Cache>>? cache}) {
    return ModelManagerState(cache: cache ?? this.cache);
  }

  List<T> getItems<T extends Cache>() => cache[T]?.cast<T>() ?? [];
}

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
@riverpod
class ModelManager extends _$ModelManager {
  late final DatabaseHelper _db;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ModelManagerState build() {
    _db = ref.watch(databaseHelperProvider);
    _db.createCache(UserAccountSchema());
    _db.createCache(PortfolioConfigSchema());
    return const ModelManagerState();
  }

  /// Loads data from the database into memory.
  Future<void> fetch<T extends Cache>(CacheSchema schema) async {
    try {
      final items = await _db.fetchAll<T>(schema);
      state = state.copyWith(
        cache: {
          ...state.cache,
          T: items,
        },
      );
    } catch (e) {
      debugPrint('ModelManager Error (fetch $T): $e');
    }
  }

  /// Specialized save for [UserAccount] with secure storage integration.
  Future<void> saveUserAccount(UserAccount account, {String? apiKey, String? apiSecret}) async {
    try {
      if (apiKey != null) {
        await _secureStorage.write(key: 'auth_${account.name}_apiKey', value: apiKey);
      }
      if (apiSecret != null) {
        await _secureStorage.write(key: 'auth_${account.name}_apiSecret', value: apiSecret);
      }

      final dbAccount = UserAccount(
        id: account.id,
        name: account.name,
        apiKey: 'SECURE_STORAGE',
        apiSecret: 'SECURE_STORAGE',
        providerData: account.providerData,
      );

      await _db.saveOne(UserAccountSchema(), dbAccount);
      await fetch<UserAccount>(UserAccountSchema());
    } catch (e) {
      debugPrint('ModelManager Error (saveUserAccount): $e');
    }
  }

  Future<Map<String, String?>> getAccountSecrets(UserAccount account) async {
    final apiKey = await _secureStorage.read(key: 'auth_${account.name}_apiKey');
    final apiSecret = await _secureStorage.read(key: 'auth_${account.name}_apiSecret');
    return {'apiKey': apiKey, 'apiSecret': apiSecret};
  }

  Future<void> update<T extends Cache>(CacheSchema schema, T item) async {
    await _db.updateOne(schema, item);
    await fetch<T>(schema);
  }

  Future<void> delete<T extends Cache>(CacheSchema schema, T item) async {
    if (item is UserAccount) {
      await _secureStorage.delete(key: 'auth_${item.name}_apiKey');
      await _secureStorage.delete(key: 'auth_${item.name}_apiSecret');
    }
    await _db.deleteOne(schema, item);
    await fetch<T>(schema);
  }
}
