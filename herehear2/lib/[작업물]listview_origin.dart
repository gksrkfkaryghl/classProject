import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {

  Future getPosts() async {
    var firestore = FirebaseFirestore.instance;
    //firestore.collection("posts").get();
    firestore.collection("Product").get();
    QuerySnapshot qn = await firestore.collection("Product").get();

    return qn.docs;
  }

  TextEditingController _addNameController;
  String searchString = "";


  Future _data;
  @override
  initState() {
    super.initState();
    _data = getPosts();
    _addNameController = TextEditingController();
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




  @override
  Widget build(BuildContext context) {

    return Container(
      child: FutureBuilder(
          future: _data,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Loading..."),
              );
            } else {
              final ThemeData theme = Theme.of(context);
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
                Divider(),
                Column(
                  children: <Widget> [
                    Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TextField(
                          cursorColor: Colors.black38,
                          onChanged: (value){
                            setState(() {
                              searchString = value.toLowerCase();
                              print("here");
                              print(searchString);
                            });
                          },
                        )
                    )
                  ],
                ),

                searchString != ""
                    ? Expanded(child: StreamBuilder<QuerySnapshot>(
                  stream: (searchString == null || searchString.trim() == "")
                      ? FirebaseFirestore.instance.collection("Product")
                      .snapshots()
                      : FirebaseFirestore.instance.collection("Product")
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
                                    document["imgurl"]
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
                )

                    : Expanded(
                    child: GridView.count(
                        padding: EdgeInsets.all(16.0),
                        childAspectRatio: 8.0 / 9.0,
                        crossAxisCount: 2,
                        //shrinkWrap: true,
                        children: List.generate(snapshot.data.length, (index) {
                          //itemCount: snapshot.data.length, //조심하기
                          //itemBuilder: (_, index) {
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            // TODO: Adjust card heights (103)
                            child: Column(
                              // TODO: Center items on the card (103)
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: 20 / 11,
                                  child: Image.network(
                                      snapshot.data[index].data()["imgurl"]),
                                  // child: Image.asset(
                                  //   product.assetName,
                                  //   package: product.assetPackage,
                                  //   fit: BoxFit.fitWidth,
                                  // ),
                                ),
                                SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        16.0, 12.0, 16.0, 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          snapshot.data[index].data()["description"],
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
                            ),
                          );
                          // );
                        })))
              ]);
            }
          }



      ),
    );
  }
}
