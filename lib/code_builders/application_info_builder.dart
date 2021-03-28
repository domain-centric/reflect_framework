import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';

import '../code_builders_code/application_info_library_code.dart';
import 'info_json.dart';

/// using main because that way we can simply debug:
/// - Read reflect_info.json
/// - create dart files

main() {
  String jsonString = File(
          'C:/Users/nilsth/AndroidStudioProjects/reflect-framework/.dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json')
      .readAsStringSync();
  var json = jsonDecode(jsonString);
  _createApplicationInfoLibraryFile(json);
}

const reflectGeneratedFile = 'generated.dart';
const reflectGeneratedPath = 'lib/' + reflectGeneratedFile;

void _createApplicationInfoLibraryFile(json) {
  File file = File(reflectGeneratedPath);
  String dartCode = _createReflectGeneratedLibCode(json);
  file.writeAsString(dartCode);
}

String _createReflectGeneratedLibCode(json) {
  String dartCode =
      ApplicationInfoLibraryCode(ReflectJson.fromJson(json)).toString();
  print(dartCode);
  return dartCode;
}

///Uses the reflect_info.json file to generate a reflect_generated library with info classes
class ApplicationInfoBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.combined.json': ['/../' + reflectGeneratedFile]
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
    } catch (exception, stacktrace) {
      print('$exception\n$stacktrace');
    }
  }
}
