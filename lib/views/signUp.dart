import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/views/To-do.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp({this.toggle});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();


  addToSF(String nameData, String emailData, String photoURL) async{
    SharedPreferences persist = await SharedPreferences.getInstance();
    persist.setBool('_signed', true);

    SharedPreferences name = await SharedPreferences.getInstance();
    name.setString('name', "$nameData");

    SharedPreferences email = await SharedPreferences.getInstance();
    email.setString('email', "$emailData");

    SharedPreferences photo = await SharedPreferences.getInstance();
    photo.setString('photo', "$photoURL");
  }

  signUserUp() async {
    final form = formKey.currentState;
    if (form != null) {
      if (form.validate()) {
        print("validated!");
        try {
          setState(() {
            _isLoading = true;
          });
          final UserCredential
          user = await
          _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ).catchError((_)
          {
            AlertDialog(
              title: Text('An Error occurred'),
              content: Text('Please try again Later'),
            );
          });

          FirebaseFirestore.instance.collection("users").add({
            "name": usernameController.text.trim(),
            "email": emailController.text.trim()
          }).then((_){
            addToSF(usernameController.text, emailController.text.trim(), 'null');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Todo(name: usernameController.text.trim(), email: emailController.text.trim(),)));
          }).catchError((_){
            AlertDialog(
              title: Text('An Error occurred'),
              content: Text('Please try again Later'),
            );
          });
        } catch (e) {
          print(e.toString());
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Alert Dialog Box"),
              content: Text("You have raised a Alert Dialog Box"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("okay"),
                ),
              ],
            ),
          );

        }
        FirebaseFirestore.instance.collection("${usernameController.text}#${emailController.text}").doc('Personal').set({"index": 1});
        FirebaseFirestore.instance.collection("${usernameController.text}#${emailController.text}").doc('Work').set({"index": 2});
        FirebaseFirestore.instance.collection("${usernameController.text}#${emailController.text}").doc('Grocery').set({"index": 3});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.orange,
        ),
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Task Genix',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Material(
                        elevation: 7,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 39),
                          width: MediaQuery.of(context).size.width / 1.3,
                          // height: MediaQuery.of(context).size.height / 1.6,
                          child: Column(
                            children: [
                              // SizedBox(height: 20),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Welcome!',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(height: 20),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            child: TextFormField(
                                              controller: usernameController,
                                              validator: (val) {
                                                return val.toString().isEmpty ||
                                                        val.toString().length <
                                                            4
                                                    ? 'Please provide over 4+ characters'
                                                    : null;
                                              },
                                              style: GoogleFonts.poppins(
                                                  textStyle:
                                                      TextStyle(fontSize: 17)),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Username..',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                              color: Colors.grey
                                                                  .shade500))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.email_rounded,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            child: TextFormField(
                                              controller: emailController,
                                              validator: (val) {
                                                return RegExp(
                                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(
                                                            val.toString())
                                                    ? null
                                                    : "Please enter correct email";
                                              },
                                              style: GoogleFonts.poppins(
                                                  textStyle:
                                                      TextStyle(fontSize: 17)),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Email..',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                              color: Colors.grey
                                                                  .shade500))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2)),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lock,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            child: TextFormField(
                                              controller: passwordController,
                                              validator: (val) {
                                                return val.toString().isEmpty ||
                                                        val.toString().length <
                                                            6
                                                    ? 'Provide password 6+ characters'
                                                    : null;
                                              },
                                              obscureText: true,
                                              style: GoogleFonts.poppins(
                                                  textStyle:
                                                      TextStyle(fontSize: 17)),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Password..',
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                          textStyle: TextStyle(
                                                              color: Colors.grey
                                                                  .shade500))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              GestureDetector(
                                onTap: () {
                                  signUserUp();
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.6,
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(colors: [
                                        Colors.orange.shade300,
                                        Colors.orange,
                                        Colors.orange.shade700
                                      ])),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              Container(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  GestureDetector(
                                    onTap: () => widget.toggle(),
                                    child: Text(
                                      'Log In!',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

addBoolToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('_signed', true);
}