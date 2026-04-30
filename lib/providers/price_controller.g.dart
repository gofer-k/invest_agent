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

String _$priceControllerHash() => r'8b3180d79683d4a23603df703dfe5b06aaa83887';

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
final assetPriceDetailsProvider = AssetPriceDetailsProvider._();

final class AssetPriceDetailsProvider
    extends
        $FunctionalProvider<
          Map<int, String>,
          Map<int, String>,
          Map<int, String>
        >
    with $Provider<Map<int, String>> {
  AssetPriceDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetPriceDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetPriceDetailsHash();

  @$internal
  @override
  $ProviderElement<Map<int, String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<int, String> create(Ref ref) {
    return assetPriceDetails(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, String>>(value),
    );
  }
}

String _$assetPriceDetailsHash() => r'5ea1b099f694a8627470eaf7ac8812f06dcf63fa';
