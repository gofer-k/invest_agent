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
    extends $AsyncNotifierProvider<IndicatorNotifier, List<Indicator>> {
  IndicatorNotifierProvider._({
    required IndicatorNotifierFamily super.from,
    required String? super.argument,
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
        '($argument)';
  }

  @$internal
  @override
  IndicatorNotifier create() => IndicatorNotifier();

  @override
  bool operator ==(Object other) {
    return other is IndicatorNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$indicatorNotifierHash() => r'0a40042f548018be114f9c4c6f013f60c1c881ed';

final class IndicatorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          IndicatorNotifier,
          AsyncValue<List<Indicator>>,
          List<Indicator>,
          FutureOr<List<Indicator>>,
          String?
        > {
  IndicatorNotifierFamily._()
    : super(
        retry: null,
        name: r'indicatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndicatorNotifierProvider call([String? cachePath]) =>
      IndicatorNotifierProvider._(argument: cachePath, from: this);

  @override
  String toString() => r'indicatorProvider';
}

abstract class _$IndicatorNotifier extends $AsyncNotifier<List<Indicator>> {
  late final _$args = ref.$arg as String?;
  String? get cachePath => _$args;

  FutureOr<List<Indicator>> build([String? cachePath]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Indicator>>, List<Indicator>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Indicator>>, List<Indicator>>,
              AsyncValue<List<Indicator>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
