import 'package:flutter/material.dart' as _i6;
import 'package:flutter/widgets.dart' as _i5;
import 'package:reflect_framework/core/action_method_info.dart' as _i4;
import 'package:reflect_framework/core/application_info.dart' as _i1;
import 'package:reflect_framework/core/service_class_info.dart' as _i2;
import 'package:reflect_framework/domain/domain_objects.dart' as _i3;

import 'gui/action_method_parameter_processor_impl.dart' as _i8;
import 'gui/action_method_result_processor_impl.dart' as _i7;

/// This code is generated by [ApplicationInfoBuilder]
/// Do not modify or remove this code!
/// Regenerate it if needed using the following command: flutter packages pub run build_runner build lib --delete-conflicting-outputs
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
      [DomainObjectsPersonServiceInfo$()];
}

class DomainObjectsPersonServiceInfo$
    extends _i2.ServiceClassInfo<_i3.PersonService> {
  @override
  final serviceObject = _i3.PersonService();

  @override
  String get name => 'People';

  @override
  String get description => '';

  @override
  bool get visible => true;

  @override
  double get order => 100.0;

  @override
  List<_i4.ActionMethodInfo> get actionMethodInfos => [
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
    implements _i4.StartWithoutParameter, _i4.InvokeWithoutParameter {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceAllPersonsInfo$(this.methodOwner);

  @override
  String get name => 'All persons';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.table_chart_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context) {
    this.invokeMethodAndProcessResult(context);
  }

  @override
  void invokeMethodAndProcessResult(_i5.BuildContext context) {
    List<_i3.Person> returnValue = methodOwner.allPersons();
    _i7.showListInTableTab(context, this, returnValue);
  }
}

class PersonServiceFindPersonsInfo$
    implements _i4.StartWithoutParameter, _i4.InvokeWithParameter<String> {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceFindPersonsInfo$(this.methodOwner);

  @override
  String get name => 'Find persons';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.table_chart_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context) {
    String parameterValue = '';
    _i8.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i5.BuildContext context, String parameterValue) {
    List<_i3.Person> returnValue = methodOwner.findPersons(parameterValue);
    _i7.showListInTableTab(context, this, returnValue);
  }
}

class PersonServiceEditInfo$
    implements
        _i4.StartWithParameter<_i3.Person>,
        _i4.InvokeWithParameter<_i3.Person> {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceEditInfo$(this.methodOwner);

  @override
  String get name => 'Edit';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context, Object parameterValue) {
    _i8.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i5.BuildContext context, _i3.Person parameterValue) {
    methodOwner.edit(parameterValue);
    _i7.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceRemoveInfo$
    implements
        _i4.StartWithParameter<_i3.Person>,
        _i4.InvokeWithParameter<_i3.Person> {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceRemoveInfo$(this.methodOwner);

  @override
  String get name => 'Remove';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context, Object parameterValue) {
    _i8.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i5.BuildContext context, _i3.Person parameterValue) {
    methodOwner.remove(parameterValue);
    _i7.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceAddNewInfo$
    implements _i4.StartWithoutParameter, _i4.InvokeWithParameter<_i3.Person> {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceAddNewInfo$(this.methodOwner);

  @override
  String get name => 'Add new';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.table_rows_sharp;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context) {
    _i3.Person parameterValue = _i3.Person();
    _i8.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i5.BuildContext context, _i3.Person parameterValue) {
    methodOwner.addNew(parameterValue);
    _i7.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceSendEmailInfo$
    implements
        _i4.StartWithParameter<_i3.Person>,
        _i4.InvokeWithParameter<_i3.Person> {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceSendEmailInfo$(this.methodOwner);

  @override
  String get name => 'Send email';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context, Object parameterValue) {
    _i8.editDomainObjectParameterInForm(context, this, parameterValue);
  }

  @override
  void invokeMethodAndProcessResult(
      _i5.BuildContext context, _i3.Person parameterValue) {
    methodOwner.sendEmail(parameterValue);
    _i7.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}

class PersonServiceLogoutInfo$
    implements _i4.StartWithoutParameter, _i4.InvokeWithoutParameter {
  @override
  final _i3.PersonService methodOwner;

  PersonServiceLogoutInfo$(this.methodOwner);

  @override
  String get name => 'Logout';

  @override
  String get description => '';

  @override
  _i5.IconData get icon => _i6.Icons.lens;

  @override
  bool get visible => true;

  @override
  double get order => 100.0;
  @override
  void start(_i5.BuildContext context) {
    this.invokeMethodAndProcessResult(context);
  }

  @override
  void invokeMethodAndProcessResult(_i5.BuildContext context) {
    methodOwner.logout();
    _i7.showMethodExecutedSnackBarForMethodsReturningVoid(context, this);
  }
}
