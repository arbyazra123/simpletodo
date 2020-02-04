
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Todo{
  final String uid;
  final int level;
  final String data;
  final Timestamp timestamp;

  Todo({@required this.uid,this.data,this.level,this.timestamp});

}