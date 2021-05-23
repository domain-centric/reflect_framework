
import 'package:flutter/material.dart';
import 'package:reflect_framework/core/action_method_info.dart';

import '../gui/gui_tab.dart' as ReflectTab;
import 'gui_tab_form_payment.dart';

///Forms:
// ======
// NarrowForm: all input fields untherneath eachother. The app bar can have a menu button for domain action methods
// WideForm: input fields next or below eachother. Can have a menu bar on top of form (with overflow menu button if need to) for domain action methods
//
//
// Input fields other than tables:
// filled style where possible, labels always floating above
//
// e.g.
// TextField
// NumberField
// Date\TimeField
// ComboFields
// DomainObjectField
// CheckBoxes
// RadioButtons
// Other (custom made and added to ReflectGuiApplication)
//
// Width
// input fields are located untherneath each other by default with a maximum length of ....px
// It is recommended to reduce/specify a smaller width where possible (TODO link)
//
// Grouping
// ?next to eachother (flow layout)?
// ?checkboxes / radiobuttons?
// ?named?
//
// Textfield
// =========
// annotations:
// obscureText
// textCapitalization
// maxLength
// maxLines
// keyboardType
// validation
// width
// icon
// prefixIcon
// suffixIcon
// helperText
// autocompletion
//
// readonly = disabled and decoration: InputDecoration.collapsed(hintText: "") to hide edit line
//
// can have a menu button for property action methods
//
// for data types:
// String
// Char?
//
// Numberfield
// =========
// annotations:
// obscure
// length
// keyboardtype
// validation
// width
// formatting
//
// can have a menu button for property action methods
//
// for data types:
// Int
// Double
// ? other
//
// TODO other input fields
// =======================
//
//
//
//
// Tables
// ======
// NarrowTable: 1 colomn without header
// WideTable: multiple columns with header, number of columns depend on available width
//
// can have a menu bar (with overflow menu button if need to) for domain action methods
//
// Width
// Tables are always located untherneath each other
// Tables take all available width if need to.
// For tables you can define the width of columns.
//
// for data types:
// lists
// streams
// ?DataTableSource?
///
class FormExampleTab extends ReflectTab.Tab {
  final ActionMethodInfo actionMethodInfo;

  FormExampleTab(this.actionMethodInfo);

  @override
  Widget build(BuildContext context) {
    return PaymentForm();
  }

  ///Can not close form directly when containing unsaved data
  @override
  bool get canCloseDirectly => false;

  @override
  // TODO: implement close
  ReflectTab.TabCloseResult get close => throw UnimplementedError();

  @override
  IconData get iconData => Icons.table_rows_sharp;

  @override
  String get title => actionMethodInfo.name;
}


class FormExampleTabFactory implements ReflectTab.TabFactory {
  @override
  ReflectTab.Tab create(ActionMethodInfo actionMethodInfo) {
    return FormExampleTab(actionMethodInfo);
  }
}