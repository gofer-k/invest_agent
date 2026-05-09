// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indicator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IndicatorNotifier)
final indicatorProvider = IndicatorNotifierFamily._();

final class IndicatorNotifierProvider
    extends $NotifierProvider<IndicatorNotifier, IndicatorNotifierState> {
  IndicatorNotifierProvider._({
    required IndicatorNotifierFamily super.from,
    required (CacheKeyType?, bool?) super.argument,
  }) : super(
         retry: null,
         name: r'indicatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$indicatorNotifierHash();

  @override
  String toString() {
    return r'indicatorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  IndicatorNotifier create() => IndicatorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndicatorNotifierState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndicatorNotifierState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IndicatorNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$indicatorNotifierHash() => r'fde9e797786e9b3c776eaad408b21e8f8bbf8d2a';

final class IndicatorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          IndicatorNotifier,
          IndicatorNotifierState,
          IndicatorNotifierState,
          IndicatorNotifierState,
          (CacheKeyType?, bool?)
        > {
  IndicatorNotifierFamily._()
    : super(
        retry: null,
        name: r'indicatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndicatorNotifierProvider call([CacheKeyType? type, bool? keepAlive]) =>
      IndicatorNotifierProvider._(argument: (type, keepAlive), from: this);

  @override
  String toString() => r'indicatorProvider';
}

abstract class _$IndicatorNotifier extends $Notifier<IndicatorNotifierState> {
  late final _$args = ref.$arg as (CacheKeyType?, bool?);
  CacheKeyType? get type => _$args.$1;
  bool? get keepAlive => _$args.$2;

  IndicatorNotifierState build([CacheKeyType? type, bool? keepAlive]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<IndicatorNotifierState, IndicatorNotifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndicatorNotifierState, IndicatorNotifierState>,
              IndicatorNotifierState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(sortedIndicators)
final sortedIndicatorsProvider = SortedIndicatorsProvider._();

final class SortedIndicatorsProvider
    extends
        $FunctionalProvider<List<Indicator>, List<Indicator>, List<Indicator>>
    with $Provider<List<Indicator>> {
  SortedIndicatorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedIndicatorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedIndicatorsHash();

  @$internal
  @override
  $ProviderElement<List<Indicator>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Indicator> create(Ref ref) {
    return sortedIndicators(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Indicator> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Indicator>>(value),
    );
  }
}

String _$sortedIndicatorsHash() => r'b379fbc0561e8a0b02911b6b20f4c53b697f73b1';
