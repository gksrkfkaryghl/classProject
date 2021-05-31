import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herehear/home.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount _currentUser;
  User currentUser;
  User user;
  String displayName = "";
  String email = "";
  String photoURL = "";

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if(_currentUser != null) {
        print('here!');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(currentUser: _currentUser),
            ),
          );
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<User> _handlegoogleSignIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      currentUser = await FirebaseAuth.instance.currentUser;
      assert(user.uid == currentUser.uid);
      print('fin!!');

      // Once signed in, return the UserCredential
      return user;
      Navigator.pushNamed(context, '/home');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleGuestSignIn() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushNamed(context, '/home');
    } catch (error) {
      print('error: $error');
    }
  }

  Widget _buildBody() {
    return RaisedButton(
      color: Colors.blue,
      child: Row(
        children: [
          Text('G', style: TextStyle(color: Colors.white, fontSize: 24)),
          SizedBox(width: 20),
          Text('Google', style: TextStyle(color: Colors.white)),
        ],
      ),
      onPressed: () async {
        user = await _handlegoogleSignIn();
        setState(() {
          print('set!!: ${user}');
          email = user.email;
          photoURL = user.photoURL;
          displayName = user.displayName;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // GoogleSignInAccount user = _currentUser;
    print('?: $_currentUser}');
    // if(user != null) {
    //   print('????: $user');
    //   // Future.delayed(Duration(milliseconds: 500),(){
    //   //   Navigator.push(
    //   //     context,
    //   //     MaterialPageRoute(
    //   //       builder: (context) => HomePage(currentUser: _currentUser),
    //   //     ),
    //   //   );
    //   // });

    //   //이렇게 하면 'Failed assertion: line 5253 pos 12: '!_debugLocked': is not true.' 에러는 안나지만
    //   //TextFormField 들어간 페이지들이 튕깁니다.
    //   // WidgetsBinding.instance.addPostFrameCallback((_){
    //   //   Navigator.push(
    //   //     context,
    //   //     MaterialPageRoute(
    //   //       builder: (context) => HomePage(currentUser: _currentUser),
    //   //     ),
    //   //   );
    //   // });
    //   // return Center(
    //   //   child: SizedBox(
    //   //     child: CircularProgressIndicator(
    //   //       valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
    //   //     ),
    //   //     height: 40.0,
    //   //     width: 40.0,
    //   //   ),
    //   // );
    // }
    // else {
      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 80.0),
              Column(
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Image.asset('assets/images/logo.png', width: MediaQuery.of(context).size.width*0.3,),
                  SizedBox(height: 16.0),
                  Text('히얼', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),),
                ],
              ),
              SizedBox(height: 120.0),
              _buildBody(),
              RaisedButton(
                color: Colors.grey,
                child: Row(
                  children: [
                    Container(child: Text('?', style: TextStyle(color: Colors.white, fontSize: 24))),
                    SizedBox(width: 20),
                    Text('Guest', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                onPressed: () => _handleGuestSignIn(),
              ),
            ],
          ),
        ),
      );
  }
}
