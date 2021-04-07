import 'package:reflect_framework/code_builders/info_domain.dart';
import 'package:reflect_framework/core/application_info.dart';
import 'package:reflect_framework/core/service_class_info.dart';

/// An [Item] can be a:
/// - [ApplicationInfo] Te name and description of the application
/// - [DomainClassInfo] The name and description in a list row or a form or a field
abstract class Item {
  /// Name of the item
  /// In the language of the user if possible
  String get name;

  /// Optional description of the name, often to give more information on what it does
  /// In the language of the user if possible
  String get description;
}

/// An [DynamicItem] can be a:
/// - [ServiceClassInfo] e.g. a main menu item
/// - [DomainObjectProperty] e.g. a form field or row
/// - [ActionMethod], e.g. a menu item
abstract class DynamicItem extends Item {
  /// Whether this item is visible
  /// Note that Items do not have an disabled state! See [https://axesslab.com/disabled-buttons-suck/] on why.
  /// Instead items are  either visible or invisible
  bool get visible;

  /// Order of appearance, relative to its peers.
  /// The lower the number, the higher on the list.
  /// This number should be 100 by default when not specified.
  double get order;
}
