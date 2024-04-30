import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openclinic/theme.dart';
import 'package:openclinic/utils/colors.dart';
//import 'package:openclinic/theme.dart';
import '_routing/router.dart' as router;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenClinic',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      onGenerateRoute: router.generateRoute,
      initialRoute: "/",
    );
  }
}

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryDark));
  runApp(App());
}
