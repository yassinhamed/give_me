import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User user;

  ProfileAvatarWidget({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child: CachedNetworkImage(
                    height: 135,
                    width: 135,
                    fit: BoxFit.cover,
                    imageUrl: user.image?.url??"",
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 135,
                      width: 135,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ),
          Text(
            user.name??'user name',
            style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
              Helper.getStarsList(currentUser.value.rate??0)

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.balance?.toStringAsFixed(2).toString()??"0.0",style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.green),),
              Text('جنيه',style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.green,fontWeight: FontWeight.w500),)

            ],
          ),
          Text(
            user.address??'user address',
            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }
}
