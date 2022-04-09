// @dart=2.9

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/views/To-do.dart';
import 'package:task/views/signIn.dart';
import 'package:task/views/signUp.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}
bool showSignIn = false;
bool _isSigned = false;

String name;
String email;
String photo;



class _AuthenticateState extends State<Authenticate> {
  // final FirebaseMessaging _fcm;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSF();

  }

  void toggleView()
  {
    setState(() {
      showSignIn = !showSignIn;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(!_isSigned){
      if(showSignIn){
        return SignIn(toggle: toggleView);
      }

      if(showSignIn == false){
        return SignUp(toggle: toggleView);
      }
    }
    if(_isSigned)
      {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(context,  MaterialPageRoute(
              builder: (context) =>
                  Todo(email: email, name: name, photo: photo,)));
        });

      }
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
