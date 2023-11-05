import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/intl/messages_ar.dart';
import '../../generated/intl/messages_ar.dart';
import '../../generated/l10n.dart';
import '../controllers/chat_controller.dart';
import '../elements/EmptyMessagesWidget.dart';
import '../elements/MessageItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/conversation.dart';
import '../repository/user_repository.dart';

class MessagesWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MessagesWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _MessagesWidgetState createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends StateMVC<MessagesWidget> {
  ChatController _con;

  _MessagesWidgetState() : super(ChatController()) {
    _con = controller as ChatController;
  }

  @override
  void initState() {
    if(isRegisteredAndLogin){
      _con.listenForConversations();
    }

    //print('conversation data: ${_con.conversation.toMap()}');
    super.initState();
  }

  Widget conversationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _con.conversations,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!=null) {
         //var _docs = _con!.orderSnapshotByTime(snapshot);
          var _docs = snapshot.data.docs;
          return ListView.separated(
              itemCount: _docs.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index) {
                Conversation _conversation = Conversation.fromJSON(_docs[index].data() );
                return MessageItemWidget(
                  message: _conversation,
                );
              });
        } else {
          return EmptyMessagesWidget();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الرسائل',
          overflow: TextOverflow.fade,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: !isRegisteredAndLogin
          ? PermissionDeniedWidget()
          : ListView(
              primary: false,
              children: <Widget>[
                conversationsList(),
              ],
            ),
    );
  }
}
