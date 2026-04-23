// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalysisNotifier)
final analysisProvider = AnalysisNotifierFamily._();

final class AnalysisNotifierProvider
    extends $AsyncNotifierProvider<AnalysisNotifier, List<AnalysisEntry>> {
  AnalysisNotifierProvider._({
    required AnalysisNotifierFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'analysisProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$analysisNotifierHash();

  @override
  String toString() {
    return r'analysisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AnalysisNotifier create() => AnalysisNotifier();

  @override
  bool operator ==(Object other) {
    return other is AnalysisNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$analysisNotifierHash() => r'fffb0b6ef4b696bc238b76b32e15dc3f088e4617';

final class AnalysisNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AnalysisNotifier,
          AsyncValue<List<AnalysisEntry>>,
          List<AnalysisEntry>,
          FutureOr<List<AnalysisEntry>>,
          String?
        > {
  AnalysisNotifierFamily._()
    : super(
        retry: null,
        name: r'analysisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnalysisNotifierProvider call([String? path]) =>
      AnalysisNotifierProvider._(argument: path, from: this);

  @override
  String toString() => r'analysisProvider';
}

abstract class _$AnalysisNotifier extends $AsyncNotifier<List<AnalysisEntry>> {
  late final _$args = ref.$arg as String?;
  String? get path => _$args;

  FutureOr<List<AnalysisEntry>> build([String? path]);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AnalysisEntry>>, List<AnalysisEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AnalysisEntry>>, List<AnalysisEntry>>,
              AsyncValue<List<AnalysisEntry>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
