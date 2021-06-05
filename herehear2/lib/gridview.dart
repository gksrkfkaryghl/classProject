import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herehear/data/location.dart';
import 'package:herehear/listview.dart';
import 'package:herehear/upload.dart';

class GridViewPage extends StatefulWidget {
  String currentUser;

  GridViewPage({this.currentUser});

  @override
  _GridViewPageState createState() => _GridViewPageState(currentUser: currentUser);
}

class _GridViewPageState extends State<GridViewPage> {
  String currentUser;

  _GridViewPageState({this.currentUser});

  String docID;
  String description;
  var doc_tags;

  getdocID(docID){
    this.docID = docID;
  }

  getdescription(description){
    this.description = description;
  }

  getdoctags(getdoctags){
    this.doc_tags = getdoctags;
  }


  CreateNotification() async {

    DocumentReference documentReference = FirebaseFirestore.instance
                                          .collection("notification").doc(currentUser);
    documentReference.set({ // update가 아니라 set으로 기본적으로 잡혀야 하는구나.. 그러면 로그인하는 동시에 만들어줘야겠군.
    'alarm' :  FieldValue.arrayUnion([description]), // doc.id는 게시글의 id를 잡아줌.
    'docID' : FieldValue.arrayUnion([docID])
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
  String searchString = "";
  String category = "Personalize";
  FocusNode focus = FocusNode();
  final TextEditingController _filter = TextEditingController();
    String currentLocation = '';
  int reload = 0;

  Future _data;
  @override
  initState() {
    super.initState();
    _data = getPosts();
    _addNameController = TextEditingController();
    focus.addListener(_onFocusChange);
    getUserTaglist();
    getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    focus.dispose();
  }

  void getCurrentLocation() async {
    currentLocation= await Location().getLocation();
  }

  Stream<DocumentSnapshot> getUserTaglist() {
    return FirebaseFirestore.instance.collection('users').doc(currentUser).snapshots();

  }

  void _onFocusChange(){
    debugPrint("Focus: "+focus.hasFocus.toString());
  }

  void _addToDatabase(String name){
    List <String> splitList = name.split(" ");

    List <String> indexList = [];

    for (int i = 0; i < splitList.length; i++){
      for (int y = 1; y < splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0,y).toLowerCase());
      }
    }

    print(indexList);

    FirebaseFirestore.instance.collection('presidents').doc().
    set(
        {
          'name' : name,
          'searchIndex' : indexList
        }
    );

  }

  final List<Tab> myTab = <Tab>[
    Tab(text: '맞춤'),
    Tab(text: '전체')
  ];




  @override
  Widget build(BuildContext context) {
    print("[GridVeiw] current user");
    print(currentUser);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.14),
              child: AppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(child: Text('히 어', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),)),
                ),
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
                bottom: TabBar(
                  onTap: (index) {
                    index == 1? category = 'all' : category = 'Personalize';
                    print('selected: $category');
                  },
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.black45,
                  labelStyle:  TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                  tabs: myTab,
                ),
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                personalize(),
                all(),
              ],
            )
        )
    );
  }

  Widget all() {
    final Stream <QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('posts').snapshots();


    return Container(
      //child: FutureBuilder(
      child: StreamBuilder<QuerySnapshot>(
          //future: _data,
          stream: _usersStream,
          //builder: (_, snapshot) {
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              // final ThemeData theme = Theme.of(context);
              return Column(children: <Widget>[
                // Row(
                //   children: <Widget> [
                //     Expanded(child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: TextField(
                //         controller: _addNameController,
                //       ),
                //     )
                //     ),
                //     RaisedButton(
                //         child: Text("Add to Database"),
                //         onPressed: (){
                //           _addToDatabase(_addNameController.text);
                //         }
                //         ),
                //   ],
                // ),
                // Divider(),


                ////
                searchField(),
                searchString != ""
                    ? searchWidget()
                    : Expanded(
                    child: GridView.count(
                        childAspectRatio: 8.0 / 9.0,
                        crossAxisCount: 3,
                        //shrinkWrap: true,
                        //children: List.generate(snapshot.data.length, (index) {
                        children: snapshot.data.docs.map((DocumentSnapshot document) {

                          // list 형태로 만들기 위해서는 필요함.
                          String doc_tags = document["tags"].toString();
                          // 임의의 값으로 정해놨는데, sign in이나 sign up하는 동시에 인자로 줘야할듯?
                          if (doc_tags.contains('money')){
                            print(doc_tags);

                            getdocID(document["docID"]);
                            getdescription(document["description"]);
                            getdoctags(document["tags"]);
                            CreateNotification();
                            WidgetsBinding.instance.addPostFrameCallback((_){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content : Text("Tag하신 게시글이 생성되었습니다."),
                                // duration: const Duration(seconds: 2),
                              ));
                            });
                          }
                          else{
                          }




                          //itemCount: snapshot.data.length, //조심하기
                          //itemBuilder: (_, index) {
                          // return listItem(snapshot.data[index]);
                          return listItem(document);
                          // );
                        }
                        ).toList()
                    )
                )
              ]);
            }
          }
      ),
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
              print('뭐야?: ${snapshot.data[0]['description']}');
              // final ThemeData theme = Theme.of(context);
              return Column(children: <Widget>[
                // Row(
                //   children: <Widget> [
                //     Expanded(child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: TextField(
                //         controller: _addNameController,
                //       ),
                //     )
                //     ),
                //     RaisedButton(
                //         child: Text("Add to Database"),
                //         onPressed: (){
                //           _addToDatabase(_addNameController.text);
                //         }
                //         ),
                //   ],
                // ),
                searchField(),
                searchString != ""
                    ? searchWidget()
                    : Expanded(
                    child: StreamBuilder<DocumentSnapshot<Object>>(
                        stream: getUserTaglist(),
                        builder: (context, userData) {
                          List favoritePosts = [];
                          if(!userData.hasData) return Text('No post yet.');
                          List tags = userData.data['tags'];
                          for(int index = 0; index < snapshot.data.length; index++) {
                            if(currentLocation == snapshot.data[index]['location']) {
                              List<dynamic> tempList = snapshot.data[index]['tags'];
                              for(int i = 0; i < tags.length; i++) {
                                for(int j = 0; j < tempList.length; j++) {
                                  if((tags[i] != null) && (tags[i] == tempList[j])) {
                                    favoritePosts.add(snapshot.data[index]);
                                    print('tag: ${tags[i].toString()}');
                                  }
                                }
                              }
                            }
                          }
                          return GridView.count(
                            // padding: EdgeInsets.all(16.0),
                              childAspectRatio: 8.0 / 9.0,
                              crossAxisCount: 3,
                              //shrinkWrap: true,
                              children: List.generate(favoritePosts.length, (index) {
                                //itemCount: snapshot.data.length, //조심하기
                                //itemBuilder: (_, index) {
                                return listItem(favoritePosts[index]);
                              }));
                      }
                    ))
              ]);
            }
          }
      ),
    );
  }

  Widget searchField() {
    return Column(
      children: <Widget> [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            color: Colors.grey[350],
            child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  color: Colors.grey[300],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                            focusNode: focus,
                            cursorColor: Colors.grey,
                            controller: _filter,
                            // cursorHeight: 25,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[300]),
                                //  when the TextFormField in unfocused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey[500]),
                                //  when the TextFormField in focused
                              ) ,
                              filled: true,
                              fillColor: Colors.grey[300],
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              suffixIcon: focus.hasFocus
                                  ? IconButton(
                                // splashColor: Colors.grey[600],
                                focusColor: Colors.grey[600],
                                color: Colors.grey[600],
                                icon: Icon(
                                  Icons.cancel,
                                  size: 17,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _filter.clear();
                                    searchString = "";
                                  });
                                },
                              )
                                  : Container(),
                            ),
                            onChanged: (value){
                              setState(() {
                                searchString = value.toLowerCase();
                                print("here");
                                print(searchString);
                              });
                            },
                          )
                      ),
                    ],
                  ),
                )
            ),
          ),
        )
      ],
    );
  }

  Widget searchWidget() {
    return  Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: (searchString == null || searchString.trim() == "")
          ? FirebaseFirestore.instance.collection("posts")
          .snapshots()
          : FirebaseFirestore.instance.collection("posts")
          .where("searchIndex", arrayContains: searchString)
          .snapshots(),
      builder: (context, snapshot){
        if (snapshot.hasError)
          return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState){
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot document){
                return new ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        document["imageURL"]
                    ),
                  ),
                  title: new Text(document['description']),
                  onTap: (){
                    print("Tap here");
                  },
                );
              }).toList(),
            );
        }
      },
    )
    );
  }

  Widget listItem(dynamic snapshot) {
    return snapshot["imageURL"] != "" ?
    Padding(
      padding: const EdgeInsets.all(1.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListViewPage(doc: snapshot, currentUser: currentUser),
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
              builder: (context) => ListViewPage(doc: snapshot, currentUser: currentUser),
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
                    style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface,),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  )
              ),
            )
        ),
      ),
    );
    Column(
      // TODO: Center items on the card (103)
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image.network(snapshot["imageURL"]),
        SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  snapshot["description"],
                  //style: theme.textTheme.headline6,
                  maxLines: 1,
                ),
                //SizedBox(height: 8.0),
                // Text(
                //   snapshot.data[index]
                //       .data()["price"]
                //       .toString(),
                //   style: theme.textTheme.subtitle2,
                // ),
                Row(
                  //direction: Axis.vertical,
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                          child: Text("more",
                              style: TextStyle(
                                  color: Colors.blue)),
                          onPressed: () => print("here button")
                        // navigateToDetail(
                        //     snapshot.data[index], widget.target2),
                      )
                    ]),
                //SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// return Container(
// child: FutureBuilder(
// future: _data,
// builder: (_, snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
// return Center(
// child: Text("Loading..."),
// );
// } else {
// final ThemeData theme = Theme.of(context);
// return Column(children: <Widget>[
// // Row(
// //   children: <Widget> [
// //     Expanded(child: Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: TextField(
// //         controller: _addNameController,
// //       ),
// //     )
// //     ),
// //     RaisedButton(
// //         child: Text("Add to Database"),
// //         onPressed: (){
// //           _addToDatabase(_addNameController.text);
// //         }
// //         ),
// //   ],
// // ),
// Divider(),
// Column(
// children: <Widget> [
// Padding(
// padding: const EdgeInsets.all(1.0),
// child: TextField(
// cursorColor: Colors.black38,
// onChanged: (value){
// setState(() {
// searchString = value.toLowerCase();
// print("here");
// print(searchString);
// });
// },
// )
// )
// ],
// ),
//
// searchString != ""
// ? Expanded(child: StreamBuilder<QuerySnapshot>(
// stream: (searchString == null || searchString.trim() == "")
// ? FirebaseFirestore.instance.collection("posts")
//     .snapshots()
//     : FirebaseFirestore.instance.collection("posts")
//     .where("searchIndex", arrayContains: searchString)
//     .snapshots(),
// builder: (context, snapshot){
// if (snapshot.hasError)
// return Text('Error: ${snapshot.error}');
// switch (snapshot.connectionState){
// case ConnectionState.waiting:
// return Center(child: CircularProgressIndicator());
// default:
// return new ListView(
// children: snapshot.data.docs.map((DocumentSnapshot document){
// return new ListTile(
// leading: CircleAvatar(
// backgroundImage: NetworkImage(
// document["imageURL"]
// ),
// ),
// title: new Text(document['description']),
// onTap: (){
// print("Tap here");
// },
// );
// }).toList(),
// );
// }
// },
// )
// )
//
//     : Expanded(
// child: GridView.count(
// padding: EdgeInsets.all(16.0),
// childAspectRatio: 8.0 / 9.0,
// crossAxisCount: 3,
// //shrinkWrap: true,
// children: List.generate(snapshot.data.length, (index) {
// //itemCount: snapshot.data.length, //조심하기
// //itemBuilder: (_, index) {
// return listItem(snapshot.data[index]);
// // );
// })))
// ]);
// }
// }
// ),
// );

