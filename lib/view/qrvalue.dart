import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRValuePage extends StatefulWidget {
  const QRValuePage({super.key});

  @override
  State<QRValuePage> createState() => _QRValuePageState();
}

class _QRValuePageState extends State<QRValuePage> {
  static TextEditingController valueName = TextEditingController();
  static TextEditingController valueAdress = TextEditingController();
  var token = "";
  var name = "";
  var adress = "";
  var CCCD = "";
  void initState() {
    super.initState();
    initToken();
  }

  Future<void> initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("tokenCheck")!;
    print("Init Token : ");
    print(token);
    getValueToken();
  }

  void getValueToken() {
    final valueJson = json.decode(token.toString());
    var encodedString = jsonEncode(token.toString());
    final valueMap = json.decode(encodedString);
    print(" json body: ");
    print(valueJson);
  }

  final nameField = TextField(
    controller: valueName..text = "",
    decoration: InputDecoration(
      labelText: 'Tên bệnh nhân',
      labelStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(
        LineIcons.user,
        color: Colors.white,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(color: Colors.white),
    cursorColor: Colors.white,
  );

  final adressField = TextField(
    controller: valueAdress..text = '...',
    decoration: InputDecoration(
      labelText: '',
      labelStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(
        LineIcons.lock,
        color: Colors.white,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    keyboardType: TextInputType.text,
    style: TextStyle(color: Colors.white),
    cursorColor: Colors.white,
    obscureText: true,
  );

  // final infoForm = Padding(
  //   padding: EdgeInsets.only(top: 30.0),
  //   //padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
  //   child: Form(
  //     child: Column(
  //       children: <Widget>[
  //         Text(
  //           "Thông tin khám bệnh",
  //           style: TextStyle(
  //               height: 2,
  //               //fontWeight: FontWeight.w800,
  //               fontSize: 16.0,
  //               color: Color.fromARGB(255, 255, 255, 255)),
  //         )
  //         nameField,
  //         adressField,
  //       ],
  //     ),
  //   ),
  // );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
          decoration: BoxDecoration(gradient: primaryGradient),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[nameField, adressField],
          ),
        ),
      ),
    );
  }
}
