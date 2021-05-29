import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter_tags/flutter_tags.dart';

import 'data/location.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';

class UploadPage extends StatefulWidget {
  GoogleSignInAccount currentUser;

  UploadPage({this.currentUser});

  @override
  _UploadPageState createState() => _UploadPageState(currentUser: currentUser);
}

class _UploadPageState extends State<UploadPage> {
  final _picker = ImagePicker();
  GoogleSignInAccount currentUser;

  _UploadPageState({this.currentUser});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();

  File _imageFile;

  // final String UserEmail = FirebaseAuth.instance.currentUser.email;
  final String currentUID = FirebaseAuth.instance.currentUser.uid;
  bool is_default = true;
  String downloadURL;
  List tagList = [];

  Future uploadToFirebase(File image) async {
    String docID = Timestamp.now().seconds.toString();
    final Position position = await Location().getCurrentLocation();
    final now = FieldValue.serverTimestamp();
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('posts/$docID');

    List <String> splitList = descriptionController.text.split(" ");
    List <String> indexList = [];

    await firebaseStorageRef.putString(nameController.text);
    if(is_default)
      downloadURL = 'http://handong.edu/site/handong/res/img/logo.png';
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

    Map<String, dynamic> data = {
      // 'type': _results.first["label"],
      'description' : descriptionController.text,
      "imageURL": downloadURL,
      'uid' : currentUID,
      'userDisplayName' : currentUser.displayName,
      'userPhotoURL' : currentUser.photoUrl,
      'likeNum' : 0,
      'docID': docID,
      'generatedTime': now,
      'updatedTime': '',
      'tags' : tagList,
      'searchIndex' : indexList
    };


    FirebaseFirestore.instance
        .collection('posts')
        .doc(docID)
        .set(data);
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

  Future pickAnImageFromCamera() async {
    var image = await _picker.getImage(source: ImageSource.camera);

    _imageFile = File(image.path);
    uploadToFirebase(_imageFile);
  }

  Widget loadImage() {
    if(is_default)
      return Container();
      // return Container(
      //   width: 2,
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(50, 8, 50, 8),
      //     child: ElevatedButton(
      //       // style: style,
      //       child: Text(
      //         '사진/동영상 선택',
      //         style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
      //       ),
      //       onPressed: null,
      //     ),
      //   ),
      // );
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

  @override
  Widget build(BuildContext context) {
    print('upload currentUser: ${currentUser}');
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
                onPressed: () {
                  uploadToFirebase(_imageFile).then((value) {
                    if(!is_default)
                      is_default = true;
                    Navigator.pop(context);
                  });
                }
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            loadImage(),
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
                    itemCount: tagList.length,
                    itemBuilder: (index) {
                      final Item currentItem = Item(title:tagList[index]);

                      return ItemTags(
                        index: index,
                        title: currentItem.title,
                        customData: currentItem.customData,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        color: Theme.of(context).colorScheme.secondary,
                        activeColor: Theme.of(context).colorScheme.primary,
                        textStyle: TextStyle(fontSize: 14),
                        combine: ItemTagsCombine.withTextBefore,
                        onPressed: (i) => print('asdfasdf: $i'),
                        onLongPressed: (i) => print('asdfasdf: $i'),
                        removeButton: ItemTagsRemoveButton(
                          onRemoved: () {
                            setState(() {
                              tagList.removeAt(index);
                            });
                            return true;
                          }
                        ),
                      );
                    },
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


// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:textfield_tags/textfield_tags.dart';
// import 'package:flutter_tags/flutter_tags.dart';
// // import 'package:firebase_analytics/firebase_analytics.dart';

// class UploadPage extends StatefulWidget {
//   @override
//   _UploadPageState createState() => _UploadPageState();
// }

// class _UploadPageState extends State<UploadPage> {
//   final _picker = ImagePicker();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final GlobalKey<TagsState> _globalKey = GlobalKey<TagsState>();

//   File _imageFile;

//   // final String UserEmail = FirebaseAuth.instance.currentUser.email;
//   final String currentUID = FirebaseAuth.instance.currentUser.uid;
//   bool is_default = true;
//   String downloadURL;
//   List tagList = [];


//   Future uploadToFirebase(File image) async {
//     String docID = Timestamp.now().seconds.toString();
//     final now = FieldValue.serverTimestamp();
//     Reference firebaseStorageRef =
//     FirebaseStorage.instance.ref().child('posts/$docID');

//     await firebaseStorageRef.putString(nameController.text);
//     if(is_default)
//       downloadURL = 'http://handong.edu/site/handong/res/img/logo.png';
//     else {
//       // UploadTask uploadTask = firebaseStorageRef.putFile(image);
//       await firebaseStorageRef.putFile(image);
//       downloadURL = await firebaseStorageRef.getDownloadURL();
//     }

//     Map<String, dynamic> data = {
//       // 'type': _results.first["label"],
//       'description' : descriptionController.text,
//       "imageURL": downloadURL,
//       'uid' : currentUID,
//       'likeNum' : 0,
//       'docID': docID,
//       'generatedTime': now,
//       'updatedTime': '',
//       'tags' : tagList,
//     };


//     FirebaseFirestore.instance
//         .collection('posts')
//         .doc(docID)
//         .set(data);
//   }

//   Future<String> pickAnImageFromGallery() async {
//     // ignore: deprecated_member_use
//     var image = await _picker.getImage(source: ImageSource.gallery);
//     // print(category);
//     // Perform image classification on the selected image.
//     // imageClassification(image);
//     _imageFile = File(image.path);
//     return image.path;
//   }

//   Future pickAnImageFromCamera() async {
//     var image = await _picker.getImage(source: ImageSource.camera);

//     _imageFile = File(image.path);
//     uploadToFirebase(_imageFile);
//   }

//   Widget loadImage() {
//     if(is_default)
//       return Container();
//       // return Container(
//       //   width: 2,
//       //   child: Padding(
//       //     padding: const EdgeInsets.fromLTRB(50, 8, 50, 8),
//       //     child: ElevatedButton(
//       //       // style: style,
//       //       child: Text(
//       //         '사진/동영상 선택',
//       //         style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
//       //       ),
//       //       onPressed: null,
//       //     ),
//       //   ),
//       // );
//     else
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.file(
//             _imageFile,
//             width: MediaQuery.of(context).size.width * 0.2,
//             ),
//           ),
//           Divider(height: 5, thickness: 1,),
//         ],
//       );

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.close, color: Colors.redAccent, size: 25,),
//             onPressed: () {
//               Navigator.pop(context);
//               is_default = true;
//             },
//           ),
//           title: Center(child: Text('Add')),
//           actions: <Widget>[
//             IconButton(
//                 icon: Icon(Icons.done, color: Theme.of(context).colorScheme.primary, size: 25,),
//                 onPressed: () {
//                   uploadToFirebase(_imageFile).then((value) {
//                     if(!is_default)
//                       is_default = true;
//                     Navigator.pop(context);
//                   });
//                 }
//             )
//           ],
//         ),
//         body: ListView(
//           children: <Widget>[
//             loadImage(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 IconButton(
//                   icon: Icon(Icons.photo_camera),
//                   iconSize: 25,
//                   onPressed: () {
//                     pickAnImageFromGallery().then((value){
//                       setState(() {
//                         print(value);
//                         is_default = false;
//                       });
//                     });
//                   },
//                 )
//               ],
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(24, 0, 24, 5),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: descriptionController,
//                     keyboardType: TextInputType.multiline,
//                     maxLines: null,
//                     minLines: 15,
//                     decoration:
//                       InputDecoration(
//                           border: InputBorder.none,
//                           hintText: "내용을 입력하세요."
//                       ),
//                   ),
//                   Divider(),
//                   Tags(
//                     key: _globalKey,
//                     textField: TagsTextField(
//                       textStyle: TextStyle(fontSize: 14),
//                       // constraintSuggestion: true, suggestions: [],
//                       onSubmitted: (value) {
//                         setState(() {
//                           tagList.add(Item(title: value));
//                           print(tagList);
//                         });
//                       }
//                     ),
//                     itemCount: tagList.length,
//                     itemBuilder: (index) {
//                       final Item currentItem = tagList[index];

//                       return ItemTags(
//                         index: index,
//                         title: currentItem.title,
//                         customData: currentItem.customData,
//                         textColor: Theme.of(context).colorScheme.onPrimary,
//                         color: Theme.of(context).colorScheme.secondary,
//                         activeColor: Theme.of(context).colorScheme.primary,
//                         textStyle: TextStyle(fontSize: 14),
//                         combine: ItemTagsCombine.withTextBefore,
//                         onPressed: (i) => print('asdfasdf: $i'),
//                         onLongPressed: (i) => print('asdfasdf: $i'),
//                         removeButton: ItemTagsRemoveButton(
//                           onRemoved: () {
//                             setState(() {
//                               tagList.removeAt(index);
//                             });
//                             return true;
//                           }
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         )
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     nameController.dispose();
//     priceController.dispose();
//     descriptionController.dispose();
//   }
// }
