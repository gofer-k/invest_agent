// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadDatabase)
final loadDatabaseProvider = LoadDatabaseProvider._();

final class LoadDatabaseProvider
    extends $AsyncNotifierProvider<LoadDatabase, String> {
  LoadDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadDatabaseHash();

  @$internal
  @override
  LoadDatabase create() => LoadDatabase();
}

String _$loadDatabaseHash() => r'9be40eeb1f4dfc242663a882ebf85097b936e2f8';

abstract class _$LoadDatabase extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(databaseHelper)
final databaseHelperProvider = DatabaseHelperProvider._();

final class DatabaseHelperProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseHelper>,
          DatabaseHelper,
          FutureOr<DatabaseHelper>
        >
    with $FutureModifier<DatabaseHelper>, $FutureProvider<DatabaseHelper> {
  DatabaseHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseHelperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHelperHash();

  @$internal
  @override
  $FutureProviderElement<DatabaseHelper> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseHelper> create(Ref ref) {
    return databaseHelper(ref);
  }
}

String _$databaseHelperHash() => r'8d5f2b1dfff64d8e31d057e48fc29d11f32b65ee';

@ProviderFor(appCacheHelper)
final appCacheHelperProvider = AppCacheHelperFamily._();

final class AppCacheHelperProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseHelper>,
          DatabaseHelper,
          FutureOr<DatabaseHelper>
        >
    with $FutureModifier<DatabaseHelper>, $FutureProvider<DatabaseHelper> {
  AppCacheHelperProvider._({
    required AppCacheHelperFamily super.from,
    required (String, CacheSchema) super.argument,
  }) : super(
         retry: null,
         name: r'appCacheHelperProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appCacheHelperHash();

  @override
  String toString() {
    return r'appCacheHelperProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DatabaseHelper> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseHelper> create(Ref ref) {
    final argument = this.argument as (String, CacheSchema);
    return appCacheHelper(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AppCacheHelperProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appCacheHelperHash() => r'606faac88e5b7b9ad2170f8e802f9bf539b05267';

final class AppCacheHelperFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DatabaseHelper>,
          (String, CacheSchema)
        > {
  AppCacheHelperFamily._()
    : super(
        retry: null,
        name: r'appCacheHelperProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AppCacheHelperProvider call(String path, CacheSchema schema) =>
      AppCacheHelperProvider._(argument: (path, schema), from: this);

  @override
  String toString() => r'appCacheHelperProvider';
}
