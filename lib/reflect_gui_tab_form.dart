import 'dart:async';

import 'package:flutter/material.dart';

import 'domain_objects.dart';

// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
import 'reflect_gui_tab.dart' as ReflectTab;

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
  String get title => "Form";
}

/// Form widgets are stateful widgets
class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  Map<String, bool> validateField = {
    "cardField": false,
    "postCodeField": false
  };
  String expiryMonth;
  int expiryYear;
  bool rememberInfo = false;
  Address _paymentAddress = new Address();
  CardDetails _cardDetails = new CardDetails();
  bool loading = false;

  final _formKey = GlobalKey<FormState>();
  final _addressLineController = TextEditingController();
  final List yearsList = List.generate(12, (int index) => index + 2020);
  static const double formSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(formSpacing),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  onSaved: (val) => _cardDetails.cardHolderName = val,
                  decoration: InputDecoration(
                      labelText: 'Name on card',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      icon: Icon(Icons.account_circle)),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        onSaved: (val) => _cardDetails.cardNumber = val,
                        //autovalidate: validateField['cardField'],
                        onChanged: (value) {
                          setState(() {
                            validateField['cardField'] = true;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Card number',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            icon: Icon(Icons.credit_card)),
                        validator: (String value) {
                          if (value.length != 16)
                            return "Please enter a valid number";
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 120.0,
                        margin: EdgeInsets.only(left: formSpacing),
                        child: TextFormField(
                          onSaved: (val) =>
                              _cardDetails.securityCode = int.parse(val),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Security Code',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        onSaved: (val) => _cardDetails.expiryMonth = val,
                        value: expiryMonth,
                        items: [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ].map<DropdownMenuItem<String>>(
                          (String val) {
                            return DropdownMenuItem(
                              child: Text(val),
                              value: val,
                            );
                          },
                        ).toList(),
                        onChanged: (val) {
                          setState(() {
                            expiryMonth = val;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Expiry Month',
                          icon: Icon(Icons.calendar_today),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: formSpacing),
                        child: DropdownButtonFormField(
                          onSaved: (val) =>
                              _cardDetails.expiryYear = val.toString(),
                          value: expiryYear,
                          items: yearsList.map<DropdownMenuItem>(
                            (val) {
                              return DropdownMenuItem(
                                child: Text(val.toString()),
                                value: val.toString(),
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(() {
                              expiryYear = val;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Expiry Year',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: formSpacing,
                ),
                TextField(),
                // TypeAheadFormField(
                //   textFieldConfiguration: TextFieldConfiguration(
                //     decoration: InputDecoration(
                //       labelText: 'Post Code',
                //       icon: Icon(Icons.location_on),
                //       floatingLabelBehavior: FloatingLabelBehavior.always,
                //       filled: true,
                //     ),
                //   ),
                //   suggestionsCallback: (pattern) async {
                //     return await _fetchAddress(pattern);
                //   },
                //   itemBuilder: (context, Address address) {
                //     return ListTile(
                //       leading: Icon(Icons.location_city),
                //       title: Text(address.addressLine),
                //       subtitle: Text(address.postCode),
                //     );
                //   },
                //   onSuggestionSelected: (Address address) {
                //     _addressLineController.text = address.addressLine;
                //   },
                //   onSaved: (val) => this._paymentAddress.postCode = val,
                // ),
                SizedBox(
                  height: formSpacing,
                ),
                TextFormField(
                  onSaved: (val) => _paymentAddress.addressLine = val,
                  controller: _addressLineController,
                  decoration: InputDecoration(
                    labelText: 'Address Line',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    icon: Icon(Icons.location_city),
                    suffixIcon: IconButton(
                      onPressed: () => _addressLineController.clear(),
                      icon: Icon(Icons.clear),
                    ),
                  ),
                ),
                SizedBox(
                  height: formSpacing,
                ),
                CheckboxListTile(
                  value: rememberInfo,
                  onChanged: (val) {
                    setState(() {
                      rememberInfo = val;
                    });
                  },
                  title: Text('Remember Information'),
                ),
                ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Cancel"),
                      //onPressed: Provider.of<Tabs>(context).close(),
                      onPressed: () {
                        print("Cancel");
                      },
                    ),
                    RaisedButton(
                        // child: loading
                        //     ? SpinKitWave(
                        //         size: 15.0,
                        //       )
                        //     : Text('Process Payment'),
                        // textColor: Theme.of(context).accentTextTheme.button.color,
                        // highlightColor: Theme.of(context).accentColor,
                        // color: Theme.of(context).accentColor,
                        // onPressed: () {
                        //   if (_formKey.currentState.validate()) {
                        //     setState(() {
                        //       loading = true;
                        //     });
                        //     _formKey.currentState.save();
                        //     Timer(Duration(seconds: 4), () {
                        //       Payment payment = new Payment(
                        //           address: _paymentAddress,
                        //           cardDetails: _cardDetails);
                        //       print(payment);
                        //       setState(() {
                        //         loading = false;
                        //       });
                        //       final snackBar =
                        //           SnackBar(content: Text('Payment Proccessed'));
                        //       Scaffold.of(context).showSnackBar(snackBar);
                        //       print('Saved');
                        //     });
                        //   }
                        // },
                        ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Address>> _fetchAddress(String postCode) async {
    // final response = await http.get(
    //     "https://my-json-server.typicode.com/refactord/deep-dive-db/addresses");
    // if (response.statusCode == 200) {
    //   return _searchAddresses(response, postCode);
    // } else {
    throw Exception('Failed to load addresses');
    // }
  }

// ///This should be done on the server side but due to the use of a basic custom JSON server
// /// I'll manually do the search here
// List<Address> _searchAddresses(Response response, String postCode) {
//   Map<String, dynamic> body = json.decode(response.body);
//   var addresses = body[postCode];
//   if (addresses != null) {
//     addresses = (addresses as List).map((a) => Address.fromJson(a)).toList();
//     return addresses;
//   }
//   return null;
// }
}

class FormExampleTabFactory implements ReflectTab.TabFactory {
  @override
  ReflectTab.Tab create() {
    return FormExampleTab();
  }
}