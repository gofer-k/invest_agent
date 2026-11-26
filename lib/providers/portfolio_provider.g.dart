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
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(portfolioPriceDomain)
final portfolioPriceDomainProvider = PortfolioPriceDomainFamily._();

final class PortfolioPriceDomainProvider
    extends
        $FunctionalProvider<
          AsyncValue<IndexPrice?>,
          IndexPrice?,
          FutureOr<IndexPrice?>
        >
    with $FutureModifier<IndexPrice?>, $FutureProvider<IndexPrice?> {
  PortfolioPriceDomainProvider._({
    required PortfolioPriceDomainFamily super.from,
    required PortfolioConfig super.argument,
  }) : super(
         retry: null,
         name: r'portfolioPriceDomainProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioPriceDomainHash();

  @override
  String toString() {
    return r'portfolioPriceDomainProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<IndexPrice?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IndexPrice?> create(Ref ref) {
    final argument = this.argument as PortfolioConfig;
    return portfolioPriceDomain(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioPriceDomainProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioPriceDomainHash() =>
    r'7f78fb3ef1ff5564ca46301c8d2a1e8a871a3cdf';

final class PortfolioPriceDomainFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<IndexPrice?>, PortfolioConfig> {
  PortfolioPriceDomainFamily._()
    : super(
        retry: null,
        name: r'portfolioPriceDomainProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PortfolioPriceDomainProvider call(PortfolioConfig portfolio) =>
      PortfolioPriceDomainProvider._(argument: portfolio, from: this);

  @override
  String toString() => r'portfolioPriceDomainProvider';
}

@ProviderFor(portfolioAssetsPriceData)
final portfolioAssetsPriceDataProvider = PortfolioAssetsPriceDataFamily._();

final class PortfolioAssetsPriceDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IndexPrice>>,
          List<IndexPrice>,
          FutureOr<List<IndexPrice>>
        >
    with $FutureModifier<List<IndexPrice>>, $FutureProvider<List<IndexPrice>> {
  PortfolioAssetsPriceDataProvider._({
    required PortfolioAssetsPriceDataFamily super.from,
    required PortfolioConfig super.argument,
  }) : super(
         retry: null,
         name: r'portfolioAssetsPriceDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioAssetsPriceDataHash();

  @override
  String toString() {
    return r'portfolioAssetsPriceDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<IndexPrice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IndexPrice>> create(Ref ref) {
    final argument = this.argument as PortfolioConfig;
    return portfolioAssetsPriceData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioAssetsPriceDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioAssetsPriceDataHash() =>
    r'1da4ec6ef1bf727fc5b0e9325cfd04528b400604';

final class PortfolioAssetsPriceDataFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<IndexPrice>>, PortfolioConfig> {
  PortfolioAssetsPriceDataFamily._()
    : super(
        retry: null,
        name: r'portfolioAssetsPriceDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PortfolioAssetsPriceDataProvider call(PortfolioConfig portfolio) =>
      PortfolioAssetsPriceDataProvider._(argument: portfolio, from: this);

  @override
  String toString() => r'portfolioAssetsPriceDataProvider';
}
