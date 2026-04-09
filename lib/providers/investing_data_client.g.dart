// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investing_data_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InvestingDataClient)
final investingDataClientProvider = InvestingDataClientFamily._();

final class InvestingDataClientProvider
    extends $NotifierProvider<InvestingDataClient, void> {
  InvestingDataClientProvider._({
    required InvestingDataClientFamily super.from,
    required RemoteRequest<dynamic> super.argument,
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
    r'71781d87947a7e6135be38e4b654116af9e404e1';

final class InvestingDataClientFamily extends $Family
    with
        $ClassFamilyOverride<
          InvestingDataClient,
          void,
          void,
          void,
          RemoteRequest<dynamic>
        > {
  InvestingDataClientFamily._()
    : super(
        retry: null,
        name: r'investingDataClientProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvestingDataClientProvider call(RemoteRequest<dynamic> endpoint) =>
      InvestingDataClientProvider._(argument: endpoint, from: this);

  @override
  String toString() => r'investingDataClientProvider';
}

abstract class _$InvestingDataClient extends $Notifier<void> {
  late final _$args = ref.$arg as RemoteRequest<dynamic>;
  RemoteRequest<dynamic> get endpoint => _$args;

  void build(RemoteRequest<dynamic> endpoint);
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
