import 'dart:io' as Io;

import 'package:dart_code/dart_code.dart';
import 'package:recase/recase.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';
import 'package:yaml/yaml.dart';

class GeneratedApplicationInfoCode extends Class {
  GeneratedApplicationInfoCode(ReflectJson reflectJson)
      : super('ReflectApplicationInfo',
            implements: _createImplements(),
            methods: _createMethods(reflectJson));

  static List<Type> _createImplements() =>
      [Type('ApplicationInfo', libraryUrl: 'core/application_info.dart')];

  static List<Method> _createMethods(ReflectJson reflectJson) {
    PubSpecYaml pubSpecYaml = PubSpecYaml();
    ClassJson applicationClassJson = _findApplicationClassJson(reflectJson);
    List<Method> methods = [];
    methods.add(DisplayName.createGetterMethod(applicationClassJson.type));
    methods.add(TitleImage.createGetterMethod(
        applicationClassJson, pubSpecYaml.assets));
    methods.add(pubSpecYaml.createStringGetterMethod('description'));
    methods.add(pubSpecYaml.createStringGetterMethod('homePage'));
    methods.add(pubSpecYaml.createStringGetterMethod('documentation'));
    methods.add(_createServiceClassGetterMethod());

    //TODO Add:
    // List<ExecutableInfo> preProcessors=reflectInfo.findActionMethodPreProcessorFunctions();
    // List<ExecutableInfo> processors=reflectInfo.findActionMethodProcessorFunctions();
    // List<ClassInfo> serviceClasses= reflectInfo.findPotentialServiceClasses( preProcessors,processors);
    // ServiceClassesInfoCode serviceClassesInfoCode=ServiceClassesInfoCode(reflectInfo);
    // List<ServiceClassInfoCode> serviceClassInfoCodes=serviceClasses.map((s) => ServiceClassInfoCode(s));
    // List<ClassInfo> domainClasses= reflectInfo.findPotentialDomainClasses(serviceClasses);
    // List<DomainClassInfoCode> domainClassCodes=serviceClasses.map((s) => DomainClassInfoCode(s));

    return methods;
  }

  static ClassJson _findApplicationClassJson(ReflectJson reflectJson) {
    const name = 'ReflectGuiApplication';
    const lib = '/reflect_framework/lib/gui/gui.dart';
    List<ClassJson> reflectGuiApplications = reflectJson.classes
        .where((c) =>
            c.extending != null &&
            c.extending.name == name &&
            c.extending.library == lib)
        .toList();

    if (reflectGuiApplications.length == 0) {
      throw Exception(
          "One class in your source must extend: $name from library: $lib");
    }
    if (reflectGuiApplications.length > 1) {
      List<String> reflectApplicationNames =
          reflectGuiApplications.map((c) => c.type.name).toList();
      throw Exception(
          "Only one class in your source code may extend: $name. Found: $reflectApplicationNames");
    }
    return reflectGuiApplications.first;
  }

  static Method _createServiceClassGetterMethod() {
    List<Annotation> annotations = [Annotation(Type('override'))];
    Type domainClassInfoType =
        Type('DomainClassInfo', libraryUrl: 'core/reflect_meta_temp.dart');

    Expression createBody = Expression.ofList([
      Expression.callConstructor(domainClassInfoType,
          parameterValues: _createParameterValues('Login')),
      Expression.callConstructor(domainClassInfoType,
          parameterValues: _createParameterValues('Orders'))
    ]);
    Type listOfDomainClassInfo = Type.ofGenericList(domainClassInfoType);
    return Method.getter('serviceClasses', createBody,
        type: listOfDomainClassInfo, annotations: annotations);
  }

  static _createParameterValues(String name) => ParameterValues(
      [ParameterValue.named('title', Expression.ofString(name))]);
}

class PubSpecYaml {
  final Map yaml;

  PubSpecYaml() : yaml = _read();

  List<String> get authors {
    YamlList authors = yaml['authors'];
    if (authors == null) {
      return const [];
    }
    return authors.map((asset) => asset.toString()).toList();
  }

  List<String> get assets {
    var flutter = yaml['flutter'];
    if (flutter == null) {
      return const [];
    }
    YamlList assets = flutter['assets'];
    if (assets == null) {
      return const [];
    }
    return assets.map((asset) => asset.toString()).toList();
  }

  static Map _read() {
    Io.File yamlFile = Io.File("pubspec.yaml");
    String yamlString = yamlFile.readAsStringSync();
    Map yaml = loadYaml(yamlString);
    return yaml;
  }

  Method createStringGetterMethod(String name) {
    List<Annotation> annotations = [Annotation(Type('override'))];
    Expression createBody = _createExpression(name);
    return Method.getter(name, createBody,
        type: Type.ofString(), annotations: annotations);
  }

  Expression _createExpression(String name) {
    var value = yaml[name.toLowerCase()];
    if (value == null) {
      return Expression.ofString('');
    } else {
      return Expression.ofString('$value');
    }
  }
}

/// A [ReflectGuiApplication] shows a [TitleImage] when no tabs are opened.
/// By default this is the [ReflectGuiApplication] name as a text (See generated ApplicationInfo.name).
/// A better alternative is to add a title image, e.g.:
/// * Your Application class is named: MyFirstApplication
/// * You have added a title image as assets\my_first_application.png
///   * Note that the file name is your Application class name in snake_case format.
///   * Note that you can use any accessible folder in your project, except the project root folder
///   * Note that you can use the following image file extensions: jpeg, webp, gif, png, bmp, wbmp
///   * Note that you can have add multiple image files for different resolutions and dark or light themes, see https://flutter.dev/docs/development/ui/assets-and-images)
/// * You have defined an asset with the path to your title image file in the flutter section of the pubspec.yaml file:
///     assets:
///     - assets/my_first_app.png
class TitleImage {
  static Method createGetterMethod(
      ClassJson applicationClassJson, List<String> assets) {
    List<Annotation> annotations = [Annotation(Type('override'))];
    Expression body = _createExpression(applicationClassJson, assets);
    Method method = Method.getter('titleImage', body,
        type: Type.ofString(), annotations: annotations);
    return method;
  }

  static String _findAssetPath(List<String> assets, String fileName) {
    // List<String> assets = _findAssets(pubSpecYaml);
    RegExp imageAsset = RegExp(
        '/' + fileName + '\.(jpeg|webp|gif|png|bmp|wbmp)\$',
        caseSensitive: false);
    String found = assets.firstWhere((asset) => imageAsset.hasMatch(asset),
        orElse: () => null);
    return found;
  }

  static Expression _createExpression(
      ClassJson applicationClassJson, List<String> assets) {
    String fileName = ReCase(applicationClassJson.type.name).snakeCase;
    String foundAssetPath = _findAssetPath(assets, fileName);
    if (foundAssetPath == null) {
      //Show warning
      print(
          'No title image found. Please define a $fileName asset in pubspec.yaml.');
      return Expression.ofString('');
    } else {
      return Expression.ofString('$foundAssetPath');
    }
  }
}
