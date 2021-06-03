import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ReCommentsPage extends StatefulWidget {
  var doc;
  var ancestorDoc;
  String currentUser;

  ReCommentsPage({this.doc, this.currentUser, this.ancestorDoc});

  @override
  _ReCommentsPageState createState() => _ReCommentsPageState(doc: doc, currentUser: currentUser, ancestorDoc: ancestorDoc);
}

class _ReCommentsPageState extends State<ReCommentsPage> {
  var doc;
  var ancestorDoc;
  String currentUser;

  _ReCommentsPageState({this.doc, this.currentUser, this.ancestorDoc});

  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  List<Map> userList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme
            .of(context)
            .colorScheme
            .primary,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
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
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(doc['userDisplayName'], style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(' ${doc['message']}'),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('좋아요 ${doc['likeNum']}개', style: TextStyle(color: Colors.grey),),
                        SizedBox(width: 20,),
                        TextButton(
                            onPressed: null,
                            child: Text('답글 달기', style: TextStyle(color: Colors.grey),))
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection("posts")
                    .doc(ancestorDoc['docID']).collection('comments').doc(doc['docID']).collection('reComments').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: commentList(snapshot),
                  );
                }
            ),
            reComment()
          ],
        ),
    );
  }

  commentList(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    print("rrr: ${snapshot.data.docs}");
    if(snapshot.hasData) {
      print('what?: ${snapshot.data.docs}');
      return snapshot.data.docs
          .map((doc) {
            ListTile(
              leading: Container(
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
              title: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(doc['userDisplayName'], style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(' ${doc['message']}'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('좋아요 ${doc['likeNum']}개', style: TextStyle(color: Colors.grey),),
                      SizedBox(width: 20,),
                      TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReCommentsPage(doc: doc, currentUser: currentUser),
                            ),
                          ),
                          child: Text('답글 달기', style: TextStyle(color: Colors.grey),))
                    ],
                  ),
                ],
              ),
            );
      }).toList();
    }
    return Container();
  }


  Widget reComment() {
    return Container(
      child: FlutterMentions(
        key: key,
        suggestionPosition: SuggestionPosition.Top,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(hintText: '댓글을 입력하세요.'),
        mentions: [
          Mention(
              trigger: '@',
              style: TextStyle(
                color: Colors.amber,
              ),
              // data: ,
              matchAll: false,
              suggestionBuilder: (data) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          data['photo'],
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Column(
                        children: <Widget>[
                          Text(data['full_name']),
                          Text('@${data['display']}'),
                        ],
                      )
                    ],
                  ),
                );
              }),
          Mention(
            trigger: '#',
            disableMarkup: true,
            style: TextStyle(
              color: Colors.blue,
            ),
            data: [
              {'id': 'reactjs', 'display': 'reactjs'},
              {'id': 'javascript', 'display': 'javascript'},
            ],
            matchAll: true,
          )
        ],
      ),
    );
  }
  
  // Future<List<Map>> getUserList() {
  //   return FirebaseFirestore.instance.collection('users').snapshots();
  // }
}

//1. user list collection으로 받아온다(이를 위해 user data 생성 필요),
//2. 이를 userList에 넣고,
//3. 멘션 기능 구현
//4. 파베에 업로드 구현

