import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herehear/data/location.dart';
import 'package:herehear/listview.dart';
import 'package:herehear/search.dart';
import 'package:herehear/upload.dart';
import 'package:provider/provider.dart';
import 'methods/searchButton.dart';

import 'main.dart';

class GridViewPage extends StatefulWidget {
  String currentUser;
  var user_tag;

  GridViewPage({this.currentUser, this.user_tag});

  @override
  _GridViewPageState createState() =>
      _GridViewPageState(currentUser: currentUser, user_tag: user_tag);
}

class _GridViewPageState extends State<GridViewPage> {
  String currentUser;
  var user_tag;

  _GridViewPageState({this.currentUser, this.user_tag});

  String docID = '';
  String description = '';
  List<dynamic> doc_tags = [];

  getdocID(docID) {
    this.docID = docID;
  }

  getdescription(description) {
    this.description = description;
  }

  getdoctags(getdoctags) {
    this.doc_tags = getdoctags;
  }

  static var flag_snack = false;

  CreateNotification(String t_doc, String t_des, var t_tags) async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("notification").doc(currentUser);
    // print("CreateNotification");
    // print(t_doc);
    // print(t_des);
    // print(t_tags);
    documentReference.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        List<dynamic> noti_docID = documentSnapshot.get('docID');
        if (noti_docID.contains(t_doc)) {
          print("이미 포함됌");
        } else {
          print("포함되지 않음");
          documentReference.update({
            // update가 아니라 set으로 기본적으로 잡혀야 하는구나.. 그러면 로그인하는 동시에 만들어줘야겠군.
            'description': FieldValue.arrayUnion([t_des]),
            // doc.id는 게시글의 id를 잡아줌.
            'docID': FieldValue.arrayUnion([t_doc]),
            // 'tags' : FieldValue.arrayUnion(t_tags),
          }).then((value) {
            print("User updated");
            Provider.of<Favorites>(context, listen: false).changeFruit(true);
          }).catchError((error) {
            print("Failed to update user: $error");
          });
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future getPosts() async {
    var firestore = FirebaseFirestore.instance;
    //firestore.collection("posts").get();
    firestore.collection("posts").get();
    QuerySnapshot qn = await firestore.collection("posts").get();

    return qn.docs;
  }

  TextEditingController _addNameController;

  // String searchString = "";
  String category = "Personalize";
  final TextEditingController _filter = TextEditingController();
  String currentLocation = '';
  int reload = 0;
  QuerySnapshot<Object> postData;

  Future _data;

  @override
  initState() {
    super.initState();
    _data = getPosts();
    _addNameController = TextEditingController();
    getUserTaglist();
    getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getCurrentLocation() async {
    currentLocation = await Location().getLocation();
  }

  Stream<DocumentSnapshot> getUserTaglist() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .snapshots();
  }

  void _addToDatabase(String name) {
    List<String> splitList = name.split(" ");

    List<String> indexList = [];

    for (int i = 0; i < splitList.length; i++) {
      for (int y = 1; y < splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0, y).toLowerCase());
      }
    }

    print(indexList);

    FirebaseFirestore.instance
        .collection('presidents')
        .doc()
        .set({'name': name, 'searchIndex': indexList});
  }

  final List<Tab> myTab = <Tab>[Tab(text: '전체'), Tab(text: '맞춤')];

  @override
  Widget build(BuildContext context) {
    // print("[GridVeiw] current user & user tag");
    // print(currentUser);
    // print(user_tag);

    print("current location: ${currentLocation}");

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.14),
              child: AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(
                      child: Text(
                    '히 어',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  )),
                ),
                actions: <Widget>[
                  // SearchButton(),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      print('on more check: ${currentUser}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPage(
                              currentUser: currentUser, user_tag: user_tag),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate:
                            PostSearchDelegate(postData, user_tag, currentUser),
                      );
                    },
                  ),
                ],
                bottom: TabBar(
                  onTap: (index) {
                    index == 1 ? category = 'all' : category = 'Personalize';
                    print('selected: $category');
                  },
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.black45,
                  labelStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                  tabs: myTab,
                ),
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                all(),
                personalize(),
              ],
            )));
  }

  Widget all() {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('posts').snapshots();
    return Container(
      //child: FutureBuilder(
      child: StreamBuilder<QuerySnapshot>(
          //future: _data,
          stream: _usersStream,
          //builder: (_, snapshot) {
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              postData = snapshot.data;
              // final ThemeData theme = Theme.of(context);
              return Column(children: <Widget>[
                Expanded(
                    child: GridView.count(
                        childAspectRatio: 8.0 / 9.0,
                        crossAxisCount: 3,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {

                              // list 형태로 만들기 위해서는 필요함 --> Set
                          List<dynamic> doc_tags = document["tags"];
                          final lists = [doc_tags, user_tag];
                          var commonElements;

                          print("doc_tags & user_tag");
                          print(doc_tags);
                          print(user_tag);

                          if (doc_tags.isEmpty || user_tag == null || currentLocation != document["location"]) {
                            commonElements = {};
                          } else {
                            commonElements = lists.fold<Set>(
                                lists.first.toSet(),
                                (a, b) => a.intersection(b.toSet()));
                          }

                          // 공통이 있다면,
                          if (commonElements.length != 0) {
                            getdocID(document["docID"]);
                            getdescription(document["description"]);
                            getdoctags(document["tags"]);

                            if (document["uid"] != currentUser) {
                              CreateNotification(docID, description, doc_tags);
                            }
                          }
                          return listItem(document);
                          // );
                        }).toList()))
              ]);
            }
          }),
    );
  }

  Widget personalize() {
    return Container(
      child: FutureBuilder(
          future: _data,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              return Column(children: <Widget>[
                Expanded(
                    child: StreamBuilder<DocumentSnapshot<Object>>(
                        stream: getUserTaglist(),
                        builder: (context, userData) {
                          List favoritePosts = [];
                          if (!userData.hasData) return Text('No post yet.');
                          List tags = userData.data['tags'];
                          for (int index = 0;
                              index < snapshot.data.length;
                              index++) {
                            if (currentLocation == snapshot.data[index]['location']) {
                              List<dynamic> tempList = snapshot.data[index]['tags'];

                              var commonElements;
                              final lists = [tempList, tags];

                              if (tempList.isEmpty || tags.isEmpty) {
                                commonElements = {};
                              } else {
                                commonElements = lists.fold<Set>(
                                    lists.first.toSet(),
                                        (a, b) => a.intersection(b.toSet()));
                              }

                              if (commonElements.length != 0){
                                favoritePosts.add(snapshot.data[index]);
                              }


                              // for (int i = 0; i < tags.length; i++) {
                              //   for (int j = 0; j < tempList.length; j++) {
                              //     if ((tags[i] != null) &&
                              //         (tags[i] == tempList[j])) {
                              //       favoritePosts.add(snapshot.data[index]);
                              //       print('tag: ${tags[i].toString()}');
                              //     }
                              //   }
                              // }
                            }
                          }
                          return GridView.count(
                              // padding: EdgeInsets.all(16.0),
                              childAspectRatio: 8.0 / 9.0,
                              crossAxisCount: 3,
                              //shrinkWrap: true,
                              children:
                                  List.generate(favoritePosts.length, (index) {
                                //itemCount: snapshot.data.length, //조심하기
                                //itemBuilder: (_, index) {
                                return listItem(favoritePosts[index]);
                              }));
                        }))
              ]);
            }
          }),
    );
  }

  Widget listItem(dynamic snapshot) {
    return snapshot["imageURL"] != ""
        ? Padding(
            padding: const EdgeInsets.all(1.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListViewPage(doc: snapshot, currentUser: currentUser, user_tag: user_tag),
                  ),
                );
              },
              child: Container(
                  child: Image.network(
                snapshot["imageURL"],
                fit: BoxFit.cover,
              )),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(1.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListViewPage(doc: snapshot, currentUser: currentUser, user_tag: user_tag,),
                  ),
                );
              },
              child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      snapshot['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 5,
                    )),
                  )),
            ),
          );
  }
}