// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CacheNotifier)
final cacheProvider = CacheNotifierFamily._();

final class CacheNotifierProvider<T extends Cache, TSchema extends CacheSchema>
    extends $AsyncNotifierProvider<CacheNotifier<T, TSchema>, List<T>> {
  CacheNotifierProvider._({
    required CacheNotifierFamily super.from,
    required (TSchema, String) super.argument,
  }) : super(
         retry: null,
         name: r'cacheProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cacheNotifierHash();

  @override
  String toString() {
    return r'cacheProvider'
        '<${T}, ${TSchema}>'
        '$argument';
  }

  @$internal
  @override
  CacheNotifier<T, TSchema> create() => CacheNotifier<T, TSchema>();

  $R _captureGenerics<$R>(
    $R Function<T extends Cache, TSchema extends CacheSchema>() cb,
  ) {
    return cb<T, TSchema>();
  }

  @override
  bool operator ==(Object other) {
    return other is CacheNotifierProvider &&
        other.runtimeType == runtimeType &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, argument);
  }
}

String _$cacheNotifierHash() => r'5c2adae075362583cc59f23c81ed7bcd6c589e01';

final class CacheNotifierFamily extends $Family {
  CacheNotifierFamily._()
    : super(
        retry: null,
        name: r'cacheProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CacheNotifierProvider<T, TSchema> call<
    T extends Cache,
    TSchema extends CacheSchema
  >(TSchema cacheSchema, String cachePath) =>
      CacheNotifierProvider<T, TSchema>._(
        argument: (cacheSchema, cachePath),
        from: this,
      );

  @override
  String toString() => r'cacheProvider';

  /// {@macro riverpod.override_with}
  Override overrideWith(
    CacheNotifier<T, TSchema>
    Function<T extends Cache, TSchema extends CacheSchema>()
    create,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as CacheNotifierProvider;
      return provider._captureGenerics(
        <T extends Cache, TSchema extends CacheSchema>() {
          provider as CacheNotifierProvider<T, TSchema>;
          return provider
              .$view(create: create<T, TSchema>)
              .$createElement(pointer);
        },
      );
    },
  );

  /// {@macro riverpod.override_with_build}
  Override overrideWithBuild(
    FutureOr<List<T>> Function<T extends Cache, TSchema extends CacheSchema>(
      Ref ref,
      CacheNotifier<T, TSchema> notifier,
    )
    build,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as CacheNotifierProvider;
      return provider._captureGenerics(
        <T extends Cache, TSchema extends CacheSchema>() {
          provider as CacheNotifierProvider<T, TSchema>;
          return provider
              .$view(runNotifierBuildOverride: build<T, TSchema>)
              .$createElement(pointer);
        },
      );
    },
  );
}

abstract class _$CacheNotifier<T extends Cache, TSchema extends CacheSchema>
    extends $AsyncNotifier<List<T>> {
  late final _$args = ref.$arg as (TSchema, String);
  TSchema get cacheSchema => _$args.$1;
  String get cachePath => _$args.$2;

  FutureOr<List<T>> build(TSchema cacheSchema, String cachePath);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<T>>, List<T>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<T>>, List<T>>,
              AsyncValue<List<T>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
