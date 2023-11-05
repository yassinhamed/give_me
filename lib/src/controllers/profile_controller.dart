import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../repository/order_repository.dart';
import '../repository/user_repository.dart';

class ProfileController extends ControllerMVC {
  User user = new User();
  List<Order> recentOrders = [];
  GlobalKey<ScaffoldState> scaffoldKey;

  ProfileController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForUser();
  }

  void listenForUser() {
    getCurrentUser().then((_user) {
      setState(() {
        user = _user;
      });
    });
  }

  void listenForRecentOrders({String message}) async {
    final Stream<Order> stream = await getRecentOrders();
    stream.listen((Order _order) {
      setState(() {
        recentOrders.add(_order);
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S
            .of(state.context)
            .verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    user = new User();
    listenForRecentOrders(
        message: S
            .of(state.context)
            .orders_refreshed_successfuly);
    listenForUser();
  }

  chargeBalance(String code) async {
   return await chargeUserBalance(code);
  }
  launchPage(String url)async{
    Uri uri = Uri.parse(url);
    if(await canLaunchUrl(uri)){
      print("can launch");
      await launchUrl(uri,mode: LaunchMode.externalApplication);
    }else{
      print("cant launch");
    }
  }
  getWhatsappSchema(){
    if (Platform.isAndroid) {
      // add the [https]
      return "https://wa.me/+249118944398/?text=${Uri.parse("السلام عليكم أريد شراء كود الشحن")}"; // new line
    } else {
      // add the [https]
      return "https://api.whatsapp.com/send?phone=249118944398=${Uri.parse("السلام عليكم أريد شراء كود الشحن")}"; // new line
    }
  }
}
