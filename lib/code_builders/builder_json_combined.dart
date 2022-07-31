import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';

import 'info_json.dart';

/// Combines all .reflect_info.json files into one lib/reflect_info.json file
class CombiningReflectJsonBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$lib$': [ReflectJson.combinedFileName]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      ReflectJson combinedReflectInfo = ReflectJson.empty();
      final libraryJsonAssets =
          buildStep.findAssets(Glob('**/*${ReflectJson.libraryExtension}'));
      await for (var libraryJsonAsset in libraryJsonAssets) {
        String jsonString = await buildStep.readAsString(libraryJsonAsset);
        combinedReflectInfo.add(jsonString);
      }

      var encoder = const JsonEncoder.withIndent("     ");
      String formattedJson = encoder.convert(combinedReflectInfo);
      var destination =
          AssetId(buildStep.inputId.package, ReflectJson.combinedFilePath);
      buildStep.writeAsString(destination, formattedJson);
    } catch (e, stackTrace) {
      log.log(Level.SEVERE, e, stackTrace);
    }
  }
}
