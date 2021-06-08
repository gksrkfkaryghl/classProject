import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herehear/home.dart';
import 'package:provider/provider.dart';

import 'listview.dart';
import 'main.dart';

class NotificationPage extends StatefulWidget {
  String currentUser;
  var user_tag;

  NotificationPage({this.currentUser, this.user_tag});

  @override
  _NotificationPageState createState() =>
      _NotificationPageState(currentUser: currentUser, user_tag: user_tag);
}

class _NotificationPageState extends State<NotificationPage> {
  String currentUser;
  var user_tag;

  _NotificationPageState({this.currentUser, this.user_tag});

  var doc_list;

  Future getPosts() async {
    QuerySnapshot qn;
    qn = await FirebaseFirestore.instance
        .collection("posts")
        .where("docID",whereIn: doc_list)
        .get(); // 이것도 uid로 바꿔줘야함.
    return qn.docs;
  }

  String URL;

  initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      // Add Your Code here.
      Provider.of<Favorites>(context, listen: false).changeFruit(false);
    });
    print("[Notification ]fruit");
    print(Provider.of<Favorites>(context, listen: false).fruit);
  }

  @override
  Widget build(BuildContext context) {
    print("[Notification] current user");
    print(currentUser);

    CollectionReference users =
        FirebaseFirestore.instance.collection('notification');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(currentUser).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Notification",
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                leading: IconButton(
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                              currentUser: currentUser, user_tag: user_tag)),
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            body: Center(child: Text("Notification does not exist"))
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          print("doc_list");
          doc_list = data["docID"];
          print(doc_list);
          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Notification",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                leading: IconButton(
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                              currentUser: currentUser, user_tag: user_tag)),
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              body: FutureBuilder(
                  future: getPosts(),
                  builder: (_, snapshot2) {
                    if (snapshot2.connectionState == ConnectionState.waiting) {
                      print("Waitting");
                      return Center(child: Text("Loading..."));
                    } else {
                      print("Done");
                      print(snapshot2.data.length);
                      return ListView(
                          children:
                              List.generate(snapshot2.data.length, (index) {
                                var post_data =  snapshot2.data[index].data();
                                //var date = DateTime.fromMillisecondsSinceEpoch(post_data["generatedTime"] * 1000);
                                //print(date);
                                URL = post_data["imageURL"];


                                return Column(
                                  children: <Widget>[
                                ListTile(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListViewPage(doc: post_data, currentUser: currentUser),
                                    ),
                                  );
                                },
                                onLongPress: (){
                                  print('Long Pressed');
                                },
                                  leading: URL != null?
                                CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        post_data["imageURL"]
                                    ),
                                  ) : Icon(Icons.preview),

                                  title: Text(post_data["description"]),

                                subtitle: Text(post_data["tags"].toString()),
                                //trailing: Text(post_data["generatedTime"]),
                                ),
                                    Divider(thickness: 1,)


                                  ],

                                );


                      }));
                    }
                  }));
        }
        return Text("loading");
      },
    );
  }
}
