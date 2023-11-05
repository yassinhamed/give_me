import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/helpers/helper.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'CustomOrderSingleInfoWidget.dart';

class CustomOrderInfo extends StatelessWidget {
  const CustomOrderInfo({Key key, this.order}) : super(key: key);
  final CustomOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderSingleInfo(
            title: 'رقم الطلب',
            details: order.orderId,
          ),
          OrderSingleInfo(
            title: 'وقت الطلب',
            details: DateFormat('dd-MM-yyyy | HH:mm')
                .format(order.publishingTime.toDate()),
          ),
          order.marketName!=null && order.marketName.trim().isNotEmpty?OrderSingleInfo(
            title: 'اسم المحل',
            details: order.marketName,
          ):SizedBox(),
          OrderSingleInfo(
            title: 'العنوان',
            details: order.marketAddress.address,
          ),
          OrderSingleInfo(
            title: 'عنوان التوصيل',
            details: order.customerAddress.address,
          ),
          OrderSingleInfo(
            title: 'حالة الطلب',
            details: Helper.fromEngToArabic(order.status.status),
          ),
          OrderSingleInfo(
            title: 'تفاصيل الطلب',
            details: order.orderDetails,
          ),
          SizedBox(
            height: 10,
          ),
        ]);
  }
}
