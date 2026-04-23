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
    extends $AsyncNotifierProvider<IndicatorNotifier, List<Cache>> {
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

String _$indicatorNotifierHash() => r'747f21477b20ab453521a0c348934d34b35f505a';

final class IndicatorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          IndicatorNotifier,
          AsyncValue<List<Cache>>,
          List<Cache>,
          FutureOr<List<Cache>>,
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

abstract class _$IndicatorNotifier extends $AsyncNotifier<List<Cache>> {
  late final _$args = ref.$arg as String?;
  String? get cachePath => _$args;

  FutureOr<List<Cache>> build([String? cachePath]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Cache>>, List<Cache>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Cache>>, List<Cache>>,
              AsyncValue<List<Cache>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
