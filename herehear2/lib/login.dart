import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert' show json;
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount _currentUser;

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
        Navigator.pushNamed(context, '/home');
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handlegoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
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
      onPressed: _handlegoogleSignIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount user = _currentUser;
    if(user != null) {
      Navigator.pushNamed(context, '/home');
    }
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
              onPressed: _handleGuestSignIn,
            ),
          ],
        ),
      ),
    );
  }
}
