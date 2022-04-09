import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/helper/settings.dart';
import 'package:task/views/addForm.dart';
import 'package:task/views/lists.dart';
import 'lists.dart';
class Todo extends StatefulWidget {
  final String name;
  final String email;
  final String photo;
  Todo({@required this.name, @required this.email, this.photo});
  @override
  _TodoState createState() => _TodoState();
}

int _currentPage = 0;

class _TodoState extends State<Todo> with TickerProviderStateMixin {
  // final Stream<QuerySnapshot> _usersStream =
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List lists = [];
  Map isChecked = {};
  List indexText = [];
  List numberList = [];
  String _currentList = 'Personal';
  List _currentColorList = [];
  List _currentListBold = [];
  List _currentTextColor = [];
  List indexes = [];
  int lastIndex;
  AnimationController _controller;
  Animation<double> _animation;
  ScrollController scrollController = new ScrollController();
  bool _dark = false;
  bool _isEmpty = false;



  //----------------
    Color _whiteBlack = Colors.white;
    Color _blackWhite = Colors.black;
    Color _greyWhite = Colors.grey;
  //----------------
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getData();
    numberList.clear();
    indexText.clear();
      // _bottomNavigationKey.currentState.setPage(1);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 5000),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    _controller.forward();
    getData();
    getThemeData();
  }
  getThemeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    bool dark = prefs.getBool('dark');
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
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future setEmptyTrue(){
    setState(() {
      _isEmpty = true;
    });
  }

  removeData(id) {
    final collection =
    FirebaseFirestore.instance.collection('${widget.name}#${widget.email}');
    collection.doc('$id').delete().then((_) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        'Delete successfully!',
        style: GoogleFonts.poppins(),
      )));
    }).catchError((error) {
      print('Delete failed: $error');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        'Delete Failed! Please try again later',
        style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.red)),
      )));
    });
  }

  getData() async {

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('${widget.name}#${widget.email}').orderBy('index', descending: false)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((data) {
      setState(() {
        lists.add(data.id);
        indexes.add(int.parse('${data['index']}'));
        var largestValue = indexes[0];
        var smallestValue = indexes[0];
        for (var i = 0; i < indexes.length; i++) {
          if (indexes[i] > largestValue) {
            largestValue = indexes[i];
          }
          if (indexes[i] < smallestValue) {
            smallestValue = indexes[i];
          }
        }

        setState(() {
          lastIndex = largestValue;
        });
        if (data.id == 'Personal') {
          _currentListBold.add(FontWeight.w800);
          _currentColorList.add(Colors.orangeAccent[200]);
          _currentTextColor.add(_whiteBlack);
        } else {
          _currentListBold.add(FontWeight.normal);
          _currentColorList.add(_whiteBlack);
          _currentTextColor.add(_blackWhite);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  if(index == 1){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          Lists(lists: lists, collection: '${widget.name}#${widget.email}', index: lastIndex,)
                      )
                    );
                  }

                  if(index == 2){
                   Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  }
                },
                selectedItemColor: Colors.orange,
                backgroundColor: _whiteBlack,
                currentIndex: 0, // this will be set when a new tab is tapped
                items: [
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.home, ),
                    label: 'Home'
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.list, color: _greyWhite),
                      label: 'Lists'
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings, color: _greyWhite),
                      label: 'Settings'
                  )
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => Navigator.push(
            context,
            SlideRightRoute(
                page: AddForm(
              userName: widget.name,
              userEmail: widget.email,
              photo: widget.photo,
              docList: _currentList,
            ))),
        child: Icon(Icons.add, color: _whiteBlack),
      ),
      backgroundColor: Colors.orange,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 40),
            Row(
              children: [
                Container(padding: EdgeInsets.only(left: 10),
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.123,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: lists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentList = '${lists[index]}';
                              if (_currentColorList
                                  .contains(Color(0xffffab40))) {
                                _currentColorList[_currentColorList
                                    .indexOf(Color(0xffffab40))] = _whiteBlack;
                              }

                              if (_currentListBold.contains(FontWeight.w800)) {
                                _currentListBold[_currentListBold.indexOf(
                                    FontWeight.w800)] = FontWeight.normal;
                              }
                             if(_dark == false){
                               if (_currentTextColor
                                   .contains(Color(0xffffffff))) {
                                 _currentTextColor[_currentTextColor.indexOf(
                                     Color(0xffffffff))] = _blackWhite;
                               }
                             }
                              if(_dark == true){
                                if (_currentTextColor
                                    .contains(Color(0xff000000))) {
                                  _currentTextColor[_currentTextColor.indexOf(
                                      Color(0xff000000))] = _blackWhite;
                                }
                              }

                              _currentColorList[index] =
                                  Colors.orangeAccent[200];
                              _currentListBold[index] = FontWeight.w800;
                              _currentTextColor[index] = _whiteBlack;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(30)),
                                  depth: -4,
                                  shadowLightColorEmboss: Colors.white54,
                                  surfaceIntensity: 0,
                                  lightSource: LightSource.topLeft,
                                  color: _currentColorList[index]),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${lists[index]}',
                                    style: GoogleFonts.poppins(
                                        fontWeight: _currentListBold[index],
                                        color: _currentTextColor[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
                GestureDetector(
                  onTap: ()
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Lists(lists: lists, collection: '${widget.name}#${widget.email}', index: lastIndex,),)
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.add,
                      color: _whiteBlack,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            SizedBox(height: 5),
            Neumorphic(
              style: NeumorphicStyle(
                  shape: NeumorphicShape.convex,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.vertical(top: Radius.circular(30))),
                  depth: -4,
                  shadowLightColorEmboss: Colors.white54,
                  surfaceIntensity: 0,
                  lightSource: LightSource.topLeft,
                  color: _whiteBlack),
              child: Container(
                decoration: BoxDecoration(
                  color: _whiteBlack,
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.3,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 10,),
                       Container(
                         padding: EdgeInsets.only(left: 30),
                         alignment: Alignment.centerLeft,
                         child: Text(
                           '$_currentList',
                           style: GoogleFonts.poppins(
                             fontSize: 29,
                             color: _blackWhite
                           ),
                         ),
                       ),

                        SizedBox(
                          height: 17,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('${widget.name}#${widget.email}')
                              .doc('$_currentList')
                              .collection('$_currentList')
                              .where('done', isEqualTo: false)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: 25,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      'Something went wrong! Please try again Later',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: _blackWhite,
                                              fontSize: 22)),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if(!snapshot.hasData){
                              print('hell');
                            }
                            if(snapshot.hasData){
                              print(snapshot.data.docs.length);
                              if(snapshot.data.docs.length == 0){
                                print("yeah!");
                              }
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                    Text(
                                      'Loading',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: _blackWhite,
                                              fontSize: 22)),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Container(
                              // height: MediaQuery.of(context).size.height/1.6,
                              child: snapshot.data.docs.length == 0 ? Column(
                                children: [
                                  Lottie.asset('assets/not_found.json'),
                                  Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      'No tasks are added! Hit the + button to add new tasks',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: _greyWhite
                                      ),
                                    ),
                                  )
                                ],
                              ) : ListView(
                                controller: scrollController,
                                shrinkWrap: true,
                                // physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                physics: NeverScrollableScrollPhysics(),
                                children: snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data = document.data();
                                  data['id'] = document.id;
                                  snapshot.data.docs.map((document) async {
                                    List test = [];
                                    test.add(document['done'].toString());
                                  }).toList();
                                  return data.isEmpty ? Text("ok", style: TextStyle(color: _blackWhite),) : FadeTransition(
                                    opacity: _animation,
                                    child: GestureDetector(
                                      onTap: () async {
                                        bool _isSent = false;
                                        final QuerySnapshot result = await FirebaseFirestore.instance.collection('notifications').where('title', isEqualTo: toBeginningOfSentenceCase('${data['title']}')).where('whenToNotify', isEqualTo: data['whenToNotify']).where('user', isEqualTo: widget.name).get();
                                        final List<DocumentSnapshot> documents = result.docs;
                                        documents.forEach((dataNotification) {
                                          print(dataNotification.data());
                                          setState(() {
                                            _isSent = dataNotification['notificationSent'];
                                            print(dataNotification['notificationSent']);
                                            print(_isSent);
                                          });

                                          _isSent = dataNotification['notificationSent'];
                                          print(dataNotification['notificationSent']);
                                          print(_isSent);

                                        });
                                        showMaterialModalBottomSheet(

                                          context: context,
                                          builder: (context) => Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [
                                              Colors.orange[300],
                                              Colors.orange[400],
                                              Colors.orange,
                                              Colors.orange[600]
                                            ])),
                                            child: SingleChildScrollView(
                                                controller:
                                                    ModalScrollController.of(
                                                        context),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(20),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "${toBeginningOfSentenceCase('${data['title']}')}",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                  fontSize: 30,
                                                                  color: _whiteBlack,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ),
                                                    ),
                                                    data['desc'] == '' || data['desc'] == null ? Container() : Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 15,
                                                          vertical: 8),
                                                      child: Text(
                                                        "${toBeginningOfSentenceCase('${data['desc']}')}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 18,
                                                                color:
                                                                    _whiteBlack,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20,),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Container(
                                                                  alignment: Alignment.center,
                                                                  padding: EdgeInsets.all(7),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    borderRadius: BorderRadius.circular(40),
                                                                  ),
                                                                  child: Icon(Icons.clear, color: Colors.white,)
                                                              ),
                                                            ),
                                                            SizedBox(width: 8,),
                                                            Text("You still have to complete this task!", style: GoogleFonts.poppins(color: _blackWhite),)
                                                          ],

                                                        ),
                                                        SizedBox(height: 15,),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 300,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.orange[800],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add_alert,
                                                            color: _whiteBlack,
                                                          ),
                                                          Text(
                                                            '${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).hour}')}:${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).minute}')}:${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).second}')} on ${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).day}')}/${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).month}')}/${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).year}')}',
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize: 16,
                                                                    color: _blackWhite,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 20,),
                                                  ],
                                                )),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Neumorphic(
                                          style: NeumorphicStyle(
                                              shadowLightColorEmboss:
                                              Colors.white54,
                                              shape: NeumorphicShape.concave,
                                              boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                      BorderRadius.circular(12)),
                                              depth: -12,
                                              lightSource: LightSource.topRight,
                                              color: Colors.orange,
                                              surfaceIntensity: .02),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 18.0),
                                                child: AutoSizeText(
                                                    '${toBeginningOfSentenceCase('${data['title']}')}',
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 21,
                                                      color: _whiteBlack,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                              ),
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: _whiteBlack,
                                                  ),
                                                  onPressed: () async{
                                                    FirebaseFirestore.instance
                                                        .collection('${widget.name}#${widget.email}')
                                                        .doc('$_currentList')
                                                        .collection('$_currentList')
                                                        .doc('${data['id']}')
                                                        .update(
                                                            {'done': true});
                                                    final QuerySnapshot result = await FirebaseFirestore.instance.collection('notifications').where("notificationSent", isEqualTo: false).where('title', isEqualTo: data['title']).get();

                                                    final List<DocumentSnapshot> documents = result.docs;
                                                    documents.forEach((data) {
                                                        FirebaseFirestore.instance.collection('notifications').doc(document.id).update({
                                                          'notificationSend': true
                                                        });

                                                    });
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                        'Task Completed',
                                                        style:
                                                        GoogleFonts.poppins(),
                                                      ),
                                                      duration:
                                                      Duration(seconds: 2),
                                                    ));
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),


                        ExpansionTile(
                          iconColor: Colors.orange,
                          title: Text(
                            "Completed tasks",
                            style: GoogleFonts.poppins(
                              color: Colors.orange,
                                fontSize: 15.0,
                                // fontWeight: FontWeight.bold
                            ),
                          ),
                          children: <Widget>[
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('${widget.name}#${widget.email}')
                                  .doc('$_currentList')
                                  .collection('$_currentList')
                                  .where('done', isEqualTo: true)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 25,
                                          color: Colors.red,
                                        ),
                                        Text(
                                          'Something went wrong! Please try again Later',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: _blackWhite,
                                                  fontSize: 22)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if(!snapshot.hasData){
                                  print('hell');
                                }
                                if(snapshot.hasData){
                                  print(snapshot.data.docs.length);
                                  if(snapshot.data.docs.length == 0){
                                    print("yeah!");
                                  }
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.orange,
                                        ),
                                        Text(
                                          'Loading',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: _blackWhite,
                                                  fontSize: 22)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Container(
                                  // height: MediaQuery.of(context).size.height/1.6,
                                  child: snapshot.data.docs.length == 0 ? Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Text(
                                          'No tasks are completed',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: _greyWhite
                                          ),
                                        ),
                                      )
                                    ],
                                  ) : ListView(
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: snapshot.data.docs
                                        .map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document.data();
                                      data['id'] = document.id;
                                      snapshot.data.docs.map((document) async {
                                        List test = [];
                                        test.add(document['done'].toString());
                                      }).toList();
                                      return data.isEmpty ? Text("ok", style: TextStyle(color: _blackWhite),) : FadeTransition(
                                        opacity: _animation,
                                        child: GestureDetector(
                                          onTap: () async {
                                            bool _isSent = false;
                                            final QuerySnapshot result = await FirebaseFirestore.instance.collection('notifications').where('title', isEqualTo: toBeginningOfSentenceCase('${data['title']}')).where('whenToNotify', isEqualTo: data['whenToNotify']).where('user', isEqualTo: widget.name).get();
                                            final List<DocumentSnapshot> documents = result.docs;
                                            documents.forEach((dataNotification) {
                                              print(dataNotification.data());
                                              setState(() {
                                                _isSent = dataNotification['notificationSent'];
                                                print(dataNotification['notificationSent']);
                                                print(_isSent);
                                              });

                                              _isSent = dataNotification['notificationSent'];
                                              print(dataNotification['notificationSent']);
                                              print(_isSent);

                                            });
                                            showMaterialModalBottomSheet(

                                              context: context,
                                              builder: (context) => Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(colors: [
                                                      Colors.orange[300],
                                                      Colors.orange[400],
                                                      Colors.orange,
                                                      Colors.orange[600]
                                                    ])),
                                                child: SingleChildScrollView(
                                                    controller:
                                                    ModalScrollController.of(
                                                        context),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.all(20),
                                                          child: Align(
                                                            alignment:
                                                            Alignment.center,
                                                            child: Text(
                                                              "${toBeginningOfSentenceCase('${data['title']}')}",
                                                              style:
                                                              GoogleFonts.poppins(
                                                                  fontSize: 30,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                          ),
                                                        ),
                                                        data['desc'] == '' || data['desc'] == null ? Container() : Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 15,
                                                              vertical: 8),
                                                          child: Text(
                                                            "${toBeginningOfSentenceCase('${data['desc']}')}",
                                                            textAlign:
                                                            TextAlign.center,
                                                            style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 18,
                                                                color:
                                                                _whiteBlack,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20,),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Align(
                                                                  alignment: Alignment.center,
                                                                  child: Container(
                                                                      alignment: Alignment.center,
                                                                      padding: EdgeInsets.all(7),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.green,
                                                                        borderRadius: BorderRadius.circular(40),
                                                                      ),
                                                                      child: Icon(Icons.done, color: Colors.white,)
                                                                  ),
                                                                ),
                                                                SizedBox(width: 8,),
                                                                Text("You completed this task", style: GoogleFonts.poppins(color: Colors.white),)
                                                              ],

                                                            ),
                                                            SizedBox(height: 15,),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: 300,
                                                          height: 60,
                                                          decoration: BoxDecoration(
                                                              color:
                                                              Colors.orange[800],
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30)),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              Icon(
                                                                Icons.add_alert,
                                                                color: _whiteBlack,
                                                              ),
                                                              Text(
                                                                '${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).hour}')}:${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).minute}')}:${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).second}')} on ${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).day}')}/${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).month}')}/${toBeginningOfSentenceCase('${DateTime.parse(data['whenToNotify'].toDate().toString()).year}')}',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                    fontSize: 16,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 20,),
                                                      ],
                                                    )),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                  shadowLightColorEmboss:
                                                  Colors.white54,
                                                  shape: NeumorphicShape.concave,
                                                  boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                      BorderRadius.circular(12)),
                                                  depth: -12,
                                                  lightSource: LightSource.topRight,
                                                  color: Colors.orange,
                                                  surfaceIntensity: .02),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 18.0),
                                                    child: AutoSizeText(
                                                        '${toBeginningOfSentenceCase('${data['title']}')}',
                                                        overflow:
                                                        TextOverflow.visible,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 21,
                                                          color: _whiteBlack,
                                                          fontWeight: FontWeight.bold,
                                                        )),
                                                  ),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: _whiteBlack,
                                                          ),
                                                          onPressed: () async{
                                                            FirebaseFirestore.instance
                                                                .collection('${widget.name}#${widget.email}')
                                                                .doc('$_currentList')
                                                                .collection('$_currentList')
                                                                .doc('${data['id']}')
                                                                .delete();
                                                            _scaffoldKey.currentState
                                                                .showSnackBar(SnackBar(
                                                              content: Text(
                                                                'Task deleted',
                                                                style:
                                                                GoogleFonts.poppins(),
                                                              ),
                                                              duration:
                                                              Duration(seconds: 2),
                                                            ));
                                                          }),
                                                      IconButton(
                                                          icon: Icon(
                                                            Icons.clear,
                                                            color: _whiteBlack,
                                                          ),
                                                          onPressed: () async{
                                                            FirebaseFirestore.instance
                                                                .collection('${widget.name}#${widget.email}')
                                                                .doc('$_currentList')
                                                                .collection('$_currentList')
                                                                .doc('${data['id']}')
                                                                .update(
                                                                {'done': false});
                                                            final QuerySnapshot result = await FirebaseFirestore.instance.collection('notifications').where("notificationSent", isEqualTo: false).where('title', isEqualTo: data['title']).get();

                                                            final List<DocumentSnapshot> documents = result.docs;
                                                            documents.forEach((data) {
                                                              FirebaseFirestore.instance.collection('notifications').doc(document.id).update({
                                                                'notificationSend': true
                                                              });

                                                            });
                                                            _scaffoldKey.currentState
                                                                .showSnackBar(SnackBar(
                                                              content: Text(
                                                                'Task uncompleted',
                                                                style:
                                                                GoogleFonts.poppins(),
                                                              ),
                                                              duration:
                                                              Duration(seconds: 2),
                                                            ));
                                                          })
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 35,)
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

}
