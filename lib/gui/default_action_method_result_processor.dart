import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reflect_framework/core/action_method_info.dart';
import 'package:reflect_framework/core/annotations.dart';
import 'package:reflect_framework/domain/domain_objects.dart';
import 'package:reflect_framework/gui/gui_tab.dart';
import 'package:reflect_framework/gui/gui_tab_form.dart';
import 'package:reflect_framework/gui/gui_tab_table.dart';

@ActionMethodResultProcessor(index: 100)
void showMethodExecutedSnackBarForMethodsReturningVoid(
    BuildContext context, ActionMethodInfo actionMethodInfo) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          '${actionMethodInfo.name} has executed successfully.'), //TODO make multilingual
    ),
  );
  //TODO catch and show error message dialog
}

//TODO other dart types e.g. int, double, num, date/time
@ActionMethodResultProcessor(index: 102, defaultIcon: Icons.crop_7_5)
void showStringInDialog(
    BuildContext context, ActionMethodInfo actionMethodInfo, String value) {
  // tabs = Provider.of<Tabs>(context);
  //TODO catch and show error message dialog
}

@ActionMethodResultProcessor(index: 110, defaultIcon: Icons.table_rows_sharp)
void showDomainObjectInReadonlyFormTab(BuildContext context,
    ActionMethodInfo actionMethodInfo, @DomainClass() Person domainObject) {
  //TODO change to Object and make @DomainClass annotation work
  var tabs = Provider.of<Tabs>(context, listen: false);
  var formTab =
      FormExampleTab(actionMethodInfo); //TODO readonly + pass domain object
  tabs.add(formTab);
  //TODO catch and show error message dialog
}

//TODO other dart types e.g. stream, iterator, etc and for generic dart types e.g. int, double, date/time
@ActionMethodResultProcessor(index: 111, defaultIcon: Icons.table_chart_sharp)
void showListInTableTab(BuildContext context, ActionMethodInfo actionMethodInfo,
    @DomainClass() List<Object> domainObjects) {
  try {
    var tabs = Provider.of<Tabs>(context, listen: false);
    var tableTab = TableExampleTab(actionMethodInfo); // TODO pass collection
    tabs.add(tableTab);
  } catch (e) {
    //TODO show error message dialog
  }
}
