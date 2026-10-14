// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PortfolioSession)
final portfolioSessionProvider = PortfolioSessionFamily._();

final class PortfolioSessionProvider
    extends $NotifierProvider<PortfolioSession, PortfolioConfig> {
  PortfolioSessionProvider._({
    required PortfolioSessionFamily super.from,
    required PortfolioConfig? super.argument,
  }) : super(
         retry: null,
         name: r'portfolioSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioSessionHash();

  @override
  String toString() {
    return r'portfolioSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PortfolioSession create() => PortfolioSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PortfolioConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PortfolioConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioSessionHash() => r'ee959969755381f97b29f09bc49676200f34b909';

final class PortfolioSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          PortfolioSession,
          PortfolioConfig,
          PortfolioConfig,
          PortfolioConfig,
          PortfolioConfig?
        > {
  PortfolioSessionFamily._()
    : super(
        retry: null,
        name: r'portfolioSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PortfolioSessionProvider call(PortfolioConfig? portfolio) =>
      PortfolioSessionProvider._(argument: portfolio, from: this);

  @override
  String toString() => r'portfolioSessionProvider';
}

abstract class _$PortfolioSession extends $Notifier<PortfolioConfig> {
  late final _$args = ref.$arg as PortfolioConfig?;
  PortfolioConfig? get portfolio => _$args;

  PortfolioConfig build(PortfolioConfig? portfolio);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PortfolioConfig, PortfolioConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PortfolioConfig, PortfolioConfig>,
              PortfolioConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
