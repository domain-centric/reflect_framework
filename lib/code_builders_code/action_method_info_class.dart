import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/application_info_builder.dart';
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

  static List<Method> _createMethods(
      ClassJson classJson, ExecutableJson methodJson) {
    bool hasParameter = _hasParameter(methodJson);
    bool hasParameterFactory = _hasParameterFactory(methodJson);
    return [
      Name.forActionMethod(classJson, methodJson).createGetterMethod(),
      Description.forActionMethod(classJson, methodJson).createGetterMethod(),
      Icon.forActionMethod(classJson, methodJson).createGetterMethod(),
      Visible.forActionMethod(classJson, methodJson).createGetterMethod(),
      Order.forActionMethod(classJson, methodJson).createGetterMethod(),
      _createStartMethod(classJson, methodJson),
      if (hasParameterFactory)
        _createParameterFactoryMethod(classJson, methodJson),
      if (hasParameter) _createProcessParameterMethod(),
      _createInvokeMethodAndProcessResultMethod(methodJson),
    ];
  }

  static Method _createStartMethod(
      ClassJson classJson, ExecutableJson methodJson) {
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
        Code('.create(this)')
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
  static _createParameterFactoryMethod(
      ClassJson classJson, ExecutableJson methodJson) {
    Type parameterType = _createParameterType(methodJson);
    Expression body = _creatingOfNewTypeExpression(classJson, methodJson);
    return Method('_createParameter', body, type: parameterType);
  }

  static Expression _creatingOfNewTypeExpression(
      ClassJson classJson, ExecutableJson methodJson) {
    TypeJson parameterType = methodJson.parameterTypes.first;
    if (_isDartType(parameterType)) {
      return _creatingOfNewDartTypeExpression(
          classJson, methodJson, parameterType);
    } else {
      //TODO throw an error that there must be an empty constructor (in this type or one of its super types) when using the [ParameterFactory] annotation. Otherwise use a ...ParameterFactory method.
      //TODO unit tests
      var type = parameterType.toType();
      return Expression.callConstructor(type);
    }
  }

  //     TODO unit tests
  static Expression _creatingOfNewDartTypeExpression(
      ClassJson classJson, ExecutableJson methodJson, TypeJson parameterType) {
    String libraryUri = parameterType.library;
    if (libraryUri.endsWith('/string.dart')) {
      return Expression.ofString('');
    } else if (libraryUri.endsWith('/bool.dart')) {
      return Expression.ofBool(true);
    } else if (libraryUri.endsWith('/int.dart')) {
      return Expression.ofInt(0);
    } else if (libraryUri.endsWith('/double.dart')) {
      return Expression.ofDouble(0);
    } else if (libraryUri.endsWith('/date_time.dart')) {
      return Expression([Type.ofDateTime(), Code('.now()')]);
    } else if (libraryUri.endsWith('/list.dart')) {
      return Expression.ofList([]); //TODO also test generics
    } else if (libraryUri.endsWith('/set.dart')) {
      return Expression.ofSet({}); //TODO also test generics
    } else if (libraryUri.endsWith('/map.dart')) {
      return Expression.ofMap({}); //TODO also test generics
    }

    throw ApplicationInfoBuilderException.forMethod(classJson, methodJson,
        'Could not create a parameterFactory method for Dart type: ${parameterType.name}. Replace the ParameterFactory annotation with method: ${parameterType.name} ${methodJson.name}ParameterFactory()');
  }

  static bool _isDartType(TypeJson parameterType) =>
      parameterType.library != null &&
      parameterType.library.startsWith("dart:");

  static Type _createParameterType(ExecutableJson methodJson) =>
      methodJson.parameterTypes.first.toType();

  static Type _createBuildContextType() =>
      Type('BuildContext', libraryUrl: 'package:flutter/widgets.dart');

  static Method _createProcessParameterMethod() {
    CodeNode body = Comment.fromString('TODO: IMPLEMENT'); //TODO
    Method method = Method(
      '_processParameter',
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
