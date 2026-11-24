// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_window_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabWindowSession)
final tabWindowSessionProvider = TabWindowSessionFamily._();

final class TabWindowSessionProvider
    extends $NotifierProvider<TabWindowSession, TabWindowSessionState> {
  TabWindowSessionProvider._({
    required TabWindowSessionFamily super.from,
    required (TabWindowList?, TabWindow?) super.argument,
  }) : super(
         retry: null,
         name: r'tabWindowSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabWindowSessionHash();

  @override
  String toString() {
    return r'tabWindowSessionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TabWindowSession create() => TabWindowSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TabWindowSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TabWindowSessionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabWindowSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabWindowSessionHash() => r'f057e5155053d477962ed02b187bbb8b7ab8234c';

final class TabWindowSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          TabWindowSession,
          TabWindowSessionState,
          TabWindowSessionState,
          TabWindowSessionState,
          (TabWindowList?, TabWindow?)
        > {
  TabWindowSessionFamily._()
    : super(
        retry: null,
        name: r'tabWindowSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabWindowSessionProvider call([TabWindowList? tabs, TabWindow? activeTab]) =>
      TabWindowSessionProvider._(argument: (tabs, activeTab), from: this);

  @override
  String toString() => r'tabWindowSessionProvider';
}

abstract class _$TabWindowSession extends $Notifier<TabWindowSessionState> {
  late final _$args = ref.$arg as (TabWindowList?, TabWindow?);
  TabWindowList? get tabs => _$args.$1;
  TabWindow? get activeTab => _$args.$2;

  TabWindowSessionState build([TabWindowList? tabs, TabWindow? activeTab]);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TabWindowSessionState, TabWindowSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TabWindowSessionState, TabWindowSessionState>,
              TabWindowSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
