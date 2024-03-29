import 'package:flutter/material.dart' as _i7;
import 'package:flutter/widgets.dart' as _i6;
import 'package:reflect_framework/core/action_method_info.dart' as _i5;
import 'package:reflect_framework/core/application_info.dart' as _i1;
import 'package:reflect_framework/core/domain_class_reflection.dart' as _i3;
import 'package:reflect_framework/core/service_class_info.dart' as _i2;
import 'package:reflect_framework/domain/domain_objects.dart' as _i4;

import 'gui/default_action_method_parameter_processor.dart' as _i9;
import 'gui/default_action_method_result_processor.dart' as _i8;

/// This code is generated by [ApplicationInfoBuilder]
/// Do not modify or remove this code!
/// Regenerate it if needed using the following command: flutter pub run build_runner build --delete-conflicting-outputs
class ReflectApplicationInfo implements _i1.ApplicationInfo {
  @override
  String get name => 'My first app';

  @override
  String get description => '';

  @override
  String? get titleImage => 'assets/my_first_app.png';

  @override
  String get homePage =>
      'https://github.com/efficientyboosters/reflect_framework';

  @override
  String get documentation =>
      'https://github.com/efficientyboosters/reflect_framework/wiki';

  @override
  List<_i2.ServiceClassInfo> get serviceClassInfos =>
      [DomainObjectsDartPersonServiceInfo$()];

  @override
  List<_i3.DomainClassReflection> get domainClassReflections => [
        AcmeDomainDartProductReflection$(),
        AcmeDomainDartTranslationsReflection$(),
        AcmeDomainDartAcmeDomainReflection$(),
        AcmeDomainDartAcmeDomainProductReflection$(),
        AcmeDomainDartAcmeDomainProductAvailabilityReflection$(),
        AcmeDomainDartTranslationsEnReflection$(),
        DomainObjectsDartPaymentReflection$(),
        DomainObjectsDartCardDetailsReflection$(),
        DomainObjectsDartAddressReflection$(),
        DomainObjectsDartPersonServiceReflection$(),
        DomainObjectsDartPersonReflection$()
      ];
}

class DomainObjectsDartPersonServiceInfo$
    extends _i2.ServiceClassInfo<_i4.PersonService> {
  @override
  final serviceObject = _i4.PersonService();

  @override
  String get name => 'People';

  @override
  String get description => '';

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  List<_i5.ActionMethodInfo> get actionMethodInfos => [
        PersonServiceAllPersonsInfo$(serviceObject),
        PersonServiceFindPersonsInfo$(serviceObject),
        PersonServiceEditInfo$(serviceObject),
        PersonServiceRemoveInfo$(serviceObject),
        PersonServiceAddNewInfo$(serviceObject),
        PersonServiceSendEmailInfo$(serviceObject),
        PersonServiceLogoutInfo$(serviceObject)
      ];
}

class PersonServiceAllPersonsInfo$
    implements _i5.StartWithoutParameter, _i5.InvokeWithoutParameter {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceAllPersonsInfo$(this.methodOwner);

  @override
  String get name => 'All persons';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.table_chart_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context) {
    invokeMethodAndProcessResult(context);
  }

  @override
  void invokeMethodAndProcessResult(_i6.BuildContext context) {
    List<_i4.Person> returnValue = methodOwner.allPersons();
    _i8.showListInTableTab(context, this, returnValue);
  }
}

class PersonServiceFindPersonsInfo$
    implements _i5.StartWithoutParameter, _i5.InvokeWithParameter<String> {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceFindPersonsInfo$(this.methodOwner);

  @override
  String get name => 'Find persons';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.table_chart_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context) {
    String parameterValue = '';
    _i9.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i6.BuildContext context, String parameterValue) {
    List<_i4.Person> returnValue = methodOwner.findPersons(parameterValue);
    _i8.showListInTableTab(context, this, returnValue);
  }
}

class PersonServiceEditInfo$
    implements
        _i5.StartWithParameter<_i4.Person>,
        _i5.InvokeWithParameter<_i4.Person> {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceEditInfo$(this.methodOwner);

  @override
  String get name => 'Edit';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context, Object parameterValue) {
    _i9.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i6.BuildContext context, _i4.Person parameterValue) {
    methodOwner.edit(parameterValue);
    _i8.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceRemoveInfo$
    implements
        _i5.StartWithParameter<_i4.Person>,
        _i5.InvokeWithParameter<_i4.Person> {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceRemoveInfo$(this.methodOwner);

  @override
  String get name => 'Remove';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context, Object parameterValue) {
    _i9.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i6.BuildContext context, _i4.Person parameterValue) {
    methodOwner.remove(parameterValue);
    _i8.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceAddNewInfo$
    implements _i5.StartWithoutParameter, _i5.InvokeWithParameter<_i4.Person> {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceAddNewInfo$(this.methodOwner);

  @override
  String get name => 'Add new';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.table_rows_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context) {
    _i4.Person parameterValue = _i4.Person();
    _i9.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i6.BuildContext context, _i4.Person parameterValue) {
    methodOwner.addNew(parameterValue);
    _i8.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceSendEmailInfo$
    implements
        _i5.StartWithParameter<_i4.Person>,
        _i5.InvokeWithParameter<_i4.Person> {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceSendEmailInfo$(this.methodOwner);

  @override
  String get name => 'Send email';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context, Object parameterValue) {
    _i9.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i6.BuildContext context, _i4.Person parameterValue) {
    methodOwner.sendEmail(parameterValue);
    _i8.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceLogoutInfo$
    implements _i5.StartWithoutParameter, _i5.InvokeWithoutParameter {
  @override
  final _i4.PersonService methodOwner;

  PersonServiceLogoutInfo$(this.methodOwner);

  @override
  String get name => 'Logout';

  @override
  String get description => '';

  @override
  _i6.IconData get icon => _i7.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  void start(_i6.BuildContext context) {
    invokeMethodAndProcessResult(context);
  }

  @override
  void invokeMethodAndProcessResult(_i6.BuildContext context) {
    methodOwner.logout();
    _i8.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}
