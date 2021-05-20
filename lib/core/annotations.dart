import 'package:flutter/widgets.dart';
import 'package:reflect_framework/core/action_method_info.dart';

/// A [ActionMethodParameterProcessor] does something with [ActionMethod] parameters, for a given method parameter signature, before the [ActionMethodResultProcessor] is called to process the method result.
///
/// [ActionMethodParameterProcessor]s are functions that:
///  - are preceded with a [ActionMethodParameterProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ServiceObjectActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodParameterProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.
class ActionMethodParameterProcessor {
  /// A number to set the index compared to other [ActionParameterAction]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  /// If the [ActionMethod] must have a [ProcessDirectly] annotation, in order to be processed by the [ActionMethodParameterProcessor]. Default=false
  final List<Object> requiredAnnotations;

  final IconData? defaultIcon;

  const ActionMethodParameterProcessor(
      {required this.index,
      this.requiredAnnotations = const [],
      this.defaultIcon});
}

/// Annotation value for a [ActionMethod] on how to process the parameter value
enum ExecutionMode {
  /// Execute the [ActionMethod] directly, by calling [ActionMethodInfo.invokeMethodAndProcessResult] in the [ActionMethodInfo.start] method
  directly,

  /// first show the [ActionMethod] parameter value and ask the user to to confirm (e.g. with a dialog). If so, call [ActionMethodInfo.invokeMethodAndProcessResult]
  firstAskConformation,

  /// first let the user edit the [ActionMethod] parameter value (e.g. in a [FormTab]). Then, call [ActionMethodInfo.invokeMethodAndProcessResult]
  firstEditParameter
}

/// A [ActionMethodResultProcessor] processed the [ActionMethod] results (e.g. displays the results to the user or sends back an reply)
///
///  [ActionMethodResultProcessor]s are functions that:
///  - are preceded with a [ActionMethodResultProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodResultProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.

class ActionMethodResultProcessor {
  /// A number to set the index compared to other [ActionMethodResultProcessor]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  final IconData? defaultIcon;

  const ActionMethodResultProcessor({required this.index, this.defaultIcon});
}

/// Annotation to indicate that a class is a [ServiceObject], so that they are recognized by the [ReflectFramework]
/// See [ServiceClassInfo]
class ServiceClass {
  const ServiceClass();
}

/// The [DomainClass] annotation is only used by the [ReflectCodeGeneration] to indicate that a method parameter or return value is a [DomainObject].
/// See:
/// - [ActionMethodParameterProcessor]s
/// - [ActionMethodResultProcessor]s
class DomainClass {
  const DomainClass();
}

/// A [ActionMethodParameterFactory] creates an new instance for the [ActionMethod] parameter.
/// This parameter can than be processed (See [ActionMethodParameterProcessor]) after which it is passed as the [ActionMethodParameter] parameter when the [ActionMethod] is invoked bij the [ActionMethodResultProcessor].
/// The MainMenu will display all [ActionMethod]s of all registered [ServiceClass]es that can directly be executed . This means that only [ActionMethod]s that either have no method parameter or have an ParameterFactory are displayed as menu items in the MainMenu.
///
/// You can put an [ActionMethodParameterFactory] annotation before an [ActionMethod] to indicate that the parameter can be created with an unnamed no-argument constructor.
/// TODO ActionMethodParameterFactoryMethod
class ActionMethodParameterFactory {
  const ActionMethodParameterFactory();
}

/// Define an icon by adding a [Icon] annotation before an [ActionMethod]
/// Otherwise the reflect framework will select an icon for you. See [info_behaviour.Icon]
class Icon {
  final IconData iconData;

  const Icon(this.iconData);
}

/// The [Translation] annotation is used to add or correct a translatable text.
/// It is an alternative for the intl package (https://pub.dev/packages/intl).
/// The key and English text will automatically be stored in [\lib\translations\translations.csv].
/// You can than later add other languages by adding another column.
/// The key will be the library name + annotation path + suffix. All words will be in lower camelCase and all words will be separated with dots.
///
/// You can place a [Translation] annotation before a class, method or property declaration.
///
/// e.g.:
///
/// import 'package:reflect_framework/annotations.dart';
///
/// //library acme_domain
///
/// class Product {
///
///   // We add a Translation annotation here otherwise the Reflect application would show this property as 'Ups code' instead of 'UPS code'
///   // This will create key: 'acmeDomain.product.upsCode' with English value 'UPS code'
///   @Translation(englishText: 'UPS code')
///   String get upsCode {
///     return '<a UPS code>';//for example only
///   }
///
///   // We add a Translation annotation here so that we can use a translatable text in our text, with a key that refers to this property
///   // this will create key: 'acmeDomain.product.availability.soldOut' with English value 'Sold out' to be used in the code
///   @Translation(keySuffix: 'soldOut', englishText: 'Sold out')
///   String get availability {
///     return Translations.forThisApp().acmeDomain.product.availability.soldOut;//to demonstrate how to use the translation
///   }
/// }
class Translation {
  /// If keySuffix=null: than the translation refers to a library member (Class, Method, Property)
  /// If keySuffix=(a camelCase string): than the translation refers to a translatable string that could be used in your dart code
  final String? keySuffix;
  final String englishText;

  const Translation({this.keySuffix, required this.englishText});
}

