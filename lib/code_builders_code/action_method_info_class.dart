import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';

class ActionMethodInfoClasses extends DelegatingList<ActionMethodInfoClass> {
  ActionMethodInfoClasses(ClassJson classJson)
      : super(_createActionMethodInfoClasses(classJson));

  static List<ActionMethodInfoClass> _createActionMethodInfoClasses(
          ClassJson classJson) =>
      classJson.methods
          .map((methodJson) => ActionMethodInfoClass(classJson, methodJson))
          .toList();
}

class ActionMethodInfoClass extends Class {
  static Type _createActionMethodType(String name) => Type(name,
      libraryUrl: 'package:reflect_framework/core/action_method_info.dart');

  ActionMethodInfoClass(ClassJson classJson, ExecutableJson methodJson)
      : super(_createClassName(classJson, methodJson),
            implements: _createImplementationTypes(methodJson),
            methods: _createMethods(classJson, methodJson));

  static bool _hasParameter(ExecutableJson methodJson) =>
      methodJson.parameterTypes.isNotEmpty;

  static final parameterFactoryAnnotation = TypeJson(
      'ActionMethodParameterFactory',
      '/reflect_framework/lib/core/annotations.dart');

  static bool _hasParameterFactory(ExecutableJson methodJson) =>
      methodJson.annotations.any((a) =>
          a.type.name ==
          'ActionMethodParameterFactory'); //TODO.contains(parameterFactoryAnnotation);

  static bool _startWithParameter(ExecutableJson methodJson) =>
      _hasParameter(methodJson) && !_hasParameterFactory(methodJson);

  static String _createClassName(
          ClassJson classJson, ExecutableJson methodJson) =>
      classJson.type.name + methodJson.name.pascalCase + 'Info\$';

  static List<Type> _createImplementationTypes(ExecutableJson methodJson) => [
        if (_startWithParameter(methodJson))
          _createActionMethodType('StartWithParameter')
        else
          _createActionMethodType('StartWithoutParameter'),
        if (_hasParameter(methodJson))
          _createActionMethodType('InvokeWithParameter')
        else
          _createActionMethodType('InvokeWithoutParameter'),
      ];

  static _hasReturnValue(ExecutableJson methodJson) =>
      methodJson.returnType != null;

  static List<Method> _createMethods(
      ClassJson classJson, ExecutableJson methodJson) {
    bool hasParameter = _hasParameter(methodJson);
    bool hasParameterFactory = _hasParameterFactory(methodJson);
    bool hasStartParameter = !hasParameter || hasParameterFactory;
    bool hasReturnValue = _hasReturnValue(methodJson);
    return [
      Name.forActionMethod(classJson, methodJson).createGetterMethod(),
      Description.forActionMethod(classJson, methodJson).createGetterMethod(),
      Icon.forActionMethod(classJson, methodJson).createGetterMethod(),
      Visible.forActionMethod(classJson, methodJson).createGetterMethod(),
      Order.forActionMethod(classJson, methodJson).createGetterMethod(),
      _createStartMethod(classJson, methodJson),
      if (hasParameterFactory) _createParameterFactoryMethod(methodJson),
      if (hasParameter) _createProcessParameterMethod(),
      _createInvokeMethodAndProcessResultMethod(methodJson),
    ];
  }

  static Method _createStartMethod(ClassJson classJson, ExecutableJson methodJson) {
    Statements body = Statements([
      Statement([
        Code('var tabs = '),
        Type('Provider', libraryUrl: 'package:provider/provider.dart'),
        Code('.of<'),
        Type('Tabs', libraryUrl: 'package:reflect_framework/gui/gui_tab.dart'),
        Code('>(context, listen: false)')
      ]),
      Statement([
        Code('var tab = '),
        Expression.callConstructor(_createTabFactoryType(methodJson.name)),
        Code('.create()')
      ]),
      Statement([Code('tabs.add(tab)')]),
    ]);
    List<Annotation> annotations = [Annotation.override()];
    Method method = Method('start', body,
        parameters: Parameters([
          Parameter.required('context', type: _createBuildContextType()),
          if (_startWithParameter(methodJson))
            Parameter.required('parameterValue', type: Type('Object')),
        ]),
        type: Type('void'),
        annotations: annotations);
    return method;
  }

  static Type _createTabFactoryType(String name) {
    switch (name) {
      case 'addNew':
        return Type('FormExampleTabFactory',
            libraryUrl: 'package:reflect_framework/gui/gui_tab_form.dart');
        break;
      case 'allPersons':
      case 'findPersons':
        return Type('TableExampleTabFactory',
            libraryUrl: 'package:reflect_framework/gui/gui_tab_table.dart');
        break;
      default:
        {
          return Type('ExampleTabFactory',
              libraryUrl: 'package:reflect_framework/gui/gui_tab.dart');
        }
    }
  }

  //TODO create parameterType from serviceObject actionMethodParameterFactoryMethod
  static _createParameterFactoryMethod(ExecutableJson methodJson) {
    Type parameterType = _createParameterType(methodJson);
    Expression body = Expression.callConstructor(parameterType);
    return Method('_createParameter', body, type: parameterType);
  }

  static Type _createParameterType(ExecutableJson methodJson) =>
      methodJson.parameterTypes.first.toType();

  static Type _createBuildContextType() =>
      Type('BuildContext', libraryUrl: 'package:flutter/widgets.dart');

  static Method _createProcessParameterMethod() {
    CodeNode body = Comment.fromString('TODO: IMPLEMENT'); //TODO
    Method method = Method(
      'processParameter',
      body,
      parameters: Parameters([
        Parameter.required('context', type: _createBuildContextType()),
        Parameter.required('parameterValue', type: Type('Object')),
      ]),
      type: Type('void'),
    );
    return method;
  }

  static Method _createInvokeMethodAndProcessResultMethod(
      ExecutableJson methodJson) {
    List<Annotation> annotations = [Annotation.override()];
    CodeNode body = Comment.fromString('TODO: IMPLEMENT'); //TODO
    Method method = Method('invokeMethodAndProcessResult', body,
        parameters: Parameters([
          Parameter.required('context', type: _createBuildContextType()),
          if (_hasParameter(methodJson))
            Parameter.required('parameterValue', type: Type('Object')),
        ]),
        type: Type('void'),
        annotations: annotations);
    return method;
  }
}
