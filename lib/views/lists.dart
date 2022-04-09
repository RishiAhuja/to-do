import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/helper/authenicate.dart';
import 'package:task/helper/settings.dart';

class Lists extends StatefulWidget {

  final List lists;
  final String collection;
  final int index;
  Lists({this.lists, this.collection, this.index});
  @override
  _ListsState createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final TextEditingController list = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 1;
  List dataList = [];
  int _index;
  bool _dark = false;

  //----------------
  Color _whiteBlack = Colors.white;
  Color _blackWhite = Colors.black;
  Color _greyWhite = Colors.grey;
  //----------------
  
  @override

  void _restartApp() async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
  }
  getThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool dark = prefs.getBool('dark');
    print(dark);
    if(dark == false){
      setState(() {
        _whiteBlack = Colors.white;
        _blackWhite = Colors.black;
        _greyWhite = Colors.grey;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getThemeData();
    print("helo!");
    print('${widget.index}');
    setState(() {
      dataList = widget.lists;
      _index = widget.index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            print(index);
            if(index == 0){
              Navigator.pop(context);
            }
            if(index == 2){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
            }
          },
          selectedItemColor: Colors.orange,
          backgroundColor: _whiteBlack,
          currentIndex: 1, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home, color: _greyWhite),
              label: 'Home'
              // title: new Text('Home', style: GoogleFonts.poppins(color: _greyWhite),),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.list),
              label: 'Lists'
              // title: new Text('Lists', style: GoogleFonts.poppins(),),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings, color: _greyWhite),
                label: 'Settings'
                // title: Text('Settings', style: GoogleFonts.poppins(color: _greyWhite),)
            )
          ],
        ),
        key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: _whiteBlack),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: _whiteBlack,
                  content: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Positioned(
                        right: -40.0,
                        top: -40.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(Icons.close, color: _whiteBlack),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Form(
                                key: _formKey2,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                  child: TextFormField(
                                    controller: list,
                                    validator: (val){
                                      return val.length <=3 || val.length == 0 || val.isEmpty || val == null ? 'Please enter 3+ characters' : null;
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'List name..',
                                      hintStyle: GoogleFonts.poppins(color: _blackWhite)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async{
                                  int localIndex;
                                  print(_index);
                                  localIndex = _index + 1;

                                  if(_formKey2.currentState.validate()){
                                    print('validated!');
                                    await FirebaseFirestore.instance.collection("${widget.collection}").doc('${toBeginningOfSentenceCase('${list.text.trim()}')}').set({
                                      'index': localIndex
                                    }).then((value) {
                                      setState(() {
                                        _index += 1;
                                      });

                                      // Navigator.pop(context);
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Added New List', style: GoogleFonts.poppins(),)));
                                    }).catchError((_){
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Failed Adding List', style: GoogleFonts.poppins(color: Colors.red),)));

                                    });
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.orange
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Add new list',
                                      style: GoogleFonts.poppins(color: _whiteBlack, fontSize: 22),
                                    ),
                                  ),
                                ),

                              )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
      ),
      backgroundColor: _whiteBlack,


      appBar: AppBar(
        elevation: 0,
        backgroundColor: _whiteBlack,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: _blackWhite),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height/1.4,
            child: ListView.builder(
              shrinkWrap: true,
                itemCount: dataList.length,
                itemBuilder: (BuildContext context,int index){
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Neumorphic(
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                              depth: -5,
                              lightSource: LightSource.topLeft,
                              color: Colors.orange,
                              surfaceIntensity: 1
                          ),
                          child: Container(
                            height: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 17.0),
                                  child: Text(
                                    '${toBeginningOfSentenceCase('${dataList[index]}')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      color: _whiteBlack,
                                      fontWeight: FontWeight.bold

                                    ),
                                  ),
                                ),
                                GestureDetector(

                                  onTap: ()
                                    {

                                      showDialog<void>(
                                        context: context,
                                        barrierDismissible: false, // user must tap button!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: _whiteBlack,
                                            title: Text('Are you sure?', style: GoogleFonts.poppins(
                                              color: Colors.red
                                            ),),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    'Do you really want to delete the whole collection',
                                                    style: GoogleFonts.poppins(color: _blackWhite),
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Confirm', style: GoogleFonts.poppins(color: Colors.red),),
                                                onPressed: () async{
                                                  print('Confirmed');
                                                  await FirebaseFirestore.instance.collection('${widget.collection}').doc('${widget.lists[index]}').delete().then((value) => _restartApp()).onError((error, stackTrace) {
                                                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Failed Deleting List', style: GoogleFonts.poppins(color: Colors.red),)));

                                                  });
                                                  Navigator.of(context).pop();
                                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authenticate()));
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Cancel', style: GoogleFonts.poppins(color: _blackWhite)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                    },
                                  child: Padding(
                                  padding: const EdgeInsets.only(right: 17.0),
                                  child: Icon(
                                    Icons.delete, color: _whiteBlack
                                  ),
                                ))
                              ],
                            ),
                          )
                      ),
                  );
                }
            ),
          ),
        ],
      )
    );
  }
}
