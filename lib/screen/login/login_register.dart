
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_todo/auth/auth_provider.dart';
import 'package:simple_todo/utils/helper.dart';
import 'package:simple_todo/utils/style.dart';

class LoginPage extends StatefulWidget {
  final bool isLoginForm;

  const LoginPage({Key key, this.isLoginForm}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState(this.isLoginForm);
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  _LoginPageState(this.isLoginForm);
  bool loading=false;
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  bool isLoginForm = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
        body: Container(
          color: Color(0xFFF9FCFF),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: SizedBox(),
              ),
              Expanded(
                flex: 3,
                child: Form(
                  key: formKey,
                  onChanged: (){
                    formKey.currentState.validate();
                  },
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    children: <Widget>[
                      Center(
                        child: Text(
                          isLoginForm?"Login":"Register",
                          style: Login1Style,
                        ),
                      ),
                      Helper.emptyVSpace(30.0),
                      TextFormField(
                        validator: (v){
                          Pattern pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(v))
                            return 'email is invalid';
                          else
                            return null;
                        },
                        style: InputText1Style,
                        decoration:
                        InputDecoration(hintText: "Email", hintStyle: Hint1Style),
                        controller: _emailController,
                      ),
                      Helper.emptyVSpace(10.0),
                      TextFormField(
                        validator: (v){
                          if(isLoginForm) {
                            if (v.isEmpty) {
                              return "Must be filled!";
                            }
                          } else {
                            if(v.length<=6){
                              return "Must greater than 6";
                            }
                          }
                          return null;
                        },
                        style: InputText1Style,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Password", hintStyle: Hint1Style),
                        controller: _passwordController,
                      ),
                      Helper.emptyVSpace(30.0),
                      _signinButton(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: (){
                      if(isLoginForm){
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (_)=>LoginPage(isLoginForm: false,)
                        ));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (_)=>LoginPage(isLoginForm: true,)
                        ));
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Text(isLoginForm?"Don't have an account?":"Already have an account?",style: Text1Style,),
                        Helper.emptyVSpace(5.0),
                        Text(isLoginForm?"Sign up":"Sign in",style: Text2Style,)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }



  bool _validateAndSave(){
    final FormState formState = formKey.currentState;
    if(formState.validate()){
      formState.save();
      return true;
    }
    return false;
  }
  _buttonHandler() async{
    if(_validateAndSave()){
      try{
        setState(() {
          loading=true;
        });
        final auth = AuthProvider.of(context).auth;
        if(isLoginForm){

          await auth.signInWithEmailAndPassword(_emailController.text, _passwordController.text);
          _key.currentState.showSnackBar(new SnackBar(content: Text("Login successful!")));


        } else {
          FirebaseApp app = await FirebaseApp.configure(
              name: 'Secondary', options: await FirebaseApp.instance.options);
          var res = await FirebaseAuth.fromApp(app)
              .createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
          if(res.user.uid!=null){
            _key.currentState.showSnackBar(new SnackBar(content: Text("Register successful!")));
            Future.delayed(Duration(seconds: 1),(){
              Navigator.pushReplacement(context,MaterialPageRoute(
                  builder: (_)=>LoginPage(isLoginForm: true,)
              ));
            });

          }

        }
      } catch(e){
        List<String> errors = e.toString().split(',');
        setState(() {
          loading=false;
        });
        _key.currentState.showSnackBar(new SnackBar(content: Text("${errors[1]}")));
        print("Error $e");
      }
    }
  }



  Widget _signinButton() {
    return Container(
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
          onTap: (){
            _buttonHandler();
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
                    isLoginForm?"Login":"Register",
                    style: LoginButton1Style,
                  ),
                ],
              )),
        ),
      ),
    );
  }

}
