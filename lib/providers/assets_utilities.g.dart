// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_utilities.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assetsByTimeSpan)
final assetsByTimeSpanProvider = AssetsByTimeSpanFamily._();

final class AssetsByTimeSpanProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTimeRange<DateTime>, List<AssetConfig>>>,
          Map<DateTimeRange<DateTime>, List<AssetConfig>>,
          FutureOr<Map<DateTimeRange<DateTime>, List<AssetConfig>>>
        >
    with
        $FutureModifier<Map<DateTimeRange<DateTime>, List<AssetConfig>>>,
        $FutureProvider<Map<DateTimeRange<DateTime>, List<AssetConfig>>> {
  AssetsByTimeSpanProvider._({
    required AssetsByTimeSpanFamily super.from,
    required List<AssetConfig> super.argument,
  }) : super(
         retry: null,
         name: r'assetsByTimeSpanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetsByTimeSpanHash();

  @override
  String toString() {
    return r'assetsByTimeSpanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<DateTimeRange<DateTime>, List<AssetConfig>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DateTimeRange<DateTime>, List<AssetConfig>>> create(Ref ref) {
    final argument = this.argument as List<AssetConfig>;
    return assetsByTimeSpan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssetsByTimeSpanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetsByTimeSpanHash() => r'068b2dd95637f6239d62f82136b88bcef4fcd39c';

final class AssetsByTimeSpanFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<DateTimeRange<DateTime>, List<AssetConfig>>>,
          List<AssetConfig>
        > {
  AssetsByTimeSpanFamily._()
    : super(
        retry: null,
        name: r'assetsByTimeSpanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssetsByTimeSpanProvider call(List<AssetConfig> assets) =>
      AssetsByTimeSpanProvider._(argument: assets, from: this);

  @override
  String toString() => r'assetsByTimeSpanProvider';
}

@ProviderFor(refreshAssetPrices)
final refreshAssetPricesProvider = RefreshAssetPricesFamily._();

final class RefreshAssetPricesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RefreshAssetPricesProvider._({
    required RefreshAssetPricesFamily super.from,
    required (UserAccount, List<AssetConfig>) super.argument,
  }) : super(
         retry: null,
         name: r'refreshAssetPricesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$refreshAssetPricesHash();

  @override
  String toString() {
    return r'refreshAssetPricesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (UserAccount, List<AssetConfig>);
    return refreshAssetPrices(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RefreshAssetPricesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$refreshAssetPricesHash() =>
    r'12ca692006ea7cbb26d2416e03e848138751ef21';

final class RefreshAssetPricesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          (UserAccount, List<AssetConfig>)
        > {
  RefreshAssetPricesFamily._()
    : super(
        retry: null,
        name: r'refreshAssetPricesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RefreshAssetPricesProvider call(
    UserAccount account,
    List<AssetConfig> assets,
  ) => RefreshAssetPricesProvider._(argument: (account, assets), from: this);

  @override
  String toString() => r'refreshAssetPricesProvider';
}

@ProviderFor(refreshAllDetails)
final refreshAllDetailsProvider = RefreshAllDetailsProvider._();

final class RefreshAllDetailsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RefreshAllDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshAllDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshAllDetailsHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return refreshAllDetails(ref);
  }
}

String _$refreshAllDetailsHash() => r'b3aed5936411793ed2ca96e5d2da2731982fc4d5';
