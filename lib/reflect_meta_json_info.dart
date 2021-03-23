import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import 'reflect_annotations.dart';

/// Used by the [ReflectInfoJsonBuilder] to create intermediate json files to generate meta code later by another builder (TODO link to builder).
/// The meta data comes from source files using the [LibraryElement] class from the source_gen package
class ReflectInfo {
  static const actionMethodPreProcessorsAttribute = 'actionMethodPreProcessors';
  static const actionMethodProcessorsAttribute = 'actionMethodProcessors';
  static const functionsAttribute = 'functions';
  static const classesAttribute = 'classes';
  static const voidName = 'void';

  // We cant use ActionMethodPreProcessorContext type to convert it to a string,
  // because it contains BuildContext and thus imports from a UI package, which does not go will with build_runner.
  // Maybe this is because build_runner can use code reflection and Flutter does not allow this???
  static const actionMethodPreProcessorContextName =
      'ActionMethodPreProcessorContext';

  final List<ExecutableInfo> functions;
  final List<ClassInfo> classes;

  //TODO functions (ending with factory in name, when needed for service objects and as a replacement for ActionMethodPreProcessorInfo and ActionMethodProcessorInfo)
  //TODO add enums (with texts)
  //TODO add TranslatableTextAnnotations

  ReflectInfo.fromLibrary(LibraryReader library)
      : this.functions = _createFunctions(library),
        this.classes = _createClasses(library);

  ReflectInfo.fromJson(Map<String, dynamic> json)
      : classes = json[classesAttribute],
        functions = json[functionsAttribute];

  Map<String, dynamic> toJson() => {
        if (functions.isNotEmpty) functionsAttribute: functions,
        if (classes.isNotEmpty) classesAttribute: classes,
      };

  static List<ClassInfo> _createClasses(LibraryReader library) {
    return library.classes
        .where((e) => _isNeededClass(e))
        .map((e) => ClassInfo.fromElement(e))
        .toList();
  }

  static bool _isNeededClass(ClassElement element) {
    return element.isPublic &&
        !element.source.fullName.contains('lib/reflect_');
  }

  static List<ExecutableInfo> _createFunctions(LibraryReader library) {
    return library.allElements
        .where((e) => _isNeededFunction(e))
        .map((e) => ExecutableInfo.fromElement(e))
        .toList();
  }

  static bool _isNeededFunction(Element element) {
    return element is FunctionElement &&
        element.isPublic &&
        (_isPotentialServiceObjectFactoryFunction(element) ||
            _isActionMethodPreProcessorFunction(element) ||
            _isActionMethodProcessorFunction(element));
  }

  static _isPotentialServiceObjectFactoryFunction(FunctionElement element) {
    const factory = 'Factory';
    return element.name.endsWith(factory) &&
        element.name.length > factory.length &&
        element.returnType != null &&
        element.returnType.element.name != voidName;
  }

  static bool _isActionMethodPreProcessorFunction(FunctionElement element) {
    String preProcessorAnnotation = '@' + (ActionMethodPreProcessor).toString();
    return element.returnType.element == null &&
        (element.parameters.length == 1 || element.parameters.length == 2) &&
        element.parameters[0].type.element.name ==
            actionMethodPreProcessorContextName &&
        element.metadata.toString().contains(preProcessorAnnotation);
  }

  static bool _isActionMethodProcessorFunction(FunctionElement element) {
    String processorAnnotation = '@' + (ActionMethodProcessor).toString();
    return (element.parameters.length == 1 || element.parameters.length == 2) &&
        element.parameters[0].type.element.name ==
            actionMethodPreProcessorContextName &&
        element.metadata.toString().contains(processorAnnotation);
  }
}

class ClassInfo {
  static const typeAttribute = 'type';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final TypeInfo type;
  final List<AnnotationInfo> annotations;
  final List<ExecutableInfo> methods;
  final List<PropertyInfo> properties;

  ClassInfo.fromElement(Element element)
      : type = TypeInfo.fromElement(element),
        annotations = _createAnnotations(element),
        methods = _createMethods(element),
        properties = _createProperties(element);

  ClassInfo.fromJson(Map<String, dynamic> json)
      : type = json[typeAttribute],
        annotations = json[annotationsAttribute],
        methods = json[methodsAttribute],
        properties = json[propertiesAttribute];

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
        if (annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods.isNotEmpty) methodsAttribute: methods,
        if (properties.isNotEmpty) propertiesAttribute: properties
      };

  static List<ExecutableInfo> _createMethods(ClassElement classElement) {
    return classElement.methods
        .where((e) => _isNeededMethod(e))
        .map((e) => ExecutableInfo.fromElement(e))
        .toList();
  }

  static bool _isNeededMethod(ExecutableElement executableElement) {
    return executableElement.isPublic &&
        executableElement.parameters.length <= 1;
  }

  static List<PropertyInfo> _createProperties(ClassElement classElement) {
    List<PropertyInfo> properties = [];
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
          .any((element) => element.name == getterAccessorElement.name + "=");
      FieldElement fieldElement = fieldElements
          .firstWhere((element) => element.name == getterAccessorElement.name);

      PropertyInfo property = PropertyInfo.fromElements(
          getterAccessorElement, hasSetter, fieldElement);
      properties.add(property);
    }
    return properties;
  }
}

class TypeInfo {
  static const libraryAttribute = 'library';
  static const nameAttribute = 'name';
  static const genericTypesAttribute = 'genericTypes';

  final String library;
  final String name;
  final List<TypeInfo> genericTypes;

  TypeInfo.fromElement(Element element)
      : library = element.source.fullName,
        name = element.name,
        genericTypes = const [];

  TypeInfo.fromDartType(DartType dartType)
      : library = dartType.element.source==null?null: dartType.element.source.fullName,
        //TODO
        name = dartType.element.name,
        //TODO
        genericTypes = _createGenericTypes(dartType);

  TypeInfo.fromJson(Map<String, dynamic> json)
      : library = json[libraryAttribute],
        name = json[nameAttribute],
        genericTypes = json[genericTypesAttribute];

  Map<String, dynamic> toJson() => {
        libraryAttribute: library,
        nameAttribute: name,
        if (genericTypes.isNotEmpty) genericTypesAttribute: genericTypes
      };

  static List<TypeInfo> _createGenericTypes(DartType dartType) {
    if (dartType is ParameterizedType) {
      List<TypeInfo> genericTypes = [];
      for (DartType genericDartType in dartType.typeArguments) {
        TypeInfo genericTypeInfo = TypeInfo.fromDartType(genericDartType);
        genericTypes.add(genericTypeInfo);
      }
      return genericTypes;
    } else {
      return const [];
    }
  }
}

class AnnotationInfo {
  static const typeAttribute = 'type';
  static const valuesAttribute = 'values';

  final TypeInfo type;
  final Map<String, Object> values;

  AnnotationInfo.fromElement(ElementAnnotation annotationElement)
      : type = TypeInfo.fromDartType(
            annotationElement.computeConstantValue().type),
        values = _values(annotationElement);

  AnnotationInfo.fromJson(Map<String, dynamic> json)
      : type = json[typeAttribute],
        values = json[valuesAttribute];

  Map<String, dynamic> toJson() =>
      {typeAttribute: type, if (values.isNotEmpty) valuesAttribute: values};

  static Map<String, Object> _values(ElementAnnotation annotationElement) {
    try {
      List<ParameterElement> parameters =
          (annotationElement.element as ConstructorElement).parameters;
      var dartObject = annotationElement.computeConstantValue();
      ConstantReader reader = ConstantReader(dartObject);
      return {
        for (ParameterElement parameter in parameters)
          parameter.name: reader.peek(parameter.name).literalValue,
      };
    } catch (e) {
      return const {};
    }
  }
}

List<AnnotationInfo> _createAnnotations(Element element) {
  List<AnnotationInfo> annotations = [];
  List<ElementAnnotation> annotationElements = element.metadata;
  for (ElementAnnotation annotationElement in annotationElements) {
    AnnotationInfo annotation = AnnotationInfo.fromElement(annotationElement);
    annotations.add(annotation);
  }
  return annotations;
}

/// Information for dart functions and methods
class ExecutableInfo {
  static const nameAttribute = 'name';
  static const returnTypeAttribute = 'returnType';
  static const parameterTypesAttribute = 'parameterTypes';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo returnType;
  final List<TypeInfo> parameterTypes;
  final List<AnnotationInfo> annotations;

  ExecutableInfo.fromElement(ExecutableElement executableElement)
      : name = executableElement.name,
        returnType = _createReturnType(executableElement),
        parameterTypes = _createParameterTypes(executableElement),
        annotations = _createAnnotations(executableElement);

  ExecutableInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        returnType = json[returnTypeAttribute],
        parameterTypes = json[parameterTypesAttribute],
        annotations = json[annotationsAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        if (returnType != null) returnTypeAttribute: returnType,
        if (parameterTypes.isNotEmpty) parameterTypesAttribute: parameterTypes,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<TypeInfo> _createParameterTypes(
      ExecutableElement executableElement) {
    return executableElement.parameters
        .map((p) => TypeInfo.fromDartType(p.type))
        .toList();
  }

  static TypeInfo _createReturnType(ExecutableElement executableElement) {
    DartType returnType = executableElement.returnType;
    var returnTypeVoid = returnType.element == null;
    if (returnTypeVoid) {
      return null;
    } else {
      return TypeInfo.fromDartType(returnType);
    }
  }
}

/// TODO: explain what a property is.
class PropertyInfo {
  static const nameAttribute = 'name';
  static const typeAttribute = 'type';
  static const hasSetterAttribute = 'hasSetter';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo type;
  final bool hasSetter;
  final List<AnnotationInfo> annotations;

  PropertyInfo.fromElements(PropertyAccessorElement propertyAccessorElement,
      this.hasSetter, FieldElement fieldElement)
      : name = propertyAccessorElement.name,
        type = TypeInfo.fromDartType(propertyAccessorElement.returnType),
        annotations = _createAnnotationsFrom2Elements(
            propertyAccessorElement, fieldElement);

  PropertyInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        hasSetter = json[hasSetterAttribute],
        type = json[typeAttribute],
        annotations = json[annotationsAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        hasSetterAttribute: hasSetter,
        typeAttribute: type,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<AnnotationInfo> _createAnnotationsFrom2Elements(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationInfo> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement));
    annotations.addAll(_createAnnotations(fieldElement));
    return annotations;
  }
}
