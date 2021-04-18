import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reflect_framework/core/action_method_info.dart';

import '../core/annotations.dart';
import 'gui_tab.dart';
import 'gui_tab_form.dart';

@ActionMethodParameterProcessor(
    index: 102, defaultIcon: Icons.table_chart_sharp)
void editDomainObjectParameterInForm(BuildContext context,
    InvokeWithParameter actionMethod, @DomainClass() Object domainObject) {
  Tabs tabs = Provider.of<Tabs>(context);
  FormExampleTab formTab = FormExampleTab();
  tabs.add(formTab);

  //TODO put in form OK button:  actionMethod.invokeMethodAndProcessResult(context, domainObject);
}

//TODO other Dart types such as int, double,num, bool, DateTime
@ActionMethodParameterProcessor(index: 103, defaultIcon: Icons.crop_7_5)
void editStringParameterInDialog(BuildContext context, InvokeWithParameter actionMethod, String string) {
  // TODO create and open dialog

  //TODO put in dialog OK button:
  actionMethod.invokeMethodAndProcessResult(context, string);
}

@ActionMethodParameterProcessor(
    index: 150, requiredAnnotations: [ExecutionMode.directly])
void executeDirectlyForMethodsWithProcessDirectlyAnnotation(BuildContext context, InvokeWithParameter actionMethod, Object anyObject) {
  actionMethod.invokeMethodAndProcessResult(context, anyObject);
}
