import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/utils/colors.dart';

class QRValuePage extends StatefulWidget {
  const QRValuePage({super.key});

  @override
  State<QRValuePage> createState() => _QRValuePageState();
}

class _QRValuePageState extends State<QRValuePage> {
  TextEditingController valueName1 = new TextEditingController();
  TextEditingController valueAdress = new TextEditingController();

  final nameField = TextField(
    //controller: valueName1,
    decoration: InputDecoration(
      labelText: '',
      labelStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(
        LineIcons.envelope,
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
    // controller: valueAdress..text = '...',
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
