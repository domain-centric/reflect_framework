import 'package:dart_code/dart_code.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';

class ActionMethodInfoCode extends Class {
  ActionMethodInfoCode(ClassJson classJson, ExecutableJson methodJson)
      : super(_createClassName(classJson, methodJson),
            implements: _createImplements(),
            methods: _createMethods(classJson, methodJson));

  static String _createClassName(
          ClassJson classJson, ExecutableJson methodJson) =>
      classJson.type.name + methodJson.name.pascalCase + 'Info\$';

  static List<Type> _createImplements() =>
      [Type('ActionMethodInfo', libraryUrl: 'core/action_method_info.dart')];

  static List<Method> _createMethods(
          ClassJson classJson, ExecutableJson methodJson) =>
      [
        Description.forActionMethod(classJson, methodJson).createGetterMethod(),
        //TODO Order.forActionMethod(methodJson).createGetterMethod()
        //TODO Icon.forActionMethod(methodJson).createGetterMethod()
        //TODO Visible.forActionMethod(methodJson).createGetterMethod()
        //TODO factory method that creates a serviceobject or returns a chashed serviceobject
        //TODO createActionMethodInfosGetterMethod(methodJson)
      ];
}
