
import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_order_model.dart';
import 'order_status.dart';

class DoneOrder{
  String orderId;
  String customerName;
  String userId;
  String customerId;
  OrderStatus status;
  Timestamp doneTime;
  String marketName;
  String details;
  String price;
  String timeInterval;
  DoneOrder();
   DoneOrder.fromJson(Map<String,dynamic> map){
    orderId = map['orderId'];
    userId = map['userId'];
    customerId = map['customerId'];
    customerName = map['customerName'];
    status = OrderStatus.fromJSON(map['status']);
    doneTime = map['doneTime'];
    marketName = map['marketName'];
    details = map['details'];
    price = map['price'];
    timeInterval = map['timeInterval'];
  }
  DoneOrder.fromCustomOrder(CustomOrder customOrder){
     orderId = customOrder.orderId;
     userId = customOrder.deliveryOffers.deliveryId;
     customerId = customOrder.userId;
     customerName = customOrder.userName;
     status = customOrder.status;
     doneTime = Timestamp.now();
     marketName = customOrder.marketName;
     details = customOrder.orderDetails;
     price = customOrder.deliveryOffers.price.toString();
     timeInterval = customOrder.deliveryOffers.timeInterval;
  }
  Map<String,dynamic> toMap(){
    Map<String, dynamic> map = {};
    map['orderId'] = orderId;
    map['userId'] = userId;
    map['customerId'] = customerId;
    map['customerName'] = customerName;
    map['status'] = status.toMap();
    map['doneTime'] = doneTime;
    map['marketName'] = marketName;
    map['details'] = details;
    map['price'] = price;
    map['timeInterval'] = timeInterval;
    return map;
  }


}