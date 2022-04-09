import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/helper/authenicate.dart';
import 'package:task/helper/forgot.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

Color _whiteBlack = Colors.white;
Color _blackWhite = Colors.black;

void _restartApp(context) async {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
}

class _SettingsPageState extends State<SettingsPage> {
  Color _orange = Colors.orange;
  bool _dark = false;
  bool _saved = false;
  String email = '';
  Color buttonColorShiftDay = Colors.orange;
  Color buttonColorShiftNight = Colors.white;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getThemeData();
  }
  getThemeData() async {
  SharedPreferences prefsformail = await SharedPreferences.getInstance();
setState(() {
  email = prefsformail.getString('email');
});
SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool dark = prefs.getBool('dark');
    print(dark);
    if(dark == false){
      setState(() {
        buttonColorShiftNight = Colors.white;
        buttonColorShiftDay = Colors.orange;
        _whiteBlack = Colors.white;
        _blackWhite = Colors.black;
        _dark = false;
      });
    }
    if(dark == true){
      setState(() {
        buttonColorShiftNight = Colors.orange;
        buttonColorShiftDay = Colors.black;
        _whiteBlack = Colors.black;
        _blackWhite = Colors.white;
        _dark = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _whiteBlack,
      appBar: AppBar(
        backgroundColor: _whiteBlack,
        elevation: 0,
        leading: IconButton(
          color: _blackWhite,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            if(_saved){
              _restartApp(context);
            }if(_saved == false){
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: _blackWhite,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Lottie.asset('assets/settings.json'),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Dark Mode',
                      style: GoogleFonts.poppins(
                        color: _blackWhite,
                        fontSize: 20
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async{
                              setState(() {
                                buttonColorShiftNight = Colors.white;
                                buttonColorShiftDay = Colors.orange;
                                _whiteBlack = Colors.white;
                                _blackWhite = Colors.black;
                              });
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('dark', false);
                              print('saved false');
                              setState(() {
                                _saved = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]),
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                                color: buttonColorShiftDay
                              ),
                              child: Icon(Icons.wb_sunny, color: buttonColorShiftNight,),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async{
                              setState(() {
                                buttonColorShiftNight = Colors.orange;
                                buttonColorShiftDay = Colors.black;
                                _whiteBlack = Colors.black;
                                _blackWhite = Colors.white;
                              });
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('dark', true);
                              print('saved true');
                              setState(() {
                                _saved = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
                                color: buttonColorShiftNight
                              ),
                              child: Icon(Icons.nightlight_round, color: buttonColorShiftDay,),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Email',
                      style: GoogleFonts.poppins(
                          color: _blackWhite,
                          fontSize: 20
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$email',
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            color: _blackWhite,
                            fontSize: 20
                        ),
                      ),
                    ),
                  )
                ],
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(opacity: 0,
                    child: IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.logout, color: Colors.grey,)
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.orange
                          ),
                          child: Text(
                            'Reset Password',
                            style: GoogleFonts.poppins(
                              color: _whiteBlack,
                              fontSize: 20
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: _whiteBlack,
                              title: Text('Are you sure you want to log out?',
                                style: GoogleFonts.poppins(
                                    color: _blackWhite,
                                    fontSize: 20
                                ),
                              ),
                              content: Lottie.asset('assets/logout.json'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Close',
                                      style: GoogleFonts.poppins(
                                          color: _blackWhite,
                                      ),
                                    ),
                                ),
                                TextButton(
                                  onPressed: () async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setBool('_signed', false);
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                                  },
                                  child: Text('Log out',
                                    style: GoogleFonts.poppins(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(Icons.logout, color: Colors.grey,)
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
