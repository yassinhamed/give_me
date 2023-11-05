import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/DoneOrderWidget.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/done_order.dart';
import '../repository/user_repository.dart';

class OrdersHistoryWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersHistoryWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersHistoryWidgetState createState() => _OrdersHistoryWidgetState();
}

class _OrdersHistoryWidgetState extends StateMVC<OrdersHistoryWidget>
    with SingleTickerProviderStateMixin {
  OrderController _con;

  _OrdersHistoryWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    if (isRegisteredAndLogin) {
      _con.tabController = TabController(length: 2, vsync: this);
      _con
          .listenForOrdersHistory()
          .then((value) async => await _con.getDoneOrders());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
            onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
          ),
          bottom: !isRegisteredAndLogin
              ? null
              : TabBar(
                  controller: _con.tabController,
                  tabs: [
                    Tab(
                      text: 'المخصصة',
                    ),
                    Tab(
                      text: 'العامة',
                    ),
                  ],
                ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).orders_history,
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
        body: !isRegisteredAndLogin
            ? PermissionDeniedWidget()
            : TabBarView(controller: _con.tabController, children: [
                StreamBuilder<QuerySnapshot>(
                    stream: _con.doneOrders,
                    builder: (context, snapshot) {
                      if (snapshot != null &&
                          snapshot.hasData &&
                          snapshot.data.docs.length > 0) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return DoneOrderWidget(
                              doneOrder: DoneOrder.fromJson(
                                  snapshot.data.docs[index].data()),
                            );
                          },
                          itemCount: snapshot.data.docs.length,
                        );
                      } else if (snapshot != null &&
                          snapshot.hasData &&
                          snapshot.data.docs.length == 0) {
                        return EmptyOrdersWidget(
                          ratio: 0.5,
                          alignment: Alignment.centerRight,
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
                Scaffold(
                  body: RefreshIndicator(
                    onRefresh: _con.refreshOrdersHistory,
                    child: _con.orders.isEmpty
                        ? EmptyOrdersWidget(
                            ratio: 0.5,
                            alignment: Alignment.centerLeft,
                          )
                        : ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _con.orders.length,
                            itemBuilder: (context, index) {
                              var _order = _con.orders.elementAt(index);
                              return OrderItemWidget(
                                  expanded: index == 0 ? true : false,
                                  order: _order);
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 20);
                            },
                          ),
                  ),
                )
              ]));
  }
}
