import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_code/dart_code.dart';
import 'package:quiver/core.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

// We cant use ActionMethodPreProcessorContext type to convert it to a string,
// because it contains BuildContext and thus imports from a UI package, which does not go well with build_runner.
// Maybe this is because build_runner can use code reflection and Flutter does not allow this???
const buildContextName = 'BuildContext';

// We cant use ActionMethodPreProcessor type to convert it to a string,
// because its library uses a required annotation and thus imports from a UI package, which does not go will with build_runner.
// Maybe this is because build_runner can use code reflection and Flutter does not allow this???
const parameterProcessorAnnotation = '@ActionMethodParameterProcessor';
const translationAnnotation = 'Translation';

/// Used by the [ReflectInfoJsonBuilder] to create intermediate json files to generate meta code later by another builder (TODO link to builder).
/// The meta data comes from source files using the [LibraryElement] class from the source_gen package
class ReflectJson {
  static const functionsAttribute = 'functions';
  static const classesAttribute = 'classes';
  static const voidName = 'void';

  final FunctionsJson functions;
  final List<ClassJson> classes;

  //TODO functions (ending with factory in name, when needed for service objects and as a replacement for ActionMethodPreProcessorInfo and ActionMethodProcessorInfo)
  //TODO add enums (with texts)
  //TODO add TranslatableTextAnnotations

  ReflectJson.fromLibrary(LibraryReader library)
      : functions = FunctionsJson.fromLibrary(library),
        classes = _createClasses(library);

  ReflectJson.empty()
      : functions = FunctionsJson.empty(),
        classes = [];

  ReflectJson.fromGeneratedReflectInfoCombinedFile()
      : this.fromJson(readJsonFromGeneratedReflectInfoCombinedFile()!);

  static const generatedReflectInfoCombinedFilePath =
      ".dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json";

  static Map<String, dynamic>? readJsonFromGeneratedReflectInfoCombinedFile() {
    String jsonString = File(generatedReflectInfoCombinedFilePath) //
        .readAsStringSync();
    var json = jsonDecode(jsonString);
    return json;
  }

  ReflectJson.fromJson(Map<String, dynamic> json)
      : classes = json[classesAttribute] == null
            ? []
            : List<ClassJson>.from(json[classesAttribute]
                .map((model) => ClassJson.fromJson(model))),
        functions = json[functionsAttribute] == null
            ? FunctionsJson.empty()
            : FunctionsJson.fromJson(json[functionsAttribute]);

  static const libraryExtension = '.reflect_info.json';
  static const combinedExtension = '.combined.json';
  static const combinedFileName = 'reflect_info$combinedExtension';
  static const combinedFilePath = 'lib/$combinedFileName';

  Map<String, dynamic> toJson() => {
        if (functions.actionMethodResultProcessors.isNotEmpty ||
            functions.actionMethodParameterProcessors.isNotEmpty)
          functionsAttribute: functions,
        if (classes.isNotEmpty) classesAttribute: classes,
      };

  static List<ClassJson> _createClasses(LibraryReader library) {
    List<ClassJson> classes = [];
    for (ClassElement classElement in library.classes) {
      if (_isNeededClass(classElement)) {
        classes.add(ClassJson.fromElement(classElement));
      } else if (_classContainsTranslationAnnotations(classElement)) {
        classes.add(
            ClassJson.fromElementWithTranslationAnnotationsOnly(classElement));
      }
    }
    return classes;
  }

  static bool _isNeededClass(ClassElement element) {
    return element.isPublic &&
        (!element.source.fullName.contains('lib/reflect_'));
  }

  // static List<ExecutableJson> _createFunctions(LibraryReader library) {
  //   List<ExecutableJson> functions = [];
  //   for (Element element in library.allElements) {
  //     if (_isPublicFunction(element)) {
  //       if (ActionMethodParameterProcessorFunction.isValid(element)) {
  //         functions.add(ActionMethodParameterProcessorFunction.fromElement(
  //             element as ExecutableElement));
  //       } else if (ActionMethodResultProcessorFunction.isValid(element)) {
  //         functions.add(ActionMethodResultProcessorFunction.fromElement(
  //             element as ExecutableElement));
  //       } else if (_isPotentialServiceObjectFactoryFunction(
  //           element as FunctionElement)) {
  //         functions.add(ExecutableJson.fromElement(element));
  //       } else if (_containsTranslationAnnotations(element)) {
  //         functions.add(
  //             ExecutableJson.fromElementWithTranslationAnnotationsOnly(
  //                 element));
  //       }
  //     }
  //   }
  //   return functions;
  // }

  // static bool _isPublicFunction(Element element) {
  //   return element is FunctionElement && element.isPublic;
  // }

  // static _isPotentialServiceObjectFactoryFunction(FunctionElement element) {
  //   const factory = 'Factory';
  //   return element.name.endsWith(factory) &&
  //       element.name.length > factory.length &&
  //       element.returnType.element!.name != voidName;
  // }

  static bool _classContainsTranslationAnnotations(ClassElement classElement) {
    return _containsTranslationAnnotations(classElement) ||
        classElement.accessors
            .any((element) => _containsTranslationAnnotations(element)) ||
        classElement.methods
            .any((element) => _containsTranslationAnnotations(element));
  }

  void add(String jsonString) {
    var json = jsonDecode(jsonString);
    ReflectJson reflectInfo = ReflectJson.fromJson(json);
    functions.addAll(reflectInfo.functions);
    classes.addAll(reflectInfo.classes);
  }
}

class ClassJson {
  static const typeAttribute = 'type';
  static const extendingAttribute = 'extending';
  static const mixinsAttribute = 'mixins';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final TypeJson type;
  final TypeJson? extending;
  final List<TypeJson> mixins;
  final List<AnnotationJson> annotations;
  final List<ExecutableJson> methods;
  final List<PropertyJson> properties;

  ClassJson.fromElement(ClassElement element)
      : type = TypeJson.fromElement(element),
        extending = _createExtending(element),
        mixins = _createMixins(element),
        annotations = _createAnnotations(element),
        methods = _createMethods(element),
        properties = _createProperties(element);

  ClassJson.fromElementWithTranslationAnnotationsOnly(ClassElement element)
      : type = TypeJson.fromElement(element),
        extending = null,
        mixins = [],
        annotations =
            _createAnnotations(element, forTranslationAnnotationsOnly: true),
        methods = _createMethodsWithTranslationAnnotationsOnly(element),
        properties = _createPropertiesWithTranslationAnnotationsOnly(element);

  ClassJson.fromJson(Map<String, dynamic> json)
      : type = TypeJson.fromJson(json[typeAttribute]),
        extending = json[extendingAttribute] == null
            ? null
            : TypeJson.fromJson(json[extendingAttribute]),
        mixins = json[mixinsAttribute] == null
            ? []
            : List<TypeJson>.from(
                json[mixinsAttribute].map((model) => TypeJson.fromJson(model))),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationJson>.from(json[annotationsAttribute]
                .map((model) => AnnotationJson.fromJson(model))),
        methods = json[methodsAttribute] == null
            ? []
            : List<ExecutableJson>.from(json[methodsAttribute]
                .map((model) => ExecutableJson.fromJson(model))),
        properties = json[propertiesAttribute] == null
            ? []
            : List<PropertyJson>.from(json[propertiesAttribute]
                .map((model) => PropertyJson.fromJson(model)));

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
        if (extending != null) extendingAttribute: extending,
        if (mixins.isNotEmpty) mixinsAttribute: mixins,
        if (annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods.isNotEmpty) methodsAttribute: methods,
        if (properties.isNotEmpty) propertiesAttribute: properties
      };

  static TypeJson? _createExtending(ClassElement element) =>
      (element.supertype!.element.name == 'Object')
          ? null
          : TypeJson.fromElement(element.supertype!.element);

  static List<ExecutableJson> _createMethods(ClassElement classElement) {
    return classElement.methods
        .where((e) => _isNeededMethod(e))
        .map((e) => ExecutableJson.fromElement(e))
        .toList();
  }

  static List<ExecutableJson> _createMethodsWithTranslationAnnotationsOnly(
      ClassElement classElement) {
    return classElement.methods
        .where((e) => _containsTranslationAnnotations(e))
        .map((e) => ExecutableJson.fromElementWithTranslationAnnotationsOnly(e))
        .toList();
  }

  static bool _isNeededMethod(ExecutableElement executableElement) {
    return executableElement.isPublic &&
        executableElement.parameters.length <= 1;
  }

  static List<PropertyJson> _createProperties(ClassElement classElement) {
    List<PropertyJson> properties = [];
    var publicAccessors =
        classElement.accessors.where((element) => element.isPublic);
    var getterAccessorElements =
        publicAccessors.where((element) => element.isGetter);
    var setterAccessorElements =
        publicAccessors.where((element) => element.isSetter);
    var fieldElements =
        classElement.fields.where((element) => element.isPublic);

    for (PropertyAccessorElement getterAccessorElement
        in getterAccessorElements) {
      bool hasSetter = setterAccessorElements
          .any((element) => element.name == '${getterAccessorElement.name}=');
      FieldElement fieldElement = fieldElements
          .firstWhere((element) => element.name == getterAccessorElement.name);

      PropertyJson property = PropertyJson.fromElements(
          getterAccessorElement, hasSetter, fieldElement);
      properties.add(property);
    }
    return properties;
  }

  static List<PropertyJson> _createPropertiesWithTranslationAnnotationsOnly(
      ClassElement classElement) {
    List<PropertyJson> properties = [];
    var publicAccessors =
        classElement.accessors.where((element) => element.isPublic);
    var getterAccessorElements =
        publicAccessors.where((element) => element.isGetter);
    var setterAccessorElements =
        publicAccessors.where((element) => element.isSetter);
    var fieldElements =
        classElement.fields.where((element) => element.isPublic);

    for (PropertyAccessorElement getterAccessorElement
        in getterAccessorElements) {
      bool hasSetter = setterAccessorElements
          .any((element) => element.name == '${getterAccessorElement.name}=');
      FieldElement fieldElement = fieldElements
          .firstWhere((element) => element.name == getterAccessorElement.name);

      if (_containsTranslationAnnotations(getterAccessorElement) ||
          _containsTranslationAnnotations(fieldElement)) {
        PropertyJson property =
            PropertyJson.fromElementsWithTranslateAnnotationOnly(
                getterAccessorElement, hasSetter, fieldElement);
        properties.add(property);
      }
    }
    return properties;
  }

  static List<TypeJson> _createMixins(ClassElement element) {
    return List<TypeJson>.from(
        element.mixins.map((i) => TypeJson.fromElement(i.element)));
  }
}

/// The meta data of different types of functions from source files using the [LibraryElement] class from the source_gen package
class FunctionsJson {
  static const actionMethodParameterProcessorsAttribute =
      'actionMethodParameterProcessors';
  static const actionMethodResultProcessorsAttribute =
      'actionMethodResultProcessors';
  final List<ActionMethodParameterProcessorFunction>
      actionMethodParameterProcessors;
  final List<ActionMethodResultProcessorFunction> actionMethodResultProcessors;

  FunctionsJson.fromLibrary(LibraryReader library)
      : actionMethodParameterProcessors =
            _createActionMethodParameterProcessors(library)
                as List<ActionMethodParameterProcessorFunction>,
        actionMethodResultProcessors =
            _createActionMethodResultProcessors(library)
                as List<ActionMethodResultProcessorFunction>;

  FunctionsJson.fromJson(Map<String, dynamic> json)
      : actionMethodParameterProcessors = json[
                    actionMethodParameterProcessorsAttribute] ==
                null
            ? []
            : List<ActionMethodParameterProcessorFunction>.from(
                json[actionMethodParameterProcessorsAttribute].map((model) =>
                    ActionMethodParameterProcessorFunction.fromJson(model))),
        actionMethodResultProcessors =
            json[actionMethodResultProcessorsAttribute] == null
                ? []
                : List<ActionMethodResultProcessorFunction>.from(
                    json[actionMethodResultProcessorsAttribute].map((model) =>
                        ActionMethodResultProcessorFunction.fromJson(model)));

  FunctionsJson.empty()
      : actionMethodParameterProcessors = [],
        actionMethodResultProcessors = [];

  Map<String, dynamic> toJson() => {
        if (actionMethodParameterProcessors.isNotEmpty)
          actionMethodParameterProcessorsAttribute:
              actionMethodParameterProcessors,
        if (actionMethodResultProcessors.isNotEmpty)
          actionMethodResultProcessorsAttribute: actionMethodResultProcessors,
      };

  static List<ExecutableJson> _createActionMethodParameterProcessors(
      LibraryReader library) {
    return library.allElements
        .where((element) =>
            ActionMethodParameterProcessorFunction.isValid(element))
        .map((e) => ActionMethodParameterProcessorFunction.fromElement(
            e as ExecutableElement))
        .toList();
  }

  static List<ExecutableJson> _createActionMethodResultProcessors(
      LibraryReader library) {
    return library.allElements
        .where(
            (element) => ActionMethodResultProcessorFunction.isValid(element))
        .map((e) => ActionMethodResultProcessorFunction.fromElement(
            e as ExecutableElement))
        .toList();
  }

  // static _isPotentialServiceObjectFactoryFunction(FunctionElement element) {
  //   const factory = 'Factory';
  //   return element.name.endsWith(factory) &&
  //       element.name.length > factory.length &&
  //       element.returnType.element!.name != 'void';
  // }
  //
  // static bool _classContainsTranslationAnnotations(ClassElement classElement) {
  //   return _containsTranslationAnnotations(classElement) ||
  //       classElement.accessors
  //           .any((element) => _containsTranslationAnnotations(element)) ||
  //       classElement.methods
  //           .any((element) => _containsTranslationAnnotations(element));
  // }

  void addAll(FunctionsJson functionsJson) {
    actionMethodParameterProcessors
        .addAll(functionsJson.actionMethodParameterProcessors);
    // actionMethodParameterProcessors.sort((a, b) => a.index.compareTo(b.index));
    actionMethodResultProcessors
        .addAll(functionsJson.actionMethodResultProcessors);
    // actionMethodResultProcessors.sort((a, b) => a.index.compareTo(b.index));
  }
}

class TypeJson {
  static const libraryAttribute = 'library';
  static const nameAttribute = 'name';
  static const genericTypesAttribute = 'genericTypes';

  final String? library;
  final String? name;
  final List<TypeJson>? genericTypes;

  TypeJson(this.name, this.library, [this.genericTypes]);

  TypeJson.fromElement(Element element)
      : library = element.source == null ? null : element.source!.fullName,
        name = element.name,
        genericTypes = const [];

  TypeJson.fromDartType(DartType dartType)
      : library = (dartType.element == null || dartType.element!.source == null)
            ? null
            : dartType.element!.source!.fullName,
        name = dartType.toString() == 'void' ? 'void' : dartType.element!.name,
        genericTypes = _createGenericTypes(dartType);

  TypeJson.fromJson(Map<String, dynamic> json)
      : library = json[libraryAttribute],
        name = json[nameAttribute],
        genericTypes = json[genericTypesAttribute] == null
            ? null
            : List<TypeJson>.from(json[genericTypesAttribute]
                .map((model) => TypeJson.fromJson(model)));

  TypeJson.buildContext()
      : library = '/flutter/src/widgets/framework.dart',
        name = 'BuildContext',
        genericTypes = null;

  TypeJson.actionMethodInfo()
      : library = '/framework/lib/core/action_method_info.dart',
        name = 'ActionMethodInfo',
        genericTypes = null;

  TypeJson.actionMethodInvokeWithParameter()
      : library = '/framework/lib/core/action_method_info.dart',
        name = 'InvokeWithParameter',
        genericTypes = null;

  static const annotationLibrary =
      '/reflect_framework/lib/core/annotations.dart';

  TypeJson.serviceClassAnnotation()
      : library = annotationLibrary,
        name = 'ServiceClass',
        genericTypes = null;

  TypeJson.actionMethodParameterProcessorAnnotation()
      : library = annotationLibrary,
        name = 'ActionMethodParameterProcessor',
        genericTypes = null;

  TypeJson.actionMethodResultProcessorAnnotation()
      : library = annotationLibrary,
        name = 'ActionMethodResultProcessor',
        genericTypes = null;

  TypeJson.parameterFactoryAnnotation()
      : library = annotationLibrary,
        name = 'ActionMethodParameterFactory',
        genericTypes = null;

  TypeJson.executionModeDirectlyAnnotation()
      : library = annotationLibrary,
        name = 'ExecutionMode.directly',
        genericTypes = null;

  ///returns library name with name as a upper camel case name that could be used as a code name
  String get codeName => ReCase(_createLibraryFileName()).pascalCase + name!;

  String _createLibraryFileName() => library!
      .replaceAll(RegExp('^.*/'), '')
      .replaceAll(RegExp(r'\.dart\$'), '');

  Map<String, dynamic> toJson() => {
        if (library != null) libraryAttribute: library,
        nameAttribute: name,
        if (genericTypes != null && genericTypes!.isNotEmpty)
          genericTypesAttribute: genericTypes
      };

  static List<TypeJson> _createGenericTypes(DartType dartType) {
    if (dartType is ParameterizedType) {
      List<TypeJson> genericTypes = [];
      for (DartType genericDartType in dartType.typeArguments) {
        TypeJson genericTypeInfo = TypeJson.fromDartType(genericDartType);
        genericTypes.add(genericTypeInfo);
      }
      return genericTypes;
    } else {
      return const [];
    }
  }

  Type toType() {
    List<Type> genericTypes = this.genericTypes == null
        ? const []
        : this.genericTypes!.map((t) => t.toType()).toList();
    String? libraryUri = _createLibraryUri();
    return Type(name!, libraryUri: libraryUri, generics: genericTypes);
  }

  String? _createLibraryUri() {
    if (library == null) {
      return null;
    } else {
      String libraryUrl = library!
          .replaceFirst(RegExp('/lib/'), '/')
          .replaceFirst('/', 'package:');
      if (libraryUrl.startsWith("dart:corepackage:")) {
        return null;
      }
      return libraryUrl;
    }
  }

  bool processorCompatibleType(TypeJson? otherType) {
    if (otherType == null) return false;
    if (this == otherType) return true;
    if (name == 'Object') return true;
    if (library != otherType.library) return false;
    if (name != otherType.name) return false;
    //TODO test on type.generics with recursive call
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is TypeJson &&
      other.library == library &&
      other.name == name &&
      other.genericTypes == genericTypes;

  @override
  int get hashCode => hash3(library, name, genericTypes);
}

class AnnotationJson {
  static const typeAttribute = 'type';
  static const valuesAttribute = 'values';

  final TypeJson type;
  final Map<String, Object?>? values;

  AnnotationJson.fromElement(ElementAnnotation annotationElement)
      : type = TypeJson.fromDartType(
            annotationElement.computeConstantValue()!.type!),
        values = _values(annotationElement);

  AnnotationJson.fromJson(Map<String, dynamic> json)
      : type = TypeJson.fromJson(json[typeAttribute]),
        values = json[valuesAttribute];

  AnnotationJson.serviceClass()
      : type = TypeJson.serviceClassAnnotation(),
        values = null;

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
    if (values != null && values!.isNotEmpty) valuesAttribute: values
      };

  static Map<String, Object?> _values(ElementAnnotation annotationElement) {
    var dartObject = annotationElement.computeConstantValue();
    ConstantReader reader = ConstantReader(dartObject);
    Map<String, Object?> values = {};
    for (String name in _valueNames(annotationElement)) {
      try {
        Object? value = reader.peek(name)!.literalValue;
        values.putIfAbsent(name, () => value);
      } catch (e) {
        // We will skip the value, if we cant get it (value is likely null)
      }
    }
    return values;
  }

  static List<String> _valueNames(ElementAnnotation annotationElement) {
    try {
      return (annotationElement.element as ConstructorElement)
          .parameters
          .map((p) => p.name)
          .toList();
    } catch (e) {
      return const [];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AnnotationJson && other.type == type && other.values == values;

  @override
  int get hashCode => hash2(type, values);
}

bool _containsTranslationAnnotations(Element element) {
  return element.metadata.toString().contains(translationAnnotation);
}

List<AnnotationJson> _createAnnotations(Element element,
    {bool forTranslationAnnotationsOnly = false}) {
  List<AnnotationJson> annotations = [];
  List<ElementAnnotation> annotationElements = element.metadata;
  for (ElementAnnotation annotationElement in annotationElements) {
    AnnotationJson annotation = AnnotationJson.fromElement(annotationElement);
    if (!forTranslationAnnotationsOnly ||
        annotation.type.name == translationAnnotation) {
      annotations.add(annotation);
    }
  }
  return annotations;
}

/// Information for dart functions and methods
class ExecutableJson {
  static const nameAttribute = 'name';
  static const returnTypeAttribute = 'returnType';
  static const parameterTypesAttribute = 'parameterTypes';
  static const annotationsAttribute = 'annotations';

  final String? name;
  final TypeJson? returnType;
  final List<TypeJson> parameterTypes;
  final List<AnnotationJson> annotations;

  ExecutableJson.fromElement(ExecutableElement executableElement)
      : name = executableElement.name,
        returnType = _createReturnType(executableElement),
        parameterTypes = _createParameterTypes(executableElement),
        annotations = _createAnnotations(executableElement);

  ExecutableJson.fromElementWithTranslationAnnotationsOnly(
      ExecutableElement executableElement)
      : name = executableElement.name,
        returnType = null,
        parameterTypes = const [],
        annotations = _createAnnotations(executableElement,
            forTranslationAnnotationsOnly: true);

  ExecutableJson.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        returnType = json[returnTypeAttribute] == null
            ? null
            : TypeJson.fromJson(json[returnTypeAttribute]),
        parameterTypes = json[parameterTypesAttribute] == null
            ? []
            : List<TypeJson>.from(json[parameterTypesAttribute]
                .map((model) => TypeJson.fromJson(model))),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationJson>.from(json[annotationsAttribute]
                .map((model) => AnnotationJson.fromJson(model)));

  bool get isParameterProcessorFunction => annotations.any(
      (a) => a.type == TypeJson.actionMethodParameterProcessorAnnotation());

  bool get isResultProcessorFunction => annotations
      .any((a) => a.type == TypeJson.actionMethodResultProcessorAnnotation());

  bool get hasParameterFactory =>
      _hasAnnotation(TypeJson.parameterFactoryAnnotation());

  bool get hasParameter => parameterTypes.isNotEmpty;

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        if (returnType != null) returnTypeAttribute: returnType,
        if (parameterTypes.isNotEmpty) parameterTypesAttribute: parameterTypes,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<TypeJson> _createParameterTypes(
      ExecutableElement executableElement) {
    return executableElement.parameters
        .map((p) => TypeJson.fromDartType(p.type))
        .toList();
  }

  static TypeJson? _createReturnType(ExecutableElement executableElement) {
    DartType returnType = executableElement.returnType;
    var returnTypeVoid = returnType.element == null;
    if (returnTypeVoid) {
      return null;
    } else {
      return TypeJson.fromDartType(returnType);
    }
  }

  bool _hasAnnotation(TypeJson annotationType) =>
      annotations.any((a) => a.type == annotationType);
}

class ActionMethodParameterProcessorFunction extends ExecutableJson {
  ActionMethodParameterProcessorFunction.fromElement(
      ExecutableElement executableElement)
      : super.fromElement(executableElement);

  ActionMethodParameterProcessorFunction.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static bool isValid(Element element) {
    return element is FunctionElement &&
        element.isPublic &&
        element.returnType.isVoid &&
        (element.parameters.length == 2 || element.parameters.length == 3) &&
        element.parameters[0].type.element!.name ==
            TypeJson.buildContext().name &&
        element.parameters[1].type.element!.name ==
            TypeJson.actionMethodInvokeWithParameter().name &&
        element.metadata.toString().contains(
            '@${TypeJson.actionMethodParameterProcessorAnnotation().name!}');
  }

  double? get index {
    try {
      AnnotationJson processorAnnotation = annotations.firstWhere(
          (p) => p.type == TypeJson.actionMethodParameterProcessorAnnotation());
      return processorAnnotation.values!['index'] as double?;
    } on Exception {
      return double.infinity;
    }
  }

  bool canProcessMethod(ExecutableJson methodJson) =>
      methodJson.parameterTypes.length == 1 &&
      parameterTypes.length == 3 &&
      parameterTypes[2]
          .processorCompatibleType(methodJson.parameterTypes.first);
}

class ActionMethodResultProcessorFunction extends ExecutableJson {
  ActionMethodResultProcessorFunction.fromElement(
      ExecutableElement executableElement)
      : super.fromElement(executableElement);

  ActionMethodResultProcessorFunction.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  static bool isValid(Element element) {
    return element is FunctionElement &&
        element.isPublic &&
        (element.parameters.length == 2 || element.parameters.length == 3) &&
        element.parameters[0].type.element!.name ==
            TypeJson.buildContext().name &&
        element.parameters[1].type.element!.name ==
            TypeJson.actionMethodInfo().name &&
        element.metadata.toString().contains(
            '@${TypeJson.actionMethodResultProcessorAnnotation().name!}');
  }

  bool canProcessMethod(ExecutableJson methodJson) =>
      (_hasReturnType(methodJson))
          ? (parameterTypes.length == 3 &&
              parameterTypes[2].processorCompatibleType(methodJson.returnType))
          : (parameterTypes.length == 2 && !_hasReturnType(methodJson));

  bool _hasReturnType(ExecutableJson methodJson) =>
      methodJson.returnType != null && methodJson.returnType!.name != 'void';

//TODO domainObject annotation
//TODO requiredAnnotations in [ActionMethodRes]

  double? get index {
    try {
      AnnotationJson processorAnnotation = annotations.firstWhere(
          (p) => p.type == TypeJson.actionMethodResultProcessorAnnotation());
      return processorAnnotation.values!['index'] as double?;
    } on Exception {
      return double.infinity;
    }
  }
}

/// TODO: explain what a property is.
class PropertyJson {
  static const nameAttribute = 'name';
  static const typeAttribute = 'type';
  static const hasSetterAttribute = 'hasSetter';
  static const annotationsAttribute = 'annotations';

  final String? name;
  final TypeJson type;
  final bool? hasSetter;
  final List<AnnotationJson> annotations;

  PropertyJson.fromElements(PropertyAccessorElement propertyGetterElement,
      this.hasSetter, FieldElement fieldElement)
      : name = propertyGetterElement.name,
        type = TypeJson.fromDartType(propertyGetterElement.returnType),
        annotations = _createAnnotationsFrom2Elements(
            propertyGetterElement, fieldElement);

  PropertyJson.fromElementsWithTranslateAnnotationOnly(
      PropertyAccessorElement propertyAccessorElement,
      this.hasSetter,
      FieldElement fieldElement)
      : name = propertyAccessorElement.name,
        type = TypeJson.fromDartType(propertyAccessorElement.returnType),
        annotations =
            _createAnnotationsFrom2ElementsWithTranslateAnnotationOnly(
                propertyAccessorElement, fieldElement);

  PropertyJson.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        hasSetter = json[hasSetterAttribute],
        type = TypeJson.fromJson(json[typeAttribute]),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationJson>.from(json[annotationsAttribute]
                .map((model) => AnnotationJson.fromJson(model)));

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        hasSetterAttribute: hasSetter,
        typeAttribute: type,
    if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<AnnotationJson> _createAnnotationsFrom2Elements(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationJson> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement));
    annotations.addAll(_createAnnotations(fieldElement));
    return annotations;
  }

  static _createAnnotationsFrom2ElementsWithTranslateAnnotationOnly(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationJson> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement,
        forTranslationAnnotationsOnly: true));
    annotations.addAll(
        _createAnnotations(fieldElement, forTranslationAnnotationsOnly: true));
    return annotations;
  }
}
