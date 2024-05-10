import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/_routing/routes.dart';
import 'package:openclinic/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowError extends StatefulWidget {
  const ShowError({super.key});

  @override
  State<ShowError> createState() => _ShowErrorState();
}

class _ShowErrorState extends State<ShowError> {
  static TextEditingController txtError = new TextEditingController();
  var token = "";
  bool isBack = false;
  void initState() {
    super.initState();
    initToken();
  }

  Future<void> initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("erorr")!;
    setState(() {
      isBack = false;
      txtError..text = token;
    });
    print("Init Token : ");
    print(token);
  }

  bool BackHome() {
    if (isBack) {
    } else {
      setState(() {
        isBack = true;
        Navigator.pushNamed(context, qrCodeReadViewRoute);
        print(isBack);
      });
    }
    return isBack;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var val = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Xác Nhận"),
                content: Text("Nhấn OK quét lại mã"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(BackHome()),
                      child: const Text('Yes')),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                ],
              );
            });
        if (val != null) {
          // return Future.value(Navigator.pushNamed(context, qrCodeReadViewRoute)
          //   as FutureOr<bool>?);
          return Future.value(val);
          //return Future.value(BackHome());
        } else {
          return Future.value(BackHome());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 2,
                  child: Text(
                    'Check In Bệnh Nhân',
                    textAlign: TextAlign.left,
                  )),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
            decoration: BoxDecoration(gradient: primaryGradient),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: txtError..text,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'LỖI',
                          labelStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(
                            LineIcons.ban,
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
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40.0),
                        height: 60.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          border: Border.all(color: Colors.white),
                          color: Colors.white,
                        ),
                        child: TextButton(
                          onPressed: BackHome,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            minimumSize: Size(88, 36),
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.0)),
                            ),
                          ),
                          child: Text('Nhấn đề quét lại mã'),
                        ),
                      )
                    ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
