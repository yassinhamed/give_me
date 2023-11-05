import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/delivery_verification.dart';
import '../models/media.dart';
import '../models/user.dart';
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<userModel.User> currentUser = new ValueNotifier(userModel.User());

bool get isRegisteredAndLogin {
  return currentUser.value.apiToken != null;
}

getDeliveryVerification() async {
  print("getting delivery verification");
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("delivery_docs")
        .doc(currentUser.value.id)
        .get();
    DeliveryVerification deliveryVerification =
        DeliveryVerification.fromJson(doc.data() ?? {});
    if (deliveryVerification.isValid()) {
      currentUser.value.delVerification = deliveryVerification;
      currentUser.value.image = Media(
          id: currentUser.value.id,
          thumb: currentUser.value.delVerification.face,
          url: currentUser.value.delVerification.face);
      print(
          "---------- delivery verifications: ${deliveryVerification.toMap()}");
    } else {
      currentUser.value.delVerification = DeliveryVerification.fromJson({});
    }
  } catch (e) {
    print(e);
  }
}

Future<num> getUserBalance() async {
  try {
    DocumentSnapshot userBalance = await FirebaseFirestore.instance
        .collection('drivers_balances')
        .doc(currentUser.value.id)
        .get();
    Map<String, dynamic> data = userBalance.data();
    if (data != null && data['balance'] != null) {
      currentUser.value.balance = double.parse(data['balance'].toString());
    } else {
      currentUser.value.balance = 0.0;
    }
  } catch (e) {
    print(e);
  }
  return currentUser.value.balance;
}

Future<num> getUserRating() async {
  try {
    DocumentSnapshot userBalance = await FirebaseFirestore.instance
        .collection('drivers_balances')
        .doc(currentUser.value.id)
        .get();
    Map<String, dynamic> data = userBalance.data();
    if (data != null && data['rating'] != null) {
      currentUser.value.rate = data['rating']['rate'];
    } else {
      currentUser.value.rate = 0.0;
    }
  } catch (e) {
    print(e);
  }
  return currentUser.value.rate;
}

Future<String> chargeUserBalance(String code) async {
  double value;
  String message;
  try {
    DocumentSnapshot prevCodes = await FirebaseFirestore.instance
        .collection('charging_codes')
        .doc('codes')
        .get();
    Map<String, dynamic> _codes = Map.from(prevCodes.data());
    if (_codes.keys.contains(code)) {
      value = double.parse(_codes[code].toString());
      _codes.remove(code);
      await FirebaseFirestore.instance
          .collection('charging_codes')
          .doc('codes')
          .set(_codes);
      _setUserBalance(currentUser.value.balance + value);
      currentUser.value.balance = currentUser.value.balance + value;
      message = 'تمت عملية الشحن بنجاح';
    } else {
      message = 'الرمز خاطئ, أدخل رمزًا صحيحًا';
    }
  } catch (e) {
    print("--------error with charging code: $e");
    print(StackTrace.current);
    message = "حدث خطأ ما, أعد المحاولة مرة أخرى";
  }
  return message;
}

_setUserBalance(double value) async {
  var prevDoc = await FirebaseFirestore.instance
      .collection('drivers_balances')
      .doc(currentUser.value.id)
      .get();
  if (prevDoc.exists) {
    await FirebaseFirestore.instance
        .collection('drivers_balances')
        .doc(currentUser.value.id)
        .update({'balance': value});
  } else {
    await FirebaseFirestore.instance
        .collection('drivers_balances')
        .doc(currentUser.value.id)
        .set({'balance': value});
    ;
  }
}

Future<userModel.User> login(userModel.User user) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}login';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.post(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<userModel.User> register(userModel.User user) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}register';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.post(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value =
        userModel.User.fromJSON(json.decode(response.body)['data']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<bool> resetPassword(userModel.User user) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.post(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  // save device token before sing out
  String _tempDeviceToken = currentUser.value.deviceToken;
  await FirebaseMessaging.instance
      .unsubscribeFromTopic("driver")
      .catchError((e) => print("-------Error when unsubscribe to topic $e"))
      .then((value) => print("----------- done unsubscribe to topic"));
  await FirebaseAuth.instance.signOut();
  currentUser.value = new userModel.User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  // reassign device token
  currentUser.value.deviceToken = _tempDeviceToken;
}

void setCurrentUser(String jsonString) async {
  try {
    if (json.decode(jsonString)['data'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'current_user', json.encode(json.decode(jsonString)['data']));
      print("seccess");
      print(json.decode(jsonString)['data']);
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: jsonString));
    throw new Exception(e);
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<userModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (prefs.containsKey('current_user')) {
    userModel.User user =
        userModel.User.fromJSON(json.decode(prefs.get('current_user')));
    currentUser.value = user;
    currentUser.value.auth = true;
    await getUserBalance();
    await getUserRating();
    await getDeliveryVerification();
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard =
        CreditCard.fromJSON(json.decode(await prefs.get('credit_card')));
  }
  return _creditCard;
}

Future<userModel.User> update(userModel.User user) async {
  final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.post(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  setCurrentUser(response.body);
  currentUser.value =
      userModel.User.fromJSON(json.decode(response.body)['data']);
  await getUserBalance();
  await getUserRating();
  await getDeliveryVerification();
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  userModel.User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=is_default&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Address.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Stream.value(new Address.fromJSON({}));
  }
}

Future<Address> addAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  try {
    final response = await client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}

Future<Address> updateAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  try {
    final response = await client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}

Future<Address> removeDeliveryAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  try {
    final response = await client.delete(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}
