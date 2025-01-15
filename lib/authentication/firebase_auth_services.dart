
import 'package:firebase_auth/firebase_auth.dart';

class firebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;

  //Creating a method for signup authentication it store user detail for signing in
  Future<User?> SignUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }
    catch (e) {
      print("Something Wrong");
    }
    return null;

  }

  //Creating a method for signing in authentication it will check whether the user if authenticated or not
  Future<User?> SignInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }
    catch (e) {
      print("Invalid User");
    }
    return null;

  }
}