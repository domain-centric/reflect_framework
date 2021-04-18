import 'package:dart_code/dart_code.dart';
import 'package:plural_noun/plural_noun.dart';
import 'package:recase/recase.dart';

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
/// _[Description] Default_
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
/// The [ReflectFramework] supports [Description]s for multiple languages. //TODO explain Translation builder and keys and csv file.
// TODO
// Name Annotation
// The ReflectFramework will automatically convert the names used in the program code to a human readable English format by default. In some cases the default name does not suffice, in example when:
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

class Name {
  final String key;
  final String englishName;

  Name.forApplicationClass(ClassJson classJson)
      : key = TranslationFactory.createKey(classJson.type),
        englishName = _createEnglishNameForClass(classJson);

  Name.forServiceClass(ClassJson classJson)
      : key = TranslationFactory.createKey(classJson.type),
        englishName = _createEnglishNameForServiceClass(classJson);

  Name.forActionMethod(ClassJson classJson, ExecutableJson methodJson)
      : key = TranslationFactory.createKey(classJson.type) +
            '.' +
            methodJson.name,
        englishName = _createEnglishNameForActionMethod(methodJson);

  static String _createEnglishNameForServiceClass(ClassJson classJson) {
    // TODO check if serviceClass has translation annotations
    String nameWithoutServiceSuffix = removeServiceSuffix(classJson.type.name);
    List<String> words = slitIntoWords(nameWithoutServiceSuffix);
    makeLastWordPlural(words);
    return words.join(' ');
  }

  static void makeLastWordPlural(List<String> words) {
    int lastWordIndex = words.length - 1;
    words[lastWordIndex] =
        PluralRules().convertToPluralNoun(words[lastWordIndex]);
  }

  static List<String> slitIntoWords(String nameWithoutServiceSuffix) =>
      nameWithoutServiceSuffix.sentenceCase.split(' ');

  static String removeServiceSuffix(String name) =>
      name.replaceAll(RegExp("Service\$"), "");

  static String _createEnglishNameForClass(ClassJson classJson) =>
      //TODO check if Class has translation annotations
      classJson.type.name.sentenceCase;

  static _createEnglishNameForActionMethod(ExecutableJson methodJson) =>
      //TODO check if Method has translation annotations
      methodJson.name.sentenceCase;

  /// Creates a Dart method to return a [Description]
  Method createGetterMethod() {
    Expression body = Expression.ofString(englishName);
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method.getter('name', body,
        type: Type.ofString(), annotations: annotations);
    return method;
  }
}

class Description {
  final String key;
  final String englishName;

  Description.forApplicationClass(ClassJson classJson)
      : key = TranslationFactory.createKey(classJson.type),
        englishName = _createEnglishDescriptionForClass(classJson);

  Description.forServiceClass(ClassJson classJson)
      : key = TranslationFactory.createKey(classJson.type),
        englishName = _createEnglishDescriptionForServiceClass(classJson);

  Description.forActionMethod(ClassJson classJson, ExecutableJson methodJson)
      : key = TranslationFactory.createKey(classJson.type) +
            '.' +
            methodJson.name,
        englishName = _createEnglishDescriptionForActionMethod(methodJson);

  static String _createEnglishDescriptionForServiceClass(ClassJson classJson) {
    // TODO check if serviceClass has translation annotations
    // TODO String nameWithoutServiceSuffix = removeServiceSuffix(classJson.type.name);
    // List<String> words = slitIntoWords(nameWithoutServiceSuffix);
    // makeLastWordPlural(words);
    // return words.join(' ');
    return ''; //TODO
  }

  static String _createEnglishDescriptionForClass(ClassJson classJson) =>
      //TODO check if Class has translation annotations
      //TODO classJson.type.name.sentenceCase;
      '';

  static _createEnglishDescriptionForActionMethod(ExecutableJson methodJson) =>
      //TODO check if Method has translation annotations
      //TODO methodJson.name.sentenceCase;
      '';

  /// Creates a Dart method to return a [Description]
  Method createGetterMethod() {
    Expression body = Expression.ofString(englishName);
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method.getter('description', body,
        type: Type.ofString(), annotations: annotations);
    return method;
  }
}

class Visible {
  Visible.forApplicationClass(ClassJson classJson); //TODO

  Visible.forServiceClass(
      ClassJson classJson); //TODO include: actionMethods.any((a) => a.visible);

  Visible.forActionMethod(
      ClassJson classJson, ExecutableJson methodJson); //TODO

  /// Creates a Dart method to return a [Description]
  Method createGetterMethod() {
    Expression body = Expression.ofBool(true); //TODO
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method.getter('visible', body,
        type: Type.ofBool(), annotations: annotations);
    return method;
  }
}

class Order {
  Order.forApplicationClass(ClassJson classJson); //TODO

  Order.forServiceClass(ClassJson classJson); //TODO

  Order.forActionMethod(ClassJson classJson, ExecutableJson methodJson); //TODO

  /// Creates a Dart method to return a [Description]
  Method createGetterMethod() {
    Expression body = Expression.ofDouble(100); //TODO
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method.getter('order', body,
        type: Type.ofDouble(), annotations: annotations);
    return method;
  }
}

class Icon {
  final Expression body;

  Icon.forActionMethod(ClassJson classJson, ExecutableJson methodJson)
      : body = createExpression(methodJson); //TODO

  /// Creates a Dart method to return a [Description]
  Method createGetterMethod() {
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method.getter('icon', body,
        type: Type('IconData', libraryUrl: 'package:flutter/widgets.dart'),
        annotations: annotations);
    return method;
  }

  //TODO replace with something descent (this is just for testing)
  static Expression createMaterialIconExpression(String materialIconName) =>
      Expression([
        Type('Icons', libraryUrl: 'package:flutter/material.dart'),
        Code('.' + materialIconName)
      ]);

  static Expression createExpression(ExecutableJson methodJson) {
    // if (methodJson.annotations.contains(TypeJson('Icon', '')))
    // get icon from behavioural method
    // get icon from annotation

    // try get icon from Icons collection
    //TODO .add   add/create/new
    //TODO .delete      remove, delete
    //TODO .archive     archive
    //TODO .search      search/find
    //TODO .settings    settings
    //TODO .info
    //TODO .favourite
    //TODO .schedule
    // try get default icon from processresultprocessor
    // try get default icon from processparameterprocessor
    // return default icon
    //TODO .lens    {default}

    switch (methodJson.name) {
      case 'addNew':
        return createMaterialIconExpression('table_rows_sharp'); //circle
        break;
      case 'allPersons':
      case 'findPersons':
        return createMaterialIconExpression('table_chart_sharp'); //circle
        break;
      default:
        {
          return createMaterialIconExpression('lens'); //circle
        }
    }
  }
}
