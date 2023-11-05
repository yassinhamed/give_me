import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  userModel.User user = new userModel.User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  OverlayEntry loader;

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    print("********** user value in user controller: ${repository.currentUser.value.toMap()}");
    user.deviceToken = repository.currentUser.value.deviceToken;
   /* _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });*/
  }

  void login() async {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    Overlay.of(state.context).insert(loader);
    try {
          userModel.User loginUser = await repository.login(user);
          if (loginUser != null && loginUser.apiToken != null) {
           await FirebaseAuth.instance.signInAnonymously();
            Navigator.of(scaffoldKey.currentContext)
                .pushReplacementNamed('/Pages', arguments: 2);
          } else {
            ScaffoldMessenger.of(scaffoldKey.currentContext)
                .showSnackBar(SnackBar(
              content: Text(S.of(state.context).wrong_email_or_password),
            ));
          }
    } catch(e){
      ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    } finally {
      loader.remove();
      Helper.hideLoader(loader);
    }
  }

  Future<void> register() async {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    Overlay.of(state.context).insert(loader);
    try {
      userModel.User registeredUser = await repository.register(user);
      if (registeredUser != null && registeredUser.apiToken != null) {
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
      } else {
        ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).wrong_email_or_password),
        ));
      }
    } catch(e){
      ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    } finally {
      loader.remove();
      Helper.hideLoader(loader);
    }
  }
  Future<void> signInFBEmailAndPassword() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
  }

  Future<void> registerFBEmailAndPassword() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );
    await FirebaseAuth.instance.currentUser.sendEmailVerification();
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(
      SnackBar(
        content:
        Text("تم إرسال كود التحقق إلى بريدك الإلكتروني, من فضلك قم بتأكيد الحساب وأعد تسجيل الدخول"),
      ),
    );
  }
  /*void login() async {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }*/

 /* void register() async {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 1);
        } else {
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).thisAccountNotExist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }*/

  void resetPassword() {
    loader = Helper.overlayLoader(state.context);
    FocusScope.of(state.context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(state.context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(state.context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
            content: Text(S.of(state.context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
