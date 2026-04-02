// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadDatabase)
final loadDatabaseProvider = LoadDatabaseProvider._();

final class LoadDatabaseProvider
    extends $AsyncNotifierProvider<LoadDatabase, String> {
  LoadDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadDatabaseHash();

  @$internal
  @override
  LoadDatabase create() => LoadDatabase();
}

String _$loadDatabaseHash() => r'9be40eeb1f4dfc242663a882ebf85097b936e2f8';

abstract class _$LoadDatabase extends $AsyncNotifier<String> {
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
        isAutoDispose: false,
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

String _$databaseHelperHash() => r'8d5f2b1dfff64d8e31d057e48fc29d11f32b65ee';
