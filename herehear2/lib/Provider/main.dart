import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
    ChangeNotifierProvider(
        create: (_) => Favorites(),
        child: MyApp(),
    ),
);

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('My favorite fruit is ' + Provider.of<Favorites>(context).fruit),
        ),
        body: Center(
          child: Column(
            children: [
              FruitButton(fruit: 'Apples'),
              FruitButton(fruit: 'Oranges'),
              FruitButton(fruit: 'Bananas'),
            ],
          ),
        ),
      ),
    );
  }
}

class FruitButton extends StatelessWidget{
  final String fruit;
  FruitButton({this.fruit});

  @override
  Widget build(BuildContext context){
    return ElevatedButton(
        onPressed: (){
          Provider.of<Favorites>(context, listen: false).changeFruit(fruit);

        },
        child: Text(fruit),
    );
  }


}


class Favorites extends ChangeNotifier {
  String fruit = 'unknown';

  void changeFruit(String newFruit){
    print("change here");
   fruit =  newFruit;
   notifyListeners();
  }
}
