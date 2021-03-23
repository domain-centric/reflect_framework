import 'reflect_meta_temp.dart';

class ReflectFramework {
  static final ReflectFramework _reflectFramework =
      ReflectFramework._internal();
  final Reflection reflection=Reflection();
  ReflectApplication application;

  ///Singleton
  factory ReflectFramework() {
    return _reflectFramework;
  }

  ReflectFramework._internal();
}

///* Provides name of application
///* For graphical user interfaces
///   * Provides a optional title image
///   * Provides colors to be used
///* Allows to override utility classes eg:
///   * command line applications, rest-full web service applications and graphical user interface applications will have different ways to execute ActionMethods
abstract class ReflectApplication {

}



