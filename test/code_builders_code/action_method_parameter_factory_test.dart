import 'package:dart_code/dart_code.dart';
import 'package:reflect_framework/code_builders/application_info_builder.dart';
import 'package:reflect_framework/code_builders/info_json.dart';
import 'package:reflect_framework/code_builders_code/action_method_info_class.dart';
import 'package:test/test.dart';

/// IMPORTANT: PREREQUISITES TO RUN TEST:
/// - run on command line:
///   flutter packages pub run build_runner build lib --delete-conflicting-outputs
///   to generate required .dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json
///
/// - run test via command line:
///   flutter packages pub run test\code_builders_code\action_method_parameter_factory_test.dart
///   or:
///   dart test\code_builders_code\action_method_parameter_factory_test.dart
///   flutter test runs tests via a headless flutter device, the flutter_tester, which doesn't support mirrors.
///   If you have tests that use mirrors and not dart:ui, then running them via flutter packages pub run test_name is supported,
///   since this runs in the dart vm.

main() {
  ReflectJson reflectJson = ReflectJson.fromGeneratedReflectInfoCombinedFile();
  ClassJson classJson = reflectJson.classes
      .where((c) => c.type.name == 'ActionMethodParameterFactoryTestService')
      .first;

  group('No parameterFactory', () {
    test('No parameter', () {
      String actual = createAndFindMethodString(reflectJson, classJson,
          actionMethodName: 'noParameter',
          actionMethodInfoClassMethod: '_createParameter');
      String expected = ''; //should have no _createParameter method
      expect(actual, expected);
    });
    test('No parameter factory', () {
      String actual = createAndFindMethodString(reflectJson, classJson,
          actionMethodName: 'noParameterFactory',
          actionMethodInfoClassMethod: '_createParameter');
      String expected = ''; //should have no _createParameter method
      expect(actual, expected);
    });
  });

  group('With ParameterFactory annotation', () {
    group('Dart Types', () {
      test('String', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'stringParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'String _createParameter()  => \'\';';
        expect(actual, expected);
      });

      test('Bool', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'boolParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'bool _createParameter()  => true;';
        expect(actual, expected);
      });

      test('Int', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'intParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'int _createParameter()  => 0;';
        expect(actual, expected);
      });

      test('Double', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'doubleParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'double _createParameter()  => 0.0;';
        expect(actual, expected);
      });

      test('DateTime', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'dateTimeParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'DateTime _createParameter()  => DateTime.now();';
        expect(actual, expected);
      });

      test('List', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'listParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'List<dynamic> _createParameter()  => [];';
        expect(actual, expected);
      });

      test('Set', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'setParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'Set<dynamic> _createParameter()  => {};';
        expect(actual, expected);
      });

      test('Map', () {
        String actual = createAndFindMethodString(reflectJson, classJson,
            actionMethodName: 'mapParameterFactoryAnnotation',
            actionMethodInfoClassMethod: '_createParameter');
        String expected = 'Map<dynamic,dynamic> _createParameter()  => {};';
        expect(actual, expected);
      });

      test('Stream should throw an unsupported exception', () {
        ExecutableJson method =
            findMethodJson(classJson, 'stringParameterFactoryAnnotation');
        method.parameterTypes.clear();
        method.parameterTypes.add(TypeJson('Stream', 'dart:asynch'));

        expect(
            () => ActionMethodInfoClass(reflectJson, classJson, method),
            throwsA(predicate((dynamic e) =>
                e is ApplicationInfoBuilderException &&
                e.toString().contains(
                    'Could not create a parameterFactory method for Dart type: Stream. Replace the ParameterFactory annotation with method: Stream stringParameterFactoryAnnotationParameterFactory()'))));
      });
    });
    group('Custom Types', () {
      //TODO test with default constructor and ParameterFactoryAnno
    });
  });

  group('With ParameterFactory methods', () {
    group('Dart Types', () {
      //TODO
    });
    group('Custom Types', () {
      //TODO
    });
  });
}

String createAndFindMethodString(ReflectJson reflectJson, ClassJson classJson,
    {String? actionMethodName, String? actionMethodInfoClassMethod}) {
  ExecutableJson methodJson = findMethodJson(classJson, actionMethodName);

  ActionMethodInfoClass actionMethodInfoClass =
      ActionMethodInfoClass(reflectJson, classJson, methodJson);

  List<Method> methods = actionMethodInfoClass.methods!
      .where((m) =>
          CodeFormatter().unFormatted(m.name) == actionMethodInfoClassMethod)
      .toList();

  if (methods.length == 1) {
    return CodeFormatter().unFormatted(methods.first);
  } else {
    return '';
  }
}

ExecutableJson findMethodJson(ClassJson classJson, String? actionMethodName) {
  try {
    return classJson.methods.firstWhere((m) => m.name == actionMethodName);
  } on StateError {
    throw Exception('Could not find action method: $actionMethodName '
        'in:  ${ReflectJson.generatedReflectInfoCombinedFilePath}');
  }
}
