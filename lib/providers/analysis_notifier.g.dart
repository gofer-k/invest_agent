// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalysisNotifier)
final analysisProvider = AnalysisNotifierFamily._();

final class AnalysisNotifierProvider<
  TConfigCache extends Cache,
  TSchema extends CacheSchema
>
    extends
        $AsyncNotifierProvider<
          AnalysisNotifier<TConfigCache, TSchema>,
          AnalysisState<TConfigCache>
        > {
  AnalysisNotifierProvider._({
    required AnalysisNotifierFamily super.from,
    required (TSchema, CacheKeyType, String?) super.argument,
  }) : super(
         retry: null,
         name: r'analysisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$analysisNotifierHash();

  @override
  String toString() {
    return r'analysisProvider'
        '<${TConfigCache}, ${TSchema}>'
        '$argument';
  }

  @$internal
  @override
  AnalysisNotifier<TConfigCache, TSchema> create() =>
      AnalysisNotifier<TConfigCache, TSchema>();

  $R _captureGenerics<$R>(
    $R Function<TConfigCache extends Cache, TSchema extends CacheSchema>() cb,
  ) {
    return cb<TConfigCache, TSchema>();
  }

  @override
  bool operator ==(Object other) {
    return other is AnalysisNotifierProvider &&
        other.runtimeType == runtimeType &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, argument);
  }
}

String _$analysisNotifierHash() => r'1ffc569255e802c8b5e01a95c5ea12dbb9c787b1';

final class AnalysisNotifierFamily extends $Family {
  AnalysisNotifierFamily._()
    : super(
        retry: null,
        name: r'analysisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnalysisNotifierProvider<TConfigCache, TSchema> call<
    TConfigCache extends Cache,
    TSchema extends CacheSchema
  >(TSchema schema, CacheKeyType type, [String? path]) =>
      AnalysisNotifierProvider<TConfigCache, TSchema>._(
        argument: (schema, type, path),
        from: this,
      );

  @override
  String toString() => r'analysisProvider';

  /// {@macro riverpod.override_with}
  Override overrideWith(
    AnalysisNotifier<TConfigCache, TSchema>
    Function<TConfigCache extends Cache, TSchema extends CacheSchema>()
    create,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as AnalysisNotifierProvider;
      return provider._captureGenerics(
        <TConfigCache extends Cache, TSchema extends CacheSchema>() {
          provider as AnalysisNotifierProvider<TConfigCache, TSchema>;
          return provider
              .$view(create: create<TConfigCache, TSchema>)
              .$createElement(pointer);
        },
      );
    },
  );

  /// {@macro riverpod.override_with_build}
  Override overrideWithBuild(
    FutureOr<AnalysisState<TConfigCache>> Function<
      TConfigCache extends Cache,
      TSchema extends CacheSchema
    >(Ref ref, AnalysisNotifier<TConfigCache, TSchema> notifier)
    build,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as AnalysisNotifierProvider;
      return provider._captureGenerics(
        <TConfigCache extends Cache, TSchema extends CacheSchema>() {
          provider as AnalysisNotifierProvider<TConfigCache, TSchema>;
          return provider
              .$view(runNotifierBuildOverride: build<TConfigCache, TSchema>)
              .$createElement(pointer);
        },
      );
    },
  );
}

abstract class _$AnalysisNotifier<
  TConfigCache extends Cache,
  TSchema extends CacheSchema
>
    extends $AsyncNotifier<AnalysisState<TConfigCache>> {
  late final _$args = ref.$arg as (TSchema, CacheKeyType, String?);
  TSchema get schema => _$args.$1;
  CacheKeyType get type => _$args.$2;
  String? get path => _$args.$3;

  FutureOr<AnalysisState<TConfigCache>> build(
    TSchema schema,
    CacheKeyType type, [
    String? path,
  ]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AnalysisState<TConfigCache>>,
              AnalysisState<TConfigCache>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AnalysisState<TConfigCache>>,
                AnalysisState<TConfigCache>
              >,
              AsyncValue<AnalysisState<TConfigCache>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2, _$args.$3));
  }
}
