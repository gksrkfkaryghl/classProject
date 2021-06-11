import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:herehear/main.dart';
import 'package:herehear/theme/theme.dart';
import 'package:herehear/upload.dart';
import 'package:herehear/weatherPage.dart';
import 'package:provider/provider.dart';
import 'gridview.dart';
import 'listview.dart';
import 'mypage.dart';
import 'new_my_page.dart';
import 'notification.dart';
import 'theme/colors.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.currentUser, this.user_tag}) : super(key: key);
  final String currentUser;
  var user_tag;

  // // User currentUser;
  // GoogleSignInAccount currentUser;



  @override
  //_HomePageState createState() => new _HomePageState();
  _HomePageState createState() => new _HomePageState(currentUser: currentUser, user_tag: user_tag);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({this.currentUser,this.user_tag});
  String currentUser;
  var user_tag;

  int _currentIndex = 0;
  //List<Widget> _children;
  //_HomePageState(this.currentUser);
  Future<bool> _onBackPressed(){
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("앱을 종료하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: ()=>Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("네"),
              onPressed: ()=>Navigator.pop(context, true),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    print("[HomePage] current user & user_tag");
    print(currentUser);
    print(user_tag);

    List<Widget> _children = [
      GridViewPage(currentUser: currentUser, user_tag: user_tag),
      //ListViewPage(doc: null, currentUser: currentUser),
      NotificationPage(currentUser: currentUser),
      // UploadPage(),
      //GridViewPage(),
      // CalendarPage(),
      weatherPage(),
      //MyPage(currentUser : currentUser, user_tag: user_tag),
      Scroll_page(currentUser: currentUser,user_tag: user_tag),

    ];
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            theme: notifier.darkTheme ? dark_theme : light_theme,
            home: Scaffold(
              body: WillPopScope(
                child: _children[_currentIndex],
                onWillPop: _onBackPressed,
              ),
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
                      icon:
                       Provider.of<Favorites>(context).fruit
                          ? Icon(
                           Icons.notifications_active,
                           color: Colors.red)
                          :
                       Icon(
                           Icons.notifications)
                  ),


                      // if (Provider.of<Favorites>(context).fruit){
                      //     Icon(Icons.search)
                      // }
                      // else{
                      //     Icon(Icons.search)
                      // }
                      // ),
                  BottomNavigationBarItem(
                      title: Text('날씨'),
                      icon: Icon(Icons.cloud_queue)),
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
