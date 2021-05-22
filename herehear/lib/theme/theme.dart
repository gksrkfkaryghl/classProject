import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

final ThemeData light_theme = _buildClosetTheme_light();
final ThemeData dark_theme = _buildClosetTheme_dark();

ThemeData _buildClosetTheme_light() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    colorScheme: ColorScheme(
      primary: PrimaryColorLight,
      primaryVariant: PrimaryVariantLight,
      secondary: SecondaryLight,
      secondaryVariant: SecondaryVariantLight,
      surface: SurfaceLight,
      background: BackgroundLight,
      error: ErrorLight,
      onPrimary: OnPrimaryLight,
      onSecondary: OnSecondaryLight,
      onSurface: OnSurfaceLight,
      onBackground: OnBackgroundLight,
      onError: OnErrorLight,
      brightness: Brightness.light,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      color: BackgroundLight,
      titleTextStyle: TextStyle(color: OnBackgroundLight),

    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(

    ),
    scaffoldBackgroundColor: BackgroundLight,
    cardColor: SurfaceLight,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: OnSecondaryLight,
      shape: RoundedRectangleBorder( //버튼을 둥글게 처리
          borderRadius: BorderRadius.circular(10)),
      colorScheme: base.colorScheme.copyWith(
        primary: SurfaceLight,
        secondary: SurfaceLight,
      ),
    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent,
    ),

    textTheme: _buildClosetTextTheme(base.textTheme),
    primaryTextTheme: _buildClosetTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildClosetTextTheme(base.accentTextTheme),
  );

}
// ThemeData light = ThemeData(
//
// );
// ThemeData light = ThemeData(
//     // brightness: Brightness.light,
//     brightness: Brightness.light,
//     // primaryColorLight: Color(0xff6200EE),
//     primarySwatch: Colors.white,
//     accentColor: Colors.pink,
//     scaffoldBackgroundColor: Color(0xfff1f1f1));
// // scaffoldBackgroundColor: Color(0xff6200EE));

ThemeData _buildClosetTheme_dark() {
  final ThemeData base = ThemeData.dark();

  return base.copyWith(
    colorScheme: ColorScheme(
      primary: PrimaryColorDark,
      primaryVariant: PrimaryVariantDark,
      secondary: SecondaryDark,
      secondaryVariant: SecondaryVariantDark,
      surface: SurfaceDark,
      background: BackgroundDark,
      error: ErrorDark,
      onPrimary: OnPrimaryDark,
      onSecondary: OnSecondaryDark,
      onSurface: OnSurfaceDark,
      onBackground: OnBackgroundDark,
      onError: OnErrorDark,
      brightness: Brightness.dark,
    ),
    // const PrimaryColorDark = Color(0xFFBB86FC);
    // const PrimaryVariantDark = Color(0xFF3700B3);
    // const SecondaryDark = Color(0xFF03DAC6);
    // const SecondaryVariantDark = Color(0xFF03DAC6);
    // const BackgroundDark = Color(0xFF121212);
    // const SurfaceDark = Color(0xFF121212);
    // const ErrorDark = Color(0xFFCF6679);
    // const OnPrimaryDark = Color(0xFF000000);
    // const OnSecondaryDark = Color(0xFF000000);
    // const OnBackgroundDark = Color(0xFFFFFFFF);
    // const OnSurfaceDark = Color(0xFFFFFFFF);
    // const OnErrorDark = Color(0xFF000000);
    appBarTheme: base.appBarTheme.copyWith(
      color: BackgroundDark,
      titleTextStyle: TextStyle(color: OnBackgroundDark),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(

    ),
    scaffoldBackgroundColor: SurfaceDark,
    cardColor: BackgroundDark,      // <--- 사진 위 아래 테두리 까망까망한 원인!!!!!!!!!!!!
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: OnSecondaryDark,
      shape: RoundedRectangleBorder( //버튼을 둥글게 처리
          borderRadius: BorderRadius.circular(10)),
      colorScheme: base.colorScheme.copyWith(
        primary: SurfaceDark,
        secondary: OnSecondaryDark,
      ),
    ),
    buttonBarTheme: base.buttonBarTheme.copyWith(
      buttonTextTheme: ButtonTextTheme.accent,
    ),

    textTheme: _buildClosetTextTheme(base.textTheme).copyWith(
      // displayColor: OnSecondaryDark,
    ),
    primaryTextTheme: _buildClosetTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildClosetTextTheme(base.accentTextTheme),
  );
}




// ThemeData dark = ThemeData(
//     brightness: Brightness.dark,
//     primarySwatch: Colors.indigo,
//     accentColor: Colors.pink,
//     scaffoldBackgroundColor: Color(0xfff1f1f1));

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;
  bool get darkTheme => _darkTheme;
  ThemeNotifier() {
    _darkTheme = false;
  }
  toggleTheme() {
    _darkTheme = !_darkTheme;
    notifyListeners();
  }
}

TextTheme _buildClosetTextTheme(TextTheme base) {
  return base
      .copyWith(
    headline5: base.headline5.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Sansita',
    ),
    headline6: base.headline6.copyWith(fontSize: 18.0),
    caption: base.caption.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
    ),
    bodyText1: base.bodyText1.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
    ),
  );
  // .apply(
  //   displayColor: OnSecondaryLight,
  // );
}

AppBarTheme _buildClosetAppBarTheme(AppBarTheme base) {
  return base.copyWith(
    centerTitle: false,
    titleTextStyle: base.titleTextStyle.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Sansita',
    ),

  );
}