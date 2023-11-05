import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../models/done_order.dart';

class DoneOrderWidget extends StatelessWidget {
  const DoneOrderWidget({Key key, this.doneOrder}) : super(key: key);
  final DoneOrder doneOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Container(
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Opacity(
          opacity: 0.8,
          child: Theme(
            data: theme,
            child: Container(
              constraints: BoxConstraints(
                minWidth: double.infinity - 20,
                maxWidth: double.infinity - 20,
                minHeight: 120,
                maxHeight: 150,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    height: BoxConstraints.expand().maxHeight,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24)),
                    ),
                    child: Text(
                      'منجز',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            fontSize: 16,
                          ),
                      maxLines: 2,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doneOrder.customerName,
                          style: Theme.of(context).textTheme.headline5.copyWith(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          doneOrder.marketName,
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          doneOrder.details,
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${doneOrder.price}  جنيه - ${doneOrder.timeInterval}',
                          style: Theme.of(context).textTheme.headline3.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            'تم في ${DateFormat('dd-MM-yyyy | HH:mm').format(doneOrder.doneTime.toDate())}',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w600))
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
