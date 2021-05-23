import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

class UpdatePage extends StatefulWidget {
  var doc;

  UpdatePage({this.doc});

  @override
  _UpdatePageState createState() => _UpdatePageState(doc);
}

class _UpdatePageState extends State<UpdatePage> {
  var doc;

  _UpdatePageState(this.doc);

  final _picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController()..text = widget.doc['name'];
    priceController = TextEditingController()..text = widget.doc['price'];
    descriptionController = TextEditingController()..text = widget.doc['description'];
  }


  File _imageFile;

  final String UserEmail = FirebaseAuth.instance.currentUser.email;

  final String currentUID = FirebaseAuth.instance.currentUser.uid;

  bool is_default = true;

  Future updateToFirebase(File image, String docID) async {
    // await FirebaseStorage.instance.ref().child('images/$docID').getDownloadURL().then((value) => print('RRRRRRRRRRRR: $value'));
    // await FirebaseStorage.instance.ref().child('images/$docID').delete();
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('posts/$docID');
    final now = FieldValue.serverTimestamp();

    // await firebaseStorageRef.putString(nameController.text);
    if(is_default) {
      FirebaseFirestore.instance.collection('posts').doc(docID).update({
        'description': descriptionController.text,
        'updatedTime': now,
      });
      return;
    }
    await firebaseStorageRef.putFile(image);
    String downloadURL = await firebaseStorageRef.getDownloadURL();

    FirebaseFirestore.instance.collection('images').doc(docID).update({
      'description': descriptionController.text,
      'imageURL': downloadURL,
      'updatedTime': now,
    });
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
    if(is_default) {
      return Image.network(
        widget.doc['imageURL'],
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 250,
      );
    } else {
      return Image.file(
        _imageFile,
        width: 300,
        height: 250,
      );
    }
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
    return Scaffold(
        appBar: AppBar(
          leading: TextButton(
            child: Text('Cancel', style: TextStyle(fontSize: 13, color: Colors.black),),
            onPressed: () {
              Navigator.pop(context, doc);
              is_default = true;
            },
          ),
          title: Center(child: Text('Edit')),
          actions: <Widget>[
            TextButton(
                child: Text('Save', style: TextStyle(color: Colors.white),),
                onPressed: () {
                  updateToFirebase(_imageFile, widget.doc['docID']).then((value) {
                    if(!is_default)
                      is_default = true;
                    Navigator.pushNamed(context, '/home');
                  }
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    decoration:
                    InputDecoration(hintText: "Enter the name of this product.",),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration:
                    InputDecoration(hintText: "Enter price."),
                  ),
                  TextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration:
                    InputDecoration(hintText: "Enter descirption."),
                  ),
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
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
}
