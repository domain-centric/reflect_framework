import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/application_info_builder.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';

class ActionMethodInfoClasses extends DelegatingList<ActionMethodInfoClass> {
  ActionMethodInfoClasses(ReflectJson reflectJson, ClassJson classJson)
      : super(_createActionMethodInfoClasses(reflectJson, classJson));

  static List<ActionMethodInfoClass> _createActionMethodInfoClasses(
          ReflectJson reflectJson, ClassJson classJson) =>
      classJson.methods
          .map((methodJson) =>
              ActionMethodInfoClass(reflectJson, classJson, methodJson))
          .toList();
}

class ActionMethodInfoClass extends Class {
  static Type _createActionMethodType(String name,
          {ExecutableJson? methodJson}) =>
      Type(name,
          libraryUri: 'package:reflect_framework/core/action_method_info.dart',
          generics: [
            if (methodJson != null) _createParameterType(methodJson)!
          ]);

  ActionMethodInfoClass(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson)
      : super(_createClassName(classJson, methodJson),
            implements: _createImplementationTypes(methodJson),
            fields: _createFields(classJson),
            constructors: _createConstructors(classJson, methodJson),
            methods: _createMethods(reflectJson, classJson, methodJson));

  static List<Field> _createFields(ClassJson classJson) =>
      [_createMethodOwnerField(classJson)];

  static final methodOwnerFieldName = 'methodOwner';

  /// e.g. creates:
  ///     final PersonService methodOwner;
  static Field _createMethodOwnerField(ClassJson classJson) {
    List<Annotation> annotations = [Annotation.override()];
    return Field(methodOwnerFieldName,
        annotations: annotations,
        type: classJson.type.toType(),
        modifier: Modifier.final$);
  }

  static List<Constructor> _createConstructors(
          ClassJson classJson, ExecutableJson methodJson) =>
      [
        Constructor(Type(_createClassName(classJson, methodJson)),
            parameters: ConstructorParameters([
              ConstructorParameter.required(methodOwnerFieldName, this$: true)
            ]))
      ];

  static bool _hasParameter(ExecutableJson methodJson) =>
      methodJson.parameterTypes.isNotEmpty;

  static _hasReturnValue(ExecutableJson methodJson) =>
      methodJson.returnType != null;

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
      classJson.type.name! + methodJson.name!.pascalCase + 'Info\$';

  static List<Type> _createImplementationTypes(ExecutableJson methodJson) => [
        if (_startWithParameter(methodJson))
          _createActionMethodType('StartWithParameter', methodJson: methodJson)
        else
          _createActionMethodType('StartWithoutParameter'),
        if (_hasParameter(methodJson))
          _createActionMethodType('InvokeWithParameter', methodJson: methodJson)
        else
          _createActionMethodType('InvokeWithoutParameter'),
      ];

  static List<Method> _createMethods(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson) {
    bool hasParameter = _hasParameter(methodJson);
    bool hasParameterFactory = _hasParameterFactory(methodJson);
    var resultProcessor = reflectJson.functions.actionMethodResultProcessors
        .firstWhere((p) => p.canProcessMethod(methodJson),
            orElse: (() => throw ApplicationInfoBuilderException.forMethod(
                classJson,
                methodJson,
                'Could not find a result processor that can process the method result.')));
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
      _createInvokeMethodAndProcessResultMethod(resultProcessor, methodJson),
    ];
  }

  static Method _createStartMethod(
      ClassJson classJson, ExecutableJson methodJson) {
    //TODO add alarm catching with alarm dialog
    Statements body = Statements([
      Statement([
        Code('var tabs = '),
        Type('Provider', libraryUri: 'package:provider/provider.dart'),
        Code('.of<'),
        Type('Tabs', libraryUri: 'package:reflect_framework/gui/gui_tab.dart'),
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

  static Type _createTabFactoryType(String? name) {
    switch (name) {
      case 'addNew':
        return Type('FormExampleTabFactory',
            libraryUri: 'package:reflect_framework/gui/gui_tab_form.dart');
      case 'allPersons':
      case 'findPersons':
        return Type('TableExampleTabFactory',
            libraryUri: 'package:reflect_framework/gui/gui_tab_table.dart');
      default:
        {
          return Type('ExampleTabFactory',
              libraryUri: 'package:reflect_framework/gui/gui_tab.dart');
        }
    }
  }

  //TODO create parameterType from serviceObject actionMethodParameterFactoryMethod
  static _createParameterFactoryMethod(
      ClassJson classJson, ExecutableJson methodJson) {
    Type? parameterType = _createParameterType(methodJson);
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
    String libraryUri = parameterType.library!;
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
      parameterType.library!.startsWith("dart:");

  static Type? _createParameterType(ExecutableJson methodJson) =>
      methodJson.parameterTypes.length == 1
          ? methodJson.parameterTypes.first.toType()
          : null;

  static Type _createBuildContextType() =>
      Type('BuildContext', libraryUri: 'package:flutter/widgets.dart');

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
      //TODO add alarm catching with alarm dialog
      ExecutableJson resultProcessorFunction,
      ExecutableJson methodJson) {
    List<Annotation> annotations = [Annotation.override()];
    Statements body = Statements([
      _createInvokeActionMethod(methodJson),
      _createInvokeResultProcessorFunction(resultProcessorFunction, methodJson)
    ]);
    Method method = Method('invokeMethodAndProcessResult', body,
        parameters: Parameters([
          Parameter.required('context', type: _createBuildContextType()),
          if (_hasParameter(methodJson))
            Parameter.required('parameterValue',
                type: _createParameterType(methodJson)!),
        ]),
        type: Type('void'),
        annotations: annotations);
    return method;
  }

  static Statement _createInvokeActionMethod(ExecutableJson methodJson) {
    var parameterValues = _createInvokeActionMethodParameterValues(methodJson);

    if (methodJson.returnType == null) {
      return Statement([
        Expression.ofVariable(methodOwnerFieldName)
            .callMethod(methodJson.name!, parameterValues: parameterValues)
      ]);
    } else {
      var type = _createReturnType(methodJson);
      return Expression.ofVariable(methodOwnerFieldName)
          .callMethod(methodJson.name!, parameterValues: parameterValues)
          .defineVariable('returnValue', type: type);
    }
  }

  // TODO named parameters
  static ParameterValues? _createInvokeActionMethodParameterValues(
          ExecutableJson methodJson) =>
      _hasParameter(methodJson)
          ? ParameterValues(
              [ParameterValue(Expression.ofVariable('parameterValue'))])
          : null;

  static Type? _createReturnType(ExecutableJson methodJson) =>
      _hasReturnValue(methodJson) ? methodJson.returnType!.toType() : null;

  static Statement _createInvokeResultProcessorFunction(
          ExecutableJson resultProcessorFunction, ExecutableJson methodJson) =>
      Statement([
        Expression.callFunction(resultProcessorFunction.name!,
            libraryUri: 'gui/action_method_result_processor_impl.dart',
            parameterValues: ParameterValues([
              ParameterValue(Expression.ofVariable('context')),
              ParameterValue(Expression.ofThis()),
              if (_hasReturnValue(methodJson))
                ParameterValue(Expression.ofVariable('returnValue'))
            ]))
      ]);
}
