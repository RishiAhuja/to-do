import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/helper/authenicate.dart';
import 'package:task/services/local_notification_service.dart';

Future<void> backgroundHandler(RemoteMessage message) async{
  LocalNotificationService.display(message);
  print("when app is terminated!");
  print(message.data.toString());
  print(message.notification.title);
}

bool showSignIn = false;
bool _isSigned = false;

String name;
String email;
String photo;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Raleway'),
      // darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,

      home: Notification(),
    );
  }
}

class Notification extends StatefulWidget {
  Notification({Key key}) : super(key: key);

  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends State<Notification> {
  void initState() {
    // TODO: implement initState
    super.initState();
    getSF();
    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message != null){
        print('local notification service initialized');
      }
    });

    ///forground work
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification != null){
        print(message.notification.body);
        print(message.notification.title);
      }

      LocalNotificationService.display(message);
      print("when app is on!");
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      LocalNotificationService.display(message);
      print("when app is background!");
    });



  }

  @override
  Widget build(BuildContext context) {
    return Authenticate();
  }


  Future<void> getSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool boolValue = prefs.getBool('_signed');
    //Return String
    String nameData = prefs.getString('name');
    //Return String
    String emailData = prefs.getString('email');

    //Return String
    String photoData = prefs.getString('photo');

    setState(() {
      if(boolValue == true)
      {
        _isSigned = boolValue;
      }
      name = nameData;
      photo = photoData;
      email = emailData;
      print(email);
      print(_isSigned);
    });
    return boolValue;
  }
}