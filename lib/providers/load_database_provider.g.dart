// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadDatabase)
final loadDatabaseProvider = LoadDatabaseFamily._();

final class LoadDatabaseProvider
    extends $AsyncNotifierProvider<LoadDatabase, String> {
  LoadDatabaseProvider._({
    required LoadDatabaseFamily super.from,
    required CacheKeyType super.argument,
  }) : super(
         retry: null,
         name: r'loadDatabaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loadDatabaseHash();

  @override
  String toString() {
    return r'loadDatabaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LoadDatabase create() => LoadDatabase();

  @override
  bool operator ==(Object other) {
    return other is LoadDatabaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loadDatabaseHash() => r'03d3d292eb3a07036839484c4de7cdf90e708633';

final class LoadDatabaseFamily extends $Family
    with
        $ClassFamilyOverride<
          LoadDatabase,
          AsyncValue<String>,
          String,
          FutureOr<String>,
          CacheKeyType
        > {
  LoadDatabaseFamily._()
    : super(
        retry: null,
        name: r'loadDatabaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LoadDatabaseProvider call(CacheKeyType cacheTYpe) =>
      LoadDatabaseProvider._(argument: cacheTYpe, from: this);

  @override
  String toString() => r'loadDatabaseProvider';
}

abstract class _$LoadDatabase extends $AsyncNotifier<String> {
  late final _$args = ref.$arg as CacheKeyType;
  CacheKeyType get cacheTYpe => _$args;

  FutureOr<String> build(CacheKeyType cacheTYpe);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

final class AppConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseHelper>,
          DatabaseHelper,
          FutureOr<DatabaseHelper>
        >
    with $FutureModifier<DatabaseHelper>, $FutureProvider<DatabaseHelper> {
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $FutureProviderElement<DatabaseHelper> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseHelper> create(Ref ref) {
    return appConfig(ref);
  }
}

String _$appConfigHash() => r'0f0de7fb59a2914475780425a7ccf121293c5628';

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

@ProviderFor(loadPrice)
final loadPriceProvider = LoadPriceFamily._();

final class LoadPriceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseHelper>,
          DatabaseHelper,
          FutureOr<DatabaseHelper>
        >
    with $FutureModifier<DatabaseHelper>, $FutureProvider<DatabaseHelper> {
  LoadPriceProvider._({
    required LoadPriceFamily super.from,
    required (CacheKeyType?, bool) super.argument,
  }) : super(
         retry: null,
         name: r'loadPriceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loadPriceHash();

  @override
  String toString() {
    return r'loadPriceProvider'
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
    final argument = this.argument as (CacheKeyType?, bool);
    return loadPrice(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadPriceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loadPriceHash() => r'7d95211f7dcc1d17c2b06d8c9a1d484ed7b8fc30';

final class LoadPriceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DatabaseHelper>,
          (CacheKeyType?, bool)
        > {
  LoadPriceFamily._()
    : super(
        retry: null,
        name: r'loadPriceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LoadPriceProvider call(CacheKeyType? type, bool keepAlive) =>
      LoadPriceProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'loadPriceProvider';
}
