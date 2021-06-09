import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'Fixmypage.dart';
import 'app.dart';
import 'listview.dart';

class Scroll_page extends StatefulWidget {
  final String currentUser;
  var user_tag;

  Scroll_page({this.currentUser, this.user_tag}); // 이따가 수정해야함

  @override
  _Scroll_pageState createState() =>
      _Scroll_pageState(currentUser: currentUser, user_tag: user_tag);
}

class _Scroll_pageState extends State<Scroll_page>
    with SingleTickerProviderStateMixin {
  String currentUser;
  var user_tag;
  List tagList = [];

  _Scroll_pageState({this.currentUser, this.user_tag});

  TabController _tabController;
  ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  Widget _customScrollView() {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        expandedHeight: 250.0,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Collapsing Toolbar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              )),
          background: Image(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 3,
              image: NetworkImage(
                  "https://i.pinimg.com/originals/22/4e/69/224e694ee3a37f176cd039a672027e21.jpg")),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 75,
                    color: Colors.black12,
                  ),
                ),
            childCount: 10),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    print("[Scroll Page]current user & user_tag");
    print(currentUser);
    print(user_tag);
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(currentUser).get(),
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
          tagList = data["tags"];

          return Scaffold(
              body: NestedScrollView(
                controller: _scrollViewController,
                headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
                  return  <Widget>[
                    SliverAppBar(
                      // 첫번째 아이콘
                      leading: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FixPage(currentUser: currentUser)),
                          );
                        },
                        icon: Icon(Icons.create),
                        color: Colors.black,
                      ),

                      //두번째 아이콘
                      actions: [
                        IconButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              print("Success to log out");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HeHeApp()),
                              );
                            } catch (e) {
                              print(e.toString());
                              return null;
                            }
                          },
                          icon: Icon(Icons.exit_to_app),
                          color: Colors.black,
                        )
                      ],
                      centerTitle: true,
                      title: Text('My page', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w500)),

                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,

                        title: Text(data["displayname"], style: TextStyle(color: Colors.black, fontSize: 10)),
                        background: Stack(
                          overflow: Overflow.visible,
                          alignment: Alignment.center,
                          children: <Widget>[
                            Image(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height / 3,
                                image: NetworkImage(
                                    "https://i.pinimg.com/originals/22/4e/69/224e694ee3a37f176cd039a672027e21.jpg")
                            ),
                            Positioned(
                                bottom: 3,
                                child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                        data["userPhotoURL"]
                                      // "https://pbs.twimg.com/media/EhIO_LyVoAA2szZ?format=jpg&name=medium"
                                    ))),

                          ],
                        ),
                      ),

                      // 여러 기능들
                      pinned: true,
                      floating: true,
                      primary: false,
                      forceElevated: boxIsScrolled,
                      toolbarHeight: 120,


                      bottom: TabBar(

                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.black45,
                        labelStyle: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: <Widget>[
                          Tab(
                            text: "Mine",
                            icon: Icon(Icons.home),
                          ),
                          Tab(
                            text: "Scrap",
                            icon: Icon(Icons.star),
                          )
                        ],
                        controller: _tabController,
                      ),
                    )
                  ];
                },
                body: TabBarView(
                  children: <Widget>[
                    PageOne(currentUser: currentUser,user_tag: user_tag),
                    PageTwo(currentUser: currentUser,user_tag: user_tag),
                  ],
                  controller: _tabController,
                ),
              ),



              );
        }
        return Text("loading");
      },
    );
  }
}



class PageOne extends StatefulWidget {

  String currentUser;
  var user_tag;
  PageOne({this.currentUser, this.user_tag});


  @override
  _PageOneState createState() => _PageOneState(currentUser:currentUser, user_tag: user_tag);
}

class _PageOneState extends State<PageOne> {

  String currentUser;
  var user_tag;
  _PageOneState({this.currentUser, this.user_tag});
  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();
  List tagList = [];


  Future getPosts() async {
    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("uid",isEqualTo: currentUser).get(); // 이것도 uid로 바꿔줘야함.
    return qn.docs;
  }

  Future _data;
  @override
  initState(){
    super.initState();
    _data = getPosts();
  }


  @override
  Widget build(BuildContext context) {
    print("[_PageOneState]current user & user_tag");
    print(currentUser);
    print(user_tag);

    return FutureBuilder(
        future: _data,
        builder: (_, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(
                child: Text("Loading...")
            );
          }
          else{
            return Column(
              children: [

                Expanded(
                    child: GridView.count(
                        padding: EdgeInsets.all(16.0),
                        childAspectRatio: 8.0/9.0,
                        crossAxisCount: 3,
                        children: List.generate(snapshot.data.length, (index){
                          return listItem(snapshot.data[index]);
                        })
                    )
                ),
              ],
            );
          }
        }
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
                  ListViewPage(doc: snapshot, currentUser: currentUser),
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
                  ListViewPage(doc: snapshot, currentUser: currentUser),
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


class PageTwo extends StatefulWidget {

  String currentUser;
  var user_tag;
  PageTwo({this.currentUser, this.user_tag});


  @override
  _PageTwoState createState() => _PageTwoState(currentUser:currentUser, user_tag: user_tag);
}

class _PageTwoState extends State<PageTwo> {

  String currentUser;
  var user_tag;
  _PageTwoState({this.currentUser, this.user_tag});
  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();
  List tagList = [];



  Future getScrap() async {
    var user_data = await FirebaseFirestore.instance.collection("users").doc(currentUser).get(); // 이것도 uid로 바꿔줘야함.
    var Scrap_list = user_data.data()["Scrap"];

    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("docID", whereIn: Scrap_list).get();
    return qn.docs;
  }

  Future _data;
  @override
  initState(){
    super.initState();
    _data = getScrap();
  }
  // @override
  Widget build(BuildContext context) {
    print("[_PageTwoState]current user & user_tag");
    print(currentUser);
    print(user_tag);

    return FutureBuilder(
        future: _data,
        builder: (_, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(
                child: Text("Loading...")
            );
          }
          else{
            return Column(
              children: [
                Expanded(
                    child: GridView.count(
                        padding: EdgeInsets.all(16.0),
                        childAspectRatio: 8.0/9.0,
                        crossAxisCount: 3,
                        children: List.generate(snapshot.data.length, (index){
                          return listItem(snapshot.data[index]);
                        })
                    )
                ),
              ],
            );
          }
        }
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
                  ListViewPage(doc: snapshot, currentUser: currentUser),
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
                  ListViewPage(doc: snapshot, currentUser: currentUser),
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
