import 'package:reflect_framework/core/annotations.dart';

@ServiceClass()
@ActionMethodParameterProcessor(index: 11) //TODO remove after test
class ActionMethodParameterFactoryTestService {
  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  void noParameter() {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  void noParameterFactory() {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void stringParameterFactoryAnnotation(String s) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void boolParameterFactoryAnnotation(bool b) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void intParameterFactoryAnnotation(int i) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void doubleParameterFactoryAnnotation(double d) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void dateTimeParameterFactoryAnnotation(DateTime dt) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void listParameterFactoryAnnotation(List l) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void setParameterFactoryAnnotation(Set s) {
    print('test');
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  @ActionMethodParameterFactory()
  void mapParameterFactoryAnnotation(Map m) {
    print('test');
  }
}
