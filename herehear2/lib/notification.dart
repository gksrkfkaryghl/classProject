import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<Favorites>(context, listen: false).changeFruit(false);


    return Container(
      child: Text("hello")

    );
  }
}
