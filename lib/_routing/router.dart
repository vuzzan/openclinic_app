import 'package:flutter/material.dart';
import 'package:openclinic/_routing/routes.dart';
import 'package:openclinic/view/login.dart';
import 'package:openclinic/view/qrread.dart';
import 'package:openclinic/view/settingpage.dart';
import 'package:openclinic/view/showerorr.dart';

// const String landingViewRoute = '/';
// const String loginViewRoute = 'Login';
// const String qrCodeReadViewRoute = 'QrCodeRead';
// const String postCheckViewRoute = 'postCheck';
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case landingViewRoute:
      print("HOME");
      return MaterialPageRoute(builder: (context) => LoginPage());
    case qrCodeReadViewRoute:
      return MaterialPageRoute(builder: (context) => QRReadPage());
    case showError:
      return MaterialPageRoute(builder: (context) => ShowError());
    case settingPage:
      return MaterialPageRoute(builder: (context) => SettingPage());
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
