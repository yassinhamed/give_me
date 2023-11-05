import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/delivery_verification.dart';
import '../elements/upload_repository.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/media.dart';
import '../repository/user_repository.dart';

class VerificationInfoController extends ControllerMVC {
  Address address ;
  DateTime dateBirth;
  TextEditingController addressName;
  var sending = false;
  bool uploading = false;
  DeliveryVerification deliveryVerification;
  Map<String,dynamic> verificationMap = {};
  Future<void> pickAndUploadImage(String fileName,BuildContext context) async {
    String imageUrl = "";
    try {
      ImagePicker imagePicker = new ImagePicker();
      imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50)
          .then((pickedImage) async {
        if (pickedImage != null) {
          imageUrl = await uploadImage(pickedImage, fileName,context);
          verificationMap['$fileName'] = imageUrl;
          setState(() { });
        }
      });
    }catch(e){
      print("Exception when uploading image: $e");
    }

  }


   Future<String > uploadImage(XFile imageFile,String fileName,BuildContext context){
    SnackBar snackBar = SnackBar(content: Text("يرجي الانتظار جاري رفع الملفات..."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Reference reference = FirebaseStorage.instance.ref('users_credentials/${currentUser.value.id}/$fileName');
     UploadTask uploadTask = reference.putFile(File(imageFile.path));
     return uploadTask.then((TaskSnapshot storageTaskSnapshot) {
       ScaffoldMessenger.of(context).clearSnackBars();
       return storageTaskSnapshot.ref.getDownloadURL();
     }, onError: (e) {
       throw Exception(e.toString());
     });

   }

   Future<void> sendVerificationRequest()async {
     uploading = true;
     setState(() {});
     try {
       verificationMap['verified'] = false;
       deliveryVerification.verified = false;
       await FirebaseFirestore.instance.collection("delivery_docs").doc(
           currentUser.value.id).set(DeliveryVerification.fromJson(verificationMap).toMap());
       currentUser.value.delVerification = deliveryVerification;
       currentUser.value.image = Media(
           id: currentUser.value.id,
           thumb: currentUser.value.delVerification.face,
           url: currentUser.value.delVerification.face);
     } catch (e) {
       print(e);
     } finally {
       uploading = false;
       setState(() {});
     }
   }

  getDeliveryVerification(){
    deliveryVerification = currentUser.value.delVerification;
    verificationMap = deliveryVerification.toMap();
  }
}
