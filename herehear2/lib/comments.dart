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

  CommentPage({this.doc, this.currentUser});

  @override
  _CommentPageState createState() => _CommentPageState(doc, currentUser);
}

class _CommentPageState extends State<CommentPage> {
  var doc;
  String currentUser;
  final String currentUID = FirebaseAuth.instance.currentUser.uid;
  // final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  QueryDocumentSnapshot<Map<String, dynamic>> docComment;

  _CommentPageState(this.doc, this.currentUser);

  @override
  Widget build(BuildContext context) {
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
          userImage: null,
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
                                image: NetworkImage(doc['userPhotoURL']),
                                fit: BoxFit.fill
                            ),
                          ),
                        ),
                      ),
                      Text('${doc['userDisplayName']}',
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
                    return ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: commentList(context, snapshot),
                    );
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
              'uid' : currentUID,
              // 'userDisplayName' : currentUser.displayName,
              // 'userPhotoURL' : currentUser.photoUrl,
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

  commentList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    try{
        return snapshot.data.docs
            .map((doc2) {
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(doc2['userPhotoURL']),
                      fit: BoxFit.fill
                  ),
                ),
              ),
              title: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(doc2['userDisplayName'], style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(' ${doc2['message']}'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('좋아요 ${doc2['likeNum']}개', style: TextStyle(color: Colors.grey),),
                      SizedBox(width: 20,),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReCommentsPage(doc: doc2, currentUser: currentUser, ancestorDoc: doc),
                              ),
                            );
                          },
                          child: Text('답글 달기', style: TextStyle(color: Colors.grey),))
                    ],
                  ),
                ],
              ),
            );
        }).toList();
        //     return ListTile(
        // leading: Icon(Icons.account_circle),
        // title: Text(
        //
        // ),
      // );
    } catch(error) {
      print(error);
    }
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

