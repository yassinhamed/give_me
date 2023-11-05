import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/chat.dart';
import '../models/conversation.dart';
import '../models/user.dart';
import '../repository/chat_repository.dart';
import '../repository/notification_repository.dart';
import '../repository/user_repository.dart';

class ChatController extends ControllerMVC {
  Conversation conversation;
   ChatRepository _chatRepository;
  Stream<QuerySnapshot> conversations;
  Stream<QuerySnapshot> chats;
  GlobalKey<ScaffoldState> scaffoldKey;
  File imageFile;
  bool uploading;
  final chatTextController = TextEditingController();

  ChatController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _chatRepository = new ChatRepository();
//    _createConversation();
  }

  signIn() {
    //_chatRepository.signUpWithEmailAndPassword(currentUser.value.email, currentUser.value.apiToken);
//    _chatRepository.signInWithToken(currentUser.value.apiToken);
  }

  Future<void> createConversation(Conversation _conversation) async {
    _conversation.users.insert(0, currentUser.value);
    _conversation.lastMessageTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    _conversation.readByUsers = [currentUser.value.id];
    setState(() {
      conversation = _conversation;
    });
    _chatRepository.createConversation(conversation).then((value)async {
      await listenForChats(conversation);
    });
  }

  listenForConversations() async {
    await _chatRepository.getUserConversations().then((snapshots) {
      setState(() {
        conversations = snapshots;
      });
    });
  }

  listenForChats(Conversation _conversation) async {
    _conversation.readByUsers.add(currentUser.value.id);
    _conversation.readByUsers = _conversation.readByUsers.toSet().toList();
    await _chatRepository.getChats(_conversation).then((snapshots) {
      setState(() {
        chats = snapshots;
        //chats.
      });
    });
  }

  addMessage(Conversation _conversation, String text)async {
    Chat _chat = new Chat(text, DateTime.now().toUtc().millisecondsSinceEpoch, currentUser.value.id);
    // if (_conversation.id == null) {
    //_conversation.id = UniqueKey().toString();
    // await createConversation(_conversation);
    //}
    _conversation.lastMessage = text;
    _conversation.lastMessageTime = _chat.time;
    _conversation.readByUsers = [currentUser.value.id];
    await _chatRepository.addMessage(_conversation, _chat).then((value) {
      _conversation.users.forEach((_user) async{
        if (_user.id != currentUser.value.id) {
          await sendNotification(body:  text.startsWith('http')?'تم إرسال صورة جديدة':text, title: "رسالة جديدة من" + " " + currentUser.value.name, deviceToken: _user.deviceToken,type: 'message');
        }
      });
    });
  }



  orderSnapshotByTime(snapshot) {
    final docs = snapshot.data.docs;
    docs.sort((QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
      var time1 = a.get('time');
      var time2 = b.get('time');
      return time2.compareTo(time1) as int;
    });
    return docs;
  }

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: source,imageQuality:source == ImageSource.camera? 20:40);
    setState(() {
      imageFile = File(pickedFile.path);
    });


    if (imageFile != null) {
      try {
        uploading = true;
        return await _chatRepository.uploadFile(imageFile);

      } catch (e) {
      print(e);
        ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    } else {
      ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
        content: Text('من فضلك اختر صورة'),

      ));


    }
  }
}
