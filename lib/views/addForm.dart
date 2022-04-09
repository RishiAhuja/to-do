import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddForm extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String photo;
  final String docList;
  AddForm({this.userName, this.userEmail, this.photo, this.docList});
  @override
  _AddFormState createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  DateTime pickedDate;
  TimeOfDay time;
  String resultTime;
  String resultDate;
  bool _dark = false;




  //----------------
  Color _whiteBlack = Colors.white;
  Color _blackWhite = Colors.black;
  Color _greyWhite = Colors.grey.shade500;
  //----------------
  @override
  void initState() {
    super.initState();
    pickedDate = DateTime.now();
    time = TimeOfDay.now();
    getThemeData();
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    if(format.format(dt).toString().contains('PM'))
    {
      var date = format.format(dt).toString().replaceAll("PM", "");
      print(date);
      setState(() {
        resultTime = date;
      });
    }
    if(format.format(dt).toString().contains('AM'))
    {
      var date = format.format(dt).toString().replaceAll("AM", "");
      print(date);
      setState(() {
        resultTime = date;
      });
    }

    print('${pickedDate.year}/${pickedDate.month}/${pickedDate.day}');
    resultDate = '${pickedDate.year}/${pickedDate.month}/${pickedDate.day}';
  }


  getThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool dark = prefs.getBool('dark');
    print(dark);
    if(dark == false){
      setState(() {
        _whiteBlack = Colors.white;
        _blackWhite = _blackWhite;
        _greyWhite = Colors.grey.shade500;
        _dark = false;
      });
    }
    if(dark == true){
      setState(() {
        _whiteBlack = Colors.black;
        _blackWhite = Colors.white;
        _greyWhite = Colors.white;
        _dark = true;
      });
    }
  }
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await DatePicker.showDateTimePicker(context, showTitleActions: true);
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(
        context: context,
        initialTime: time
    );
    if(t != null)
      setState(() {
        time = t;
        print(time.toString());
        final now = new DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
        final format = DateFormat.jm();
        if(format.format(dt).toString().contains('PM'))
          {
            var date = format.format(dt).toString().replaceAll("PM", "");
            print(date);
          }
        if(format.format(dt).toString().contains('AM'))
        {
          var date = format.format(dt).toString().replaceAll("AM", "");
          print(date);
        }
        print( format.format(dt));
      });
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year-5),
      lastDate: DateTime(DateTime.now().year+5),
      initialDate: pickedDate,
    );
    if(date != null)
      setState(() {
        pickedDate = date;
        print('${pickedDate.day}/${pickedDate.month}/${pickedDate.year}');
        resultDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
  }

  String _dateString;
  String _timeString;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _taskController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _getDate() {
    final String formattedDateTime =
    DateFormat('dd-MM-yy').format(DateTime.now()).toString();
    setState(() {
      _dateString = formattedDateTime;
      print(_dateString);
    });
  }

  void _getTime() {
    final String formattedDateTime =
    DateFormat('kk:mm:ss').format(DateTime.now()).toString();
    setState(() {
      _timeString = formattedDateTime;
      print(_timeString);
    });
  }


  uploadTask()
  async{
    _getDate();
    _getTime();
    // FirebaseMessaging().onTokenRefresh.listen((newToken) {
    //   print("token $newToken");
    // });
    // final FirebaseMessaging _fcm = FirebaseMessaging();
    // String fcmToken = await _fcm.getToken(
    //
    // );
    // print("token $fcmToken");

    String token = await FirebaseMessaging.instance.getToken();
    print("okay");
    if(_formKey.currentState.validate())
      {
        Map<String, dynamic> userMap = {
          'title': _taskController.text,
          'desc': _descController.text,
          'time': _timeString,
          'date': _dateString,
          'done': false,
          'whenToNotify': Timestamp.fromDate(_selectedDate)
        };
        Map<String, dynamic> tokenMap = {
          'token': "$token",
          'whenToNotify': Timestamp.fromDate(_selectedDate),
          'notificationSent': false,
          'title': toBeginningOfSentenceCase(_taskController.text.trim()),
          'desc': _descController.text,
          'user': toBeginningOfSentenceCase(widget.userName),
        };
        print('$tokenMap');

        FirebaseFirestore.instance.collection("${widget.userName}#${widget.userEmail}").doc('${widget.docList}').collection('${widget.docList}').add(userMap).then((value) {
          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Updated Successfully!", style: GoogleFonts.poppins(),)));
        }).catchError((_){
          // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Can't Update data!", style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.red)),)));
        });
        var randomDoc = FirebaseFirestore.instance.collection("notifications").doc();
        FirebaseFirestore.instance.collection("notifications").doc('${randomDoc.id}').set({
          'token': token,
          'whenToNotify': Timestamp.fromDate(_selectedDate),
          'notificationSent': false,
          'title': toBeginningOfSentenceCase(_taskController.text.trim()),
          'desc': _descController.text,
          'user': toBeginningOfSentenceCase(widget.userName),
          'id': randomDoc.id
        }).then((value) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Updated Successfully!", style: GoogleFonts.poppins(),)));
        }).catchError((_){
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Can't Update data!", style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.red)),)));
        });

      }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: _whiteBlack,
          ),
          onPressed: () => Navigator.pop(context),
          ),
      ),
      backgroundColor: Colors.orange,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Create a new Task!", style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: _whiteBlack,
                fontSize: 30
              )
            ),),
            Material(
              borderRadius: BorderRadius.circular(30),
              elevation: 7,
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: _whiteBlack
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/1.3,
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 2)),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.topic,
                                  color: _greyWhite,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2.2,
                                  child: TextFormField(
                                    controller: _taskController,
                                    validator: (val) {
                                      return val.toString().isEmpty || val.toString().length < 4 ? 'Provide Enter 4+ characters' : null;

                                    },
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 17, color: _blackWhite)),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Header..',
                                        hintStyle: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: _greyWhite))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _greyWhite, width: 2)),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  color: _greyWhite,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2.2,
                                  child: TextFormField(
                                    controller: _descController,
                                    validator: (val) {
                                      return null;
                                    },
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(fontSize: 17, color: _blackWhite)),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Description..',
                                        hintStyle: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: _greyWhite))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _greyWhite, width: 2),
                        ),
                        height: 50,
                        width: MediaQuery.of(context).size.width/1.3,
                        child: Align(alignment: Alignment.center, child: Text("${DateFormat.yMMMMd("en_US").format(_selectedDate)} at ${DateFormat("H:mm").format(_selectedDate)} ", style: GoogleFonts.poppins(fontSize: 20, color: _blackWhite),)),
                      ),
                    ),
                    SizedBox(height: 25,),
                    GestureDetector(
                      onTap: () => uploadTask(),
                      child: Container(
                        width: MediaQuery.of(context).size.width/1.7,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange[300],
                              Colors.orange,
                              Colors.orange[700],
                            ]
                          ),
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Add new task',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 25,
                                color: _whiteBlack
                              )
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
        ),
      ),
    );
  }
}
