import 'package:flutter/material.dart';
import 'package:reflect_framework/core/action_method_info.dart';

import '../gui/gui_tab.dart';
import '../gui/gui_tab_form.dart';
import '../gui/gui_tab_table.dart';

///TODO to be replaced by generated.dart library with a [GeneratedApplicationInfo] class that implements [ApplicationInfo]
class ServiceObjectInfo {
  final String title;

  ServiceObjectInfo({this.title});

  final List<ActionMethodInfoOld> mainMenuItems = _createMainMenuItems();

  static List<ActionMethodInfoOld> _createMainMenuItems() {
    //TODO this is for testing and needs replacing
    return [
      ActionMethodInfoOld(
          title: "Random",
          tabFactory: ExampleTabFactory(),
          icon: Icons.tab_sharp),
      ActionMethodInfoOld(
          title: "Form",
          tabFactory: FormExampleTabFactory(),
          icon: Icons.table_rows_sharp),
      ActionMethodInfoOld(
          title: "Table",
          tabFactory: TableExampleTabFactory(),
          icon: Icons.table_chart_sharp),
    ];
  }
}


