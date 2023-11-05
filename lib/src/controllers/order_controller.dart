import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:markets_deliveryboy/src/helpers/helper.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/delivery_offer.dart';
import 'package:markets_deliveryboy/src/models/order_status.dart';
import 'package:markets_deliveryboy/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:rxdart/rxdart.dart';

import '../../generated/l10n.dart';
import '../models/done_order.dart';
import '../models/order.dart';
import '../repository/notification_repository.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  int currentStep = 0;
  TabController tabController;
  List<Order> orders = <Order>[];
  Stream<QuerySnapshot> doneOrders ;
  List<String> steps = [];
  Stream<QuerySnapshot> myOffers;
  Stream<QuerySnapshot> customOrders;
  final customOrderCollection = 'custom_order';
  double deliveryPrice;
  String deliveryTime;
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<FormState> formKey;
  final List<String> orderStatusNotifications = [
    'جاري تجهيز الطلب...',
    'طلبك جاهز الآن!',
    'طلبك في الطريق',
    'تم تسليم الطلب يرجى تأكيد العملية',
  ];
   double minDelPrice= 0;
  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.formKey = new GlobalKey<FormState>();
    getMinDeliveryPrice();
    initSteps();
  }

  Future<void> listenForOrders({String message}) async {
    print("----------------- lestenint for orders");
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print("--------------- error loading order $a");
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
    print("orders length: ${orders.length}");
  }

  Future<void> listenForOrdersHistory({String message}) async {
    print("----------------- listening for history orders");
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print("--------------- error loading history order $a");
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
    print("history orders length: ${orders.length}");

  }

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(
        message: S.of(state.context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    print("-------------------- refreshing order");
    orders.clear();
    await listenForOrders(message: S.of(state.context).order_refreshed_successfuly);
    print("--------------- orders length: ${orders.length}");
  }

  // About Custom Orders

  initSteps() async {
    steps = List.generate(
        customOrderStatus.values.length - 2,
        (index) => Helper.fromEngToArabic(
            Helper.fromEnumToEnglish(customOrderStatus.values[index+1])));
  }

  getDoneOrders()async{
    try {
      doneOrders = await FirebaseFirestore.instance
          .collection('done_orders')
          .doc(currentUser.value.id)
          .collection('my_orders')
          .orderBy('doneTime', descending: true)
          .snapshots();
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }
  Future<void> getPublishedOrders() async {
    try {
      Stream<QuerySnapshot> publishedOrders = await FirebaseFirestore.instance
          .collection('published_orders')
          .orderBy('publishingTime', descending: true).limit(30)
          .snapshots();
      setState(() {
        customOrders = publishedOrders;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getDeliveryOffers() async {
    try {
      myOffers = await FirebaseFirestore.instance
          .collection('deliveries_offers')
          .doc(currentUser.value.id)
          .collection('my_offers')
          .orderBy('publishingTime', descending: true)
          .snapshots();
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }
  getMinDeliveryPrice()async{
    DocumentSnapshot<Map<String, dynamic>> settings;
    try {
      settings =
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('settings')
          .get();
    }catch(e){
      print(e);
    }
    minDelPrice = double.parse((settings['min']??0).toString()) *-1;

  }

  Future<bool> makeOffer(CustomOrder order) async {
    try {
      if (await isApplyForThisOrder(order.orderId,order.deliveryOffers.deliveryId,order.userId)){
        return false;
      }
      await FirebaseFirestore.instance
          .collection('deliveries_offers')
          .doc(currentUser.value.id)
          .collection('my_offers')
          .doc(order.orderId)
          .set(order.toMap());
      await addOfferToOrder(order.deliveryOffers);
     await sendNotification(
        title: 'عرض جديد على طلبك',
        body: order.deliveryOffers.price.toString() +
            ' جنيه - ' +
            order.deliveryOffers.timeInterval,
        deviceToken: order.deviceToken,
        type: 'order',
      );
    return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future<bool> isApplyForThisOrder(String orderId,String deliveryId,String customerId)async{
    bool isApply = false;
    DocumentSnapshot order = await FirebaseFirestore.instance.collection('custom_order').doc(customerId).collection('user_custom_orders').doc(orderId).get();
    Map<String ,dynamic> data = order.data();
    List<dynamic> offers = data['deliveryOffers'];
    offers.forEach((offer) {
     if(offer['deliveryId'] == deliveryId){
       isApply = true;
       return;
     }
    });
    return isApply;
  }
  Future<void> addOfferToOrder(DeliveryOffer offer) async {
    try {
      DocumentSnapshot oldOrder = await FirebaseFirestore.instance
          .collection('custom_order')
          .doc(offer.customerId)
          .collection('user_custom_orders')
          .doc(offer.orderId)
          .get();
      Map<String ,dynamic> data = oldOrder.data();
      List<dynamic> offers = data['deliveryOffers'];
      offers.add(offer.toMap());
      await FirebaseFirestore.instance
          .collection('custom_order')
          .doc(offer.customerId)
          .collection('user_custom_orders')
          .doc(offer.orderId)
          .update({'deliveryOffers': offers});
    } catch (e) {
      print(e);
    }
  }

  increaseOfferState(DeliveryOffer offer, String deviceToken) async {
    if (currentStep<1){
      Fluttertoast.showToast(
        msg: "لم يتم قبول عرضك بعد",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        //backgroundColor: Theme.of(state.context).backgroundColor,
        //textColor: Theme.of(state.context).hintColor,
        timeInSecForIosWeb: 5,
      );
      return;
    }
    if (currentStep < steps.length - 2) {
      currentStep++;
      setState(() {});
      await changeOfferState(offer, deviceToken);
    }
  }

/*
  decreaseOfferState(DeliveryOffer offer) async {
    if (currentStep > -1) {
      if (currentStep == 0) {
        deleteOffer(offer);
      } else {
        currentStep--;
        await changeOfferState(offer);
        setState(() {});
      }
    }
  }
*/

  changeOfferState(DeliveryOffer offer, String deviceToken) async {
    Map<String, dynamic> map = {
      'status': {
        'id': currentStep + 1,
        'status':
            Helper.fromEnumToEnglish(customOrderStatus.values[currentStep+1])
      }
    };
    try {
      await FirebaseFirestore.instance
          .collection('custom_order')
          .doc(offer.customerId)
          .collection('user_custom_orders')
          .doc(offer.orderId)
          .update(map);
      await FirebaseFirestore.instance
          .collection('deliveries_offers')
          .doc(offer.deliveryId)
          .collection('my_offers')
          .doc(offer.orderId)
          .update(map);
      if (currentStep > 1 && currentStep < 6) {
        sendNotification(
          title: orderStatusNotifications[currentStep-2],
          body: "تتبع طلبك",
          deviceToken: deviceToken,
          type: 'order',
        );
      }
    } catch (e) {
      print(e);
    }
  }

  deleteOffer(DeliveryOffer offer) {
    print('offer deleted');
  }
/* getPublishedOrders() async {
    customOrders = Stream.empty();
    List<QuerySnapshot> customOrdersList = [];
    try {
      */ /* Stream<int> s1 = Stream.fromIterable([1,2,3]);
      Stream<int> s2 = Stream.fromIterable([4,5,6]);
      List<int> list = await s1.toList();
      list.addAll(await s2.toList());
      Stream<int> s3 = Stream.fromIterable(list);
      s3.listen((event) {print(event);});*/ /*

      QuerySnapshot usersDocs = await FirebaseFirestore.instance
          .collection(customOrderCollection)
          .get();

      for (QueryDocumentSnapshot doc in usersDocs.docs) {
        if(doc.id !='24'&& doc.id !='26'){
        print('-----------------\nid: ${doc.id}');
         await FirebaseFirestore.instance
            .collection(customOrderCollection)
            .doc(doc.id)
            .collection('user_custom_orders')
            .snapshots().listen((QuerySnapshot event) async{
          await customOrdersList.add( event);
        }).onError((v)=>print('error: $v'));
        //customOrders = await Rx.concat([userOrders,customOrders]);
      }}

      print('customOrders List length: ${customOrdersList.length}');
    } catch (e) {
      print('---------error getting custom orders:\n$e');
    } finally {
      customOrders = await Stream.fromIterable(customOrdersList);
      setState(() {});
    }
  }*/
//print('first snapshots: ${customOrders.first.then((value) => value.docs.first.id.length)}');

}
