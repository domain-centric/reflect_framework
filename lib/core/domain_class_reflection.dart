import 'package:reflect_framework/core/action_method_info.dart';

//import 'package:reflect_framework/core/property_reflection.dart';
import 'package:reflect_framework/core/reflect_documentation.dart';
import 'package:reflect_framework/core/service_class_info.dart';

/// [DomainObject]s represent entities: the nouns of the domain. If your application is a sales application it’s likely that your domain model contains [DomainObject]s such as: customers, products and orders.
///
/// [DomainObject]s are created by a developer or are reused from an existing application that needs to be re-written. They can be created from scratch or generated from a schema, e.g.:
/// * [Database schema](https://en.wikipedia.org/wiki/Database_schema)
/// * [XML schema](https://en.wikipedia.org/wiki/XML_Schema_(W3C))
/// * [JSON schema](https://en.wikipedia.org/wiki/JSON#Metadata_and_schema)
/// * [Web service](https://en.wikipedia.org/wiki/Web_Services_Description_Language)
///
/// [DomainObject]s are [Plain Old Dart Object](https://en.wikipedia.org/wiki/Plain_old_Java_object): they do not have to extend or implement any class nor need any annotation.
/// The [ReflectFramework] will recognize all [DomainObject]s that are:
/// - A public class (name does not start with an underscore)
/// - Is not a Dart type (not in a Dart library)
/// - Has one or more [Property]s
/// - Can be (directly or indirectly) reached from [ServiceObjectActionMethod]s

abstract class DomainObject extends ConceptDocumentation {}

/// The [ApplicationInfoBuilder] creates Reflection classes
/// (with [DomainClassInfoCode]) that implement [DomainClassReflection]
/// for all classes that are recognized as [DomainObject]s.
abstract class DomainClassReflection extends ClassInfo {
  // [DomainObject]s do not have an icon (for now)
  List<ActionMethodInfo> get actionMethods;
//List<PropertyReflection> get propertyReflections;
}
