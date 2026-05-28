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
    extends $AsyncNotifierProvider<PriceImporter, String> {
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

String _$priceImporterHash() => r'e25341394e30c9494cc58dd07d26af169773ac76';

final class PriceImporterFamily extends $Family
    with
        $ClassFamilyOverride<
          PriceImporter,
          AsyncValue<String>,
          String,
          FutureOr<String>,
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

abstract class _$PriceImporter extends $AsyncNotifier<String> {
  late final _$args = ref.$arg as (CacheKeyType, String?);
  CacheKeyType get cacheTYpe => _$args.$1;
  String? get path => _$args.$2;

  FutureOr<String> build(CacheKeyType cacheTYpe, [String? path]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
