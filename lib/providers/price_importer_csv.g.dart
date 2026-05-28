// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_importer_csv.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PriceImporter)
final priceImporterProvider = PriceImporterFamily._();

final class PriceImporterProvider
    extends $AsyncNotifierProvider<PriceImporter, void> {
  PriceImporterProvider._({
    required PriceImporterFamily super.from,
    required (CacheKeyType, String?) super.argument,
  }) : super(
         retry: null,
         name: r'priceImporterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priceImporterHash();

  @override
  String toString() {
    return r'priceImporterProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PriceImporter create() => PriceImporter();

  @override
  bool operator ==(Object other) {
    return other is PriceImporterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priceImporterHash() => r'f938d05ba4fc053150163cb0394b6c954ad77a73';

final class PriceImporterFamily extends $Family
    with
        $ClassFamilyOverride<
          PriceImporter,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          (CacheKeyType, String?)
        > {
  PriceImporterFamily._()
    : super(
        retry: null,
        name: r'priceImporterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PriceImporterProvider call(CacheKeyType cacheTYpe, [String? path]) =>
      PriceImporterProvider._(argument: (cacheTYpe, path), from: this);

  @override
  String toString() => r'priceImporterProvider';
}

abstract class _$PriceImporter extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as (CacheKeyType, String?);
  CacheKeyType get cacheTYpe => _$args.$1;
  String? get path => _$args.$2;

  FutureOr<void> build(CacheKeyType cacheTYpe, [String? path]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
