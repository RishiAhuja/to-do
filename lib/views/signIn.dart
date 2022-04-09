// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/helper/forgot.dart';
import 'package:task/views/To-do.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn({this.toggle});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _success;
  bool _isLoading = false;

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

        final UserCredential user = (await _auth

                .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        )
                .catchError((_) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
            'Failed to Login! Please double check your credentials',
            style: GoogleFonts.poppins(),
          )));
        }));

        if (user != null) {
          var userName;
          FirebaseFirestore.instance
              .collection('users')
              .where("email", isEqualTo: emailController.text)
              .snapshots()
              .listen((event) {
            print(event.docs[0]['name']);
            setState(() {
              userName = event.docs[0]['name'];
              print(userName);
              _isLoading = true;
              _success = true;
              print(user.user.email);

              addToSF(userName, user.user.email, 'null');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Todo(email: user.user.email, name: userName)));
            });
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
            'Failed to Login! Please double check your credentials',
            style: GoogleFonts.poppins(),
          )));
          setState(() {
            _success = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                                  'Welcome Back!',
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
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPassword())),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            decoration:
                                                TextDecoration.underline)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              GestureDetector(
                                onTap: () async{
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
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   height: 14,
                              // ),
                              // Container(
                              //   padding: EdgeInsets.symmetric(horizontal: 20),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //           flex: 2,
                              //           child: Divider(
                              //             color: Colors.grey,
                              //             thickness: 1,
                              //           )),
                              //       Expanded(
                              //           flex: 1,
                              //           child: Align(
                              //               alignment: Alignment.center,
                              //               child: Text(
                              //                 'or',
                              //                 style: GoogleFonts.poppins(
                              //                     textStyle: TextStyle(
                              //                         color: Colors.grey)),
                              //               ))),
                              //       Expanded(
                              //           flex: 2,
                              //           child: Divider(
                              //             color: Colors.grey,
                              //             thickness: 1,
                              //           )),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 14,
                              // ),
                              // GestureDetector(
                              //   onTap: () async {
                              //     try {
                              //       final GoogleSignInAccount googleUser =
                              //       await GoogleSignIn().signIn();
                              //       setState(() {
                              //         _isLoading = true;
                              //       });
                              //       // Obtain the auth details from the request
                              //       final GoogleSignInAuthentication
                              //       googleAuth =
                              //       await googleUser.authentication;
                              //
                              //       // Create a new credential
                              //       final credential =
                              //       GoogleAuthProvider.credential(
                              //         accessToken: googleAuth.accessToken,
                              //         idToken: googleAuth.idToken,
                              //       );
                              //
                              //       var user = await FirebaseAuth.instance
                              //           .signInWithCredential(credential);
                              //       print(user.user);
                              //       if (user.user != null) {
                              //         print(user.user.displayName);
                              //         print(user.user.photoURL);
                              //         print(user.user.photoURL);
                              //         addToSF(user.user.displayName, user.user.photoURL, user.user.photoURL);
                              //         Navigator.pushReplacement(
                              //             context,
                              //             MaterialPageRoute(
                              //                 builder: (context) => Todo(
                              //                     email: user.user.email,
                              //                     name:user.user.displayName,
                              //                     photo: user.user.photoURL
                              //                 )));
                              //       }
                              //
                              //     } catch (e) {
                              //       print(e.toString());
                              //       return showDialog(
                              //         context: context,
                              //         builder: (ctx) => AlertDialog(
                              //           title: Text(
                              //             "Failed to Login in!",
                              //             style: GoogleFonts.poppins(
                              //                 textStyle:
                              //                 TextStyle(color: Colors.red)),
                              //           ),
                              //           content: Text(
                              //             "Error - ${e.toString()}",
                              //             style: GoogleFonts.poppins(),
                              //           ),
                              //           actions: <Widget>[
                              //             FlatButton(
                              //               onPressed: () {
                              //                 Navigator.of(ctx).pop();
                              //               },
                              //               child: Text(
                              //                 "Close",
                              //                 style: GoogleFonts.poppins(),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //     }
                              //   },
                              //   child: Container(
                              //     alignment: Alignment.center,
                              //     width:
                              //         MediaQuery.of(context).size.width / 1.7,
                              //     height: 55,
                              //     decoration: BoxDecoration(
                              //       border: Border.all(
                              //           color: Colors.grey.shade300, width: 2),
                              //       borderRadius: BorderRadius.circular(15),
                              //     ),
                              //     child: Align(
                              //         alignment: Alignment.center,
                              //         child: Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.center,
                              //           children: [
                              //             Container(
                              //                 margin: EdgeInsets.only(left: 10),
                              //                 child: Image.asset(
                              //                   'assets/google.png',
                              //                   width: 30,
                              //                   height: 30,
                              //                 )),
                              //             SizedBox(
                              //               width: 16,
                              //             ),
                              //             Padding(
                              //               padding:
                              //                   const EdgeInsets.only(right: 8),
                              //               child: Align(
                              //                 alignment: Alignment.centerRight,
                              //                 child: Text(
                              //                   'Sign In with Google',
                              //                   style: GoogleFonts.poppins(),
                              //                 ),
                              //               ),
                              //             )
                              //           ],
                              //         )),
                              //   ),
                              // ),
                              SizedBox(
                                height: 14,
                              ),
                              Container(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have a account?",
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  GestureDetector(
                                    onTap: () => widget.toggle(),
                                    child: Text(
                                      'Create one!',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 12),
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

