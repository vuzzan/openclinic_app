import 'package:flutter/material.dart';
import 'package:openclinic/view/login.dart';
import 'package:openclinic/view/qrread.dart';
import 'package:openclinic/view/qrvalue.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case "ScanBarcode":
      return MaterialPageRoute(builder: (context) => QRReadPage());
    case "QRReadPage":
      return MaterialPageRoute(builder: (context) => QRValuePage());
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
