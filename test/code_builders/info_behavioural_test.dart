import 'package:dart_code/dart_code.dart';
import 'package:reflect_framework/code_builders/info_behavioural.dart';
import 'package:reflect_framework/code_builders/info_json.dart';
import 'package:test/test.dart';

/// IMPORTANT: PREREQUISITES TO RUN TEST:
/// - run on command line:
///   flutter packages pub run build_runner build lib --delete-conflicting-outputs
///   to generate required .dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json
///
/// - run test via command line:
///   flutter packages pub run test\code_builders\info_behavioural_test.dart
///   or:
///   dart test\code_builders\info_behavioural_test.dart
///   flutter test runs tests via a headless flutter device, the flutter_tester, which doesn't support mirrors.
///   If you have tests that use mirrors and not dart:ui, then running them via flutter packages pub run test_name is supported,
///   since this runs in the dart vm.

main() {
  ReflectJson reflectJson = ReflectJson.fromGeneratedReflectInfoCombinedFile();
  ClassJson personServiceCLass =
      reflectJson.classes.where((c) => c.type.name == 'PersonService').first;

  group('Icon', () {
    test('default icon', () {
      ExecutableJson methodJson =
          personServiceCLass.methods.where((m) => m.name == 'allPersons').first;
      String actual =
          CodeFormatter().unFormatted(Icon.createExpression(methodJson));
      String expected = '_i1.Icons.lens';
      expect(actual, expected);
    });
  });
}
