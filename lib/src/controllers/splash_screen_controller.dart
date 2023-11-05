import 'dart:async';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../helpers/custom_trace.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC with ChangeNotifier {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState> scaffoldKey;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  SplashScreenController() {
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }

  @override
  void initState() {
    super.initState();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    //firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    configureFirebase(firebaseMessaging);
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null &&
          settingRepo.setting.value.appName != '' &&
          settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 41;
        progress?.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 59;
        progress?.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    });
  }

  void configureFirebase(FirebaseMessaging _firebaseMessaging) async {
    String _vapidKey =
        'AAAAzoceVJQ:APA91bFlQ8KANU9QwTJc3gPCF8WDcyO90wsORAFfpdsC8v4RWFSGj3y8wpL2Z0vTfZnQfgoKHM-qDme0IlyVP68L8V2YCTThUr7sr9PeXm_FkoluTCsSkuuJxuzOyBhHD2Lv2D5F32eE';
    try {
      Future<PermissionStatus> permissionStatus =
          NotificationPermissions.getNotificationPermissionStatus();
      if (permissionStatus != PermissionStatus.granted) {
        NotificationPermissions.requestNotificationPermissions();
      }
      _firebaseMessaging
          .subscribeToTopic("driver")
          .catchError((e) => print("-------Error when subsecribe to topic $e"));
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          sound: true, badge: true);
      _firebaseMessaging.getToken(vapidKey: _vapidKey).then((_deviceToken) {
        print(
            "----------------- user before:\n${userRepo.currentUser.value.toMap()}");
        userRepo.currentUser.value.deviceToken = _deviceToken;
        print(
            "----------------- user before:\n${userRepo.currentUser.value.toMap()}");

        print('.............. device token: $_deviceToken');
      }).catchError((e) {
        print('Notification not configured: $e');
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        Fluttertoast.showToast(
          msg: message.notification.title,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
        );
        if (message.data['type'] == 'close') {
          settingRepo.navigatorKey.currentState
              .pushReplacementNamed('/Pages', arguments: 3);
          await userRepo.getUserBalance();
          await userRepo.getUserRating();
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('------------ A new onMessageOpenedApp event was published!');
        settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages',
            arguments: (message?.data['type'] ?? "") == 'message'
                ? 3
                : message.data['type'] == 'newOrder'
                    ? 2
                    : 0);
      });

      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    } catch (e) {
      print("Error when configure firebase messaging: $e");
    }
  }

//   try {
//     _firebaseMessaging.(
//       onMessage: notificationOnMessage,
//       onLaunch: notificationOnLaunch,
//       onResume: notificationOnResume,
//     );
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: e));
//     print(CustomTrace(StackTrace.current, message: 'Error Config Firebase'));
//   }
// }

//   Future notificationOnResume(Map<String, dynamic> message) async {
//     print(CustomTrace(StackTrace.current, message: message['data']['id']));
//     try {
//       if (message['data']['id'] == "orders") {
//         settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages', arguments: 1);
//       }
//     } catch (e) {
//       print(CustomTrace(StackTrace.current, message: e));
//     }
//   }
//
//   Future notificationOnLaunch(Map<String, dynamic> message) async {
//     String messageId = await settingRepo.getMessageId();
//     try {
//       if (messageId != message['google.message_id']) {
//         if (message['data']['id'] == "orders") {
//           await settingRepo.saveMessageId(message['google.message_id']);
//           settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages', arguments: 1);
//         }
//       }
//     } catch (e) {
//       print(CustomTrace(StackTrace.current, message: e));
//     }
//   }
//
//   Future notificationOnMessage(Map<String, dynamic> message) async {
//     Fluttertoast.showToast(
//       msg: message['notification']['title'],
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.TOP,
// //      backgroundColor: Theme.of(state.context).backgroundColor,
// //      textColor: Theme.of(state.context).hintColor,
//       timeInSecForIosWeb: 5,
//     );
//   }
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  settingRepo.navigatorKey.currentState.pushReplacementNamed('/Pages',
      arguments: (message?.data['type'] ?? "") == 'message'
          ? 3
          : message.data['type'] == 'newOrder'
              ? 2
              : 0);
}
