import 'package:build/build.dart';

import 'reflect_builder_info.dart';
import 'reflect_builder_json.dart';
import 'reflect_builder_json_combined.dart';

/// run from command line: flutter packages pub run build_runner build lib --delete-conflicting-outputs

Builder reflectJsonBuilder(BuilderOptions builderOptions) =>
    ReflectJsonBuilder();

Builder combiningReflectJsonBuilder(BuilderOptions builderOptions) =>
    CombiningReflectJsonBuilder();

Builder reflectInfoBuilder(BuilderOptions builderOptions) =>
    ReflectInfoBuilder();
