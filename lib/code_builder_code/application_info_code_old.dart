import 'dart:io' as Io;

import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

import '../code_builder/info_behavioural.dart';
import '../code_builder/info_json.dart';

/// The [ReflectFramework] [ReflectInfoBuilder] creates an [ApplicationInfo] class using [ApplicationInfoFactory].
class ApplicationInfoFactory {
  final ClassJson applicationClassJson;

  ApplicationInfoFactory(ReflectJson reflectJson)
      : applicationClassJson = findApplicationClassJson(reflectJson);

  Class createCode() {
    PubSpecYaml pubSpecYaml = PubSpecYaml();
    return Class((b) => b
      ..name = 'ApplicationInfo'
      //..extend = refer('ClassInfo','package:reflect_framework/service_class_info.dart')
      ..methods.add(DisplayName.createMethod(applicationClassJson.type))
      ..methods.add(
          TitleImage.createMethod(applicationClassJson, pubSpecYaml.assets))
      ..methods.add(pubSpecYaml.createStringGetterMethod('description'))
      ..methods.add(pubSpecYaml.createStringGetterMethod('homePage'))
      ..methods.add(pubSpecYaml.createStringGetterMethod('documentation'))
      ..methods.add(pubSpecYaml.createAuthorsGetterMethod()));
  }

  static ClassJson findApplicationClassJson(ReflectJson reflectJson) {
    const name = 'ReflectGuiApplication';
    const lib = '/reflect_framework/lib/gui.dart';
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
    return Method((b) {
      b
        ..name = name
        ..type = MethodType.getter
        ..returns = refer('String')
        ..body = _createReturnStringCode(name);
    });
  }

  Code _createReturnStringCode(String name) {
    var value = yaml[name.toLowerCase()];
    if (value == null) {
      return Code("return null;");
    } else {
      return Code("return '$value';");
    }
  }

  Method createAuthorsGetterMethod() {
    return Method((b) {
      b
        ..name = 'authors'
        ..type = MethodType.getter
        ..returns = refer('List<String>')
        ..body = _createAuthorsCode();
    });
  }

  Code _createAuthorsCode() {
    if (authors == null) {
      return Code("return null;");
    } else {
      return Code("return ${authors.map((s) => "'$s'").toList().toString()};");
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
  static Method createMethod(
      ClassJson applicationClassJson, List<String> assets) {
    return Method((b) => b
      ..name = 'titleImage'
      ..type = MethodType.getter
      ..returns = refer('String')
      ..body = _createCode(applicationClassJson, assets));
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

  static Code _createCode(ClassJson applicationClassJson, List<String> assets) {
    String fileName = ReCase(applicationClassJson.type.name).snakeCase;
    String foundAssetPath = _findAssetPath(assets, fileName);
    if (foundAssetPath == null) {
      //Show warning
      print(
          'No title image found. Please define a $fileName asset in pubspec.yaml.');
      return Code("return null;");
    } else {
      return Code("return '$foundAssetPath';");
    }
  }
}
