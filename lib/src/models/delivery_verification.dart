import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

import '../repository/user_repository.dart';
import 'address.dart';

class DeliveryVerification {
  String id;
  String name;
  bool verified;

  String frontLicence;
  String backLicence;
  String frontId;
  String backId;
  String face;
  String frontCar;
  String backCar;
  String searchCertificate;
  Address address;
  Timestamp dateBirth;

  DeliveryVerification(
      {this.id,
      this.name,
      this.verified,
      this.frontLicence,
      this.backLicence,
      this.frontId,
      this.backId,
      this.face,
      this.frontCar,
      this.backCar,
      this.searchCertificate,
      this.address,
      this.dateBirth});

  DeliveryVerification.fromJson(Map<String, dynamic> map) {
    id  = currentUser.value.id;
    verified = map['verified'] ?? false;
    name  = currentUser.value.name;
    frontLicence = map['frontLicence'];
    backLicence = map['backLicence'];
    frontId = map['frontId'];
    backId = map['backId'];
    face = map['face'];
    frontCar = map['frontCar'];
    backCar = map['backCar'];
    searchCertificate = map['searchCertificate'];
    address = Address.fromJSON(map['address']??{});
    dateBirth = map['dateBirth'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['id'] = currentUser.value.id;
    map['name'] = currentUser.value.name;
    map['verified'] = verified ?? false;
    map['address'] = address.toMap();
    map['dateBirth'] = dateBirth;
    map['frontLicence'] = frontLicence;
    map['backLicence'] = backLicence;
    map['frontId'] = frontId;
    map['backId'] = backId;
    map['face'] = face;
    map['frontCar'] = frontCar;
    map['backCar'] = backCar;
    map['searchCertificate'] = searchCertificate;

    return map;
  }

  bool isValid() {
    return id != null
        && name != null
        && face != null
        && verified != null
        && frontLicence != null
        && backLicence != null
        && frontId != null
        && backId != null
        && frontCar != null
        && backCar != null
        && searchCertificate != null
        && address != null
        && address.address != ""
        && dateBirth != null;
  }
}
