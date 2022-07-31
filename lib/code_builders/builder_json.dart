import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'info_json.dart';

///Uses [ReflectJson] to create .reflect_info.json files with meta data from source files using the source_gen package
class ReflectJsonBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [ReflectJson.libraryExtension]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    AssetId source = buildStep.inputId;
    AssetId destination = source.changeExtension(ReflectJson.libraryExtension);

    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    try {
      final lib = LibraryReader(await buildStep.inputLibrary);

      ReflectJson reflectInfo = ReflectJson.fromLibrary(lib);

      if (reflectInfo.toJson().isNotEmpty) {
        var encoder = const JsonEncoder.withIndent("     ");
        String formattedJson = encoder.convert(reflectInfo);
        //TODO normally we use jsonEncode(reflectInfo)
        buildStep.writeAsString(destination, formattedJson);
      }
    } catch (exception, stackTrace) {
      log.log(Level.SEVERE, exception, stackTrace);
    }
  }
}
