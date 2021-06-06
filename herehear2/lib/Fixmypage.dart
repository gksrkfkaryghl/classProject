
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:herehear/mypage.dart';
import 'package:image_picker/image_picker.dart';
import './methods/validators.dart';
import './methods/toast.dart';
import 'home.dart';
import 'listview.dart';

class FixPage extends StatefulWidget {
  final String currentUser;
  FixPage({this.currentUser});

  static const routeName = '/signup';

  @override
  _FixPageState createState() => _FixPageState(currentUser: currentUser);
}

class _FixPageState extends State<FixPage> {
  String currentUser;
  _FixPageState({this.currentUser});


  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  // TextEditingController emailController = TextEditingController(text: "Hello");
  // final TextEditingController passwordController = TextEditingController();
  // final TextEditingController displayController = TextEditingController();
  // final TextEditingController descriptionController = TextEditingController();
  // final TextEditingController locationController = TextEditingController();
  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController displayController;
  TextEditingController descriptionController;
  TextEditingController locationController;



  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();

  List tagList = [];
  var tag_flag = false;

  static String UID;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String downloadURL;

  var Scrap_list;
  // User Firebase에 넣는 함수
  Future addUser() async {
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('users/$UID');

    if (_imageFile != null){
      await firebaseStorageRef.putFile(_imageFile);
      downloadURL = await firebaseStorageRef.getDownloadURL();
    }


    Map<String, dynamic> data = {
      "email": emailController.text,
      "password": passwordController.text,
      "displayname": displayController.text,
      "Scrap": Scrap_list,
      "tags": tagList,
      "location": locationController.text,
      "uid": UID,
      "userPhotoURL" : downloadURL,
    };
    FirebaseFirestore.instance.collection('users').doc(currentUser).set(data);
  }


  _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  final AuthService2 _auth = AuthService2(); // 새로추가.
  // 이미지 파트
  bool is_default = true;
  File _imageFile;

  Widget loadImage() {
    if(_imageFile == null)
      return Container();
    else
      return Column(
          children: <Widget>[
            Image.file(_imageFile),
            Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
            )
          ]
      );
  }

  final _picker = ImagePicker();
  Future<String> pickAnImageFromGallery() async {
    var image = await _picker.getImage(source: ImageSource.gallery);
    _imageFile = File(image.path);
    return image.path;
  }




  _buildBody() {
    print("[FixmyPage]currentUser");
    print(currentUser);

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(currentUser).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          Scrap_list = data["Scrap"];
          downloadURL = data["userPhotoURL"];
          if (tag_flag == false) {
            tagList = data["tags"];
            tag_flag = true;
            print("tagList");
            print(tagList);
          }

          emailController = new TextEditingController(text: data["email"]);
          passwordController = new TextEditingController(text: data["password"]);
          displayController= new TextEditingController(text: data["displayname"]);
          descriptionController= new TextEditingController(text: data["description"]);
          locationController= new TextEditingController(text: data["location"]);


          // return Text("Full Name: ${data['full_name']} ${data['last_name']}");
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
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Displayname',
                        //hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      controller: displayController,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Location',
                        //hintText: '',
                        border: OutlineInputBorder(),
                      ),
                      controller: locationController,
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 24, 5),
                        child: Column(
                          children: [
                            Tags(
                              key: _globalKey,
                              textField: TagsTextField(
                                  textStyle: TextStyle(fontSize: 14),
                                  // constraintSuggestion: true, suggestions: [],
                                  onSubmitted: (value) {
                                    setState(() {
                                      tagList.add(value);
                                      print(tagList);
                                    });
                                  }),
                              itemCount: tagList.length,
                              itemBuilder: (index) {
                                final Item currentItem =
                                    Item(title: tagList[index]);
                                return ItemTags(
                                  index: index,
                                  title: currentItem.title,
                                  customData: currentItem.customData,
                                  textColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  textStyle: TextStyle(fontSize: 14),
                                  combine: ItemTagsCombine.withTextBefore,
                                  onPressed: (i) => print('asdfasdf: $i'),
                                  onLongPressed: (i) => print('asdfasdf: $i'),
                                  removeButton:
                                      ItemTagsRemoveButton(onRemoved: () {
                                    setState(() {
                                      tagList.removeAt(index);
                                    });
                                    return true;
                                  }),
                                );
                              },
                            )
                          ],
                        )),
                    SizedBox(height: 10),
                    loadImage(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.photo_camera),
                          iconSize: 25,
                          onPressed: () {
                            pickAnImageFromGallery().then((value){
                              setState(() {
                              });
                            });
                          },
                        )
                      ],
                    ),
                    Center(
                      child: FlatButton(
                        child: Text(
                          'Fix it',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (!_formKey.currentState.validate()) return;
                          try {
                            setState(() => _loading = true);
                            addUser();
                            print("Fix up Sccess");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage(currentUser: currentUser, user_tag: tagList)),
                            );
                          } catch (e) {
                            toastError(_scaffoldKey, e);
                          } finally {
                            setState(() => _loading = false);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Text("loading");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Fix My Page',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
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
