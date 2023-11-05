import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/controllers/order_controller.dart';
import 'package:markets_deliveryboy/src/elements/custom_order_elements/CustomOrderInfoWidget.dart';
import '../../helpers/helper.dart';
import '../../models/conversation.dart';
import '../../models/custom_order_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../models/media.dart';
import '../../models/route_argument.dart';
import '../../models/user.dart' as userModel;
import '../../repository/settings_repository.dart';
import '../../repository/user_repository.dart';
import 'CustomOrderSingleInfoWidget.dart';

class OfferPage extends StatefulWidget {
  final CustomOrder order;

  const OfferPage({Key key, this.order}) : super(key: key);

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends StateMVC<OfferPage> {
  OrderController _con;

  _OfferPageState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    //print(widget.order.toMap()['status']);
    _con.currentStep = int.tryParse(widget.order.status.id) - 1;
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
        actions: [
          SizedBox(
            width: 10,
          ),
        int.parse(widget.order.status.id)>1&&int.parse(widget.order.status.id)<7
              ? IconButton(
                  onPressed: () {
                    userModel.User user = currentUser.value;
                    userModel.User customer = userModel.User(
                        id: widget.order.userId,
                        name: widget.order.userName,
                        deviceToken: widget.order.deviceToken,
                        image: Media(thumb: widget.order.userImageUrl));
                    Navigator.of(context).pushNamed('/Chat',
                        arguments: RouteArgument(
                            param: new Conversation(
                          [user, customer],
                          visibleToUsers: [user.id, customer.id],
                          name: customer.name,
                          id: Helper.getConversationIdWithClient(customer.id),
                        )));
                  },
                  icon: Icon(
                    Icons.message,
                    color: Theme.of(context).accentColor,
                  ))
              : SizedBox(),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomOrderInfo(
                order: widget.order,
              ),
              OrderSingleInfo(
                title: 'السعر',
                details: widget.order.deliveryOffers.price.toString() + ' جنيه',
              ),
              OrderSingleInfo(
                title: 'مدة التوصيل',
                details: widget.order.deliveryOffers.timeInterval,
              ),
              SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  SizedBox(width:14,),
                  TextButton.icon(
                      onPressed: () async{

                        if (Platform.isAndroid) {
                          // AndroidIntent intent = AndroidIntent(
                          //   action: 'action_view',
                          //   data: 'https://play.google.com/store/apps/details?'
                          //       'id=com.google.android.apps.myapp',
                          //   arguments: {'authAccount': currentUser.value.email},
                          // );
                          // await intent.launch();

                          AndroidIntent mapIntent = AndroidIntent(
                              action: 'action_view',
                              package: 'com.google.android.apps.maps',
                              data: 'google.navigation:q=${_con.currentStep<4?widget.order
                                  .marketAddress.latitude:widget.order.customerAddress.latitude},${_con.currentStep<4?widget.order
                                  .marketAddress.longitude:widget.order.customerAddress.longitude}'
                          );
                         await mapIntent.launch();
                        }else{
                          Navigator.of(context).pushNamed("/Pages",arguments:RouteArgument(id: '4',param: CustomOrder.fromJson({...widget.order.toMap(),"status":{
                            "id":_con.currentStep+1,
                            "status":"Any"
                          }})));
                        }
                      },
                      icon: Icon(Icons.location_on),
                      label: Text(_con.currentStep < 4?'انتقل إلى مكان الطلب':'انتقل إلى مكان التسليم')),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Stepper(
                  physics: ClampingScrollPhysics(),
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controlsDetails) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: controlsDetails.currentStep < 5
                            ? ElevatedButton(
                                child: Text('متابعة'),
                                onPressed: () => _con.increaseOfferState(
                                    widget.order.deliveryOffers,
                                    widget.order.deviceToken),
                              )
                            : controlsDetails.currentStep >5?SizedBox():Text("بانتظار تأكيد الزبون"));
                  },
                  currentStep: _con.currentStep,
                  steps: _con.steps
                      .map((String key) => Step(
                          isActive: _con.currentStep >= _con.steps.indexOf(key),
                          state: _con.currentStep >= _con.steps.indexOf(key)
                              ? StepState.complete
                              : StepState.indexed,
                          title: Text(key),
                          content: SizedBox()))
                      .toList())
            ],
          ),
        ),
      ),
    );
  }
}
