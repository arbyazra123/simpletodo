import 'package:flutter/material.dart';

class Helper{
  static Widget emptyVSpace (space){
    return Padding(padding: EdgeInsets.only(top: space),);
  }

  static Widget emptyHSpace (space){
    return Padding(padding: EdgeInsets.only(left: space),);
  }

  static const loginColor = Color(0xFF554E8F);
  static const hintColor = Color(0xFFACABAB);
  static const inputColor = Color(0xFF373737);
  static const greyBlue = Color(0xFF82A0B7);
  static const greyPurple = Color(0xFF8B87B3);
  static const grey = Color(0xFFC6C6C8);
  static const darkGrey = Color(0xFF404040);

}