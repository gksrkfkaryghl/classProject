import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herehear/theme/theme.dart';
import 'package:herehear/upload.dart';
import 'package:provider/provider.dart';
import 'gridview.dart';
import 'listview.dart';
import 'myPage.dart';
import 'theme/colors.dart';

class HomePage extends StatefulWidget {
  // User currentUser;
  GoogleSignInAccount currentUser;

  HomePage({this.currentUser});


  @override
  _HomePageState createState() => _HomePageState(currentUser);
}

class _HomePageState extends State<HomePage> {
  GoogleSignInAccount currentUser;
  int _currentIndex = 0;
  //List<Widget> _children;
  _HomePageState(this.currentUser);

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [
      GridViewPage(),
      ListViewPage(currentUser: currentUser),

      // UploadPage(),
      //GridViewPage(),
      // CalendarPage(),
      MyPage(),
    ];
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            theme: notifier.darkTheme ? dark_theme : light_theme,
            home: Scaffold(
              body: _children[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                selectedItemColor:
                notifier.darkTheme ? PrimaryColorDark : PrimaryColorLight,
                //unselectedItemColor: Theme.of(context).colorScheme.onSecondary,
                unselectedItemColor:
                notifier.darkTheme ? SecondaryDark : SecondaryLight,
                selectedLabelStyle: Theme.of(context).textTheme.caption,
                unselectedLabelStyle: Theme.of(context).textTheme.caption,
                onTap: (value) {
                  setState(() {
                    _currentIndex = value;
                    print(_children[_currentIndex]);

                  });
                },
                items: [
                  BottomNavigationBarItem(
                      title: Text('홈'),
                      icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      title: Text('피드'),
                      // icon: ImageIcon(AssetImage('assets/closet.png'), size: 24,)
                      icon: Icon(Icons.search)),
                  BottomNavigationBarItem(
                      title: Text('일정'),
                      icon: Icon(Icons.date_range)),
                  BottomNavigationBarItem(
                      title: Text('마이 페이지'), icon: Icon(Icons.perm_identity)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
