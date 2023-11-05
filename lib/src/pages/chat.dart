import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/chat_controller.dart';
import '../elements/ChatMessageListItemWidget.dart';
import '../elements/EmptyMessagesWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/chat.dart';
import '../models/conversation.dart';
import '../models/route_argument.dart';
import '../models/user.dart';
import '../repository/user_repository.dart';

class ChatWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ChatWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends StateMVC<ChatWidget> {
  final _myListKey = GlobalKey<AnimatedListState>();
  final myController = TextEditingController();

  ChatController _con;

  _ChatWidgetState() : super(ChatController()) {
    _con = controller as ChatController;

  }
@override
reassemble(){
    super.reassemble();
}
  @override
  void initState() {
    _con.conversation = widget.routeArgument.param as Conversation;
    if (_con.conversation.id != null) {
      _con.listenForChats(_con.conversation);
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Widget chatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _con.chats,
      builder: (context, snapshot) {
        return snapshot.data !=null && snapshot.hasData
            ? ListView.builder(
            key: _myListKey,
            reverse: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            itemCount: snapshot.data.docs.length,
            shrinkWrap: false,
            primary: true,
            itemBuilder: (context, index) {
              print(snapshot.data.docs[index].data());
              Chat _chat = Chat.fromJSON(snapshot.data.docs[index].data());
             //_chat.user = _con!.conversation!.users!.firstWhere((_user) => _user.id == _chat.userId);
              _chat.user = _con.conversation.users.firstWhere((_user) => _user.id != currentUser.value.id);
              return ChatMessageListItem(
                chat: _chat,
              );
            })
            : EmptyMessagesWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
            onPressed: () {
              if (widget.routeArgument.id == null) {
                // from conversation page
                Navigator.of(context).pushNamed('/Pages', arguments: 3);
              } else {
                Navigator.of(context).pushNamed('/Details', arguments: RouteArgument(id: '0', param: widget.routeArgument.id, heroTag: 'chat_tab'));
              }
            }),
        //automaticallyImplyLeading: false,
        title: Text(
          _con.conversation.name,
          overflow: TextOverflow.fade,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              border: Border.all(color: Theme.of(context).accentColor),
            ),
            margin: EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: _con.conversation.users
                    .firstWhere(
                        (element) => element.id != currentUser.value.id,
                    orElse: () => User.fromJSON({}))
                    .image
                    ?.thumb ??
                    '',
                placeholder: (context, url) => Image.asset(
                  'assets/img/loading.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              ),
            ),
          ),
          SizedBox(width: 12,),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: chatList(),
          ),
          _con.conversation.isActive??true?Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Wrap(
                  children: [
                    SizedBox(width: 10),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl = await _con.getImage(ImageSource.gallery);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          await _con.addMessage(_con.conversation, imageUrl);
                        }
                        Timer(Duration(milliseconds: 100), () {
                          _con.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.photo_outlined,
                        color: Theme.of(context).accentColor,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var imageUrl = await _con.getImage(ImageSource.camera);
                        if (imageUrl != null && imageUrl.trim() != '') {
                          await _con.addMessage(_con.conversation, imageUrl);
                        }
                        Timer(Duration(milliseconds: 100), () {
                          _con.chatTextController.clear();
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(context).accentColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: 'اكتب لبدء الدردشة',
                      hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8)),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.only(right: 30),
                        onPressed: () {
                          _con.addMessage(_con.conversation, myController.text);
                          print('adding message: \nconversation: ${_con.conversation.toMap()}');
                          Timer(Duration(milliseconds: 100), () {
                            myController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.send_outlined,
                          color: Theme.of(context).accentColor,
                          size: 30,
                        ),
                      ),
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
              ],

            ),
          ): Center(
            child: Text(
              "تم إغلاق المحادثة",
              style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
