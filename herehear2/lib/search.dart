import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herehear/listview.dart';

List<String> allNames = [];
var mainColor = Color(0xff1B3954);
var textColor = Color(0xff727272);
var accentColor = Color(0xff16ADE1);
var whiteText = Color(0xffF5F5F5);

class PostSearchDelegate extends SearchDelegate {
  QuerySnapshot<Object> postData;
  var user_tag;
  String currentUser;

  PostSearchDelegate(this.postData, this.user_tag, this.currentUser);
  var suggestion = [];
  List<String> searchResult = List();

  Future getPostData() async {
    allNames = await user_tag;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    getPostData();
    searchResult.clear();
    searchResult =
        allNames.where((element) => element.startsWith(query)).toList();
    return Container(
      margin: EdgeInsets.all(20),
      child: ListView(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          scrollDirection: Axis.vertical,
          children: List.generate(suggestion.length, (index) {
            var item = suggestion[index];
            return Card(
              color: Colors.white,
              child: Container(padding: EdgeInsets.all(16), child: Text(item)),
            );
          })),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: (query == null || query.trim() == "")
              ? FirebaseFirestore.instance.collection("posts")
              .snapshots()
              : FirebaseFirestore.instance.collection("posts")
              .where("searchIndex", arrayContains: query)
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListViewPage(doc: document, currentUser: currentUser),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
            }
          },
        )
    );
  }
}