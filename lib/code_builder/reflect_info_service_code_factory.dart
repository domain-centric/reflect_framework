import 'package:code_builder/code_builder.dart';

import 'reflect_info_behavioural.dart';
import 'reflect_info_json.dart';

// TODO this library to be replaced using [dart_code] library

class ServiceClassInfoFactory {
  List<Class> createCodes(ReflectJson reflectJson) {
    List<Class> serviceClassInfos = [];
    for (ClassJson classJson in reflectJson.classes) {
      //TODO if (classJson.annotations.contains(AnnotationJson.serviceClass())) {
      //TODO check if serviceClasses have a empty constructor or a empty factory constructor or a factory function with name <serviceClassName>Factory that returns the correct type (if not throw exception)
      //TODO check if the service class has properties (if not show warning)
      List<Class> actionMethodInfos =
          ActionMethodInfoFactory.createCodes(classJson);
      //TODO check if the service class has action Methods (if not throw exception)
      Class serviceClassInfo =
          _createServiceClassInfoCode(classJson, actionMethodInfos);
      serviceClassInfos.add(serviceClassInfo);
      // }
    }
    //TODO throw exception if serviceClasses.isEmpty

    return serviceClassInfos;
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
  Class _createServiceClassInfoCode(
      ClassJson classJson, List<Class> actionMethodInfos) {
    return Class((b) => b
          ..name = classJson.type.codeName
          ..extend = refer('ServiceClassInfo',
              'package:reflect_framework/service_class_info.dart')
          ..methods.add(DisplayName.createMethod(classJson.type))
          ..fields.add(_createServiceObjectField(classJson.type))

        // ..methods.add(
        //     TitleImage.createMethod(applicationClassJson, pubSpecYaml.assets))
        // ..methods.add(pubSpecYaml.createStringGetterMethod('description'))
        // ..methods.add(pubSpecYaml.createStringGetterMethod('homePage'))
        // ..methods.add(pubSpecYaml.createStringGetterMethod('documentation'))
        // ..methods.add(pubSpecYaml.createAuthorsGetterMethod()));
        );
  }

  //TODO move to reflect_info_behavioural (see displayName)
  Field _createServiceObjectField(TypeJson type) {
    //TODO _createObjectUsingFactoryFunction?

    String code = _createObjectUsingEmptyConstructor(type);
    return Field((b) {
      return b
        ..name = 'serviceObject'
        ..modifier = FieldModifier.final$
        ..type = refer(type.name, 'package:${type.library}')
        ..assignment = Code(code);
    });
  }

  String _createObjectUsingEmptyConstructor(TypeJson type) {
    //Reference ref=refer(type.name,'package:${type.library}');
    return '';
  }
}

/// TODO move to reflect_info_action_method_info (because it needs to stay clear of reflect_info_action_method_info because of build runner can not stand GUI-Flutter libs)
class ActionMethodInfoFactory {
  static List<Class> createCodes(ClassJson classJson) {
    return [_createCode(classJson)];
  }

  static Class _createCode(ClassJson classJson) {
    return Class((b) => b
          ..name = 'Some Action Method' //TODO
          ..extend = refer('ActionMethodInfo',
              'package:reflect_framework/action_method_info.dart')
        //TODO ..methods.add(DisplayName.createMethod(classJson.type));
        // ..methods.add(
        //     TitleImage.createMethod(applicationClassJson, pubSpecYaml.assets))
        );
  }
}
