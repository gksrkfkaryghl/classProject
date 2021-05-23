import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'update.dart';

class DetailPage extends StatefulWidget {
  var data;

  DetailPage({this.data});

  @override
  _DetailPageState createState() => _DetailPageState(data: this.data);
}

class _DetailPageState extends State<DetailPage> {
  var data;
  final snackBar1 = SnackBar(content: Text('I LIKE IT!'));
  final snackBar2 = SnackBar(content: Text('You can only do it once!!'));
  bool alreadyClicked = false;
  bool isClicked = false;
  int likeNum;

  _DetailPageState({this.data});

  void deleteDoc(String docID) {
    FirebaseFirestore.instance.collection('posts').doc(docID).delete();
    FirebaseStorage.instance.ref().child('posts/$docID').delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Center(child: Text('Detail')),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.create),
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
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteDoc(data['docID']);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[

          ],
        )
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
                ],
              ),
              Image.network(
                doc['imageURL'],
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
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
                        IconButton(icon: Icon(Icons.question_answer, color: Colors.red), onPressed: () {
                          setState(() {
                          });
                        }),
                        Expanded(
                          child: Container(),
                        ),
                        IconButton(icon: Icon(Icons.star_border, color: Colors.red), onPressed: () {
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
                    Text(
                      doc['description'],
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 30,),
                  ],
                ),
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

