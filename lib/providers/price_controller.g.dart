// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PriceController)
final priceControllerProvider = PriceControllerFamily._();

final class PriceControllerProvider
    extends $NotifierProvider<PriceController, PriceControllerState> {
  PriceControllerProvider._({
    required PriceControllerFamily super.from,
    required (CacheKeyType?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'priceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priceControllerHash();

  @override
  String toString() {
    return r'priceControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PriceController create() => PriceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PriceControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PriceControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PriceControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priceControllerHash() => r'61e4f3ba8b016ab9202263ffee347276151a4bc5';

final class PriceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PriceController,
          PriceControllerState,
          PriceControllerState,
          PriceControllerState,
          (CacheKeyType?, bool?)
        > {
  PriceControllerFamily._()
    : super(
        retry: null,
        name: r'priceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PriceControllerProvider call([CacheKeyType? type, bool? keepAlive]) =>
      PriceControllerProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'priceControllerProvider';
}

abstract class _$PriceController extends $Notifier<PriceControllerState> {
  late final _$args = ref.$arg as (CacheKeyType?, bool?);
  CacheKeyType? get type => _$args.$1;
  bool? get keepAlive => _$args.$2;

  PriceControllerState build([CacheKeyType? type, bool? keepAlive]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PriceControllerState, PriceControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PriceControllerState, PriceControllerState>,
              PriceControllerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(assetPriceDetails)
final assetPriceDetailsProvider = AssetPriceDetailsFamily._();

final class AssetPriceDetailsProvider
    extends
        $FunctionalProvider<
          Map<int, String>,
          Map<int, String>,
          Map<int, String>
        >
    with $Provider<Map<int, String>> {
  AssetPriceDetailsProvider._({
    required AssetPriceDetailsFamily super.from,
    required (CacheKeyType?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'assetPriceDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetPriceDetailsHash();

  @override
  String toString() {
    return r'assetPriceDetailsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Map<int, String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<int, String> create(Ref ref) {
    final argument = this.argument as (CacheKeyType?, bool?);
    return assetPriceDetails(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssetPriceDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetPriceDetailsHash() => r'8fd74c6bfef1b299b756feae7132dd878c2a74c4';

final class AssetPriceDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Map<int, String>, (CacheKeyType?, bool?)> {
  AssetPriceDetailsFamily._()
    : super(
        retry: null,
        name: r'assetPriceDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssetPriceDetailsProvider call([CacheKeyType? type, bool? keepAlive]) =>
      AssetPriceDetailsProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'assetPriceDetailsProvider';
}

@ProviderFor(assetPrices)
final assetPricesProvider = AssetPricesFamily._();

final class AssetPricesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IndexPriceItem>>,
          List<IndexPriceItem>,
          FutureOr<List<IndexPriceItem>>
        >
    with
        $FutureModifier<List<IndexPriceItem>>,
        $FutureProvider<List<IndexPriceItem>> {
  AssetPricesProvider._({
    required AssetPricesFamily super.from,
    required (int, DateTime?) super.argument,
  }) : super(
         retry: null,
         name: r'assetPricesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetPricesHash();

  @override
  String toString() {
    return r'assetPricesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<IndexPriceItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<IndexPriceItem>> create(Ref ref) {
    final argument = this.argument as (int, DateTime?);
    return assetPrices(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AssetPricesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetPricesHash() => r'fb68f68739b02784f71932c09ab7f5f45345231f';

final class AssetPricesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<IndexPriceItem>>,
          (int, DateTime?)
        > {
  AssetPricesFamily._()
    : super(
        retry: null,
        name: r'assetPricesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssetPricesProvider call(int assetId, [DateTime? endTime]) =>
      AssetPricesProvider._(argument: (assetId, endTime), from: this);

  @override
  String toString() => r'assetPricesProvider';
}
