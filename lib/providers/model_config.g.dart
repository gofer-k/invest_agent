// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.

@ProviderFor(ModelConfig)
final modelConfigProvider = ModelConfigProvider._();

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
final class ModelConfigProvider
    extends $NotifierProvider<ModelConfig, ModelConfigState> {
  /// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.
  ModelConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelConfigHash();

  @$internal
  @override
  ModelConfig create() => ModelConfig();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelConfigState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelConfigState>(value),
    );
  }
}

String _$modelConfigHash() => r'8877194c1df2249e67880f8d5d134622a295bfff';

/// Riverpod 3.0 style (Modern Riverpod) Notifier for managing app data.

abstract class _$ModelConfig extends $Notifier<ModelConfigState> {
  ModelConfigState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ModelConfigState, ModelConfigState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ModelConfigState, ModelConfigState>,
              ModelConfigState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(sortedAssets)
final sortedAssetsProvider = SortedAssetsProvider._();

final class SortedAssetsProvider
    extends
        $FunctionalProvider<
          List<AssetConfig>,
          List<AssetConfig>,
          List<AssetConfig>
        >
    with $Provider<List<AssetConfig>> {
  SortedAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedAssetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedAssetsHash();

  @$internal
  @override
  $ProviderElement<List<AssetConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<AssetConfig> create(Ref ref) {
    return sortedAssets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AssetConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AssetConfig>>(value),
    );
  }
}

String _$sortedAssetsHash() => r'e32455484d43e8228e0f1c8d34abbf2ff9031f72';

@ProviderFor(portfolios)
final portfoliosProvider = PortfoliosProvider._();

final class PortfoliosProvider
    extends
        $FunctionalProvider<
          List<PortfolioConfig>,
          List<PortfolioConfig>,
          List<PortfolioConfig>
        >
    with $Provider<List<PortfolioConfig>> {
  PortfoliosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfoliosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfoliosHash();

  @$internal
  @override
  $ProviderElement<List<PortfolioConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<PortfolioConfig> create(Ref ref) {
    return portfolios(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PortfolioConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PortfolioConfig>>(value),
    );
  }
}

String _$portfoliosHash() => r'e497b6519b29cc09a7de3015f5e2f87802027c3d';

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

String _$userAccountsHash() => r'52b15ef684dfe21fa890db626c4f17ad887b1b18';

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

String _$assetsLoaderHash() => r'2f00c734c063fb7247d8128ddc21535c183334c3';

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

String _$portfolioLoaderHash() => r'fffc2fa945491c63390d146222d1bada2aa83d78';
