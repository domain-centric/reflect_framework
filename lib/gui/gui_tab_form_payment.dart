import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/domain_objects.dart';

/// Form widgets are stateful widgets
class PaymentForm extends StatefulWidget {
  const PaymentForm({Key? key}) : super(key: key);

  @override
  PaymentFormState createState() => PaymentFormState();
}

class PaymentFormState extends State<PaymentForm> {
  Map<String, bool> validateField = {
    "cardField": false,
    "postCodeField": false
  };
  String? expiryMonth;
  int? expiryYear;
  bool? rememberInfo = false;
  final Address _paymentAddress = Address();
  final CardDetails _cardDetails = CardDetails();
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
          padding: const EdgeInsets.all(formSpacing),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  onSaved: (val) => _cardDetails.cardHolderName = val,
                  decoration: const InputDecoration(
                      labelText: 'Name on card',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      icon: Icon(Icons.account_circle)),
                ),
                const SizedBox(
                  height: formSpacing,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        onSaved: (val) => _cardDetails.cardNumber = val,
                        //autovalidateMode: validateField['cardField'],
                        onChanged: (value) {
                          setState(() {
                            validateField['cardField'] = true;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Card number',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                            icon: Icon(Icons.credit_card)),
                        validator: (String? value) {
                          if (value!.length != 16) {
                            return "Please enter a valid number";
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 120.0,
                        margin: const EdgeInsets.only(left: formSpacing),
                        child: TextFormField(
                          onSaved: (val) =>
                              _cardDetails.securityCode = int.parse(val!),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Security Code',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
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
                              value: val,
                              child: Text(val),
                            );
                          },
                        ).toList(),
                        onChanged: (val) {
                          setState(() {
                            expiryMonth = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Expiry Month',
                          icon: Icon(Icons.calendar_today),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: formSpacing),
                        child: DropdownButtonFormField(
                          onSaved: (dynamic val) =>
                              _cardDetails.expiryYear = val.toString(),
                          value: expiryYear,
                          items: yearsList.map<DropdownMenuItem>(
                            (val) {
                              return DropdownMenuItem(
                                value: val.toString(),
                                child: Text(val.toString()),
                              );
                            },
                          ).toList(),
                          onChanged: (dynamic val) {
                            setState(() {
                              expiryYear = val;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Expiry Year',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: formSpacing,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Post Code',
                    icon: Icon(Icons.location_on),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: formSpacing,
                ),
                TextFormField(
                  onSaved: (val) => _paymentAddress.addressLine = val,
                  controller: _addressLineController,
                  decoration: InputDecoration(
                    labelText: 'Address Line',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    icon: const Icon(Icons.location_city),
                    suffixIcon: IconButton(
                      onPressed: () => _addressLineController.clear(),
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
                const SizedBox(
                  height: formSpacing,
                ),
                CheckboxListTile(
                  value: rememberInfo,
                  onChanged: (val) {
                    setState(() {
                      rememberInfo = val;
                    });
                  },
                  title: const Text('Remember Information'),
                ),
                ButtonBar(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Padding(
                          padding: EdgeInsets.all(15), child: Text("Cancel")),
                      //onPressed: Provider.of<Tabs>(context).close(),
                      onPressed: () {
                        //TODO
                      },
                    ),
                    ElevatedButton(
                      child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text('Process Payment')),
                      //  textColor: Theme.of(context).accentTextTheme.button.color,
                      // highlightColor: Theme.of(context).accentColor,
                      // color: Theme.of(context).accentColor,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          _formKey.currentState!.save();
                          Timer(const Duration(seconds: 4), () {
                            // Payment payment = Payment(
                            //     address: _paymentAddress,
                            //     cardDetails: _cardDetails);
                            // print(payment);
                            setState(() {
                              loading = false;
                            });
                            const snackBar =
                                SnackBar(content: Text('Payment Proccessed'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            //print('Saved');
                          });
                        }
                      },
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
}
