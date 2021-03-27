import '../core/annotations.dart';
import 'action_method_pre_processor_context.dart';

@ActionMethodProcessor(100)
void showPopupTextForMethodsReturningVoid(
    ActionMethodPreProcessorContext context) {
  context.actionMethodInfo.process(context, []);
}

//TODO other dart types e.g. int, double, num, date/time
@ActionMethodProcessor(102)
void showStringInDialog(ActionMethodPreProcessorContext context, String value) {
  // tabs = Provider.of<Tabs>(context);
  // TODO
}

@ActionMethodProcessor(110)
void showDomainObjectInReadonlyFormTab(ActionMethodPreProcessorContext context,
    @DomainClass() Object domainObject) {
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab.readOnly(context, domainObject);
  // tabs.add(formTab);
}

//TODO other dart types e.g. stream, iterator, etc and for generic dart types e.g. int, double, date/time
@ActionMethodProcessor(111)
void showListInTableTab(ActionMethodPreProcessorContext context,
    @DomainClass() List<Object> domainObjects) {
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab.readOnly(context, domainObject);
  // tabs.add(formTab);
}
