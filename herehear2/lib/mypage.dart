import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
// import 'package:herehear/%EC%B0%B8%EA%B3%A0%EC%9E%90%EB%A3%8C/Fixmypage.dart';
// import 'package:herehear/%EC%B0%B8%EA%B3%A0%EC%9E%90%EB%A3%8C/SignUp.dart';

import 'Fixmypage.dart';
import 'new_my_page.dart';
import 'app.dart';
import 'login.dart';

class MyPage extends StatefulWidget {

  final String currentUser;
  var user_tag;
  MyPage({this.currentUser, this.user_tag});


  @override
  _MyPageState createState() => _MyPageState(currentUser: currentUser, user_tag: user_tag );
}

class _MyPageState extends State<MyPage> {
  String currentUser;
  var user_tag;

  _MyPageState({this.currentUser, this.user_tag});

  Future getPosts() async {
    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("uid",isEqualTo: currentUser).get(); // 이것도 uid로 바꿔줘야함.
    return qn.docs;
  }

  // user에서 스크랩 array 값이 posts의 docs 이름과 일치하면 됩니다.
  Future getScrap() async {
    var user_data = await FirebaseFirestore.instance.collection("users").doc(currentUser).get(); // 이것도 uid로 바꿔줘야함.
    var Scrap_list = user_data.data()["Scrap"];

    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("docID", whereIn: Scrap_list).get();
    return qn.docs;
  }

  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();
  List tagList = [];


  Future _data;
  var flag = true; // true: 내가 쓴 게시글, false: 스크랩한 게시글

  @override
  initState(){
    super.initState();
    _data = getPosts();
    //Userinfo();
  }

  @override
  Widget build(BuildContext context) {
    print("[myPage]current user & user_tag");
    print(currentUser);
    print(user_tag);

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return
      FutureBuilder<DocumentSnapshot>(
      future: users.doc(currentUser).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              appBar: AppBar(
                centerTitle: true,
                title: const Text('My Page',
                  style: TextStyle(color: Colors.black,
                  ),
                ),
                leading: IconButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      // MaterialPageRoute(builder: (context) => FixPage(currentUser: currentUser, )),
                        MaterialPageRoute(builder: (context) => Scroll_page(currentUser: currentUser, user_tag: user_tag,)),

                    );
                  },
                  icon: Icon(Icons.create),
                  color: Colors.black,
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      try{
                        await FirebaseAuth.instance.signOut();
                        print("Success to log out");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HeHeApp()),
                        );
                      }catch(e){
                        print(e.toString());
                        return null;
                      }
                    },
                    icon: Icon(Icons.exit_to_app),
                    color: Colors.black,
                  )
                ],
              ),
            resizeToAvoidBottomInset: false,
            body: Column(
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 3,
                          image: NetworkImage(
                          "https://i.pinimg.com/originals/22/4e/69/224e694ee3a37f176cd039a672027e21.jpg"
                          )),
                      Positioned(
                          bottom: -60.0,
                          child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  data["userPhotoURL"]
                                // "https://pbs.twimg.com/media/EhIO_LyVoAA2szZ?format=jpg&name=medium"
                              )))
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  ListTile(
                    title: Center(
                        child: Text(data["displayname"],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600

                            ))),
                    subtitle: Center(child: Text(data["location"])),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 5),
                      child: Column(
                        children: [
                          Tags(
                            key: _globalKey,
                            // textField: TagsTextField(
                            //     textStyle: TextStyle(fontSize: 14),
                            //     // constraintSuggestion: true, suggestions: [],
                            //     onSubmitted: (value) {
                            //       setState(() {
                            //         tagList.add(value);
                            //         print(tagList);
                            //       });
                            //     }),
                            itemCount: tagList.length,
                            itemBuilder: (index) {
                              final Item currentItem =
                              Item(title: tagList[index]);
                              return ItemTags(
                                index: index,
                                title: currentItem.title,
                                customData: currentItem.customData,
                                textColor:
                                Theme.of(context).colorScheme.onPrimary,
                                color:
                                Theme.of(context).colorScheme.secondary,
                                activeColor:
                                Theme.of(context).colorScheme.primary,
                                textStyle: TextStyle(fontSize: 14),
                                combine: ItemTagsCombine.withTextBefore,
                                onPressed: (i) => print('asdfasdf: $i'),
                                onLongPressed: (i) => print('asdfasdf: $i'),
                                removeButton:
                                ItemTagsRemoveButton(onRemoved: () {
                                  setState(() {
                                    tagList.removeAt(index);
                                  });
                                  return true;
                                }),
                              );
                            },
                          )
                        ],
                      )
                  ),






                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = true;
                                _data = getPosts();
                              });
                            },
                            style: flag == true
                                ? ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                                shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.blue))))
                                : ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                                shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.blue)))),
                            child: Text(
                              'Mine',
                              style: flag == true ?
                              TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              )
                                  :TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),

                            )),
                      ),
                      SizedBox(
                        //width: double.infinity,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = false;
                                _data = getScrap();

                              });
                            },
                            style: flag == false
                                ? ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                                shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.blue))))
                                : ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                                shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.blue)))),
                            child: Text(
                              'Scrap',
                              style: flag == false ?
                              TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              )
                                  :TextStyle(
                                //fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey,
                              ),

                            )),
                      ),
                    ],
                  ),
                  FutureBuilder(
                      future: _data,
                      builder: (_, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting){
                          return Center(
                              child: Text("Loading...")
                          );
                        }
                        else{
                          return Expanded(
                              child: GridView.count(
                                  padding: EdgeInsets.all(16.0),
                                  childAspectRatio: 8.0/9.0,
                                  crossAxisCount: 2,
                                  children: List.generate(snapshot.data.length, (index){
                                    return Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            AspectRatio(
                                                aspectRatio: 20 / 11,
                                                child: Image.network(snapshot.data[index].data()["imageURL"])
                                            ),
                                            SingleChildScrollView(
                                              child: Container(
                                                  padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget> [
                                                      Text(
                                                        snapshot.data[index].data()["description"],
                                                        maxLines: 1,
                                                      )
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        )
                                    );

                                  })
                              )

                          );
                        }

                      }
                  )
                ],
              )
          );
        }
        return Text("loading");
      },
    );
  }
}
