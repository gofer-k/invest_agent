// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StrategyNotifier)
final strategyProvider = StrategyNotifierFamily._();

final class StrategyNotifierProvider
    extends $AsyncNotifierProvider<StrategyNotifier, AnalysisState<Strategy>> {
  StrategyNotifierProvider._({
    required StrategyNotifierFamily super.from,
    required (CacheKeyType?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'strategyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$strategyNotifierHash();

  @override
  String toString() {
    return r'strategyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  StrategyNotifier create() => StrategyNotifier();

  @override
  bool operator ==(Object other) {
    return other is StrategyNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$strategyNotifierHash() => r'4bbb98df0c41b909329d5542121c12ff2eeda1fa';

final class StrategyNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          StrategyNotifier,
          AsyncValue<AnalysisState<Strategy>>,
          AnalysisState<Strategy>,
          FutureOr<AnalysisState<Strategy>>,
          (CacheKeyType?, bool?)
        > {
  StrategyNotifierFamily._()
    : super(
        retry: null,
        name: r'strategyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StrategyNotifierProvider call([CacheKeyType? type, bool? keepAlive]) =>
      StrategyNotifierProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'strategyProvider';
}

abstract class _$StrategyNotifier
    extends $AsyncNotifier<AnalysisState<Strategy>> {
  late final _$args = ref.$arg as (CacheKeyType?, bool?);
  CacheKeyType? get type => _$args.$1;
  bool? get keepAlive => _$args.$2;

  FutureOr<AnalysisState<Strategy>> build([
    CacheKeyType? type,
    bool? keepAlive,
  ]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AnalysisState<Strategy>>,
              AnalysisState<Strategy>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AnalysisState<Strategy>>,
                AnalysisState<Strategy>
              >,
              AsyncValue<AnalysisState<Strategy>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
