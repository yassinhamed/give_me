import 'package:flutter/material.dart';

class OrderSingleInfo extends StatelessWidget {
  const OrderSingleInfo({Key key,this.title,this.details}) : super(key: key);
  final String title;
  final String details;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: Theme.of(context).textTheme.headline6.copyWith(color: Theme.of(context).accentColor),),
        Padding(
          padding: const EdgeInsets.only(right: 42,bottom: 10,top: 10),
          child: SelectableText(details,style: Theme.of(context).textTheme.headline4,),
        ),
      ],
    );
  }
}
