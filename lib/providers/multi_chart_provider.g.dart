// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MultiChartNotifier)
final multiChartProvider = MultiChartNotifierFamily._();

final class MultiChartNotifierProvider
    extends $NotifierProvider<MultiChartNotifier, MultiChartNotifierState> {
  MultiChartNotifierProvider._({
    required MultiChartNotifierFamily super.from,
    required (CacheKeyType?, PeriodType?, ChartStyle?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'multiChartProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$multiChartNotifierHash();

  @override
  String toString() {
    return r'multiChartProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MultiChartNotifier create() => MultiChartNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MultiChartNotifierState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MultiChartNotifierState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MultiChartNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$multiChartNotifierHash() =>
    r'e697ee3f287313edc5594e055a2a5fead6ddc4b0';

final class MultiChartNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MultiChartNotifier,
          MultiChartNotifierState,
          MultiChartNotifierState,
          MultiChartNotifierState,
          (CacheKeyType?, PeriodType?, ChartStyle?, bool?)
        > {
  MultiChartNotifierFamily._()
    : super(
        retry: null,
        name: r'multiChartProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MultiChartNotifierProvider call([
    CacheKeyType? type,
    PeriodType? periodType,
    ChartStyle? chartStyle,
    bool? keepAlive,
  ]) => MultiChartNotifierProvider._(
    argument: (type, periodType, chartStyle, keepAlive),
    from: this,
  );

  @override
  String toString() => r'multiChartProvider';
}

abstract class _$MultiChartNotifier extends $Notifier<MultiChartNotifierState> {
  late final _$args =
      ref.$arg as (CacheKeyType?, PeriodType?, ChartStyle?, bool?);
  CacheKeyType? get type => _$args.$1;
  PeriodType? get periodType => _$args.$2;
  ChartStyle? get chartStyle => _$args.$3;
  bool? get keepAlive => _$args.$4;

  MultiChartNotifierState build([
    CacheKeyType? type,
    PeriodType? periodType,
    ChartStyle? chartStyle,
    bool? keepAlive,
  ]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MultiChartNotifierState, MultiChartNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MultiChartNotifierState, MultiChartNotifierState>,
              MultiChartNotifierState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3, _$args.$4),
    );
  }
}

@ProviderFor(sortedMultiCharts)
final sortedMultiChartsProvider = SortedMultiChartsFamily._();

final class SortedMultiChartsProvider
    extends
        $FunctionalProvider<
          List<MultiChartConfig>,
          List<MultiChartConfig>,
          List<MultiChartConfig>
        >
    with $Provider<List<MultiChartConfig>> {
  SortedMultiChartsProvider._({
    required SortedMultiChartsFamily super.from,
    required CacheKeyType? super.argument,
  }) : super(
         retry: null,
         name: r'sortedMultiChartsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sortedMultiChartsHash();

  @override
  String toString() {
    return r'sortedMultiChartsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<MultiChartConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MultiChartConfig> create(Ref ref) {
    final argument = this.argument as CacheKeyType?;
    return sortedMultiCharts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MultiChartConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MultiChartConfig>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SortedMultiChartsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sortedMultiChartsHash() => r'61bd286a56148de96ba3326296c6090425659756';

final class SortedMultiChartsFamily extends $Family
    with $FunctionalFamilyOverride<List<MultiChartConfig>, CacheKeyType?> {
  SortedMultiChartsFamily._()
    : super(
        retry: null,
        name: r'sortedMultiChartsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SortedMultiChartsProvider call(CacheKeyType? type) =>
      SortedMultiChartsProvider._(argument: type, from: this);

  @override
  String toString() => r'sortedMultiChartsProvider';
}

@ProviderFor(multiChartsBy)
final multiChartsByProvider = MultiChartsByFamily._();

final class MultiChartsByProvider
    extends
        $FunctionalProvider<
          List<MultiChartConfig>,
          List<MultiChartConfig>,
          List<MultiChartConfig>
        >
    with $Provider<List<MultiChartConfig>> {
  MultiChartsByProvider._({
    required MultiChartsByFamily super.from,
    required (CacheKeyType?, AssetConfig, PeriodType, ChartStyle)
    super.argument,
  }) : super(
         retry: null,
         name: r'multiChartsByProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$multiChartsByHash();

  @override
  String toString() {
    return r'multiChartsByProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<MultiChartConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MultiChartConfig> create(Ref ref) {
    final argument =
        this.argument as (CacheKeyType?, AssetConfig, PeriodType, ChartStyle);
    return multiChartsBy(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MultiChartConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MultiChartConfig>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MultiChartsByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$multiChartsByHash() => r'52e1eec59b3a783a2f9c7afc081dde4857c77ab5';

final class MultiChartsByFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<MultiChartConfig>,
          (CacheKeyType?, AssetConfig, PeriodType, ChartStyle)
        > {
  MultiChartsByFamily._()
    : super(
        retry: null,
        name: r'multiChartsByProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MultiChartsByProvider call(
    CacheKeyType? type,
    AssetConfig asset,
    PeriodType periodType,
    ChartStyle style,
  ) => MultiChartsByProvider._(
    argument: (type, asset, periodType, style),
    from: this,
  );

  @override
  String toString() => r'multiChartsByProvider';
}

@ProviderFor(removeMultiChartBy)
final removeMultiChartByProvider = RemoveMultiChartByFamily._();

final class RemoveMultiChartByProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RemoveMultiChartByProvider._({
    required RemoveMultiChartByFamily super.from,
    required (CacheKeyType?, AssetConfig) super.argument,
  }) : super(
         retry: null,
         name: r'removeMultiChartByProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$removeMultiChartByHash();

  @override
  String toString() {
    return r'removeMultiChartByProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (CacheKeyType?, AssetConfig);
    return removeMultiChartBy(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RemoveMultiChartByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$removeMultiChartByHash() =>
    r'e15ae6b001db11a442c3bdca23c0b104bd64598d';

final class RemoveMultiChartByFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          (CacheKeyType?, AssetConfig)
        > {
  RemoveMultiChartByFamily._()
    : super(
        retry: null,
        name: r'removeMultiChartByProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RemoveMultiChartByProvider call(CacheKeyType? type, AssetConfig asset) =>
      RemoveMultiChartByProvider._(argument: (type, asset), from: this);

  @override
  String toString() => r'removeMultiChartByProvider';
}
