import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';

import '../code_builders/info_json.dart';
import 'action_method_info_class.dart';

class ServiceClassInfoClasses extends DelegatingList<ServiceClassInfoClass> {
  ServiceClassInfoClasses(ReflectJson reflectJson)
      : super(_createsServiceClassInfoClasses(reflectJson));

  static List<ServiceClassInfoClass> _createsServiceClassInfoClasses(
      ReflectJson reflectJson) {
    final serviceClassAnnotation = TypeJson.serviceClassAnnotation();
    List<ServiceClassInfoClass> serviceClassInfoClasses = [];
    for (ClassJson classJson in reflectJson.classes) {
      if (classJson.annotations.any((a) => a.type == serviceClassAnnotation)) {
        //TODO check if serviceClasses have a empty constructor or a empty factory constructor or a factory function with name <serviceClassName>Factory that returns the correct type (if not throw exception)
        //TODO check if the service class has properties (if not show warning)
        var actionMethodInfoClasses =
            ActionMethodInfoClasses(reflectJson, classJson);
        if (actionMethodInfoClasses.isNotEmpty) {
          ServiceClassInfoClass serviceClassInfoCode =
              ServiceClassInfoClass(classJson, actionMethodInfoClasses);
          serviceClassInfoClasses.add(serviceClassInfoCode);
        }
      }
    }
    //TODO throw exception if serviceClasses.isEmpty
    return serviceClassInfoClasses;
  }
}

///e.g.:
/// class DomainObjectsPayment extends _i1.ServiceClassInfo {
///  final _i3.Payment _serviceObject = _i3.Payment();
///
///   Object get serviceObject => _serviceObject;
///
///   String get displayName =>'Payments';
///
///   double get order => 500;
/// }
class ServiceClassInfoClass extends Class {
  final ClassJson classJson;
  final ActionMethodInfoClasses actionMethodInfoClasses;

  ServiceClassInfoClass(this.classJson, this.actionMethodInfoClasses)
      : super(_createClassName(classJson),
            superClass: _createServiceClassInfoType(classJson),
            fields: _createFields(classJson),
            methods: _createMethods(classJson, actionMethodInfoClasses));

  static List<Field> _createFields(ClassJson classJson) =>
      [_createServiceObjectField(classJson)];

  static String _createClassName(ClassJson classJson) =>
      '${classJson.type.codeName}Info\$';

  static Type _createServiceClassInfoType(ClassJson classJson) =>
      Type('ServiceClassInfo',
          libraryUri: 'package:reflect_framework/core/service_class_info.dart',
          generics: [classJson.type.toType()]);

  static List<Method> _createMethods(ClassJson classJson,
          ActionMethodInfoClasses actionMethodInfoClasses) =>
      [
        Name.forServiceClass(classJson).createGetterMethod(),
        Description.forServiceClass(classJson).createGetterMethod(),
        Visible.forServiceClass(classJson).createGetterMethod(),
        Order.forServiceClass(classJson).createGetterMethod(),
        _createActionMethodInfosGetterMethod(actionMethodInfoClasses),
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
