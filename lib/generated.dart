import 'package:flutter/material.dart' as _i5;
import 'package:reflect_framework/core/action_method_info.dart' as _i3;
import 'package:reflect_framework/core/application_info.dart' as _i1;
import 'package:reflect_framework/core/service_class_info.dart' as _i2;
import 'package:reflect_framework/gui/gui_tab.dart' as _i4;
import 'package:reflect_framework/gui/gui_tab_form.dart' as _i6;
import 'package:reflect_framework/gui/gui_tab_table.dart' as _i7;

/// This code is generated by [ApplicationInfoBuilder]
/// Do not modify or remove this code!
/// Regenerate it if needed using the following command: flutter packages pub run build_runner build lib --delete-conflicting-outputs
class ReflectApplicationInfo implements _i1.ApplicationInfo {
  @override
  String get name => 'My first app';

  @override
  String get description => '';

  @override
  String get titleImage => 'assets/my_first_app.png';

  @override
  String get homePage =>
      'https://github.com/efficientyboosters/reflect_framework';

  @override
  String get documentation =>
      'https://github.com/efficientyboosters/reflect_framework/wiki';

  @override
  List<_i2.ServiceClassInfo> get serviceClassInfos =>
      [DomainObjectsPersonServiceInfo$()];
}

class DomainObjectsPersonServiceInfo$ implements _i2.ServiceClassInfo {
  @override
  String get name => 'People';

  @override
  String get description => '';

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  List<_i3.ActionMethodInfoOld> get actionMethodInfos => [
        _i3.ActionMethodInfoOld(
            title: 'Random',
            tabFactory: _i4.ExampleTabFactory(),
            icon: _i5.Icons.tab_sharp),
        _i3.ActionMethodInfoOld(
            title: 'Form',
            tabFactory: _i6.FormExampleTabFactory(),
            icon: _i5.Icons.table_rows_sharp),
        _i3.ActionMethodInfoOld(
            title: 'Table',
            tabFactory: _i7.TableExampleTabFactory(),
            icon: _i5.Icons.table_chart_sharp)
      ];
}
