import 'package:flutter/widgets.dart';
import 'package:reflect_framework/core/action_method_info.dart';

import '../core/annotations.dart';

@ActionMethodParameterProcessor(index: 100)
void executeDirectlyForMethodsWithoutParameter(
    BuildContext context, InvokeWithoutParameter actionMethod) {
  actionMethod.invokeMethodAndProcessResult(context);
}

@ActionMethodParameterProcessor(index: 102)
void editDomainObjectParameterInForm(BuildContext context,
    InvokeWithParameter actionMethod, @DomainClass() Object domainObject) {
  // TODO something like:
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab(context, domainObject);
  // tabs.add(formTab);

  //TODO put in form OK button:
  actionMethod.invokeMethodAndProcessResult(context, domainObject);
}

//TODO other Dart types such as int, double,num, bool, DateTime
@ActionMethodParameterProcessor(index: 103)
void editStringParameterInDialog(
    BuildContext context, InvokeWithParameter actionMethod, String string) {
  // TODO create and open dialog

  //TODO put in dialog OK button:
  actionMethod.invokeMethodAndProcessResult(context, string);
}

@ActionMethodParameterProcessor(
    index: 150, requiredAnnotations: [ExecutionMode.directly])
void executeDirectlyForMethodsWithProcessDirectlyAnnotation(
    BuildContext context, InvokeWithParameter actionMethod, Object anyObject) {
  actionMethod.invokeMethodAndProcessResult(context, anyObject);
}
