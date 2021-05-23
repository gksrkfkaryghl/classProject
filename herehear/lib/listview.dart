import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:herehear/upload.dart';
import 'update.dart';

class ListViewPage extends StatefulWidget {
  var data;

  ListViewPage({this.data});

  @override
  _ListViewPageState createState() => _ListViewPageState(data: this.data);
}

class _ListViewPageState extends State<ListViewPage> {
  var data;
  final snackBar1 = SnackBar(content: Text('I LIKE IT!'));
  final snackBar2 = SnackBar(content: Text('You can only do it once!!'));
  bool alreadyClicked = false;
  bool isClicked = false;
  int likeNum;

  _ListViewPageState({this.data});

  void deleteDoc(String docID) {
    FirebaseFirestore.instance.collection('posts').doc(docID).delete();
    FirebaseStorage.instance.ref().child('posts/$docID').delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // title: Center(child: Text('Detail')),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).colorScheme.primary,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdatePage(doc: data),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.mail_outline, color: Theme.of(context).colorScheme.primary,),
              onPressed: () {
                deleteDoc(data['docID']);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("posts").snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Text("There is no expense");
              // List<Widget> imageCards = getExpenseItems(context, snapshot);
              // List<String> l = getImageURL(snapshot);
              // print("@@@@: ${l}");
              return ListView(
                children: postList(context, snapshot),
              );
            }
        ),
    );
  }

  Widget likeNumber() {
    if(isClicked)
      likeNum = data['likeNum'] + 1;
    else
      likeNum = data['likeNum'];
    return Text(
      likeNum.toString(),
      style: TextStyle(fontSize: 20, color: Colors.red),
    );
  }

  List<Widget> postList (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    try {
      return snapshot.data.docs
          .map((doc) {
        if(snapshot.hasData)
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  //profile image
                  Text('${doc['uid']}', style: TextStyle(fontSize: 13),),
                  Expanded(child: Container()),
                  IconButton(
                      icon: Icon(Icons.more_horiz),
                      onPressed: null)
                ],
              ),
              Image.network(
                doc['imageURL'],
                width: MediaQuery.of(context).size.width,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.favorite, color: Colors.red), onPressed: () {
                        setState(() {
                          if(!alreadyClicked) {
                            FirebaseFirestore.instance.collection('posts').doc(doc['docID']).update({
                              'likeNum': doc['likeNum'] + 1,
                            }).then((value) {
                              setState(() {
                                isClicked = true;
                              });
                            });
                            alreadyClicked = true;
                            ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                          }
                          else
                            ScaffoldMessenger.of(context).showSnackBar(snackBar2);
                        });
                      }),
                      IconButton(icon: Icon(Icons.question_answer,), onPressed: () {
                        setState(() {
                        });
                      }),
                      Expanded(
                        child: Container(),
                      ),
                      IconButton(icon: Icon(Icons.star_border, color: Colors.yellow), onPressed: () {
                        setState(() {
                        });
                      }),
                    ],
                  ),
                  SizedBox(height: 10),
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
            ],
          );
      }).toList();
      // Card(
      //   clipBehavior: Clip.antiAlias,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: <Widget>[
      //       AspectRatio(
      //         aspectRatio: 18 / 11,
      //         child: Image.network(
      //           doc['imageURL'],
      //           fit: BoxFit.fitWidth,
      //         ),
      //       ),
      //       Expanded(
      //         child: Padding(
      //           padding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: <Widget>[
      //               Text(
      //                 doc['name'],
      //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      //                 maxLines: 1,
      //               ),
      //               SizedBox(height: 6.0),
      //               Text(
      //                 '\$ ${doc['price']}',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //               Expanded(child: Container()),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: <Widget>[
      //                   // Expanded(child: Container()),
      //                   GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(
      //                         context,
      //                         MaterialPageRoute(
      //                           builder: (context) => DetailPage(data: doc),
      //                         ),
      //                       );
      //                     },
      //                     child: Text(
      //                       "more",
      //                       style: TextStyle(color: Colors.lightBlue),
      //                     ),
      //                   ),
      //                 ],
      //               )
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // );
    } catch(error) {
      print(error);
    }
  }
}

