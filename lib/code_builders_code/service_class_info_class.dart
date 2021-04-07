// import 'package:code_builder/code_builder.dart';
//
import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';

import '../code_builders/info_json.dart';

class ServiceClassInfoClasses extends DelegatingList<Class> {
  ServiceClassInfoClasses(ReflectJson reflectJson)
      : super(_createsServiceClassInfoClasses(reflectJson));

  static List<Class> _createsServiceClassInfoClasses(ReflectJson reflectJson) {
    final serviceClassAnnotation = TypeJson.serviceClassAnnotation();
    List<Class> serviceClassInfoClasses = [];
    for (ClassJson classJson in reflectJson.classes) {
      if (classJson.annotations.any((a) => a.type == serviceClassAnnotation)) {
        //TODO check if serviceClasses have a empty constructor or a empty factory constructor or a factory function with name <serviceClassName>Factory that returns the correct type (if not throw exception)
        //TODO check if the service class has properties (if not show warning)

        //TODO check if the service class has action Methods (if not throw exception)
        Class serviceClassInfoCode = ServiceClassInfoClass(classJson);
        serviceClassInfoClasses.add(serviceClassInfoCode);
      }
    }
    //TODO throw exception if serviceClasses.isEmpty

    return serviceClassInfoClasses;
  }
}

// List<Class> createServiceClassInfoCodes(ReflectJson reflectJson) {
//     List<Class> serviceClassInfoCodes = [];
//     for (ClassJson classJson in reflectJson.classes) {
//       //TODO if (classJson.annotations.contains(AnnotationJson.serviceClass())) {
//       //TODO check if serviceClasses have a empty constructor or a empty factory constructor or a factory function with name <serviceClassName>Factory that returns the correct type (if not throw exception)
//       //TODO check if the service class has properties (if not show warning)
//
//       //TODO check if the service class has action Methods (if not throw exception)
//       Class serviceClassInfoCode = ServiceClassInfoCode(classJson);
//       serviceClassInfoCodes.add(serviceClassInfoCode);
//     }
//     //TODO throw exception if serviceClasses.isEmpty
//
//     return serviceClassInfoCodes;
//   }

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
  ServiceClassInfoClass(ClassJson classJson)
      : super(_createClassName(classJson),
            implements: [_createServiceClassInfoType()],
            methods: _createMethods(classJson));

  static String _createClassName(ClassJson classJson) =>
      classJson.type.codeName + 'Info\$';

  static Type _createServiceClassInfoType() => Type('ServiceClassInfo',
      libraryUrl: 'package:reflect_framework/core/service_class_info.dart');

  static List<Method> _createMethods(ClassJson classJson) => [
        Name.forServiceClass(classJson).createGetterMethod(),
        Description.forServiceClass(classJson).createGetterMethod(),
        Visible.forServiceClass(classJson).createGetterMethod(),
        Order.forServiceClass(classJson).createGetterMethod(),
        //TODO remove Service suffix and convert singular to plural
        //TODO Icon.forServiceClass(classJson).createGetterMethod()
        //TODO factory method that creates a serviceobject or returns a chashed serviceobject
        _createActionMethodInfosGetterMethod(classJson),
      ];

  static _createActionMethodInfosGetterMethod(ClassJson classJson) {
    Expression body = Expression.ofList(
        [_createForRandomTab(), _createForFormTab(), _createForTableTab()]);
    List<Annotation> annotations = [Annotation.override()];
    Type type = Type.ofGenericList(Type('ActionMethodInfoOld',
        libraryUrl: 'package:reflect_framework/core/action_method_info.dart'));
    Method method = Method.getter('actionMethodInfos', body,
        type: type, annotations: annotations);
    return method;
  }

  static Expression _createForRandomTab() => Expression.callConstructor(
      Type('ActionMethodInfoOld',
          libraryUrl: 'package:reflect_framework/core/action_method_info.dart'),
      parameterValues: ParameterValues([
        ParameterValue.named('title', Expression.ofString('Random')),
        ParameterValue.named(
            'tabFactory',
            Expression.callConstructor(Type('ExampleTabFactory',
                libraryUrl: 'package:reflect_framework/gui/gui_tab.dart'))),
        ParameterValue.named(
            'icon',
            Expression([
              Type('Icons', libraryUrl: 'package:flutter/material.dart'),
              Code('.tab_sharp')
            ])),
      ]));

  static Expression _createForFormTab() => Expression.callConstructor(
      Type('ActionMethodInfoOld',
          libraryUrl: 'package:reflect_framework/core/action_method_info.dart'),
      parameterValues: ParameterValues([
        ParameterValue.named('title', Expression.ofString('Form')),
        ParameterValue.named(
            'tabFactory',
            Expression.callConstructor(Type('FormExampleTabFactory',
                libraryUrl:
                    'package:reflect_framework/gui/gui_tab_form.dart'))),
        ParameterValue.named(
            'icon',
            Expression([
              Type('Icons', libraryUrl: 'package:flutter/material.dart'),
              Code('.table_rows_sharp')
            ])),
      ]));

  static Expression _createForTableTab() => Expression.callConstructor(
      Type('ActionMethodInfoOld',
          libraryUrl: 'package:reflect_framework/core/action_method_info.dart'),
      parameterValues: ParameterValues([
        ParameterValue.named('title', Expression.ofString('Table')),
        ParameterValue.named(
            'tabFactory',
            Expression.callConstructor(Type('TableExampleTabFactory',
                libraryUrl:
                    'package:reflect_framework/gui/gui_tab_table.dart'))),
        ParameterValue.named(
            'icon',
            Expression([
              Type('Icons', libraryUrl: 'package:flutter/material.dart'),
              Code('.table_chart_sharp')
            ])),
      ]));
}
