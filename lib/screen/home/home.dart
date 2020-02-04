
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_todo/auth/auth.dart';
import 'package:simple_todo/auth/auth_provider.dart';
import 'package:simple_todo/screen/home/add_task_bottom_sheet.dart';
import 'package:simple_todo/utils/helper.dart';
import 'package:simple_todo/utils/style.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String name;
  String uid;
  getUser()async{
    final auth = new Auth();
    FirebaseUser user = await auth.user();
    setState(() {
      name = user.email.split("@")[0];
      uid = user.uid;
    });
  }
  DateTime _now = DateTime.now();
  DateTime _start;
  DateTime _end;
  DateTime _startYesterday;
  DateTime _endYesterday;

  int tasks=0;

  @override
  void initState() {
    super.initState();
    getUser();

    _now = DateTime.now();
    _start = DateTime(_now.year, _now.month, _now.day, 0, 0);
    _end = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);
    _startYesterday = DateTime(_now.year, _now.month, _now.day-1, 0, 0);
    _endYesterday = DateTime(_now.year, _now.month, _now.day-1, 23, 59, 59);
  }


  void _showAddTask() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.8,

            child: AddTaskBottomSheet(),
          );
        }
    );
  }




  Color getColor(int value){
    List<Color> color = [Color(0xFFFFD506),Color(0xFF1ED102),Color(0xFFD10263),Color(0xFF3044F2),Color(0xFFF29130)];
    return color[value];
  }
  String getDate(Timestamp timestamp){
    return DateFormat("hh:mm a").format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider.of(context).auth;
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          elevation: 0,
          brightness: Brightness.dark,
          backgroundColor: Colors.white.withOpacity(0.0),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: ()async{
                await auth.signOut();
              },
            ),
          ],
          flexibleSpace: Image.asset('assets/bg/bg_top.png',fit: BoxFit.cover,),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15,0, 15,25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Hello $name",style: Text7Style,),
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection("users").document(uid).collection("data").where('timestamp', isGreaterThanOrEqualTo: _startYesterday)
                          .where('timestamp', isLessThanOrEqualTo: _end) .snapshots(),
                      builder: (_,snapshot){
                        if (!snapshot.hasData) return new Text("You have 0 tasks",style: Text7StyleMini,);
                        if (snapshot.data.documents.length==0) return new Text("You have 0 tasks",style: Text7StyleMini,);
                        return Text("You have ${snapshot.data.documents.length} tasks",style: Text7StyleMini,);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _todayWidget(),
          Helper.emptyVSpace(10.0),
          _tomorrowWidget()
        ],
      ),
      floatingActionButton: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(1000),
          onTap: (){
            _showAddTask();
          },
          child: Container(
            margin: EdgeInsets.all(10),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              image: DecorationImage(
                image: AssetImage("assets/icons/add_button.png"),
                fit: BoxFit.contain
              )
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _todayWidget(){
    return Container(
      height: 350,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Helper.emptyVSpace(20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
              child: Text("Today",style: Text3Style,),
            ),
            Helper.emptyVSpace(20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("users").document(uid).collection("data").where('timestamp', isGreaterThanOrEqualTo: _start)
                    .where('timestamp', isLessThanOrEqualTo: _end) .snapshots(),
                builder: (_,snapshot){

                  if (!snapshot.hasData) return Center(child: new Text("There is no data today",style: Text6Style,textAlign: TextAlign.center  ,));
                  if (snapshot.data.documents.length==0) return Center(child: new Text("There is no data today",style: Text6Style,textAlign: TextAlign.center  ,));
                  final docs = snapshot.data.documents;
                  return new ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (_,i){
                      return _dataList(docs[i]);
                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _dataList(DocumentSnapshot docs){

    return Padding(
      padding: const EdgeInsets.only(bottom:15.0),
      child: Container(
        width: double.maxFinite,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05),offset: Offset(0,4),blurRadius: 9)
            ],
            borderRadius: BorderRadius.circular(5)
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
                left: 0,
                child: Container(

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5)),
                      color: getColor(docs['level']-1),
                      boxShadow: [
                        BoxShadow(color: getColor(docs['level']-1).withOpacity(0.3),offset: Offset(0,3),blurRadius: 6)
                      ]
                  ),
                  height: 60,
                  width: 5,
                )),
            Container(

              child: Row(
                children: <Widget>[
                  Expanded(
                      flex:2,
                      child: Center(child: Text(getDate(docs['timestamp']).toString(),style: Text4Style,))),
                  Expanded(
                      flex:5,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Text(docs['data'],style: Text5Style,overflow: TextOverflow.ellipsis,),
                      ))
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _tomorrowWidget(){
    return Container(
      height: 300,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Helper.emptyVSpace(20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
              child: Text(DateFormat("EEE, MMM d").format(DateTime(_now.year,_now.month,_now.day-1)),style: Text3Style,),
            ),
            Helper.emptyVSpace(20.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("users").document(uid).collection("data").where('timestamp', isGreaterThanOrEqualTo: _startYesterday)
                    .where('timestamp', isLessThanOrEqualTo: _endYesterday) .snapshots(),
                builder: (_,snapshot){

                  if (!snapshot.hasData) return Center(child: new Text("There is no data yesterday",style: Text6Style,textAlign: TextAlign.center  ,));
                  if (snapshot.data.documents.length==0) return Center(child: new Text("There is no data yesterday",style: Text6Style,textAlign: TextAlign.center  ,));
                  final docs = snapshot.data.documents;
                  return new ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (_,i){
                      return _dataList(docs[i]);
                    },
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

