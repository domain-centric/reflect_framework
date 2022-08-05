import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';
import 'package:reflect_framework/code_builders_code/action_method_info_class.dart';
//import 'package:reflect_framework/code_builders_code/property_reflection.dart';

/// Process:
///
/// Read SourceCodeModel (e.g. stored as reflect.json files)
/// - using DomainClassIdentifier and ServiceClassIdentifier? that have a bool isPotentialDomain/ServiceClass method
///
/// Find potential domainObjects using a DomainClassIdentifier
/// For each domainObject:
///   for each property
///       check if property type is supported
/// Then for each service object and [DomainObject]
///   for each method
///       check of there is a [ActionMethodParameterProcessor] and [ActionMethodResultProcessor] using the domainObjects

/// TODO would it be better to identify DomainClasses in [ReflectJsonBuilder]?
abstract class DomainClassIdentifier {
  bool isDomainClass(ClassJson classJson);
}

class DefaultDomainClassIdentifier implements DomainClassIdentifier {
  static final CharacterSet lettersAndUnderScore =
      CharacterSet().addLetters().addLiterals('_');

  static final regex = FluentRegex()
      .startOfLine()
      .literal('/')
      .characterSet(
          lettersAndUnderScore, const Quantity.oneOrMoreTimes()) //project name
      .literal('/')
      .literal('lib')
      .literal('/')
      .literal('domain')
      .characterSet(lettersAndUnderScore, const Quantity.zeroOrMoreTimes())
    ..group(
            FluentRegex()
              ..literal('/')
              ..characterSet(
                  lettersAndUnderScore, const Quantity.oneOrMoreTimes()),
            quantity: const Quantity.zeroOrMoreTimes())
        .literal('/')
        .characterSet(lettersAndUnderScore, const Quantity.oneOrMoreTimes())
        .literal('.dart')
        .endOfLine();

  @override
  bool isDomainClass(ClassJson classJson) =>
      regex.hasMatch(classJson.type.library!);
}

class DomainClassReflections extends DelegatingList<DomainClassReflection> {
  DomainClassReflections(ReflectJson reflectJson)
      : super(_createDomainClassReflections(reflectJson));

  /// TODO make a config file where you can tell the builder what DomainClassIdentifier to use?
  static final DomainClassIdentifier domainClassIdentifier =
      DefaultDomainClassIdentifier();

  static List<DomainClassReflection> _createDomainClassReflections(
      ReflectJson reflectJson) {
    List<DomainClassReflection> serviceClassInfoClasses = [];
    for (ClassJson classJson in reflectJson.classes) {
      if (domainClassIdentifier.isDomainClass(classJson)) {
        //TODO check if domainClass has a empty constructor or a empty factory constructor or a factory function with name <domainClassName>Factory that returns the correct type (if not log a warning)
        //TODO check if the DomainClass has properties (if not log a warning)
        //TODO
        // var propertyReflections = PropertyReflections(reflectJson, classJson);
        // if (propertyReflections.isNotEmpty) {
        DomainClassReflection domainClassReflection =
            DomainClassReflection(classJson); //TODO: propertyReflections);
        serviceClassInfoClasses.add(domainClassReflection);
        // }
      }
    }
    //TODO throw exception if serviceClasses.isEmpty
    return serviceClassInfoClasses;
  }
}

///e.g.:
///  TODO add generated code example
class DomainClassReflection extends Class {
  final ClassJson classJson;

  //final PropertyReflections propertyReflections;

  DomainClassReflection(
    this.classJson,
  ) // this.propertyReflections)
  : super(_createClassName(classJson),
            superClass: _createDomainClassReflectionType(classJson),
            fields: _createFields(classJson),
            methods: _createMethods(classJson)); //, propertyReflections));

  static List<Field> _createFields(ClassJson classJson) =>
      [_createServiceObjectField(classJson)];

  static String _createClassName(ClassJson classJson) =>
      '${classJson.type.codeName}Reflection\$';

  static Type _createDomainClassReflectionType(ClassJson classJson) =>
      Type('DomainClassReflection',
          libraryUri: 'package:reflect_framework/core/domain_class_info.dart',
          generics: [classJson.type.toType()]);

  static List<Method> _createMethods(
    ClassJson classJson,
  ) =>
      //PropertyReflections propertyReflections) =>
      [
        //TODO change forServiceClass to forDomainClass
        Name.forServiceClass(classJson).createGetterMethod(),
        Description.forServiceClass(classJson).createGetterMethod(),
        Visible.forServiceClass(classJson).createGetterMethod(),
        Order.forServiceClass(classJson).createGetterMethod(),
        //_createActionMethodInfosGetterMethod(propertyReflections),
      ];

  static _createActionMethodInfosGetterMethod(
      ActionMethodInfoClasses actionMethodInfoClasses) {
    CodeFormatter codeFormatter = CodeFormatter();
    CodeNode body = Expression.ofList(actionMethodInfoClasses
        .map((a) => Expression.callConstructor(
            Type(codeFormatter.unFormatted(a.name)),
            parameterValues: ParameterValues([
              ParameterValue(Expression.ofVariable(serviceObjectFieldName))
            ])))
        .toList());
    List<Annotation> annotations = [Annotation.override()];
    var actionMethodInfo = Type('ActionMethodInfo',
        libraryUri: 'package:reflect_framework/core/action_method_info.dart');
    Type type = Type.ofList(genericType: actionMethodInfo);
    Method method = Method.getter('actionMethodInfos', body,
        type: type, annotations: annotations);
    return method;
  }

  static String serviceObjectFieldName = 'serviceObject';

  /// e.g. creates:
  ///     final PersonService serviceObject=PersonService();
  static Field _createServiceObjectField(ClassJson classJson) {
    //TODO check if ServiceClass has empty constructor or factory function. If not throw an exception that there mus be a <ServiceClassType> <serviceClassName>Factory method
    Expression serviceObjectCreationExpression = Expression.callConstructor(
        classJson.type.toType()); //TODO can also be a function
    List<Annotation> annotations = [Annotation.override()];
    return Field(serviceObjectFieldName,
        annotations: annotations,
        modifier: Modifier.final$,
        value: serviceObjectCreationExpression);
  }
}
