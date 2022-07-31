import '../core/annotations.dart';

class Payment {
  Address? address;
  CardDetails? cardDetails;

  Payment({this.address, this.cardDetails});
}

class CardDetails {
  String? cardHolderName;
  String? cardNumber;
  String? expiryMonth;
  String? expiryYear;
  int? securityCode;

  CardDetails(
      {this.cardHolderName,
      this.cardNumber,
      this.expiryMonth,
      this.expiryYear,
      this.securityCode});
}

class Address {
  String? postCode;
  String? addressLine;

  Address({this.postCode, this.addressLine});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postCode: json['postCode'],
      addressLine: json['address'],
    );
  }
}

@ServiceClass()
@ActionMethodParameterProcessor(index: 11) //TODO remove after test
class PersonService {
  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 22) //TODO remove after test
  List<Person> allPersons() {
    return [
      Person.fromNames("James", "Gosling"),
      Person.fromNames("Eric", "Evans"),
      Person.fromNames("Martin", "Fowler"),
      Person.fromNames("Richard", "Pawson"),
      Person.fromNames("Nils", "ten Hoeve")
    ];
  }

  @DomainClass() //TODO remove after test
  @ActionMethodParameterFactory()
  @ActionMethodParameterProcessor(index: 33) //TODO remove after test
  List<Person> findPersons(String query) {
    return [
      Person.fromNames("James", "Gosling"),
      Person.fromNames("Eric", "Evans"),
      Person.fromNames("Martin", "Fowler"),
      Person.fromNames("Richard", "Pawson"),
      Person.fromNames("Nils", "ten Hoeve")
    ];
  }

  @ExecutionMode.firstEditParameter
  void edit(Person person) {}

  @ExecutionMode.firstAskConformation
  void remove(Person person) {}

  @ExecutionMode.firstEditParameter
  @ActionMethodParameterFactory()
  void addNew(Person person) {}

  @ExecutionMode.directly
  void sendEmail(Person person) {}

  //Test: action method without parameter
  void logout() {}
}

class Person {
  String? givenName;

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 111) //TODO remove after test
  String? surName;

  @DomainClass() //TODO remove after test
  @ActionMethodParameterProcessor(index: 222) //TODO remove after test
  String get fullName {
    return "${givenName ?? ""} ${surName ?? ""}";
  }

  Person();

  Person.fromNames(this.givenName, this.surName);
}
