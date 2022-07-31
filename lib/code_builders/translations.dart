//TODO reuse in TranslationBuilder
// import 'package:reflect_framework/annotations.dart';

import 'package:recase/recase.dart';

import 'info_json.dart';

class TranslationFactory {
  // static final invalidCharacters = RegExp('[^a-z0-9\.]');
  // static final precedingDots = RegExp('^\.+');
  // static final trailingDots = RegExp('\.+\$');
  //
  // static String createKeyForElement(Element element) {
  //   String key = _createElementKey(element).toLowerCase();
  //   return key;
  // }
  //
  // static String createKeyForElementWithSuffix(
  //     Element element, String keySuffix) {
  //   String key =
  //       createKeyForElement(element) + '.' + _validKeySuffix(keySuffix);
  //   return key;
  // }
  //
  // static String _validKeySuffix(String keySuffix) {
  //   return keySuffix
  //       .toLowerCase()
  //       .replaceAll(invalidCharacters, '')
  //       .replaceAll(precedingDots, '')
  //       .replaceAll(trailingDots, '')
  //       .replaceAll('..', '.');
  // }
  //
  // static String _createElementKey(Element element) {
  //   var parent = element.enclosingElement;
  //   if (element is CompilationUnitElement) {
  //     return _createLibraryKey(element);
  //   } else if (parent == null) {
  //     return element.name;
  //   } else {
  //     return _createElementKey(parent) + '.' + element.name; //recursive call
  //   }
  // }
  //
  // static String _createLibraryKey(CompilationUnitElement element) {
  //   String name = element.toString();
  //   String key = name
  //       .replaceAll(RegExp('^.*lib/'), '')
  //       .replaceAll(RegExp('\.dart\$'), '')
  //       .replaceAll('_', '');
  //   return key;
  // }
  //
  // // TODO for service class
  // // TODO Translate annotations
  // static createEnglishTextForElement(Element element) {
  //   String text = element.name;
  //   StringBuffer sentence = new StringBuffer();
  //   for (int i = 0; i < text.length; i++) {
  //     String char = text[i];
  //     String nextChar = i + 1 == text.length ? null : text[i + 1];
  //     sentence.write(i == 0 ? char.toUpperCase() : char.toLowerCase());
  //
  //     if (nextChar != null) {
  //       bool isEndOfWord =
  //           char.toLowerCase() == char && nextChar.toUpperCase() == nextChar;
  //
  //       if (isEndOfWord) {
  //         sentence.write(' ');
  //       }
  //     }
  //   }
  //   return sentence.toString();
  // }

  static String createKey(TypeJson typeJson) {
    String libName = typeJson.library!
        .replaceAll(RegExp('^.*lib/'), '')
        .replaceAll(RegExp(r'\.dart\$'), '');
    String memberName = typeJson.name!;
    String key = '${ReCase(libName).camelCase}.${ReCase(memberName).camelCase}';
    return key;
  }

  /// Creates English text from a given function/class/action method or domain property
  /// This is generated from the source code either by using the name or a [Translation] annotation.
  /// This is an English text (assuming the source code is 100% english).
  static String createEnglishText(TypeJson typeJson) {
    /// TODO remove Service suffix (if any) and make the name plural if it is a [serviceObject]
    /// TODO use Translation annotation instead when there is one.
    return _createEnglishTextFromName(typeJson);
  }

  static String _createEnglishTextFromName(TypeJson typeJson) =>
      ReCase(typeJson.name!).sentenceCase;
}
