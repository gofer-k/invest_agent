// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DatabasePath)
final databasePathProvider = DatabasePathProvider._();

final class DatabasePathProvider
    extends $AsyncNotifierProvider<DatabasePath, String> {
  DatabasePathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databasePathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databasePathHash();

  @$internal
  @override
  DatabasePath create() => DatabasePath();
}

String _$databasePathHash() => r'09ff5d846712c456243b5fe685109acd4161dafd';

abstract class _$DatabasePath extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(databaseHelper)
final databaseHelperProvider = DatabaseHelperProvider._();

final class DatabaseHelperProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseHelper>,
          DatabaseHelper,
          FutureOr<DatabaseHelper>
        >
    with $FutureModifier<DatabaseHelper>, $FutureProvider<DatabaseHelper> {
  DatabaseHelperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseHelperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHelperHash();

  @$internal
  @override
  $FutureProviderElement<DatabaseHelper> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseHelper> create(Ref ref) {
    return databaseHelper(ref);
  }
}

String _$databaseHelperHash() => r'd94759fc26391b8a5544e23e34853693cab13e57';
