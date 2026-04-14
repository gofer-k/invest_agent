// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investing_data_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(httpClient)
final httpClientProvider = HttpClientProvider._();

final class HttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  HttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return httpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$httpClientHash() => r'ecd4acdd7bf72fa50bdd6af529a0f33b9d3d9aca';

@ProviderFor(InvestingDataClient)
final investingDataClientProvider = InvestingDataClientFamily._();

final class InvestingDataClientProvider
    extends $NotifierProvider<InvestingDataClient, void> {
  InvestingDataClientProvider._({
    required InvestingDataClientFamily super.from,
    required RemoteRequest super.argument,
  }) : super(
         retry: null,
         name: r'investingDataClientProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$investingDataClientHash();

  @override
  String toString() {
    return r'investingDataClientProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InvestingDataClient create() => InvestingDataClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InvestingDataClientProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$investingDataClientHash() =>
    r'df820c720826d87c012e7ae2f73ff3ac89acfaa6';

final class InvestingDataClientFamily extends $Family
    with
        $ClassFamilyOverride<
          InvestingDataClient,
          void,
          void,
          void,
          RemoteRequest
        > {
  InvestingDataClientFamily._()
    : super(
        retry: null,
        name: r'investingDataClientProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvestingDataClientProvider call(RemoteRequest endpoint) =>
      InvestingDataClientProvider._(argument: endpoint, from: this);

  @override
  String toString() => r'investingDataClientProvider';
}

abstract class _$InvestingDataClient extends $Notifier<void> {
  late final _$args = ref.$arg as RemoteRequest;
  RemoteRequest get endpoint => _$args;

  void build(RemoteRequest endpoint);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
