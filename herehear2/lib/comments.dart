import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:herehear/recomments.dart';

class CommentPage extends StatefulWidget {
  var doc;
  String currentUser;
  String docUserName;
  String docUserPhotoURL;
  String currentUserDisplayName = '';
  String currentUserPhotoURL = '';

  CommentPage({this.doc, this.currentUser, this.docUserName, this.docUserPhotoURL, this.currentUserDisplayName, this.currentUserPhotoURL});

  @override
  _CommentPageState createState() => _CommentPageState(doc, currentUser, docUserName, docUserPhotoURL, currentUserDisplayName, currentUserPhotoURL);
}

class _CommentPageState extends State<CommentPage> {
  var doc;
  String currentUser;
  String docUserName;
  String docUserPhotoURL;

  // final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  QueryDocumentSnapshot<Map<String, dynamic>> docComment;
  String displayName = '';
  String userPhotoURL = '';
  var userDoc;
  var currentUserDoc;
  String currentUserDisplayName = '';
  String currentUserPhotoURL = '';
  int reloadFlag = 0;

  _CommentPageState(this.doc, this.currentUser, this.docUserName, this.docUserPhotoURL, this.currentUserDisplayName, this.currentUserPhotoURL);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCurrentUserData();
  }


  // Future getCurrentUserData() async {
  //   var currentUserData = await FirebaseFirestore.instance.collection('users').doc(currentUser);
  //   currentUserData.get().then((doc) => currentUserDoc = doc.data());
  //   print('씨바라: ${currentUserDoc}');
  //
  //   var currentUserData = await FirebaseFirestore.instance.collection('users').get().data.docs.where((element) => element['uid'] == doc['uid']);
  //   currentUserData.get().then((doc) => currentUserDoc = doc.data());
  //   print('씨바라: ${currentUserDoc}');
  //
  //
  //   userDoc = snapshot2.data.docs.where((element) => element['uid'] == doc['uid']);
  //   selectedPostID = doc['docID'];
  //   displayName = userDoc.first.get('displayname');
  //   userPhotoURL = userDoc.first.get('userPhotoURL');
  //   // currentUserDisplayName = currentUserDoc['displayname'];
  //   // currentUserPhotoURL = currentUserDoc['userPhotoURL'];
  // }


  void deleteDoc(var commentDoc) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(doc['docID']).collection('comments').doc(commentDoc['docID']).delete();
      print('댓글 삭제 완료!');
      setState(() {
        reloadFlag += 1;
      });
    } catch(e) {
      print('권한 없음');
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    print("????: $currentUserPhotoURL");
    Future.delayed(Duration(milliseconds: 500),(){
    });
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme
              .of(context)
              .colorScheme
              .primary,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: CommentBox(
          userImage: currentUserPhotoURL,
          //currentUser.photoUrl,
          child: ListView(
            children: [
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(docUserPhotoURL),
                                fit: BoxFit.fill
                            ),
                          ),
                        ),
                      ),
                      Text('$docUserName',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                      Expanded(child: Container()),
                      IconButton(
                          icon: Icon(Icons.more_horiz),
                          onPressed: null)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 5,
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Text(
                          doc['description'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(height: 30,),
                    ],
                  ),
                  Divider(),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("posts")
                      .doc(doc['docID']).collection('comments').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return Text("There is no expense");
                    return FutureBuilder(
                        future: FirebaseFirestore.instance.collection("users").get(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot2) {
                          if(!snapshot2.hasData) return Container();
                          print("댓글 다는 유저: ${currentUserDisplayName}");

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                              ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: commentList(context, snapshot, snapshot2),
                                ),
                              ],
                            ),
                          );
                        }
                    );
                    //   ListView(
                    //   scrollDirection: Axis.vertical,
                    //   shrinkWrap: true,
                    //   children: commentList(context, snapshot),
                    // );
                  }
              ),
            ],
          ),
          labelText: '댓글을 입력하세요..',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () {
            print(commentController.text);
            final now = FieldValue.serverTimestamp();
            String docID = Timestamp.now().seconds.toString();

            Map<String, dynamic> data = {
              // 'type': _results.first["label"],
              'message' : commentController.text,
              'uid' : currentUser,
              'displayname' : currentUserDisplayName,
              'userPhotoURL' : currentUserPhotoURL,
              'likeNum' : 0,
              'docID': docID,
              'generatedTime': now,
              'updatedTime': '',
              'nestedComments': [],
            };

            FirebaseFirestore.instance
                .collection('posts')  
                .doc(doc['docID'])
                .collection('comments')
                .doc(docID)
                .set(data);

            commentController.clear();
            FocusScope.of(context).unfocus();
            // if (formKey.currentState.validate()) {
            //   print(commentController.text);
            //   final now = FieldValue.serverTimestamp();
            //   String docID = Timestamp.now().seconds.toString();
            //
            //   Map<String, dynamic> data = {
            //     // 'type': _results.first["label"],
            //     'message' : commentController.text,
            //     'uid' : currentUID,
            //     'userDisplayName' : currentUser.displayName,
            //     'userPhotoURL' : currentUser.photoUrl,
            //     'likeNum' : 0,
            //     'docID': docID,
            //     'generatedTime': now,
            //     'updatedTime': '',
            //     'nestedComments': [],
            //   };
            //
            //   FirebaseFirestore.instance
            //       .collection('posts')
            //       .doc(doc['docID'])
            //       .collection('comments')
            //       .doc(docID)
            //       .set(data);
            //
            //   commentController.clear();
            //   FocusScope.of(context).unfocus();
            // } else {
            //   print("Not validated");
            // }
          },
          // formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  commentList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot2) {
    try{
        return snapshot1.data.docs
            .map((doc2) {
          if (snapshot1.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("Loading..."),
            );
          } else {
            userDoc = snapshot2.data.docs.toList().where((element) => element['uid'] == doc2['uid']).single.data();
            print('userDoc!!!: ${userDoc['displayname']}');
            print('user포토!!: ${userDoc['displayname']}');
            displayName = userDoc['displayname'];
            userPhotoURL = userDoc['userPhotoURL'];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(userPhotoURL),
                      fit: BoxFit.fill
                  ),
                ),
              ),
              title: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(displayName, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(' ${doc2['message']}'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('좋아요 ${doc2['likeNum']}개', style: TextStyle(color: Colors.grey),),
                      SizedBox(width: 20,),
                      TextButton(
                        child: Text('삭제', style: TextStyle(color: Colors.grey),),
                        onPressed: () async {
                          if(doc2['uid'] == currentUser) {
                            _showMyDialog(doc2);
                          }
                          else {
                            final snackBar = SnackBar(
                              content: Text('댓글 작성자만 삭제할 수 있습니다.'),
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        }).toList();
        //     return ListTile(
        // leading: Icon(Icons.account_circle),
        // title: Text(
        //
        // ),
      // );
    } catch(error) {
      print('commentlist error!!');
      print(error);
    }
  }

  Future<void> _showMyDialog(QueryDocumentSnapshot<Object> doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Alert'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('댓글을 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                print('Confirmed');
                await deleteDoc(doc);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  //
  // Widget commentChild(data) {
  //   return ListView(
  //     children: [
  //       for (var i = 0; i < data.length; i++)
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
  //           child: ListTile(
  //             leading: GestureDetector(
  //               onTap: () async {
  //                 // Display the image in large form.
  //                 print("Comment Clicked");
  //               },
  //               child: Container(
  //                 height: 50.0,
  //                 width: 50.0,
  //                 decoration: new BoxDecoration(
  //                     color: Colors.blue,
  //                     borderRadius: new BorderRadius.all(Radius.circular(50))),
  //                 child: CircleAvatar(
  //                     radius: 50,
  //                     backgroundImage: NetworkImage(data[i]['pic'] + "$i")),
  //               ),
  //             ),
  //             title: Text(
  //               data[i]['name'],
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             subtitle: Text(data[i]['message']),
  //           ),
  //         )
  //     ],
  //   );
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("Comment Page"),
  //       backgroundColor: Colors.pink,
  //     ),
  //     body: Container(
  //       child: CommentBox(
  //         userImage:
  //         currentUser.photoUrl,
  //         child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  //             stream: FirebaseFirestore.instance.collection("posts").doc(
  //                 doc['docID']).collection('comments').snapshots(),
  //             builder: (BuildContext context,
  //                 AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //               return commentList(snapshot);
  //             }
  //         ),
  //         labelText: '댓글을 입력하세요..',
  //         withBorder: false,
  //         errorText: 'Comment cannot be blank',
  //         sendButtonMethod: () {
  //           if (formKey.currentState.validate()) {
  //             print(commentController.text);
  //             final now = FieldValue.serverTimestamp();
  //             String docID = Timestamp.now().seconds.toString();
  //
  //             Map<String, dynamic> data = {
  //               // 'type': _results.first["label"],
  //               'message' : commentController.text,
  //               'uid' : currentUID,
  //               'userDisplayName' : currentUser.displayName,
  //               'userPhotoURL' : currentUser.photoUrl,
  //               'likeNum' : 0,
  //               'docID': docID,
  //               'generatedTime': now,
  //               'updatedTime': '',
  //               'nestedComments': [],
  //             };
  //
  //             FirebaseFirestore.instance
  //                 .collection('posts')
  //                 .doc(doc['docID'])
  //                 .collection('comments')
  //                 .doc(docID)
  //                 .set(data);
  //
  //             commentController.clear();
  //             FocusScope.of(context).unfocus();
  //           } else {
  //             print("Not validated");
  //           }
  //         },
  //         formKey: formKey,
  //         commentController: commentController,
  //         backgroundColor: Colors.black,
  //         textColor: Colors.white,
  //         sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
  //       ),
  //     ),
  //   );
  // }
}

