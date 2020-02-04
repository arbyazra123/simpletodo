import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_todo/model/todo.dart';

class DB {
  final db = Firestore.instance;

  Stream<QuerySnapshot> init() {
    return db.collection('users').snapshots();
  }

  Future<String> createData(Todo todo) async {
    var r = await db.collection('users').document(todo.uid).collection("data").add({
      "level":todo.level,
      "data":todo.data,
      "timestamp":todo.timestamp
    });
    return r.documentID;

  }

  void deleteData(Todo todo) async {
    await db.collection('users').document(todo.uid).delete();
  }

  // Should not be inside here but probably inside a todoObject

}

DB db = DB();