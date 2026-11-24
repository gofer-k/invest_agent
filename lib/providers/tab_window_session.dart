import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:invest_agent/model/cache_schema.dart';
import 'package:invest_agent/widgets/utils/tabbed_window_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_window_session.g.dart';

class TabWindow {
  final TabbedWindowType type;
  final Cache cache;

  const TabWindow({required this.type, required this.cache});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabWindow &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          cache == other.cache;

  @override
  int get hashCode => type.hashCode ^ cache.hashCode;
}

typedef TabWindowList = Set<TabWindow>;

@immutable
class TabWindowSessionState {
  final TabWindowList tabs;
  final TabWindow? activeTab;

  const TabWindowSessionState({this.tabs = const {}, this.activeTab});

  TabWindowSessionState copyWith({
    TabWindowList? newTabs,
    TabWindow? newActiveTab,
  }) {
    return TabWindowSessionState(
      tabs: newTabs ?? tabs,
      activeTab: newActiveTab ?? activeTab,
    );
  }
}

@riverpod
class TabWindowSession extends _$TabWindowSession {
  @override
  TabWindowSessionState build([TabWindowList? tabs, TabWindow? activeTab]) {
    return TabWindowSessionState(
      tabs: tabs ?? {},
      activeTab: activeTab ?? (tabs?.isNotEmpty == true ? tabs!.first : null),
    );
  }

  @override
  TabWindowList get tabs => state.tabs;

  @override
  TabWindow? get activeTab => state.activeTab;

  void updateActiveTab(TabWindow? updatedTab) {
    if (updatedTab != null && state.tabs.contains(updatedTab)) {
      state = state.copyWith(newActiveTab: updatedTab);
    } else {
      log("Failed update active tab");
    }
  }

  bool addTab(TabWindow newTab, [bool updateActiveTab = true]) {
    final newTabs = Set<TabWindow>.from(state.tabs);
    if (newTabs.add(newTab)) {
      state = state.copyWith(
        newTabs: newTabs,
        newActiveTab: updateActiveTab ? newTab : state.activeTab,
      );
      return true;
    }
    log("Failed to add tab");
    return false;
  }

  bool removeTab(TabWindow tab) {
    final newTabs = Set<TabWindow>.from(state.tabs);
    if (newTabs.remove(tab)) {
      TabWindow? newActive = state.activeTab;
      if (activeTab?.hashCode == tab.hashCode) {
        newActive = newTabs.isEmpty ? null : newTabs.first;
      }
      state = state.copyWith(newTabs: newTabs, newActiveTab: newActive);
      return true;
    }
    log("Failed to remove tab");
    return false;
  }

  void clear() => state = const TabWindowSessionState();
}
