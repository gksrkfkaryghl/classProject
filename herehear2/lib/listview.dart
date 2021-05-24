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
                      IconButton(icon: Icon(Icons.favorite_outline), onPressed: () {
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
                      IconButton(icon: Icon(Icons.question_answer), onPressed: () {
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


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ListViewPage extends StatefulWidget {
//   @override
//   _ListViewPageState createState() => _ListViewPageState();
// }

// class _ListViewPageState extends State<ListViewPage> {

//   Future getPosts() async {
//     var firestore = FirebaseFirestore.instance;
//     //firestore.collection("posts").get();
//     firestore.collection("Product").get();
//     QuerySnapshot qn = await firestore.collection("Product").get();

//     return qn.docs;
//   }

//   TextEditingController _addNameController;
//   String searchString = "";


//   Future _data;
//   @override
//   initState() {
//     super.initState();
//     _data = getPosts();
//     _addNameController = TextEditingController();
//   }

//   void _addToDatabase(String name){
//     List <String> splitList = name.split(" ");

//     List <String> indexList = [];

//     for (int i = 0; i < splitList.length; i++){
//       for (int y = 1; y < splitList[i].length + 1; y++) {
//         indexList.add(splitList[i].substring(0,y).toLowerCase());
//       }
//     }

//     print(indexList);

//     FirebaseFirestore.instance.collection('presidents').doc().
//     set(
//       {
//         'name' : name,
//         'searchIndex' : indexList
//       }
//     );

//   }




//   @override
//   Widget build(BuildContext context) {

//     return Container(
//       child: FutureBuilder(
//           future: _data,
//           builder: (_, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Text("Loading..."),
//               );
//             } else {
//               final ThemeData theme = Theme.of(context);
//               return Column(children: <Widget>[
//                 // Row(
//                 //   children: <Widget> [
//                 //     Expanded(child: Padding(
//                 //       padding: const EdgeInsets.all(8.0),
//                 //       child: TextField(
//                 //         controller: _addNameController,
//                 //       ),
//                 //     )
//                 //     ),
//                 //     RaisedButton(
//                 //         child: Text("Add to Database"),
//                 //         onPressed: (){
//                 //           _addToDatabase(_addNameController.text);
//                 //         }
//                 //         ),
//                 //   ],
//                 // ),
//                 Divider(),
//                 Column(
//                       children: <Widget> [
//                         Padding(
//                             padding: const EdgeInsets.all(1.0),
//                             child: TextField(
//                               cursorColor: Colors.black38,
//                               onChanged: (value){
//                                 setState(() {
//                                   searchString = value.toLowerCase();
//                                   print("here");
//                                   print(searchString);
//                                 });
//                               },
//                             )
//                         )
//                       ],
//                     ),

//                 searchString != ""
//                 ? Expanded(child: StreamBuilder<QuerySnapshot>(
//                   stream: (searchString == null || searchString.trim() == "")
//                       ? FirebaseFirestore.instance.collection("Product")
//                     .snapshots()
//                       : FirebaseFirestore.instance.collection("Product")
//                       .where("searchIndex", arrayContains: searchString)
//                       .snapshots(),
//                   builder: (context, snapshot){
//                       if (snapshot.hasError)
//                         return Text('Error: ${snapshot.error}');
//                       switch (snapshot.connectionState){
//                         case ConnectionState.waiting:
//                           return Center(child: CircularProgressIndicator());
//                         default:
//                           return new ListView(
//                             children: snapshot.data.docs.map((DocumentSnapshot document){
//                               return new ListTile(
//                                 leading: CircleAvatar(
//                                   backgroundImage: NetworkImage(
//                                     document["imgurl"]
//                                   ),
//                                 ),
//                                 title: new Text(document['description']),
//                                 onTap: (){
//                                   print("Tap here");
//                               },
//                               );
//                             }).toList(),
//                           );
//                       }
//                     },
//                   )
//                 )

//                 : Expanded(
//                     child: GridView.count(
//                         padding: EdgeInsets.all(16.0),
//                         childAspectRatio: 8.0 / 9.0,
//                         crossAxisCount: 2,
//                         //shrinkWrap: true,
//                         children: List.generate(snapshot.data.length, (index) {
//                           //itemCount: snapshot.data.length, //조심하기
//                           //itemBuilder: (_, index) {
//                           return Card(
//                             clipBehavior: Clip.antiAlias,
//                             // TODO: Adjust card heights (103)
//                             child: Column(
//                               // TODO: Center items on the card (103)
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 AspectRatio(
//                                   aspectRatio: 20 / 11,
//                                   child: Image.network(
//                                       snapshot.data[index].data()["imgurl"]),
//                                   // child: Image.asset(
//                                   //   product.assetName,
//                                   //   package: product.assetPackage,
//                                   //   fit: BoxFit.fitWidth,
//                                   // ),
//                                 ),
//                                 SingleChildScrollView(
//                                   child: Container(
//                                     padding: EdgeInsets.fromLTRB(
//                                         16.0, 12.0, 16.0, 8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text(
//                                           snapshot.data[index].data()["description"],
//                                           //style: theme.textTheme.headline6,
//                                           maxLines: 1,
//                                         ),
//                                         //SizedBox(height: 8.0),
//                                         // Text(
//                                         //   snapshot.data[index]
//                                         //       .data()["price"]
//                                         //       .toString(),
//                                         //   style: theme.textTheme.subtitle2,
//                                         // ),
//                                         Row(
//                                           //direction: Axis.vertical,
//                                             mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                             children: <Widget>[
//                                               MaterialButton(
//                                                 child: Text("more",
//                                                     style: TextStyle(
//                                                         color: Colors.blue)),
//                                                 onPressed: () => print("here button")
//                                                     // navigateToDetail(
//                                                     //     snapshot.data[index], widget.target2),
//                                               )
//                                             ]),
//                                         //SizedBox(height: 50.0),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                           // );
//                         })))
//               ]);
//             }
//           }



//       ),
//     );
//   }
// }
