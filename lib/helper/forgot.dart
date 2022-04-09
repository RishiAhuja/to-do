import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _send = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  sendResetEmail()
  async{
    if(_formKey.currentState.validate())
      {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim()).then((value) {
          setState(() {
            _send = true;
          });
        });
      }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              children: [
                Container(
                  child: Text(
                    'Please enter your Email',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                SizedBox(height: 15,),
                Lottie.asset('assets/forgot.json'),
                SizedBox(height: 55,),
                Material(
                  color: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.3,
                    margin: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 2)),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 12),
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
                                  width: MediaQuery.of(context).size.width / 2.2,
                                  child: TextFormField(
                                    controller: _emailController,
                                    validator: (val) {
                                      return RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(val.toString())
                                          ? null
                                          : "Please enter correct email";
                                    },
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 17)),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Email..',
                                        hintStyle: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: Colors.grey.shade500))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25,),
                        _send ? Text('Password Reset email send!', style: GoogleFonts.montserrat(),) : Container(),
                        GestureDetector(
                          onTap: () => sendResetEmail(),
                          child: Container(
                            child: Material(
                              elevation: 7,
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: MediaQuery.of(context).size.width/1.7,
                                height: 65,
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
                                    'Reset password',
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white
                                      )
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
