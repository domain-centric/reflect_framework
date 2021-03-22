import 'package:reflect_framework/reflect_annotations.dart';
import 'package:reflect_framework/reflect_meta_service_object.dart';

class Payment {
  Address address;
  CardDetails cardDetails;

  Payment({this.address, this.cardDetails});
}

class CardDetails {
  String cardHolderName;
  String cardNumber;
  String expiryMonth;
  String expiryYear;
  int securityCode;

  CardDetails({this.cardHolderName,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.securityCode});
}

class Address {
  String postCode;
  String addressLine;

  Address({this.postCode, this.addressLine});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postCode: json['postCode'],
      addressLine: json['address'],
    );
  }
}

@ServiceClass()
@ActionMethodPreProcessor(index:11)//TODO remove after test
class PersonService {

  @DomainClass()//TODO remove after test
  @ActionMethodPreProcessor(index:22)//TODO remove after test
  List<Person> allPersons() {
    return [
      Person("James", "Gosling"),
      Person("Eric", "Evans"),
      Person("Martin", "Fowler"),
      Person("Richard", "Pawson"),
      Person("Nils", "ten Hoeve")
    ];
  }

  @DomainClass()//TODO remove after test
  @ActionMethodPreProcessor(index: 33)//TODO remove after test
  List<Person> findPersons(String query) {
    return [
      Person("James", "Gosling"),
      Person("Eric", "Evans"),
      Person("Martin", "Fowler"),
      Person("Richard", "Pawson"),
      Person("Nils", "ten Hoeve")
    ];
  }

}

class Person {
  String givenName;

  @DomainClass()//TODO remove after test
  @ActionMethodPreProcessor(index:111)//TODO remove after test
  String surName;

  @DomainClass()//TODO remove after test
  @ActionMethodPreProcessor(index:222)//TODO remove after test
  String get fullName {
    return givenName ?? "" + " " + surName ?? "".trim();
  }

  Person(this.givenName, this.surName);



}