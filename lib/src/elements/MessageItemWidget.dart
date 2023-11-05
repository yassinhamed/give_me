import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/conversation.dart' as model;
import '../models/user.dart' as UserModel;
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class MessageItemWidget extends StatefulWidget {
  MessageItemWidget({Key key, this.message}) : super(key: key);
  final model.Conversation message;

  @override
  _MessageItemWidgetState createState() => _MessageItemWidgetState();
}

class _MessageItemWidgetState extends State<MessageItemWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/Chat',
            arguments: RouteArgument(param: widget.message));
      },
      child: Container(
        color: this.widget.message.readByUsers.contains(currentUser.value.id)
            ? Colors.transparent
            : Theme.of(context).focusColor.withOpacity(0.05),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: CachedNetworkImage(
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: this
                              .widget
                              .message
                              .users
                              .firstWhere(
                                  (element) =>
                                      element.id != currentUser.value.id,
                                  orElse: () => UserModel.User.fromJSON({}))
                              .image
                              ?.thumb ??
                          'https://',
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error_outline),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 3,
                  width: 12,
                  height: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          this.widget.message.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.bodyText1.merge(
                              TextStyle(
                                  fontWeight: this
                                          .widget
                                          .message
                                          .readByUsers
                                          .contains(currentUser.value.id)
                                      ? FontWeight.w400
                                      : FontWeight.w800)),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                this.widget.message.lastMessageTime,
                                isUtc: true)),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          this.widget.message.lastMessage.startsWith('http')?'تم إرسال صورة':this.widget.message.lastMessage,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption.merge(
                              TextStyle(
                                  fontWeight: this
                                          .widget
                                          .message
                                          .readByUsers
                                          .contains(currentUser.value.id)
                                      ? FontWeight.w400
                                      : FontWeight.w900)),
                        ),
                      ),
                      Text(
                        DateFormat('dd-MM-yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                this.widget.message.lastMessageTime,
                                isUtc: true)),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
