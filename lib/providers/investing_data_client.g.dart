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
    extends
        $AsyncNotifierProvider<InvestingDataClient, InvestingDataClientState> {
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
    r'da9a4f0ece9ec0870017b88f065aba10778df8c6';

final class InvestingDataClientFamily extends $Family
    with
        $ClassFamilyOverride<
          InvestingDataClient,
          AsyncValue<InvestingDataClientState>,
          InvestingDataClientState,
          FutureOr<InvestingDataClientState>,
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

  InvestingDataClientProvider call(RemoteRequest endPoint) =>
      InvestingDataClientProvider._(argument: endPoint, from: this);

  @override
  String toString() => r'investingDataClientProvider';
}

abstract class _$InvestingDataClient
    extends $AsyncNotifier<InvestingDataClientState> {
  late final _$args = ref.$arg as RemoteRequest;
  RemoteRequest get endPoint => _$args;

  FutureOr<InvestingDataClientState> build(RemoteRequest endPoint);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<InvestingDataClientState>,
              InvestingDataClientState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InvestingDataClientState>,
                InvestingDataClientState
              >,
              AsyncValue<InvestingDataClientState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
