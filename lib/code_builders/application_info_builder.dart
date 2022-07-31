import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:logging/logging.dart';

import '../code_builders_code/application_info_library.dart';
import 'info_json.dart';

/// using main because that way we can simply debug:
/// - Read reflect_info.json
/// - create dart files

main() {
  var json = ReflectJson.readJsonFromGeneratedReflectInfoCombinedFile()!;
  _createApplicationInfoLibraryFile(json);
}

const reflectGeneratedFile = 'generated.dart';
const reflectGeneratedPath = 'lib/$reflectGeneratedFile';

void _createApplicationInfoLibraryFile(json) {
  File file = File(reflectGeneratedPath);
  String dartCode = _createReflectGeneratedLibCode(json);
  file.writeAsString(dartCode);
}

String _createReflectGeneratedLibCode(json) {
  var reflectJson = ReflectJson.fromJson(json);
  String dartCode = ApplicationInfoLibraryCode(reflectJson).toString();
  return dartCode;
}

///Uses the reflect_info.json file to generate a reflect_generated library with info classes
class ApplicationInfoBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.combined.json': ['/../$reflectGeneratedFile']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      String jsonString = await buildStep.readAsString(buildStep.inputId);
      var json = jsonDecode(jsonString);

      String dartCode = _createReflectGeneratedLibCode(json);
      AssetId destination =
          AssetId(buildStep.inputId.package, reflectGeneratedPath);
      buildStep.writeAsString(destination, dartCode);
      log.log(Level.INFO, 'Successfully created $destination');
    } catch (exception, stackTrace) {
      log.log(Level.SEVERE, exception, stackTrace);
    }
  }
}

class ApplicationInfoBuilderException implements Exception {
  final String message;

  ApplicationInfoBuilderException.forClass(ClassJson classJson, String message)
      : message = createMessage(
            [classJson.type.library!, classJson.type.name!], message);

  ApplicationInfoBuilderException.forMethod(
      ClassJson classJson, ExecutableJson methodJson, String message)
      : message = createMessage(
      [classJson.type.library!, classJson.type.name!, methodJson.name!],
            message);

  static createMessage(List<String> sources, String message) {
    return 'ApplicationInfoBuilderException:\n${sources.join('.')}:\n$message';
  }

  @override
  String toString() => message;
}
