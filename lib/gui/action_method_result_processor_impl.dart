import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reflect_framework/core/annotations.dart';
import 'package:reflect_framework/gui/gui_tab.dart';
import 'package:reflect_framework/gui/gui_tab_form.dart';
import 'package:reflect_framework/gui/gui_tab_table.dart';


@ActionMethodResultProcessor(100)
void showPopupTextForMethodsReturningVoid(BuildContext context) {
  //TODO
}

//TODO other dart types e.g. int, double, num, date/time
@ActionMethodResultProcessor(102)
void showStringInDialog(BuildContext context, Object value) {
  // tabs = Provider.of<Tabs>(context);
  // TODO
}

@ActionMethodResultProcessor(110)
void showDomainObjectInReadonlyFormTab(
    BuildContext context, @DomainClass() Object domainObject) {
  var tabs = Provider.of<Tabs>(context);
  var formTab = FormExampleTab(); //TODO readonly + pass domain object
  tabs.add(formTab);
}

//TODO other dart types e.g. stream, iterator, etc and for generic dart types e.g. int, double, date/time
@ActionMethodResultProcessor(111)
void showListInTableTab(
    BuildContext context, @DomainClass() List<Object> domainObjects) {
  var tabs = Provider.of<Tabs>(context);
  var tableTab = TableExampleTab(); // TODO pass collection
  tabs.add(tableTab);
}
