

import 'package:markets_deliveryboy/src/repository/user_repository.dart';

class DeliveryOffer{
  String orderId;
  String deliveryId;
  String customerId;
  String deliveryName;
  String deliveryImageUrl;
  num price;
  String timeInterval;
  String deliveryDeviceToken;
  double rate;
  DeliveryOffer(
      {this.orderId,
      this.deliveryId,
      this.customerId,
      this.deliveryName,
      this.deliveryImageUrl,
      this.price,
      this.timeInterval,
        this.deliveryDeviceToken,
        this.rate
      });



  Map<String,dynamic> toMap(){
    Map<String,dynamic> map ={};
    map['orderId'] = this.orderId;
    map['deliveryId'] = this.deliveryId;
    map['device_token'] = deliveryDeviceToken;
    map['customerId'] = this.customerId;
    map['deliveryName'] = this.deliveryName;
    map['deliveryImageUrl'] = this.deliveryImageUrl;
    map['price'] = this.price;
    map['timeInterval'] = this.timeInterval;
    map['rate'] = this.rate??0.0;
    return map;
  }
  DeliveryOffer.fromJson(Map<String,dynamic> map){
    this.orderId = map['orderId'];
    this.deliveryId = map['deliveryId'];
    this.customerId = map['customerId'];
    this.deliveryName = map['deliveryName'];
    this.deliveryImageUrl = map['deliveryImageUrl'];
    this.price = map['price'];
    this.timeInterval = map['timeInterval'];
    this.deliveryDeviceToken = map['device_token'];
    this.rate = map['rate']??0.0;
  }
}