import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ProfileAvatarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

class ProfileWidget extends StatefulWidget {

  ProfileWidget({Key key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  ProfileController _con;
  TextEditingController _textController;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    if(isRegisteredAndLogin) {
      _textController = TextEditingController();
      _con.listenForRecentOrders();
    }
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:!isRegisteredAndLogin
          ? SizedBox(height: 0,): FloatingActionButton.extended(icon:Icon(Icons.add),onPressed: () {
        AlertDialog alertDialog = AlertDialog(
          title: Text('شحن الرصيد'),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
            child: TextField(
              controller:_textController,
              decoration: InputDecoration(
                hintText: 'أدخل كود الرصيد',
                label: Text('الكود'),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text('إلغاء')),
            TextButton(onPressed: ()async{
             if(_textController.text!= null && _textController.text.isNotEmpty){
               String result = await _con.chargeBalance(_textController.text.trim());
               Navigator.of(context).pop();
               _textController.clear();
               setState(() { });
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
             }
            }, child: Text('موافق')),
          ],
        );
        showDialog(context: context, builder: (context)=>alertDialog);
      }, label: Text('إضافة رصيد')),
      appBar: AppBar(
        leading: new IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme
            .of(context)
            .accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S
              .of(context)
              .profile,
          style: Theme
              .of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3, color: Theme
              .of(context)
              .primaryColor)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme
              .of(context)
              .primaryColor, labelColor: Theme
              .of(context)
              .hintColor),
        ],
      ),
      key: _con.scaffoldKey,
      body: !isRegisteredAndLogin
          ? PermissionDeniedWidget()
          : SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          children: <Widget>[
            ProfileAvatarWidget(user: _con.user),
            SizedBox(height: 10,),
            Text("اطلب كود الشحن من هنا",style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.black),),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed:()=>_con.launchPage("https://www.facebook.com/Delivery.GM/") , icon: Icon(Icons.facebook,color: Colors.blue,size: 37,)),
                IconButton(onPressed:()=>_con.launchPage("https://www.instagram.com/invites/contact/?i=1nljrzh0z66jf&utm_content=cxtda8a") , icon: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/img/instagram.png"),
                    ),
                  ),
                )),
                IconButton(onPressed:()=>_con.launchPage(_con.getWhatsappSchema()) , icon: Icon(Icons.whatsapp,color: Colors.green,size: 35,)),
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              leading: Icon(
                Icons.person,
                color: Theme
                    .of(context)
                    .hintColor,
              ),
              title: Text(
                S
                    .of(context)
                    .about,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _con.user.bio ?? 'user bio',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText2,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              leading: Icon(
                Icons.shopping_basket,
                color: Theme
                    .of(context)
                    .hintColor,
              ),
              title: Text(
                S
                    .of(context)
                    .recent_orders,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline4,
              ),
            ),
            _con.recentOrders.isEmpty
                ? CircularLoadingWidget(height: 200)
                : ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: _con.recentOrders.length,
                itemBuilder: (context, index) {
                  var _order = _con.recentOrders.elementAt(index);
                  return OrderItemWidget(
                      expanded: index == 0 ? true : false, order: _order);
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 20);
                }),
          ],
        ),
      ),
    );
  }
}
