import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_todo/auth/auth.dart';
import 'package:simple_todo/screen/home/home.dart';
import 'package:simple_todo/screen/login/login_register.dart';

import 'auth/auth_provider.dart';

void main() => runApp(Root());


class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Simple Todo",
        home: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent,systemNavigationBarColor: Colors.transparent),
            child: MyApp()),
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final BaseAuth auth = AuthProvider.of(context).auth;
    return StreamBuilder<String>(
      stream: auth.onAuthStateChanged,
      builder: (BuildContext context,AsyncSnapshot<String> snapshots) {
        if (snapshots.connectionState == ConnectionState.active) {
          return snapshots.hasData ? Home() : LoginPage(isLoginForm: true,);
        }
        return _waitingScreen();
      },
    );
  }

  Widget _waitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
