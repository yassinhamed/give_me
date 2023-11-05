import 'delivery_verification.dart';
import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  Media image;
  bool verifiedPhone;
  String verificationId;
  // used for indicate if client logged in or not
  bool auth;
  num balance;
  double rate;
  DeliveryVerification delVerification;
//  String role;

  User(
      {this.id,
        this.name,
        this.email,
        this.password,
        this.apiToken,
        this.deviceToken,
        this.phone,
        this.verifiedPhone,
        this.verificationId,
        this.address,
        this.bio,
        this.image,
        this.auth,
        this.delVerification,
      });

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      try {
        verifiedPhone = jsonMap['custom_fields']['verifiedPhone']['view'] == '1' ? true : false;
      } catch (e) {
        verifiedPhone = false;
      }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    map["verifiedPhone"] = verifiedPhone;
    return map;
  }
  Map toRestrictMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["thumb"] = image?.thumb;
    map["device_token"] = deviceToken;
    return map;
  }
  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }
}
