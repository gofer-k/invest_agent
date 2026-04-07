// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PriceController)
final priceControllerProvider = PriceControllerProvider._();

final class PriceControllerProvider
    extends $NotifierProvider<PriceController, PriceControllerState> {
  PriceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceControllerHash();

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
}

String _$priceControllerHash() => r'027532045376bd91f3cfbf6e410bd901ea9dc649';

abstract class _$PriceController extends $Notifier<PriceControllerState> {
  PriceControllerState build();
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
    element.handleCreate(ref, build);
  }
}
