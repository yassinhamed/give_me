import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    _con.progress.addListener(() {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      print('progress: $progress');
       if (progress == 100) {
        try {
          if (currentUser.value.apiToken == null) {
            Navigator.of(context).pushReplacementNamed('/Login');
          } else {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          }
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor:   Color(0xFFff8a5c),
        key: _con.scaffoldKey,
        body: Container(
          child: Center(
            child:  Lottie.asset(
              'assets/lottie_files/delivery-guy.json',
            ),
          ),
        ),
      ),
    );
  }
}
