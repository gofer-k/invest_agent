// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StrategySession)
final strategySessionProvider = StrategySessionFamily._();

final class StrategySessionProvider
    extends $NotifierProvider<StrategySession, Strategy> {
  StrategySessionProvider._({
    required StrategySessionFamily super.from,
    required Strategy? super.argument,
  }) : super(
         retry: null,
         name: r'strategySessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$strategySessionHash();

  @override
  String toString() {
    return r'strategySessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StrategySession create() => StrategySession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Strategy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Strategy>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StrategySessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$strategySessionHash() => r'b8f973fbabd169ad180ce1e58228867001a7b873';

final class StrategySessionFamily extends $Family
    with
        $ClassFamilyOverride<
          StrategySession,
          Strategy,
          Strategy,
          Strategy,
          Strategy?
        > {
  StrategySessionFamily._()
    : super(
        retry: null,
        name: r'strategySessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StrategySessionProvider call(Strategy? strategy) =>
      StrategySessionProvider._(argument: strategy, from: this);

  @override
  String toString() => r'strategySessionProvider';
}

abstract class _$StrategySession extends $Notifier<Strategy> {
  late final _$args = ref.$arg as Strategy?;
  Strategy? get strategy => _$args;

  Strategy build(Strategy? strategy);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Strategy, Strategy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Strategy, Strategy>,
              Strategy,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
