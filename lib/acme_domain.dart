import 'reflect_annotations.dart';

//library acme_domain

class Product {
  // We add a Translation annotation here otherwise the Reflect application would show this property as 'Ups code' instead of 'UPS code'
  // This will create key: 'acmeDomain.product.upsCode' with English value 'UPS code'
  @Translation(englishText: 'UPS code')
  String get upsCode {
    return '<a UPS code>'; //for example only
  }

  // We add a Translation annotation here so that we can use a translatable text in our text, with a key that refers to this property
  // this will create key: 'acmeDomain.product.availability.soldOut' with English value 'Sold out' to be used in the code
  @Translation(keySuffix: 'soldOut', englishText: 'Sold out')
  String get availability {
    return Translations.forThisApp()
        .acmeDomain
        .product
        .availability
        .soldOut; //to demonstrate how to use the translation
  }
}

//TODO remove when this class can be generated
//TODO generate in Translations lib
abstract class Translations {
  static Translations forThisApp() {
    //TODO get Translations implementation based on locale with dart.io package using: Platform.localeName
    return TranslationsEn();
  }

  _AcmeDomain get acmeDomain;
}

abstract class _AcmeDomain {
  _AcmeDomainProduct get product;
}

abstract class _AcmeDomainProduct {
  _AcmeDomainProductAvailability get availability;
}

abstract class _AcmeDomainProductAvailability {
  String get soldOut;
}

//TODO generate in TranslationsEn lib
class TranslationsEn extends Translations {
  @override
  _AcmeDomain get acmeDomain => _AcmeDomainEn();
}

class _AcmeDomainEn extends _AcmeDomain {
  @override
  _AcmeDomainProduct get product => _AcmeDomainProductEn();
}

class _AcmeDomainProductEn extends _AcmeDomainProduct {
  @override
  _AcmeDomainProductAvailability get availability =>
      _AcmeDomainProductAvailabilityEn();
}

class _AcmeDomainProductAvailabilityEn extends _AcmeDomainProductAvailability {
  @override
  String get soldOut => 'Sold out';
}
