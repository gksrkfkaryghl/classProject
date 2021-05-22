import 'package:flutter/material.dart';

import 'home.dart';
import 'listview.dart';
import 'login.dart';
import 'mypage.dart';
import 'upload.dart';

class HeHeApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HereHear',
      home: HomePage(),
      initialRoute: '/login',
      routes: {
        '/home': (context) => HomePage(),
        '/listview': (context) => ListViewPage(),
        '/upload': (context) => UploadPage(),
        '/mypage': (context) => MyPage(),
        '/login': (context) => LoginPage(),
      },
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}
