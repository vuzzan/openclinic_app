import 'package:flutter/material.dart';
import 'package:openclinic/view/login.dart';
import 'package:openclinic/view/qrread.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case "homeViewRoute":
      return MaterialPageRoute(builder: (context) => QRReadPage());
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
