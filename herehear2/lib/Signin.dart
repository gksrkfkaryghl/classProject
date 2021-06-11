import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import './methods/validators.dart';
import './methods/toast.dart';
import 'gridview.dart';
import 'home.dart';
import 'listview.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key}) : super(key: key);
  static const routeName = '/signin';


  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();

  List tagList = [];
  static String UID;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // User Firebase에 넣는 함수
  Future addUser() async {
    Map<String, dynamic> data = {
      "email": emailController.text,
      "password": passwordController.text,
      "displayname": displayController.text,
      "Scrap": [],
      "tags": tagList,
      "location": locationController.text,
      "uid": UID,
    };
    FirebaseFirestore.instance.collection('users').doc(UID).set(data);
  }

  Map<String, dynamic> documentData;

  _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  final AuthService2 _auth = AuthService2(); // 새로추가.

  _buildBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'eg) johndoe@xxx.com',
                  border: OutlineInputBorder(),
                ),
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: emailValidator,
              ),
              // Container(height: 10,),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'eg) very hard key',
                  border: OutlineInputBorder(),
                ),
                controller: passwordController,
                obscureText: true,
                validator: passwordValidator,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: FlatButton(
                  minWidth: 220,
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  color: Color(0xFF25BEFF),
                  textColor: Colors.white,
                  onPressed: () async {

                    print("Here that this  is");
                    if (!_formKey.currentState.validate()) return;
                    try {
                      setState(() => _loading = true);
                      await FirebaseFirestore.instance
                          .collection("users")
                          .where("email", isEqualTo: emailController.text)
                          .get()
                          .then((event) {
                        if (event.docs.isNotEmpty) {
                          documentData = event.docs.single.data();
                          UID = documentData["uid"];
                          print("[Sign In] current user & tags");
                          print(UID);
                          print(documentData["tags"]);

                        }
                      });

                      //password 맞는지 체크하기.
                      documentData["password"] != passwordController.text
                          ? toastError(_scaffoldKey, null)
                          : Navigator.push(
                              context,
                              //MaterialPageRoute(builder: (context) => ListViewPage(currentUser: null,target: UID,)),
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(currentUser: UID, user_tag: documentData["tags"])),
                            );
                    } catch (e) {
                      print("error fetching data: $e");
                      toastError(_scaffoldKey, e);
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                ),
              ),

              SignInButton(
                Buttons.Google,
                onPressed: () async {
                  if (!_formKey.currentState.validate()) return;
                  try {
                    setState(() => _loading = true);
                    dynamic result = await _auth.signInWithGoogle();
                    UID = result.uid.toString();
                    addUser();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(currentUser: UID, user_tag: null)),
                    );
                  } catch (e) {
                    print('Error: Goggle sign in');
                    toastError(_scaffoldKey, e);
                  } finally {
                    setState(() => _loading = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,

        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back, color:Color(0xFF21252A)),
          onPressed: (){
            Navigator.pop(context);
          },
          ),
          centerTitle: true,
          title: Text('Sign in',
          style: TextStyle(color: Color(0xFF2FC1FF))),
          backgroundColor: Colors.white,

        ),
        body: _loading ? _buildLoading() : _buildBody());
  }
}

class AuthService2 {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 게스트 로그인
  Future signInAnon() async {
    try {
      var temp = await _auth.signInAnonymously();
      User user = temp.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 로그 아웃
  Future signOut() async {
    try {
      print("sign out");
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // 구글 로그인
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
