import 'package:collection/collection.dart';
import 'package:dart_code/dart_code.dart';
import 'package:logging/logging.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/application_info_builder.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';

class ActionMethodInfoClasses extends DelegatingList<ActionMethodInfoClass> {
  ActionMethodInfoClasses(ReflectJson reflectJson, ClassJson classJson)
      : super(_createActionMethodInfoClasses(reflectJson, classJson));

  static final Logger log = Logger('build.fallback');

  static List<ActionMethodInfoClass> _createActionMethodInfoClasses(
      ReflectJson reflectJson, ClassJson classJson) {
    List<ActionMethodInfoClass> actionMethodInfoClasses = [];
    for (ExecutableJson methodJson in classJson.methods) {
      try {
        var actionMethodInfoClass =
            ActionMethodInfoClass(reflectJson, classJson, methodJson);
        actionMethodInfoClasses.add(actionMethodInfoClass);
      } on Exception catch (exception, stackTrace) {
        // Method was not an action method
        log.log(Level.WARNING, exception, stackTrace);
      }
    }
    return actionMethodInfoClasses;
  }
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

  static const methodOwnerFieldName = 'methodOwner';

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

  //TODO move to methodJson
  static _hasReturnValue(ExecutableJson methodJson) =>
      methodJson.returnType != null;

  //TODO move to methodJson
  static bool _startWithParameter(ExecutableJson methodJson) =>
      methodJson.hasParameter && !methodJson.hasParameterFactory;

  static String _createClassName(
          ClassJson classJson, ExecutableJson methodJson) =>
      '${classJson.type.name!}${methodJson.name!.pascalCase}Info\$';

  static List<Type> _createImplementationTypes(ExecutableJson methodJson) => [
        if (_startWithParameter(methodJson))
          _createActionMethodType('StartWithParameter', methodJson: methodJson)
        else
          _createActionMethodType('StartWithoutParameter'),
        if (methodJson.hasParameter)
          _createActionMethodType('InvokeWithParameter', methodJson: methodJson)
        else
          _createActionMethodType('InvokeWithoutParameter'),
      ];

  static List<Method> _createMethods(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson) {
    return [
      Name.forActionMethod(classJson, methodJson).createGetterMethod(),
      Description.forActionMethod(classJson, methodJson).createGetterMethod(),
      Icon.forActionMethod(classJson, methodJson).createGetterMethod(),
      Visible.forActionMethod(classJson, methodJson).createGetterMethod(),
      Order.forActionMethod(classJson, methodJson).createGetterMethod(),
      _createStartMethod(reflectJson, classJson, methodJson),
      _createInvokeMethodAndProcessResultMethod(
          reflectJson, classJson, methodJson),
    ];
  }

  static ActionMethodResultProcessorFunction findResultProcessorFunction(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson) {
    var resultProcessor = reflectJson.functions.actionMethodResultProcessors
        .firstWhere((p) => p.canProcessMethod(methodJson),
            orElse: (() => throw ApplicationInfoBuilderException.forMethod(
                classJson,
                methodJson,
                'Could not find a result processor that can process the method result.')));
    return resultProcessor;
  }

  static ActionMethodParameterProcessorFunction?
      _findParameterProcessorFunction(ReflectJson reflectJson,
          ClassJson classJson, ExecutableJson methodJson) {
    if (!methodJson.hasParameter) return null;
    var parameterProcessor = reflectJson
        .functions.actionMethodParameterProcessors
        .firstWhere((p) => p.canProcessMethod(methodJson),
            orElse: (() => throw ApplicationInfoBuilderException.forMethod(
                classJson,
                methodJson,
                'Could not find a parameter processor that can process the method parameter.')));
    return parameterProcessor;
  }

  static Method _createStartMethod(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson) {
    Method method = Method(
        'start', _createStartMethodBody(reflectJson, classJson, methodJson),
        parameters: Parameters([
          Parameter.required(contextVariableName,
              type: _createBuildContextType()),
          if (_startWithParameter(methodJson))
            Parameter.required(parameterValueVariableName,
                type: Type('Object')),
        ]),
        type: Type('void'),
        annotations: [Annotation.override()]);
    return method;
  }

  static Statements _createStartMethodBody(
      ReflectJson reflectJson, ClassJson classJson, ExecutableJson methodJson) {
    //TODO add alarm catching with alarm dialog
    ActionMethodParameterProcessorFunction? parameterProcessorFunction =
        _findParameterProcessorFunction(reflectJson, classJson, methodJson);

    bool hasParameterFactory = methodJson.hasParameterFactory;
    Statements body = Statements([
      if (hasParameterFactory) _createParameterValue(classJson, methodJson),
      if (parameterProcessorFunction == null)
        _createInvokeInvokeMethodAndProcessResultMethod(methodJson),
      if (parameterProcessorFunction != null)
        _createInvokeParameterProcessorFunction(
            parameterProcessorFunction, methodJson),

      // Statement([
      //   Code('var tabs = '),
      //   Type('Provider', libraryUri: 'package:provider/provider.dart'),
      //   Code('.of<'),
      //   Type('Tabs', libraryUri: 'package:reflect_framework/gui/gui_tab.dart'),
      //   Code('>(context, listen: false)')
      // ]),
      // Statement([
      //   Code('var tab = '),
      //   Expression.callConstructor(_createTabFactoryType(methodJson.name)),
      //   Code('.create(this)')
      // ]),
      // Statement([Code('tabs.add(tab)')]),
    ]);
    return body;
  }

  static const String parameterValueVariableName = 'parameterValue';

  //TODO create parameterType from serviceObject actionMethodParameterFactoryMethod
  static _createParameterValue(ClassJson classJson, ExecutableJson methodJson) {
    Type? parameterType = _createParameterType(methodJson);
    return _creatingOfNewTypeExpression(classJson, methodJson)
        .defineVariable(parameterValueVariableName, type: parameterType);
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

  static const String contextVariableName = 'context';

  static Statement _createInvokeParameterProcessorFunction(
          ExecutableJson parameterProcessorFunction,
          ExecutableJson methodJson) =>
      Statement([
        Expression.callFunction(parameterProcessorFunction.name!,
            libraryUri: 'gui/default_action_method_parameter_processor.dart',
            parameterValues: ParameterValues([
              ParameterValue(Expression.ofVariable(contextVariableName)),
              ParameterValue(Expression.ofThis()),
              ParameterValue(Expression.ofVariable(parameterValueVariableName))
            ]))
      ]);

  static const invokeMethodAndProcessResultMethodName =
      'invokeMethodAndProcessResult';

  static Method _createInvokeMethodAndProcessResultMethod(
      //TODO add alarm catching with alarm dialog
      ReflectJson reflectJson,
      ClassJson classJson,
      ExecutableJson methodJson) {
    ActionMethodResultProcessorFunction resultProcessorFunction =
        findResultProcessorFunction(reflectJson, classJson, methodJson);
    List<Annotation> annotations = [Annotation.override()];
    Statements body = Statements([
      _createInvokeActionMethod(methodJson),
      _createInvokeResultProcessorFunction(resultProcessorFunction, methodJson)
    ]);
    Method method = Method(invokeMethodAndProcessResultMethodName, body,
        parameters: Parameters([
          Parameter.required(contextVariableName,
              type: _createBuildContextType()),
          if (methodJson.hasParameter)
            Parameter.required(parameterValueVariableName,
                type: _createParameterType(methodJson)!),
        ]),
        type: Type('void'),
        annotations: annotations);
    return method;
  }

  static Statement _createInvokeInvokeMethodAndProcessResultMethod(
      ExecutableJson methodJson) {
    ParameterValues parameterValues = ParameterValues([
      ParameterValue(Expression.ofVariable(contextVariableName)),
      if (methodJson.hasParameter)
        ParameterValue(Expression.ofVariable(parameterValueVariableName)),
    ]);
    return Statement([
      IdentifierStartingWithLowerCase(invokeMethodAndProcessResultMethodName),
      Code('('),
      parameterValues,
      Code(')'),
    ]);
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
          .defineVariable(returnValueVariableName, type: type);
    }
  }

  // TODO named parameters
  static ParameterValues? _createInvokeActionMethodParameterValues(
          ExecutableJson methodJson) =>
      methodJson.hasParameter
          ? ParameterValues([
              ParameterValue(Expression.ofVariable(parameterValueVariableName))
            ])
          : null;

  static Type? _createReturnType(ExecutableJson methodJson) =>
      _hasReturnValue(methodJson) ? methodJson.returnType!.toType() : null;

  static const returnValueVariableName = 'returnValue';

  static Statement _createInvokeResultProcessorFunction(
          ExecutableJson resultProcessorFunction, ExecutableJson methodJson) =>
      Statement([
        Expression.callFunction(resultProcessorFunction.name!,
            libraryUri: 'gui/default_action_method_result_processor.dart',
            parameterValues: ParameterValues([
              ParameterValue(Expression.ofVariable(contextVariableName)),
              ParameterValue(Expression.ofThis()),
              if (_hasReturnValue(methodJson))
                ParameterValue(Expression.ofVariable(returnValueVariableName))
            ]))
      ]);
}
