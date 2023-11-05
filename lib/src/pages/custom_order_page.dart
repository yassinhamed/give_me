import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets_deliveryboy/src/controllers/order_controller.dart';
import 'package:markets_deliveryboy/src/elements/BlockButtonWidget.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/CustomOrderInfoWidget.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/CustomOrderSingleInfoWidget.dart';
import 'package:markets_deliveryboy/src/elements/CustomTextFeildWidget.dart';
import 'package:markets_deliveryboy/src/helpers/helper.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/delivery_offer.dart';
import 'package:markets_deliveryboy/src/models/order_status.dart';
import 'package:markets_deliveryboy/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../generated/l10n.dart';
import '../models/conversation.dart';
import '../models/media.dart';
import '../models/route_argument.dart';
import '../models/user.dart' as userModel;

class CustomOrderPage extends StatefulWidget {
  final CustomOrder order;

  const CustomOrderPage({Key key, this.order}) : super(key: key);

  @override
  _CustomOrderPageState createState() => _CustomOrderPageState();
}

class _CustomOrderPageState extends StateMVC<CustomOrderPage> {
  OrderController _con;

  _CustomOrderPageState() : super(OrderController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).hintColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          widget.order.orderDetails,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _con.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               CustomOrderInfo(order: widget.order,),
                Row(
                  children: [
                    SizedBox(width:14,),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/Pages",arguments:RouteArgument(id: '4',param: CustomOrder.fromJson({...widget.order.toMap(),"status":{
                            "id":0,
                            "status":"Any"
                          }})));
                        },
                        icon: Icon(Icons.location_on),
                        label: Text('انتقل إلى مكان الطلب')),


                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).accentColor,
                  indent: 30,
                  endIndent: 30,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('قدم عرضك', style: Theme.of(context).textTheme.headline4),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  title: 'سعر التوصيل',
                  onSave: (String value) => _con.deliveryPrice = double.parse(value),
                  activeSuffix: true,
                ),
                CustomTextField(
                  title: 'مدة التوصيل',
                  onSave: (String value) => _con.deliveryTime = value,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: BlockButtonWidget(
                      color: Theme.of(context).accentColor,
                      text: Text(
                        'تقديم',
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.white),
                      ),
                      onPressed: () async{
                        if (_con.formKey.currentState.validate()) {
                          _con.formKey.currentState.save();
                          if ((currentUser.value.balance??0) < (_con.minDelPrice??0)) {
                            Fluttertoast.showToast(
                              msg: 'ليس لديك رصيد كافٍ لتقديم العرض',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 5,
                            );
                          }else if(!currentUser.value.delVerification.verified) {
                            Fluttertoast.showToast(
                              msg: 'لم يتم توثيق حسابك بعد !',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 5,
                            );
                          }
                          else {
                            Navigator.of(context).pushNamed('/Pages',
                                arguments: 0);
                            CustomOrder newOrder = widget.order;
                            newOrder.status.status = Helper.fromEnumToEnglish(
                                customOrderStatus.WaitingForAgree);
                            newOrder.deliveryOffers = DeliveryOffer(
                              price: _con.deliveryPrice,
                              timeInterval: _con.deliveryTime,
                              orderId: widget.order.orderId,
                              customerId: widget.order.userId,
                              deliveryId: currentUser.value.id,
                              deliveryImageUrl: currentUser.value.image.url,
                              deliveryName: currentUser.value.name,
                              deliveryDeviceToken: currentUser.value
                                  .deviceToken,
                              rate: currentUser.value.rate
                            );
                            if(await _con.makeOffer(newOrder)){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تقديم عرضك بنجاح")));
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تعذر تقديم العرض, لقد قمت بالتقدم عليه سابقًا")));
                            }
                          }
                        }
                      }),

                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
