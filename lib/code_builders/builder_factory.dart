import 'package:build/build.dart';

import 'application_info_builder.dart';
import 'builder_json.dart';
import 'builder_json_combined.dart';

/// run from command line: flutter packages pub run build_runner build lib --delete-conflicting-outputs

Builder reflectJsonBuilder(BuilderOptions builderOptions) =>
    ReflectJsonBuilder();

Builder combiningReflectJsonBuilder(BuilderOptions builderOptions) =>
    CombiningReflectJsonBuilder();

Builder applicationInfoBuilder(BuilderOptions builderOptions) =>
    ApplicationInfoBuilder();
