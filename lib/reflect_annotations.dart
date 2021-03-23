/// A [ActionMethodPreProcessor] does something with [ActionMethod] parameters, for a given method parameter signature, before the [ActionMethodProcessor] is called to process the method result.
///
/// [ActionMethodPreProcessor]s are functions that:
///  - are preceded with a [ActionMethodPreProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ServiceObjectActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodPreProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.
class ActionMethodPreProcessor {
  /// A number to set the index compared to other [ActionParameterAction]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  /// If the [ActionMethod] must have a [ProcessDirectly] annotation, in order to be pre-processed by the [ActionMethodPreProcessor]. Default=false
  final bool actionMethodMustHaveProcessDirectlyAnnotation;

  const ActionMethodPreProcessor(
      {this.index, this.actionMethodMustHaveProcessDirectlyAnnotation = false});
}

/// A [ActionMethodProcessor] processes the [ActionMethod] results (e.g. displays the results to the user or sends back an reply)
///
///  [ActionMethodProcessor]s are functions that:
///  - are preceded with a [ActionMethodProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.

class ActionMethodProcessor {
  /// A number to set the index compared to other [ActionMethodProcessor]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  const ActionMethodProcessor(this.index);
}

/// Annotation to indicate that [ActionMethodInfo.preProcess] needs to call [ActionMethodInfo.process] directly.
class ProcessDirectly {
  const ProcessDirectly();
}

/// The [DomainClass] annotation is only used by the [ReflectCodeGeneration] to indicate that a method parameter or return value is a [DomainObject].
/// See:
/// - [ActionMethodPreProcessor]s
/// - [ActionMethodProcessor]s

class DomainClass {
  const DomainClass();
}
