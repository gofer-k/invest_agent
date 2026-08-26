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

String _$strategySessionHash() => r'b4063caa571ccc3add41e7ddbe8b9a3838b33ab6';

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
  void runBuild() {
    final ref = this.ref as $Ref<Strategy, Strategy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Strategy, Strategy>,
              Strategy,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
