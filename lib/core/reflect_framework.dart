import '../gui/reflect_generated.dart';
import 'reflect_documentation.dart';
import 'reflect_meta_temp.dart';

///TODO DartDoc
abstract class ReflectFramework extends ConceptDocumentation {}

//TODO generate it into reflect_generated lib
class ReflectFrameworkInfo {
  final ApplicationInfo application = ApplicationInfo();

  final List<ServiceObjectInfo> serviceObjects = [
    ServiceObjectInfo(title: "Login"),
    ServiceObjectInfo(title: "Orders")
  ];
}

/// * Provides name of application
/// * For graphical user interfaces
///   * Provides a optional title image
///   * Provides colors to be used
/// * Allows to override utility classes eg:
///   * command line applications, rest-full web service applications and graphical user interface applications will have different ways to execute ActionMethods
abstract class ReflectApplication extends ConceptDocumentation {}
