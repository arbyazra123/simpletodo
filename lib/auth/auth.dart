import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<FirebaseUser> user();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<String> get onAuthStateChanged{
    return _firebaseAuth.onAuthStateChanged.map((FirebaseUser user)=>user?.uid);
  }
  @override
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    final user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.user.uid;
  }

  @override
  Future<String> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  @override
  Future<FirebaseUser> user() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}