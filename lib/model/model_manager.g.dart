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

String _$modelManagerHash() => r'1bf76c91bb9351857582924efa1946d2f1b9aed7';

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

@ProviderFor(useAssets)
final useAssetsProvider = UseAssetsProvider._();

final class UseAssetsProvider
    extends
        $FunctionalProvider<
          List<AssetConfig>,
          List<AssetConfig>,
          List<AssetConfig>
        >
    with $Provider<List<AssetConfig>> {
  UseAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'useAssetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$useAssetsHash();

  @$internal
  @override
  $ProviderElement<List<AssetConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<AssetConfig> create(Ref ref) {
    return useAssets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AssetConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AssetConfig>>(value),
    );
  }
}

String _$useAssetsHash() => r'a3d0cb45fd1401d5aea5171450dca9f43af12ba9';

@ProviderFor(usePortfolios)
final usePortfoliosProvider = UsePortfoliosProvider._();

final class UsePortfoliosProvider
    extends
        $FunctionalProvider<
          List<PortfolioConfig>,
          List<PortfolioConfig>,
          List<PortfolioConfig>
        >
    with $Provider<List<PortfolioConfig>> {
  UsePortfoliosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usePortfoliosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usePortfoliosHash();

  @$internal
  @override
  $ProviderElement<List<PortfolioConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PortfolioConfig> create(Ref ref) {
    return usePortfolios(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PortfolioConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PortfolioConfig>>(value),
    );
  }
}

String _$usePortfoliosHash() => r'b21eaa7ae514ec31dd4c321e88cdc3f47c6d4fc3';

@ProviderFor(userAccounts)
final userAccountsProvider = UserAccountsProvider._();

final class UserAccountsProvider
    extends
        $FunctionalProvider<
          List<UserAccount>,
          List<UserAccount>,
          List<UserAccount>
        >
    with $Provider<List<UserAccount>> {
  UserAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAccountsHash();

  @$internal
  @override
  $ProviderElement<List<UserAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<UserAccount> create(Ref ref) {
    return userAccounts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UserAccount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UserAccount>>(value),
    );
  }
}

String _$userAccountsHash() => r'52ea1ab40f7abd49f2cbb6673e94256a5c8e40b5';

@ProviderFor(assetsLoader)
final assetsLoaderProvider = AssetsLoaderProvider._();

final class AssetsLoaderProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssetConfig>>,
          List<AssetConfig>,
          FutureOr<List<AssetConfig>>
        >
    with
        $FutureModifier<List<AssetConfig>>,
        $FutureProvider<List<AssetConfig>> {
  AssetsLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetsLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetsLoaderHash();

  @$internal
  @override
  $FutureProviderElement<List<AssetConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssetConfig>> create(Ref ref) {
    return assetsLoader(ref);
  }
}

String _$assetsLoaderHash() => r'a8759627e7e9eb2416f41637692054954df7a5ad';

@ProviderFor(portfolioLoader)
final portfolioLoaderProvider = PortfolioLoaderProvider._();

final class PortfolioLoaderProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PortfolioConfig>>,
          List<PortfolioConfig>,
          FutureOr<List<PortfolioConfig>>
        >
    with
        $FutureModifier<List<PortfolioConfig>>,
        $FutureProvider<List<PortfolioConfig>> {
  PortfolioLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioLoaderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioLoaderHash();

  @$internal
  @override
  $FutureProviderElement<List<PortfolioConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PortfolioConfig>> create(Ref ref) {
    return portfolioLoader(ref);
  }
}

String _$portfolioLoaderHash() => r'4a21ac04ec9026316e5285152ed752926d8a4261';
