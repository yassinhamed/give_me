import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/MyOffersWidget.dart';
import '../../generated/l10n.dart';
import '../elements/DrawerWidget.dart';
import '../models/route_argument.dart';
import '../pages/map.dart';
import '../pages/orders.dart';
import '../pages/orders_history.dart';
import 'messages.dart';

// ignore: must_be_immutable
class PagesTestWidget extends StatefulWidget {
  dynamic currentTab;
  DateTime currentBackPressTime;
  RouteArgument routeArgument;
  Widget currentPage = OrdersWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesTestWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 1;
    }
  }

  @override
  _PagesTestWidgetState createState() {
    return _PagesTestWidgetState();
  }
}

class _PagesTestWidgetState extends State<PagesTestWidget> {
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(PagesTestWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      switch (tabItem) {
        case 0:
          widget.currentPage = MyOffersWidget(parentScaffoldKey: widget.scaffoldKey,);
          break;
        case 1:
          widget.currentPage = OrdersHistoryWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage = MessagesWidget(parentScaffoldKey: widget.scaffoldKey,);
          break;
        case 4:
        widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            widget.currentTab = i;
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.person),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.history),
              label: '',
            ),
            BottomNavigationBarItem(
                label: '',
                icon: Container(
                  width: 42,
                  height: 42,
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                    ],
                  ),
                  child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
              icon: new Icon(widget.currentTab == 3 ? Icons.chat : Icons.chat_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(widget.currentTab==4? Icons.location_on : Icons.location_on_outlined),
              label: '',
            ),

          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (widget.currentBackPressTime == null || now.difference(widget.currentBackPressTime) > Duration(seconds: 2)) {
      widget.currentBackPressTime = now;
      Fluttertoast.showToast(msg: S.of(context).tapBackAgainToLeave);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }
}
