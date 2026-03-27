// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.

@ProviderFor(ModelManager)
final modelManagerProvider = ModelManagerProvider._();

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
final class ModelManagerProvider
    extends $NotifierProvider<ModelManager, ModelManagerState> {
  /// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
  ModelManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelManagerHash();

  @$internal
  @override
  ModelManager create() => ModelManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelManagerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelManagerState>(value),
    );
  }
}

String _$modelManagerHash() => r'848458f4dfaa7c34ed7e7a391933391af9d2b935';

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.

abstract class _$ModelManager extends $Notifier<ModelManagerState> {
  ModelManagerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ModelManagerState, ModelManagerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModelManagerState, ModelManagerState>,
              ModelManagerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
