import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reflect_framework/reflect_gui_tab_form.dart';
import 'package:reflect_framework/reflect_gui_tab_table.dart';
import 'package:reflect_framework/reflect_gui_tab.dart';

class Reflection {
  final ApplicationInfo applicationInfo = ApplicationInfo();
  final List<ServiceObjectInfo> serviveObjectInfos = [
    ServiceObjectInfo(title:"Login"),
    ServiceObjectInfo(title:"Orders")
  ];
}

class ApplicationInfo {
  String get title {
    return "Application title"; //TODO get using reflection of [ReflectApplication] or https://pub.dev/packages/package_info
  }

  String get titleImagePath => 'assets/my_first_app.png';
}

class ServiceObjectInfo {
  final String title ;

  ServiceObjectInfo({this.title});

  final List<ActionMethodInfo> mainMenuItems = _createMainMenuItems();

  static List<ActionMethodInfo> _createMainMenuItems() {
    //TODO this is for testing and needs replacing
    return [
      ActionMethodInfo(
          title: "Random",
          tabFactory: ExampleTabFactory(),
          icon: Icons.tab_sharp),
      ActionMethodInfo(
          title: "Form",
          tabFactory: FormExampleTabFactory(),
          icon: Icons.table_rows_sharp),
      ActionMethodInfo(
          title: "Table",
          tabFactory: TableExampleTabFactory(),
          icon: Icons.table_chart_sharp),
    ];
  }
}

class ActionMethodInfo {
  final TabFactory tabFactory;
  final String title;
  final IconData icon;

  ActionMethodInfo(
      {@required this.title, @required this.tabFactory, this.icon});

  void execute(BuildContext context, Object serviceObject) {
    //TODO create different ways to execute an actionMethod (e.g. open FormTab, open ListTab, showHamburger, dialog etc) with ResultHandlers (provided by the ReflectApplication)
    var tabs = Provider.of<Tabs>(context, listen: false);
    var tab = tabFactory.create();
    tabs.add(tab);
  }
}


