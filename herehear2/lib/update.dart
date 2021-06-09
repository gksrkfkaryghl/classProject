import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'data/location.dart';
import 'gridview.dart';
import 'home.dart';
import 'listview.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage({this.doc, this.currentUser, this.user_tag});

  var doc;
  final String currentUser;
  var user_tag;

  @override
  _UpdatePageState createState() => _UpdatePageState(doc, currentUser, user_tag);
}

class _UpdatePageState extends State<UpdatePage> {
  var doc;
  final String currentUser;
  var user_tag;

  _UpdatePageState(this.doc, this.currentUser, this.user_tag);

  final _picker = ImagePicker();
  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();
  List tagList = [];

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController()..text = widget.doc['description'];
    tagList = doc['tags'];
  }


  File _imageFile;

  bool is_default = true;
  String downloadURL;

  Future updateToFirebase(File image, String docID) async {
    final String currentLocation = await Location().getLocation();
    final now = FieldValue.serverTimestamp();
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('posts/$docID');

    List <String> splitList = descriptionController.text.split(" ");
    List <String> indexList = [];

    if(is_default)
      downloadURL = doc['imageURL'];
    else {
      // UploadTask uploadTask = firebaseStorageRef.putFile(image);
      await firebaseStorageRef.putFile(image);
      downloadURL = await firebaseStorageRef.getDownloadURL();
    }

    for (int i = 0; i < splitList.length; i++){
      for (int y = 1; y < splitList[i].length + 1; y++) {
        indexList.add(splitList[i].substring(0,y).toLowerCase());
      }
    }

    for (int i = 0; i < tagList.length; i++){
      for (int y = 1; y < tagList[i].length + 1; y++) {
        indexList.add(tagList[i].substring(0,y).toLowerCase());
      }
    }

    // await firebaseStorageRef.putString(nameController.text);
    if(is_default) {
      FirebaseFirestore.instance.collection('posts').doc(docID).update({
        'description' : descriptionController.text,
        "imageURL": downloadURL,
        'uid' : currentUser,
        'docID': docID,
        'updatedTime': now,
        'tags' : tagList,
        'location' : currentLocation,
        'searchIndex' : indexList,
      });
      return;
    }
    await firebaseStorageRef.putFile(image);
    downloadURL = await firebaseStorageRef.getDownloadURL();

    FirebaseFirestore.instance.collection('posts').doc(docID).update({
      'description' : descriptionController.text,
      "imageURL": downloadURL,
      'uid' : currentUser,
      'docID': docID,
      'updatedTime': now,
      'tags' : tagList,
      'location' : currentLocation,
      'searchIndex' : indexList,
    });
    return;
  }

  Future<String> pickAnImageFromGallery() async {
    // ignore: deprecated_member_use
    var image = await _picker.getImage(source: ImageSource.gallery);
    // print(category);
    // Perform image classification on the selected image.
    // imageClassification(image);
    _imageFile = File(image.path);
    return image.path;
  }

  Widget loadImage(BuildContext context) {
    if(is_default)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              doc['imageURL'],
              width: MediaQuery.of(context).size.width * 0.2,
            ),
          ),
          Divider(height: 5, thickness: 1,),
        ],
      );
    else
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              _imageFile,
              width: MediaQuery.of(context).size.width * 0.2,
            ),
          ),
          Divider(height: 5, thickness: 1,),
        ],
      );
  }

  // void updateDoc(String docID, String name, int price, String description, String imgURL) {
  //   FirebaseFirestore.instance.collection('images').doc(docID).update({
  //     'name': name,
  //     'price': price,
  //     'description': description,
  //     'imageURL' : imgURL
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    print('upload currentUser: ${currentUser}');
    print('tag: ${tagList}');
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.redAccent, size: 25,),
            onPressed: () {
              Navigator.pop(context);
              is_default = true;
            },
          ),
          title: Center(child: Text('Add')),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done, color: Theme.of(context).colorScheme.primary, size: 25,),
                onPressed: () async {
                  await updateToFirebase(_imageFile, doc['docID']);
                  if(!is_default)
                    is_default = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(currentUser: currentUser, user_tag: user_tag),
                    ),
                  );
                }
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            loadImage(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_camera),
                  iconSize: 25,
                  onPressed: () {
                    pickAnImageFromGallery().then((value){
                      setState(() {
                        print(value);
                        is_default = false;
                      });
                    });
                  },
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 5),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 15,
                    decoration:
                    InputDecoration(
                        border: InputBorder.none,
                        hintText: "내용을 입력하세요."
                    ),
                  ),
                  Divider(),
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
                    textField: TagsTextField(
                        textStyle: TextStyle(fontSize: 14),
                        // constraintSuggestion: true, suggestions: [],
                        onSubmitted: (value) {
                          setState(() {
                            tagList.add(value);
                            print(tagList);
                          });
                        }
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
  }
}
