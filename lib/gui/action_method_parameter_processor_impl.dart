import '../core/annotations.dart';
import 'action_method_processor_context.dart';

@ActionMethodParameterProcessor(index: 100)
void executeDirectlyForMethodsWithoutParameter(
    ActionMethodProcessorContext context) {
  context.actionMethodInfo.processResult(context, []);
}

@ActionMethodParameterProcessor(index: 102)
void editDomainObjectParameterInForm(
    ActionMethodProcessorContext context, @DomainClass() Object domainObject) {
  // TODO something like:
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab(context, domainObject);
  // tabs.add(formTab);

  //TODO put in form OK button:
  context.actionMethodInfo.processResult(context, [domainObject]);
}

//TODO other Dart types such as int, double,num, bool, DateTime
@ActionMethodParameterProcessor(index: 103)
void editStringParameterInDialog(
    ActionMethodProcessorContext context, String value) {
  // TODO create and open dialog

  //TODO put in dialog OK button:
  context.actionMethodInfo.processResult(context, [value]);
}

@ActionMethodParameterProcessor(
    index: 150, requiredAnnotations: [ExecutionMode.directly])
void executeDirectlyForMethodsWithProcessDirectlyAnnotation(
    ActionMethodProcessorContext context, Object anyObject) {
  //TODO create parameter?

  context.actionMethodInfo.processResult(context, [anyObject]);
}
