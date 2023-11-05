import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/controllers/order_controller.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/CustomOrderItemWidget.dart';
import 'package:markets_deliveryboy/src/elements/EmptyOrdersWidget.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../repository/user_repository.dart';
import '../PermissionDeniedWidget.dart';
import 'CustomOfferItemWidget.dart';

class MyOffersWidget extends StatefulWidget {
  const MyOffersWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  @override
  StateMVC<MyOffersWidget> createState() => _MyOffersWidgetState();
}

class _MyOffersWidgetState extends StateMVC<MyOffersWidget> {
  OrderController _con;

  _MyOffersWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  initState() {
    super.initState();
    if(isRegisteredAndLogin){
      _con.getDeliveryOffers();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'عروضي',
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body:!isRegisteredAndLogin
          ? PermissionDeniedWidget(): StreamBuilder<QuerySnapshot>(
        stream: _con.myOffers,
        builder: (context, snapshot) {
          if (snapshot != null &&
              snapshot.hasData &&
              snapshot.data.docs.length > 0) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return CustomOfferItem(
                    order:
                        CustomOrder.fromJson(snapshot.data.docs[index].data()),
                  );
                });
          } else if (snapshot != null &&
              snapshot.hasData &&
              snapshot.data.docs.length == 0) {
            return EmptyOrdersWidget();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
