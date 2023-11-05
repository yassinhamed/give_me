import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/verification_info_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../models/delivery_verification.dart';
import '../models/address.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

// ignore: must_be_immutable
class VerificationInfo extends StatefulWidget {
  String avatar;
  String phone;
  String country;
  String email;

  VerificationInfo(this.avatar, this.phone, this.country, this.email);

  @override
  _VerificationInfoState createState() => _VerificationInfoState();
}

class _VerificationInfoState extends StateMVC<VerificationInfo> {
  VerificationInfoController _con;

  _VerificationInfoState() : super(VerificationInfoController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.addressName = TextEditingController();
    _con.getDeliveryVerification();
    _con.addressName.text = _con.deliveryVerification.address.address;
    //_con.check();
  }

  @override
  void dispose() {
    super.dispose();
    _con.addressName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'توثيق الحساب',
          style: TextStyle(fontSize: 18, color: Colors.deepOrangeAccent),
        ),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.black,
            )),
      ),
      body: _con.uploading
          ? const Center(
              child: Text(
                'جاري رفع الملفات...',
                style: TextStyle(color: Colors.black),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'يرجي إرفاق الملفات التالية وسيتم مراجعة طلبك لتوثيق حسابك كسائق معتمد في  Give Me',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 14),
                          ListTile(
                            leading: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                LocationResult result = await showLocationPicker(
                                  context,
                                  setting.value.googleMapsKey,
                                  initialCenter: LatLng(
                                      currentUser.value.delVerification?.address
                                              ?.latitude ??
                                          15.31,
                                      currentUser.value.delVerification?.address
                                              ?.longitude ??
                                          35.32),
                                  //automaticallyAnimateToCurrentLocation: true,
                                  //mapStylePath: 'assets/mapStyle.json',
                                  myLocationButtonEnabled: true,
                                  //resultCardAlignment: Alignment.bottomCenter,
                                  language: 'ar',
                                );
                                print("result = $result");

                                if (result != null && result.latLng != null) {
                                  _con.address = Address(
                                      address: result.address,
                                      latitude: result.latLng.latitude,
                                      longitude: result.latLng.longitude);
                                  _con.addressName.text =
                                      _con.address?.address ?? "لم يتم التحديد";
                                  _con.verificationMap['address']=_con.address.toMap();
                                } else {
                                  _con.addressName.text = "لم يتم التحديد";
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.my_location,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                            title: Text(
                              'عنوان السكن',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                          TextFormField(
                            controller: _con.addressName,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText:
                                  'انقر على الأيقونة في الأعلى لتحديد عنوان السكن',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ListTile(
                            leading: IconButton(
                              icon: Icon(
                                Icons.calendar_month,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () {
                                try {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime(1995),
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime(DateTime.now().year))
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        _con.verificationMap['dateBirth'] =
                                            Timestamp.fromDate(value);
                                      });
                                    }
                                  });
                                } on Exception catch (_) {}
                              },
                            ),
                            title: Text(
                              'تاريخ الميلاد',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            trailing: _con.verificationMap['dateBirth']!=null?Text(
                              DateFormat('dd-MM-yyy').format(
                                  (_con.verificationMap['dateBirth']??Timestamp.now())
                                          .toDate() ),
                              style: Theme.of(context).textTheme.headline5,
                            ):Text("لم يتم التحديد"),
                          ),
                          const SizedBox(height: 5),
                          ListView(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            children: [
                              accountInfo(
                                  imgUrl: _con.verificationMap['face'],
                                  title: 'صورة لك تظهر وجهك',
                                  onTap: () => _con.pickAndUploadImage('face',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['frontLicence'],
                                  title: 'صورة أمامية لرخصة القيادة',
                                  onTap: () =>
                                      _con.pickAndUploadImage('frontLicence',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['backLicence'],
                                  title: 'صورة خلفية لرخصة القيادة',
                                  onTap: () =>
                                      _con.pickAndUploadImage('backLicence',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['searchCertificate'],
                                  title: 'شهادة البحث',
                                  onTap: () =>
                                      _con.pickAndUploadImage('searchCertificate',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['frontId'],
                                  title: 'صورة أمامية لبطاقة اثبات الهوية',
                                  onTap: () => _con.pickAndUploadImage('frontId',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['backId'],
                                  title: 'صورة خلفية لبطاقة إثبات الهوية',
                                  onTap: () => _con.pickAndUploadImage('backId',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['frontCar'],
                                  title: 'صورة امامية لسيارتك أو دراجتك',
                                  onTap: () => _con.pickAndUploadImage('frontCar',context)),
                              accountInfo(
                                  imgUrl: _con.verificationMap['backCar'],
                                  title: 'صورة خلفية لسيارتك أو دراجتك',
                                  onTap: () => _con.pickAndUploadImage('backCar',context)),
                            ],
                          ),
                        ]),
                    SizedBox(height: 20,),
                    BlockButtonWidget(
                      onPressed: () async {
                        _con.deliveryVerification =
                            DeliveryVerification.fromJson(
                                _con.verificationMap);
                        print(_con.deliveryVerification.toMap());
                        if (!_con.deliveryVerification.isValid()) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              'يرجي ملئ حميع الحقول',
                              style: TextStyle(color: Colors.white),
                            ),
                          ));
                        } else {
                          _con.sendVerificationRequest().then((_) {
                            Navigator.of(context).pop();
                            setState(() { });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Colors.white,
                              content: Text(
                                'تم ارسال طلب التوثيق وسيتم الرد عليك في أقرب وقت',
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                            ));
                          });
                        }
                      },
                      color:Theme.of(context).accentColor,
                      text: Text('إرسال طلب التوثيق'),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),
    );
  }

  Widget accountInfo(
      {String imgUrl, String trailing, String title, VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
            ),
            trailing: TextButton(
              child: Text("تغيير"),
              onPressed: onTap,
            ),
          ),
          CachedNetworkImage(
            width: double.infinity,
            fit: BoxFit.cover,
            height: 200,
            imageUrl: imgUrl,
            placeholder: (context, url) => Image.asset(
              'assets/img/loading.gif',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            errorWidget: (context, url, error) => Icon(Icons.link_outlined),
          )
        ],
      ),
    );
  }

}
