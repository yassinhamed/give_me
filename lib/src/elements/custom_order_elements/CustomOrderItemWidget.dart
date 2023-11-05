import 'package:flutter/material.dart';
import 'package:markets_deliveryboy/src/helpers/helper.dart';
import 'package:markets_deliveryboy/src/models/custom_order_model.dart';
import 'package:markets_deliveryboy/src/models/order_status.dart';
import '../../../generated/l10n.dart';
import 'package:intl/intl.dart' show DateFormat;

class CustomOrderItemWidget extends StatefulWidget {
  final CustomOrder order;
  final ValueChanged<void> onCanceled;

  const CustomOrderItemWidget({Key key, this.order, this.onCanceled})
      : super(key: key);

  @override
  State<CustomOrderItemWidget> createState() => _CustomOrderItemWidgetState();
}

class _CustomOrderItemWidgetState extends State<CustomOrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    bool isActive = !(widget.order.status == Helper.fromEnumToEnglish(customOrderStatus.Canceled));

    return InkWell(
      onTap: () {
        if(isActive)
        Navigator.of(context)
            .pushNamed('/CustomOrderPage', arguments: widget.order);
      },
      child: Container(
        child: Card(
          margin: EdgeInsets.all(10),
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Opacity(
            opacity: isActive ? 1 : 0.5,
            child: Theme(
              data: theme,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: double.infinity - 20,
                  maxWidth: double.infinity - 20,
                  minHeight: 100,
                  maxHeight: 120,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      height: BoxConstraints.expand().maxHeight,
                      width: 70,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24)),
                      ),
                      child: Text(
                        isActive
                            ? Helper.fromEngToArabic(widget.order.status.status)
                            : S.of(context).cancel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              fontSize: 16,
                            ),
                        maxLines: 2,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.order.marketName.trim().isNotEmpty?widget.order.marketName:widget.order.marketAddress.address,
                            style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 16,fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 5,),
                          Text(
                            widget.order.orderDetails,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 5,),
                          Expanded(
                            child: Text(
                              DateFormat('dd-MM-yyyy | HH:mm')
                                  .format(widget.order.publishingTime.toDate()),
                              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16,fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
