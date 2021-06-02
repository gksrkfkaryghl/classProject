import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:herehear/%EC%B0%B8%EA%B3%A0%EC%9E%90%EB%A3%8C/Fixmypage.dart';
// import 'package:herehear/%EC%B0%B8%EA%B3%A0%EC%9E%90%EB%A3%8C/SignUp.dart';

import 'Fixmypage.dart';
import 'login.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  Future getPosts() async {
    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("uid",isEqualTo: "Qz2LP0sw9DMP2XDqtyKzECs9J0q2").get(); // 이것도 uid로 바꿔줘야함.
    return qn.docs;
  }


  // user에서 스크랩 array 값이 posts의 docs 이름과 일치하면 됩니다.
  Future getScrap() async {
    var user_data = await FirebaseFirestore.instance.collection("users").doc("Qz2LP0sw9DMP2XDqtyKzECs9J0q2").get(); // 이것도 uid로 바꿔줘야함.
    var Scrap_list = user_data.data()["Scrap"];

    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance.collection("posts")
        .where("docID", whereIn: Scrap_list).get();
    return qn.docs;
  }


  final UID = "Qz2LP0sw9DMP2XDqtyKzECs9J0q2";
  Map<String, dynamic> documentData;

  String displayname;
  String location;

  Future Userinfo() async {
    await FirebaseFirestore.instance.collection("users")
        .where("uid", isEqualTo: UID).get().then((event) {
      if (event.docs.isNotEmpty) {
        documentData = event.docs.single.data();
        displayname = documentData["displayname"];
        location = documentData["location"];

        print("Userinfo here");
        print("displayname");
        print(displayname);
        print("location");
        print(location);
      }
    });
  }





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
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(UID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
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
                      MaterialPageRoute(builder: (context) => FixPage(target: data["uid"], )),
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
                          MaterialPageRoute(builder: (context) => LoginPage()),
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
                              "https://images.theconversation.com/files/229443/original/file-20180726-106508-fdvuja.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1200&h=675.0&fit=crop")),
                      Positioned(
                          bottom: -60.0,
                          child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  "https://spnimage.edaily.co.kr/images/Photo/files/NP/P/2008/05/PP08050700004.JPG")))
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  ListTile(
                    title: Center(
                        child: Text(data["displayname"],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                    subtitle: Center(child: Text(data["location"])),
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
                                MaterialStateProperty.all<Color>(Colors.blue),
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
                                MaterialStateProperty.all<Color>(Colors.blue),
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

          return Column(
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: <Widget>[
                  Image(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 3,
                      image: NetworkImage(
                          "https://images.theconversation.com/files/229443/original/file-20180726-106508-fdvuja.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1200&h=675.0&fit=crop")),
                  Positioned(
                      bottom: -60.0,
                      child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                              "https://spnimage.edaily.co.kr/images/Photo/files/NP/P/2008/05/PP08050700004.JPG")))
                ],
              ),
              SizedBox(
                height: 60,
              ),
              ListTile(
                title: Center(
                    child: Text(data["displayname"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                subtitle: Center(child: Text(data["location"])),
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
                            MaterialStateProperty.all<Color>(Colors.blue),
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
                            MaterialStateProperty.all<Color>(Colors.blue),
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
          );
        }

        return Text("loading");
      },
    );

  }
}
