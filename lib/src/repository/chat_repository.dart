import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../helpers/helper.dart';
import '../models/chat.dart';
import '../models/conversation.dart';
import '../models/user.dart' as userModel;
import 'user_repository.dart';

class ChatRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

//  User _userFromFirebaseUser(User user) {
//    return user != null ? User(uid: user.uid) : null;
//  }

  Future signInWithToken(String token) async {
    try {
      UserCredential result = await _auth.signInWithCustomToken(token);
      if (result.user != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance
        .collection("users")
        .add(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String token) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("token", isEqualTo: token)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .get();
  }

  // Create Conversation
  Future<void> createConversation(Conversation conversation) async{
    return await FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversation.id)
        .set(conversation.toMap() as Map<String, dynamic>)
        .catchError((e) {
      print(e);
    });
  }

  /*Future<Stream<QuerySnapshot>> getUserConversations(String? userId) async {
    return await FirebaseFirestore.instance
        .collection("conversations")
        .where('visible_to_users', arrayContains: userId)
        .orderBy('time', descending: true)
        .snapshots();
  }*/
  Future<Stream<QuerySnapshot>> getUserConversations() async {
    return await FirebaseFirestore.instance
        .collection("conversations") .where('visible_to_users', arrayContains: currentUser.value.id)
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChats(Conversation conversation) async {
    return await updateConversation(
            conversation.id, {'read_by_users': conversation.readByUsers})
        .then((value) async {
      return await FirebaseFirestore.instance
          .collection("conversations")
          .doc(conversation.id)
          .collection("chats")
          .orderBy('time', descending: true)
          .snapshots();
    });
  }

  Future<DocumentReference> addMessage(Conversation conversation, Chat chat) async{
    return  await FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversation.id)
        .collection("chats")
        .add(chat.toMap() as Map<String, dynamic>)
        .whenComplete(() {
      setConversation(
          conversation.id, conversation.toMap() as Map<String, dynamic>);
    }).catchError((e) {
      print(e.toString());
    });
  }

    Future<void> updateConversation (
      String conversationId, Map<String, dynamic> conversation)async {
      await FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversationId).update(conversation)
        .catchError((e) {
      print(e.toString());
    });
  }
  Future<void> setConversation (
      String conversationId, Map<String, dynamic> conversation)async {
    await FirebaseFirestore.instance
        .collection("conversations")
        .doc(conversationId).set(conversation)
        .catchError((e) {
      print(e.toString());
    });

  }


  Future<String> uploadFile(File _imageFile,) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref('chats/$fileName');
    UploadTask uploadTask = reference.putFile(_imageFile);
    return uploadTask.then((TaskSnapshot storageTaskSnapshot) {
      return storageTaskSnapshot.ref.getDownloadURL();
    }, onError: (e) {
      throw Exception(e.toString());
    });

  }
  void test()async{
     QuerySnapshot<Map<String, dynamic>> chatCol = await FirebaseFirestore.instance.collection("Chat").get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocs = chatCol.docs;
  }
}
