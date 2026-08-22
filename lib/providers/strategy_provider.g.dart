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
    extends $NotifierProvider<StrategyNotifier, StrategyNotifierState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StrategyNotifierState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StrategyNotifierState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StrategyNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$strategyNotifierHash() => r'204f2b19408d4679ed1fafed3ce645da9007ff95';

final class StrategyNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          StrategyNotifier,
          StrategyNotifierState,
          StrategyNotifierState,
          StrategyNotifierState,
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

abstract class _$StrategyNotifier extends $Notifier<StrategyNotifierState> {
  late final _$args = ref.$arg as (CacheKeyType?, bool?);
  CacheKeyType? get type => _$args.$1;
  bool? get keepAlive => _$args.$2;

  StrategyNotifierState build([CacheKeyType? type, bool? keepAlive]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StrategyNotifierState, StrategyNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StrategyNotifierState, StrategyNotifierState>,
              StrategyNotifierState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
