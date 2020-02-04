
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_todo/auth/auth.dart';
import 'package:simple_todo/model/todo.dart';
import 'package:simple_todo/repository/repo.dart';
import 'package:simple_todo/utils/helper.dart';
import 'package:simple_todo/utils/style.dart';

class AddTaskBottomSheet extends StatefulWidget {
  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> with SingleTickerProviderStateMixin{
  GlobalKey<ScaffoldState> _key  = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formState  = new GlobalKey<FormState>();

   TabController _tabController ;
   final _dataController = new TextEditingController();
   String uid;
   bool loading =false;

   getUID()async{
     final auth = Auth();
       uid = await auth.currentUser();
   }
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 5, vsync: this);
    getUID();
  }


  List<Widget> getTabs(){
    List<Widget> data=[];
    List<Color> color = [Color(0xFFFFD506),Color(0xFF1ED102),Color(0xFFD10263),Color(0xFF3044F2),Color(0xFFF29130)];
    for(int i=0;i<color.length;i++){
      data.add(new Container(
        decoration: BoxDecoration(
          color: color[i],
          shape: BoxShape.circle,
        ),
        width: 15,
        height: 15,

      ));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        key: _key,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40)),
          ),
          child: Form(
            key: _formState,
            onChanged: (){
              _formState.currentState.validate();
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding:EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          height: 4,
                          color: Color(0xFF707070),
                        ),
                      ),
                      Helper.emptyVSpace(30.0),
                      Align(
                        alignment: Alignment.center,
                        child: Text("Add new task",style: Text6Style,),
                      ),
                      Helper.emptyVSpace(25.0),
                      TextFormField(
                        validator: (v){
                          if(v.isEmpty){
                            return "Must be filled!";
                          }
                          return null;
                        },
                        controller: _dataController,
                        style: InputText2Style,
                        decoration: InputDecoration(
                          hintText: "Its awesome day!",
                          border:InputBorder.none,
                        ),
                        maxLines: 15,
                        minLines: 10,

                      ),

                      Helper.emptyVSpace(10.0),


                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: _levels(),
                ),
                Expanded(
                  flex: 0,
                  child: _addTaskButton(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _levels(){
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal:15.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        Divider(color: Color(0xFFCFCFCF),thickness: 2,),
        Helper.emptyVSpace(5.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: TabBar(

              labelPadding: EdgeInsets.all(10.0),
              indicatorSize: TabBarIndicatorSize.label,
              controller: _tabController,
              indicatorColor: Color(0xFF707070),
              tabs:getTabs()
          ),

        ),
        Helper.emptyVSpace(5.0),
        Divider(color: Color(0xFFCFCFCF),thickness: 2,),
      ],
    );
  }

   Widget _addTaskButton() {

     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
       child: Container(
         height: 55,
         width: double.maxFinite,
         decoration: BoxDecoration(
             boxShadow: [
               BoxShadow(
                   color: Color(0xFF6894EE), blurRadius: 3.0, offset: Offset(0, 3))
             ],
             borderRadius: BorderRadius.circular(5),
             gradient: LinearGradient(
               colors: [
                 Color(0xFF7EB6FF),
                 Color(0xFF5F87E7),
               ],
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,
             )),
         child: Material(
           type: MaterialType.transparency,
           child: InkWell(
             splashColor: Colors.blue[900].withOpacity(0.2),
             highlightColor: Colors.transparent,
             onTap: () async{
               if(_formState.currentState.validate()) {
                 setState(() {
                   loading = true;
                 });
                 var db = new DB();
                 var todo = new Todo(uid: uid,
                     level: _tabController.index + 1,
                     data: _dataController.text,
                     timestamp: Timestamp.now());
                 var res = await db.createData(todo);
                 if (res != null) {
                   setState(() {
                     loading = false;
                   });

                   _key.currentState.showSnackBar(
                       new SnackBar(content: Text("Success!")));
                   Future.delayed(Duration(seconds: 1), () {
                     Navigator.of(context).pop();
                   });
                 }
               }


             },
             child: Center(
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: <Widget>[
                     loading?CircularProgressIndicator(
                       strokeWidth: 1,
                       valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                       backgroundColor: Colors.blue,):Container(),
                     Helper.emptyHSpace(10.0),
                     Text(
                       "Add Task",
                       style: LoginButton1Style,
                     ),
                   ],
                 )),
           ),
         ),
       ),
     );
   }
}
