import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'reflect_meta_json_info.dart';

///Uses [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ReflectInfoJsonBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.json']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      AssetId source = buildStep.inputId;
      AssetId destination = source.changeExtension('.json');

      final resolver = buildStep.resolver;
      if (!await resolver.isLibrary(buildStep.inputId)) return;
      final lib = LibraryReader(await buildStep.inputLibrary);

      ReflectInfo reflectInfo = ReflectInfo.fromLibrary(lib);

      if (reflectInfo
          .toJson()
          .isNotEmpty) {
        var encoder = new JsonEncoder.withIndent("     ");
        String formattedJson = encoder.convert(reflectInfo);
        //TODO normally we use jsonEncode(reflectInfo)
        buildStep.writeAsString(destination, formattedJson);
      }
    } catch (e,stackTrace) {
      print(stackTrace);
    }
  }
}
