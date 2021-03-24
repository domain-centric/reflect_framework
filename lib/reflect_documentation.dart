/// The [ReflectFramework] documentation is generated and can import [Dart doc comments](https://dart.dev/guides/language/effective-dart/documentation)
/// The documentation is part of the Dart code, which has the following advantages over separated documentation:
/// * Directly available for the developer
/// * References to other code can be used (which is updated during refactoring)
/// * Documentation is better an par with the Dart code
/// * The IDE is used as an editor (with spelling checker and text completion)
///
/// Sometimes we need to define a concept. We do this with:
/// * [Dart doc comments](https://dart.dev/guides/language/effective-dart/documentation) that explains the concept
/// * Followed by a abstract class of which the class name corresponds with the concept
/// * This class extends or implements the [ConceptDocumentation] class to indicate it is intended as concept documentation
/// * This class has an empty body
///
/// Example: e.g. see: [ReflectFramework]
abstract class ConceptDocumentation {}
