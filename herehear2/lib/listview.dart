import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herehear/upload.dart';
import 'comments.dart';
import 'update.dart';

class ListViewPage extends StatefulWidget {
  GoogleSignInAccount currentUser;
  final String target;
  ListViewPage({this.currentUser, this.target});

  @override
  _ListViewPageState createState() => _ListViewPageState(currentUser: currentUser);
}

class _ListViewPageState extends State<ListViewPage> {
  // User currentUser;
  GoogleSignInAccount currentUser;
  final snackBar1 = SnackBar(content: Text('I LIKE IT!'));
  final snackBar2 = SnackBar(content: Text('You can only do it once!!'));
  final String currentUID = FirebaseAuth.instance.currentUser.uid;
  int likeNum;

  int n = 0;

  _ListViewPageState({this.currentUser});

  void deleteDoc(String docID) {
    FirebaseFirestore.instance.collection('posts').doc(docID).delete();
    FirebaseStorage.instance.ref().child('posts/$docID').delete();
  }

  @override
  Widget build(BuildContext context) {
    print("here it is");
    print(widget.target);

    print('currentUser?!!: ${currentUser}');
    // print('_currentUser: ${_currentUser}');
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
              print('on more check: ${currentUser}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadPage(currentUser: currentUser),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).colorScheme.primary,),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UpdatePage(doc: data),
              //   ),
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.mail_outline, color: Theme.of(context).colorScheme.primary,),
            // onPressed: () {
            //   deleteDoc(data['docID']);
            //   Navigator.pop(context);
            // },
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

  List<Widget> postList (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    try {
      return snapshot.data.docs
          .map((doc) {
        if(snapshot.hasData) {
          Map<String, dynamic> data = doc.data();
          return Column(
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
                  SizedBox(width: 8,),
                  Text('${doc['userDisplayName']}', style: TextStyle(fontSize: 17),),
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
                      IconButton(
                          icon: likeIcon(data),
                          onPressed: () {
                            bool flag = true;

                            //print(target);

                            // 중복되는지 체크.
                            print('?!?!?!: $data');
                            var dataList = data.values.toList();
                            var keyList = data.keys.toList();
                            int tempLength = data.length;
                            print('?????: $tempLength');
                            for (int i = 0; i < tempLength; i++){
                              print(dataList[i]);

                              if (currentUID == dataList[i].toString()){
                                if (keyList[i] == "uid"){
                                  continue;
                                }
                                flag = false;
                                print("같음");
                                break;
                              }
                            }

                            // 변경가능.
                            if (flag == true){
                              print("변경가능");

                              // LikeData(widget.target3, widget.post.data()['like'] + 1);
                              likeData(doc);

                              setState(() {
                                n++;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content : Text("I Like it !!"),
                                duration: const Duration(seconds: 2),
                              )
                              );


                              // Navigator.push(context, MaterialPageRoute(builder: (context) {
                              //   return Wrapper(target: widget.target3,);
                              // }));

                            }
                            //변경불가
                            else{
                              print("변경불가");
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content : Text("You can only do it once !!"),
                                duration: const Duration(seconds: 2),
                              )
                              );
                            }
                          }),
                      IconButton(icon: Icon(Icons.question_answer), onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentPage(doc: doc, currentUser: currentUser),
                          ),
                        );
                      }),
                      Expanded(
                        child: Container(),
                      ),
                      IconButton(
                          icon: Icon(Icons.star_border, color: Colors.yellow),
                          onPressed: () {
                            ScrapData(doc);
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
        }
      }).toList();
    } catch(error) {
      print(error);
    }
  }

  Widget likeIcon(Map<String, dynamic> data){
    var dataList = data.values.toList();
    var keyList = data.keys.toList();
    int tempLength = data.length;
    for (int i = 0; i < tempLength; i++){

      if (currentUID == dataList[i].toString()){
        if (keyList[i] == "uid"){
          continue;
        }
        print('~~');
        return Icon(Icons.favorite, color: Colors.red);
      }
    }
    return Icon(Icons.favorite_outline);
  }

  likeData(QueryDocumentSnapshot<Object> doc) async {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("posts").doc(doc['docID']);

    // String temp = image?.path ?? "https://handong.edu/site/handong/res/img/logo.png";
    //String temp = image?.path ?? widget.post.data()['imgurl'];

    // create map
    //print("imgurl");
    //print(temp);

    String field_name = "like_user" + (doc['likeNum'] + 1).toString();
    print(field_name);

    int likeNum = doc['likeNum'] + 1;

    // Map<String, dynamic> tempp =  widget.data.data();
    // tempp[field_name] = doc['uid'];
    // tempp["likeNum"] = doc['likeNum'] + 1;

    FirebaseFirestore.instance.collection('posts').doc(doc['docID']).update({
      field_name : currentUID,
      'likeNum' : likeNum,
    }).whenComplete(() => print('완료!!'));



    // Map<String, dynamic> products = {
    //   "name": widget.data.data()['name'],
    //   "price": widget.post.data()['price'],
    //   "description": widget.post.data()['description'],
    //   "imgurl": widget.post.data()['imgurl'],
    //   "like": widget.post.data()['like'] + 1,
    //   "created": widget.post.data()['created'],
    //   "modified": widget.post.data()['modified'],
    //   field_name : like_user
    // };

    // String temp2 = widget.post.data()['imgurl'];

    // documentReference.set(tempp).whenComplete(() {
    //   print("like updated 완료");
    // });
  }

  ScrapData(QueryDocumentSnapshot<Object> doc) async{
    // uid가 안잡혀서 임의로 잡았음.
    FirebaseFirestore.instance.collection("users")
        .doc("Qz2LP0sw9DMP2XDqtyKzECs9J0q2").update({
      'Scrap' : FieldValue.arrayUnion([doc.id]) // doc.id는 게시글의 id를 잡아줌.
    });
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