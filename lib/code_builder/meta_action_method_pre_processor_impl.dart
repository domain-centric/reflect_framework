import '../core/annotations.dart';
import 'meta_action_method_pre_processor_context.dart';

@ActionMethodPreProcessor(index: 100)
void executeDirectlyForMethodsWithoutParameter(
    ActionMethodPreProcessorContext context) {
  context.actionMethodInfo.process(context, []);
}

@ActionMethodPreProcessor(index: 102)
void editDomainObjectParameterInForm(ActionMethodPreProcessorContext context,
    @DomainClass() Object domainObject) {
  // TODO something like:
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab(context, domainObject);
  // tabs.add(formTab);

  //TODO put in form OK button:
  context.actionMethodInfo.process(context, [domainObject]);
}

//TODO other Dart types such as int, double,num, bool, DateTime
@ActionMethodPreProcessor(index: 103)
void editStringParameterInDialog(
    ActionMethodPreProcessorContext context, String value) {
  // TODO create and open dialog

  //TODO put in dialog OK button:
  context.actionMethodInfo.process(context, [value]);
}

@ActionMethodPreProcessor(
    index: 150, actionMethodMustHaveProcessDirectlyAnnotation: true)
void executeDirectlyForMethodsWithProcessDirectlyAnnotation(
    ActionMethodPreProcessorContext context, Object anyObject) {
  context.actionMethodInfo.process(context, [anyObject]);
}
