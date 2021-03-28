import '../core/action_method_info.dart';
import '../core/reflect_documentation.dart';
import '../core/reflect_framework.dart';
import '../core/service_class_info.dart';

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

/// The [ReflectFramework] creates info classes (with [DomainClassInfoCode]) that implement [DomainClassInfo] for all classes that are recognized as [DomainObject]s.
abstract class DomainClassInfo extends ClassInfo {
  // [DomainObject]s do not have an icon (for now)
  //   List<ActionMethodInfo> get actionMethods;
  //   List<PropertyInfo> get propertyInfos;

}

/// [DomainObject]s have [state](https://en.wikipedia.org/wiki/State_(computer_science)). This means the [DomainObject]s contain information that may change over time. This information is represented by [Property]s.
/// TODO explain Dart property field, getter and setter accessors and readonly properties
/// TODO explain which property types are supported by the [ReflectFramework]
abstract class Property extends ConceptDocumentation {}

/// Domain objects can have [ActionMethod]s.
/// TODO example
abstract class PropertyActionMethod extends ConceptDocumentation {}
