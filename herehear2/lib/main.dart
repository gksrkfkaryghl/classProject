import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';

// void main() => runApp(HeHeApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      ChangeNotifierProvider(
        create: (_) => Favorites(),
        child: HeHeApp(),
      )
  );

}

class Favorites extends ChangeNotifier {
  var fruit = false;

  void changeFruit(bool newFruit){

    print("change fruit");
    fruit =  newFruit;
    print(fruit);

    notifyListeners();
  }
}