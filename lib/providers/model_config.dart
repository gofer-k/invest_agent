import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/model/portfolio_config.dart';
import 'package:invest_agent/utils/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'load_database_provider.dart';
import '../model/asset_config.dart';
import '../model/user_account.dart';

part 'model_config.g.dart';

/// The state for ModelManager, holding in-memory cache of different models.

@immutable
class ModelConfigState {
  final Map<Type, List<Cache>> cache;
    const ModelConfigState({this.cache = const {}});

  ModelConfigState copyWith({Map<Type, List<Cache>>? cache}) {
    return ModelConfigState(cache: cache ?? this.cache);
  }

  List<T> getItems<T extends Cache>() => cache[T]?.cast<T>() ?? [];
}

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
@riverpod
class ModelConfig extends _$ModelConfig {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Map<Type, CacheSchema> _schemas = {
    AssetConfig: AssetConfigSchema(),
    UserAccount: UserAccountSchema(),
    PortfolioConfig: PortfolioConfigSchema()
  };

  @override
  ModelConfigState build() {
    // When the database is ready, initialize the schemas and trigger initial fetches.
    ref.listen(appConfigProvider, (previous, next) {
      next.whenData((db) async {
        try {
          await db.createCache(UserAccountSchema());
          await db.createCache(AssetConfigSchema());
          await db.createCache(PortfolioConfigSchema());

          // Trigger initial background fetches to populate the cache
          await fetchType<UserAccount>();
          await fetchType<AssetConfig>();
          await fetchType<PortfolioConfig>();
        } catch (e) {
          debugPrint('ModelManager Init Error: $e');
        }
      });
    }, fireImmediately: true);

    return const ModelConfigState();
  }

  Future<DatabaseHelper> _getDb() async {
    return await ref.read(appConfigProvider.future);
  }

  /// Loads data from the database into memory.
  Future<List<T>> fetchType<T extends Cache>() async {
    final schema = _schemas[T];
    if (schema == null) throw Exception("Schema not registered for $T");
    return await fetch<T>(schema);
  }

  /// Loads data from the database into memory.
  Future<List<T>> fetch<T extends Cache>(CacheSchema schema) async {
    try {
      final db = await _getDb();
      final items = await db.fetchAll<T>(schema);
      state = state.copyWith(
        cache: {
          ...state.cache,
          T: items,
        },
      );
      return items;
    } catch (e) {
      debugPrint('ModelManager Error (fetch $T): $e');
      return [];
    }
  }

  Future<void> save<T extends Cache>(CacheSchema schema, T item) async {
    final db = await _getDb();
    await db.saveOne(schema, item);
    await fetch<T>(schema);
  }

  Future<void> update<T extends Cache>(CacheSchema schema, T item) async {
    final db = await _getDb();
    await db.updateOne(schema, item);
    await fetch<T>(schema);
  }

  Future<void> delete<T extends Cache>(CacheSchema schema, T item) async {
    if (item is UserAccount) {
      await _secureStorage.delete(key: 'auth_${item.name}_apiKey');
      await _secureStorage.delete(key: 'auth_${item.name}_apiSecret');
    }
    final db = await _getDb();
    await db.deleteOne(schema, item);
    await fetch<T>(schema);
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

      final db = await _getDb();
      await db.saveOne(UserAccountSchema(), dbAccount);
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

  Future<bool> removeAsset(AssetConfig asset) async {
    try {
      await _getDb();

      final allPortfolios = state.getItems<PortfolioConfig>();
      final portfoliosWithAsset = allPortfolios.where(
              (p) => p.metaIds.contains(asset.id)
      );

      for (final portfolio in portfoliosWithAsset) {
        final updatedIds = portfolio.metaIds.where((id) => id != asset.id).toList();
        await update(PortfolioConfigSchema(), portfolio.copyWith(metaIds: updatedIds));
      }

      await delete(AssetConfigSchema(), asset);

      return true;
    } catch (e) {
      debugPrint('Error removing asset: $e');
      return false;
    }
  }
}

@riverpod
List<AssetConfig> sortedAssets(Ref ref) {
  final assets = ref.watch(modelConfigProvider.select(
   (s) => s.getItems<AssetConfig>()));
  return assets.toList()..sort((a, b) => a.symbol.compareTo(b.symbol));
}

@riverpod
List<PortfolioConfig> portfolios(Ref ref) {
  return ref.watch(modelConfigProvider.select(
        (s) => s.getItems<PortfolioConfig>(),
  ));
}

@riverpod
List<UserAccount> userAccounts(Ref ref) {
  return ref.watch(modelConfigProvider).getItems<UserAccount>();
}

@riverpod
Future<List<AssetConfig>> assetsLoader(Ref ref) async {
  return await ref.read(modelConfigProvider.notifier).fetchType<AssetConfig>();
}

@riverpod
Future<List<PortfolioConfig>> portfolioLoader(Ref ref) async {
  return await ref.read(modelConfigProvider.notifier).fetchType<PortfolioConfig>();
}
