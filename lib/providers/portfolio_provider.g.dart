// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PortfolioNotifier)
final portfolioProvider = PortfolioNotifierFamily._();

final class PortfolioNotifierProvider
    extends
        $AsyncNotifierProvider<
          PortfolioNotifier,
          AnalysisState<PortfolioConfig>
        > {
  PortfolioNotifierProvider._({
    required PortfolioNotifierFamily super.from,
    required (CacheKeyType?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'portfolioProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioNotifierHash();

  @override
  String toString() {
    return r'portfolioProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PortfolioNotifier create() => PortfolioNotifier();

  @override
  bool operator ==(Object other) {
    return other is PortfolioNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioNotifierHash() => r'd7cd797636002e67d2548f019fc9de6f04208278';

final class PortfolioNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PortfolioNotifier,
          AsyncValue<AnalysisState<PortfolioConfig>>,
          AnalysisState<PortfolioConfig>,
          FutureOr<AnalysisState<PortfolioConfig>>,
          (CacheKeyType?, bool?)
        > {
  PortfolioNotifierFamily._()
    : super(
        retry: null,
        name: r'portfolioProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PortfolioNotifierProvider call([CacheKeyType? type, bool? keepAlive]) =>
      PortfolioNotifierProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'portfolioProvider';
}

abstract class _$PortfolioNotifier
    extends $AsyncNotifier<AnalysisState<PortfolioConfig>> {
  late final _$args = ref.$arg as (CacheKeyType?, bool?);
  CacheKeyType? get type => _$args.$1;
  bool? get keepAlive => _$args.$2;

  FutureOr<AnalysisState<PortfolioConfig>> build([
    CacheKeyType? type,
    bool? keepAlive,
  ]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AnalysisState<PortfolioConfig>>,
              AnalysisState<PortfolioConfig>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AnalysisState<PortfolioConfig>>,
                AnalysisState<PortfolioConfig>
              >,
              AsyncValue<AnalysisState<PortfolioConfig>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
