import 'package:code_builder/code_builder.dart';

import '../core/reflect_documentation.dart';
import 'info_json.dart';
import 'translations.dart';

/// The [ReflectApplication], [ServiceObject]s and [DomainObject]s can have behavior that defines how the objects act or how they are displayed. Behavior can be defined with:
/// * [BehavioralAnnotation]s
/// * [BehavioralMethod]s
abstract class ObjectBehavior extends ConceptDocumentation {}

/// [BehavioralAnnotation]s are recognized by the [ReflectFramework] and define how [DomainObject]s, [Property]s or [ActionMethods] behave (how they act and how they are displayed).
/// * [BehavioralAnnotation]s are normally located before the declaration of the member:
/// * [BehavioralAnnotation]s for a class: are located before the class key word
/// * [BehavioralAnnotation]s for a [DomainObjectProperty]: are located before the getter method or field of a [Property]
/// * [BehavioralAnnotation]s for an [ActionMethod]: are located before the [ActionMethod]
abstract class BehavioralAnnotation extends ConceptDocumentation {}

/// [BehavioralMethod]s are recognized by the [ReflectFramework] and dynamically define how [DomainObject]s, [Property]s or [ActionMethod]s behave (how they act and how they displayed). The [ReflectFramework] will call these [BehavioralMethod]s when the user interface is updated to get the current behavioral values depending on the state of the object (its property values)
///
/// [BehavioralMethod] Convention:
/// * Syntax: <memberName><behaviourName>
///   * <memberName>= can be a ClassName, a [Property]Name or a [ActionMethod]Name
///   * <behaviourName>= A behavior like [Hidden], [Disabled], [Validation], etc
/// * [BehavioralMethod]s do NOT have any parameters
/// * [BehavioralMethod]s ALWAYS return a value (See implementations of [BehavioralMethod])
/// * [BehavioralMethod]s are public (name does not start with an underscore)
/// * [BehavioralMethod]s are not static
/// * [BehavioralMethod]s are normally located after the declaration of the member:
///   * [BehavioralMethod]s for classes: are located after the constructors
///   * [BehavioralMethod]s for [DomainObjectProperty]: are located after the getter and setter methods of the properties
///   * [BehavioralMethod]s for [ActionMethod]: are located after the [ActionMethod]
abstract class BehavioralMethod extends ConceptDocumentation {}

///Class names, [DomainObjectProperty] names and [ActionMethod] names are part of the [ubiquitous language](https://martinfowler.com/bliki/UbiquitousLanguage.html): in terms both understand by users and developers. The [ReflectFramework] therefore displays the same names as used in the program code.
///
/// _[DisplayName] Default_
/// The Dart code of your program already has English names:
/// * Classes have names that are formatted in [UpperCamelCase](https://en.wikipedia.org/wiki/Camel_case), e.g. OrderService
/// * [Property] names are formatted in [lowerCamelCase](https://en.wikipedia.org/wiki/Camel_case), e.g. orderLines
/// * [ActionMethod] names are formatted in [lowerCamelCase](https://en.wikipedia.org/wiki/Camel_case), e.g. addOrderLine .
///
/// The [ReflectFramework] translates these [camelCase]((https://en.wikipedia.org/wiki/Camel_case)) names to normal sentences for the human user.
/// * [ReflectApplication] name is translated , e.g. "MyFirstApp" becomes "My first app"
/// * [ServiceObject] names are translated to a plural form without the "Service" suffix, e.g. "OrderService" becomes "Orders"
/// * [Property] names are translated, e.g. "orderLines" becomes "Order lines"
/// * [ActionMethod] names are translated, e.g. "addOrderLine" becomes "Add order line".
///
/// The [ReflectFramework] supports [DisplayName]s for multiple languages. //TODO explain Translation builder and keys and csv file.
// TODO
// DisplayName Annotation
// The ReflectFramework will automatically convert the names used in the program code to a human readable English format by default. In some cases the default DisplayName does not suffice, in example when:
//
// A different use of capital case is needed
// Special characters are needed that can not be used in the code
// The plural form of the default displayName of a ServiceObject is incorrect
// In these cases you can use a DisplayName annotation. The DisplayName annotation is placed:
//
// before the class keyword
// before the getter method of a DomainObjectProperty
// or before a ActionMethod
// TODO EXAMPLE ACMEWebShop

class DisplayName {
  /// Creates a Dart method to return a [DisplayName]
  static Method createMethod(TypeJson typeJson) {
    //TODO String key = TranslationFactory.createKey(typeJson);
    //TODO String code = "return translation().$key";
    String englishText = TranslationFactory.createEnglishText(typeJson);
    String code = "return '$englishText';";
    return Method((b) {
      return b
        ..name = 'displayName'
        ..type = MethodType.getter
        ..returns = refer('String')
        ..body = Code(code);
    });
  }
}
