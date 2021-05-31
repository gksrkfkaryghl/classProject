import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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


  Future _data;
  var flag = true; // true: 내가 쓴 게시글, false: 스크랩한 게시글

  @override
  initState(){
    super.initState();
    _data = getPosts();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text('Abdul Aziz Ahwan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
          subtitle: Center(child: Text("native")),
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
}