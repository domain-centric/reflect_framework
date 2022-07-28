import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reflect_framework/core/action_method_info.dart';

class Tabs extends ListBase<Tab> with ChangeNotifier, DiagnosticableTreeMixin {
  List<Tab> _tabs = [];
  Tab? _selectedTab;

  int get length => _tabs.length;

  set length(int length) {
    _tabs.length = length;
  }

  void operator []=(int index, Tab value) {
    _tabs[index] = value;
    notifyListeners();
  }

  Tab operator [](int index) => _tabs[index];

  void add(Tab value) {
    if (_tabs.length >= 10) {
      _closeOneTab();
    }
    _tabs.add(value);
    _selectedTab = value;
    notifyListeners();
  }

  void addAll(Iterable<Tab> all) {
    _tabs.addAll(all);
    _selectedTab = all.last;
    notifyListeners();
  }

  Tab get selected {
    if (_tabs.contains(_selectedTab)) {
      return _selectedTab!;
    } else if (_tabs.isEmpty) {
      throw new Exception('No tabs, so no selected tab');
    } else {
      _selectedTab = _tabs.last;
      return _selectedTab!;
    }
  }

  set selected(Tab selectedTab) {
    if (!_tabs.contains(selectedTab)) {
      add(selectedTab);
    }
    _selectedTab = selectedTab;
    notifyListeners();
  }

  int get selectedIndex {
    try {
      return _tabs.indexOf(selected);
    } on Exception {
      return -1;
    }
  }

  close(Tab tab) {
    if (tab.canCloseDirectly) {
      _tabs.remove(tab);
      notifyListeners();
    } else {
      var closeResult = tab.close;
      if (closeResult == TabCloseResult.CLOSED) {
        _tabs.remove(tab);
        notifyListeners();
      }
    }
  }

  void closeAll() {
    _tabs.clear();
    notifyListeners();
  }

  void closeOthers(Tab tab) {
    _tabs.clear();
    _tabs.add(tab);
    notifyListeners();
  }

  void _closeOneTab() {
    Tab tabToClose = _findTabToClose()!;
    close(tabToClose);
    // We are not going to ask the user the close other tabs if
    // the tab.close result is TabCloseResult.CANCELED.
    // At least we tried to keep the number of open tabs below 10.
  }

  ///returns a [Tab] that can be closed directly, or otherwise the first (oldest) [Tab]
  Tab? _findTabToClose() {
    return _tabs.firstWhere((tab) => tab.canCloseDirectly,
        orElse: () => _tabs.first);
  }
}

abstract class Tab extends StatelessWidget {
  const Tab({Key? key}) : super(key: key);

  String get title;

  IconData get iconData;

  bool get canCloseDirectly;

  /// asks the [Tab] to close. The [Tab] could open a dialog if it contains
  /// unsaved data, so the user can decide if the [Tab] can be closed or not.
  TabCloseResult get close;
}

enum TabCloseResult { CANCELED, CLOSED }

abstract class TabFactory {
  Tab create(ActionMethodInfo actionMethodInfo);
}

///TODO remove, only intended for testing
class ExampleTab extends Tab {
  final String _creationDateTime;

  final ActionMethodInfo actionMethodInfo;

  ExampleTab(this.actionMethodInfo)
      : _creationDateTime =
            DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now());

  @override
  bool get canCloseDirectly => true;

  @override
  TabCloseResult get close => TabCloseResult.CLOSED;

  @override
  IconData get iconData {
    var i = new Random().nextInt(5);
    switch (i) {
      case 0:
        return Icons.favorite;
      case 1:
        return Icons.info;
      case 2:
        return Icons.tab;
      case 3:
        return Icons.table_rows;
      case 4:
        return Icons.edit;
      default:
        return Icons.settings;
    }
  }

  @override
  String get title {
    return actionMethodInfo.name;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(_creationDateTime, textAlign: TextAlign.center),
    );
  }
}

///TODO remove, only intended for testing
class ExampleTabFactory implements TabFactory {
  @override
  Tab create(ActionMethodInfo actionMethodInfo) {
    return ExampleTab(actionMethodInfo);
  }
}
