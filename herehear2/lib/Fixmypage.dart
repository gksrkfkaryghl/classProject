import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import './methods/validators.dart';
import './methods/toast.dart';
import 'home.dart';
import 'listview.dart';

class FixPage extends StatefulWidget {
  const FixPage({Key key, this.target}) : super(key: key);
  final String target;
  static const routeName = '/signup';

  @override
  _FixPageState createState() => _FixPageState();
}

class _FixPageState extends State<FixPage> {
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

  _googleSignIn() async {
    final bool isSignedIn = await GoogleSignIn().isSignedIn();
    GoogleSignInAccount googleUser;
    if (isSignedIn)
      googleUser = await GoogleSignIn().signInSilently();
    else
      googleUser = await GoogleSignIn().signIn();
    // await GoogleSignIn().signOut();
    // GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    // print("signed in " + user.displayName);
    return user;
  }

  _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  final AuthService2 _auth = AuthService2(); // 새로추가.

  _buildBody() {
    print("widget.target");
    print(widget.target);

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.target).get(),
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
                    SizedBox(
                      height: 10,
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
                            // 이전에 로그인 되어있던 내용이 있다면, signout 시키고 새롭게 로그인.
                            //await _auth.signOut();
                            //dynamic result = await _auth.signInAnon();
                            UID = widget.target;
                            print("UID");
                            print(UID);

                            addUser();
                            print("Fix up Sccess");
                            Navigator.push(
                              context,
                              //MaterialPageRoute(builder: (context) => ListViewPage(currentUser: null, target: UID,)),
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(currentUser: null)),
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
                          final Item currentItem = Item(title: tagList[index]);
                          return ItemTags(
                            index: index,
                            title: currentItem.title,
                            customData: currentItem.customData,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            color: Theme.of(context).colorScheme.secondary,
                            activeColor: Theme.of(context).colorScheme.primary,
                            textStyle: TextStyle(fontSize: 14),
                            combine: ItemTagsCombine.withTextBefore,
                            onPressed: (i) => print('asdfasdf: $i'),
                            onLongPressed: (i) => print('asdfasdf: $i'),
                            removeButton: ItemTagsRemoveButton(onRemoved: () {
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
              SizedBox(
                height: 10,
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
                      // 이전에 로그인 되어있던 내용이 있다면, signout 시키고 새롭게 로그인.
                      await _auth.signOut();
                      dynamic result = await _auth.signInAnon();
                      UID = result.uid.toString();
                      addUser();
                      print("Sign up Sccess");
                      Navigator.push(
                        context,
                        //MaterialPageRoute(builder: (context) => ListViewPage(currentUser: null, target: UID,)),
                        MaterialPageRoute(
                            builder: (context) => HomePage(currentUser: null)),
                      );
                    } catch (e) {
                      toastError(_scaffoldKey, e);
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                ),
              ),
              // Text('or'),
              // SignInButton(
              //   Buttons.Google,
              //   onPressed: () async {
              //     if (!_formKey.currentState.validate()) return;
              //     try {
              //       setState(() => _loading = true);
              //       dynamic result = await _auth.signInWithGoogle();
              //       UID = result.uid.toString();
              //       addUser();
              //
              //       Navigator.push(
              //         context,
              //         // MaterialPageRoute(builder: (context) => ListViewPage(currentUser: null,target: UID,)),
              //         MaterialPageRoute(builder: (context) => HomePage(currentUser: null)),
              //
              //       );
              //
              //
              //       // await _googleSignIn();
              //       // Navigator.pushReplacementNamed(context, '/');
              //       // Navigator.pushReplacementNamed(context, '/auth');
              //       // Navigator.pushReplacementNamed(context, '/home');
              //     } catch (e) {
              //       print('Error: Goggle sign in');
              //       toastError(_scaffoldKey, e);
              //     } finally {
              //       setState(() => _loading = false);
              //     }
              //   },
              // ),
              // SizedBox(height: 20,),
              // Text("Don't have an account yet?"),
              // FlatButton(
              //   child: Text('Sign up'),
              //   onPressed: () {
              //     Navigator.pushNamed(context, '/signup');
              //   },
              // )
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
