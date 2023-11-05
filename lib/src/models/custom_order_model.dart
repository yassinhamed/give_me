import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:markets_deliveryboy/src/models/address.dart';
import 'package:markets_deliveryboy/src/models/order_status.dart';

import 'delivery_offer.dart';

class CustomOrder {
  String userId;
  String orderId;
  DeliveryOffer deliveryOffers;
  String marketName;
  String orderDetails;
  Address marketAddress;
  Address customerAddress;
  Timestamp publishingTime;
  OrderStatus status;
  String deviceToken;
  String userName;
  String userImageUrl;
  CustomOrder(
      {this.userId,
        this.orderId,
        this.deliveryOffers,
        this.marketName,
        this.orderDetails,
        this.marketAddress,
        this.customerAddress,
        this.publishingTime,
        this.status,
        this.userName,
        this.userImageUrl
      });



  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['userId'] = userId;
    map['orderId'] = orderId;
    map['deliveryOffers'] = deliveryOffers.toMap();
    map['marketName'] = marketName;
    map['orderDetails'] = orderDetails;
    map['marketAddress'] = marketAddress.toMap();
    map['customerAddress'] = customerAddress.toMap();
    map['publishingTime'] = publishingTime;
    map['status'] = status.toMap();
    map['device_token'] = deviceToken;
    map['userName'] = userName;
    map['userImageUrl'] = userImageUrl;
    return map;
  }

  CustomOrder.fromJson(Map<String, dynamic> map) {
    userId = map['userId'];
    orderId = map['orderId'];
    deliveryOffers = map['deliveryOffers'] is Map?DeliveryOffer.fromJson(map['deliveryOffers']):DeliveryOffer();
    marketName = map['marketName']??'';
    orderDetails = map['orderDetails'];
    marketAddress = Address.fromJSON(map['marketAddress']);
    customerAddress = Address.fromJSON( map['customerAddress']);;
    publishingTime = map['publishingTime'];
    status = OrderStatus.fromJSON(map['status']);
    deviceToken = map['device_token'];
    userName = map['userName'];
    userImageUrl = map[userImageUrl];
  }
/* CustomOrder.fromCustomOrder(
      {CustomOrder order, String price, String timeInterval}){
    userId = order.user.id;
    orderId = order.id;
    this.price = price;
    this.timeInterval = timeInterval;
    marketName = order.market.name;
    orderDetails = order.details;
    marketAddress = order.market.address;
    customerAddress = order.user.address;
    publishingTime = order.dateTime;
    status = order.orderStatus;
  }*/
}
