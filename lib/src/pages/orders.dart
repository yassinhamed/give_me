
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/CustomOrderItemWidget.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> with SingleTickerProviderStateMixin {
  OrderController _con;

  _OrdersWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    if (isRegisteredAndLogin) {
      print("---------- yes, registered");
      _con.tabController = TabController(length: 2, vsync: this);
      _con.listenForOrders();
      _con.getPublishedOrders();

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('orders page rebuilt..........');
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        bottom:!isRegisteredAndLogin
            ? null: TabBar(tabs: [

          Tab(text: 'المخصصة',),
          Tab(text: 'العامة',),

        ],
          controller: _con.tabController,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).orders,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body:!isRegisteredAndLogin
          ? PermissionDeniedWidget() :TabBarView(
        controller: _con.tabController,
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: _con.customOrders,
              builder: (BuildContext context, snapshot) {
                if (snapshot != null && snapshot.hasData &&snapshot.data.docs.length>0) {
                  print('snapshot: ${snapshot.data.docs.length}');
                  return ListView.separated(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, index) =>
                    snapshot.data.docs[index]!=null?CustomOrderItemWidget(
                      order: CustomOrder.fromJson(snapshot.data.docs[index].data()),
                    ):SizedBox(),
                    separatorBuilder: (context, index) => SizedBox(
                      height: 20,
                    ),
                  );
                }else if (snapshot != null && snapshot.hasData &&snapshot.data.docs.length==0){
                  return EmptyOrdersWidget(ratio: 0.5,alignment: Alignment.centerRight,);
                }
                return Center(child: CircularProgressIndicator());
              }) ,
          RefreshIndicator(
            onRefresh: _con.refreshOrders,
            child:
            _con.orders.isEmpty
                ?  EmptyOrdersWidget(ratio: 0.5,alignment: Alignment.centerLeft)
                : ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: _con.orders.length,
              itemBuilder: (context, index) {
                var _order = _con.orders.elementAt(index);
                return OrderItemWidget(
                    expanded: index == 0 ? true : false, order: _order);
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 20);
              },
            ),
          ),
        ],
      ),
    );
  }
}
