import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/_routing/routes.dart';
import 'package:openclinic/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class QRReadPage extends StatefulWidget {
  const QRReadPage({super.key});

  @override
  State<QRReadPage> createState() => _QrReadPageState();
}

class _QrReadPageState extends State<QRReadPage> {
  TextEditingController txtMathe = new TextEditingController();
  TextEditingController txtTenBenhNhan = new TextEditingController();
  TextEditingController txtNgaySinh = new TextEditingController();

  String qrResult = 'Nhấn vào đây để quét QR CODE';
  var valSend = <String>{};
  var token = "";

  var step = "checkthe"; // checkthe, checkdiachi, checkin (chon bs va pk)

  void initState() {
    super.initState();
    setState(() {
      step = "checkthe";
    });
    initToken();
  }

  Future<void> initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("login")!;
    print("init state pageReadQr");
    print(token);
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
        GetValue(qrResult);
      });
    } on PlatformException {
      qrResult = 'Sai';
    }
  }

  Future<void> Checkin() async {
    const url = 'https://vnem.com/test/checkthe.json';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw qrResult = 'Sai';
    }
  }

  void GetValue(String value) {
    var values = value.split('|');
    for (var val in values) {
      RegExp hexPattern = RegExp(r'^[a-fA-F0-9]+$');
      bool checkHex = hexPattern.hasMatch(val); // check is hex
      if (checkHex) {
        if (double.tryParse(val) != null) {
          //check is numberric (1)
          valSend.add(val);
        } else {
          final valHex = utf8.decode(hex.decode(val));
          valSend.add(valHex);
        }
      } else {
        valSend.add(val);
      }
    }
    //
    CheckThe();
  }

  Future<void> CheckThe() async {
    Response response;
    try {
      Dio _dio = new Dio();
      response = await _dio.post(
          //"https://vnem.com/test/senddoublecheck.php",
          "https://vnem.com/test/checkthe.json",
          data: FormData.fromMap({"r": "2"}),
          onSendProgress: (int sent, int total) {});
      var tokenCheck = response.toString();
      //final body = json.decode(token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("tokenCheck", tokenCheck);
      //print(tokenCheck);
      setState(() {
        step = "checkdiachi";
      });
      print("CHECK THE done");
      //Navigator.pushNamed(context, postCheckViewRoute);
    } catch (e) {
      print(e);
    }
  }

  sendCheckThe() {
    String strCCCD = '111111111111|000000000|tên|12122000|địa chỉ chỉ|08072021';
    String theBHYT =
        'GD4494920711100|4cc6b0c6a16e67204de1baa16e68205469e1babf6e|02/01/1953|1|4c6f6e6720587579c3aa6e20312c205468e1bb8b207472e1baa56e204e616d205068c6b0e1bb9b632c20487579e1bb876e2044757920587579c3aa6e2c2054e1bb896e68205175e1baa36e67204e616d|49 - 895|22/07/2020|-|30/06/2020|49074920711100|-|4|22/07/2025|3163aee3cd56aceb-7102|';
    print(theBHYT);
    GetValue(theBHYT);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    final checkThe =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      TextFormField(
        controller: txtMathe..text = "3000000001",
        decoration: InputDecoration(
          labelText: 'Mã Thẻ/CCCD',
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            LineIcons.barcode,
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
      TextFormField(
        controller: txtTenBenhNhan..text = "txtTenBenhNhan",
        decoration: InputDecoration(
          labelText: 'Tên Bệnh Nhân',
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
      ),
      TextFormField(
        controller: txtNgaySinh..text = "txtNgaySinh",
        decoration: InputDecoration(
          labelText: 'Ngày Sinh',
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
          onPressed: CheckThe,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            minimumSize: Size(88, 36),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
          ),
          child: Text('CHECK THẺ'),
        ),
      )
    ]);
    final checkDiaChi =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      TextFormField(
        controller: txtMathe..text = "1111111111",
        decoration: InputDecoration(
          labelText: 'Mã Thẻ/CCCD 2222',
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            LineIcons.barcode,
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
      TextFormField(
        controller: txtTenBenhNhan..text = "222222222222",
        decoration: InputDecoration(
          labelText: 'Tên Bệnh Nhân 3333',
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
      ),
      TextFormField(
        controller: txtNgaySinh..text = "3333333333333333",
        decoration: InputDecoration(
          labelText: 'Ngày Sinh',
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
          onPressed: null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            minimumSize: Size(88, 36),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
          ),
          child: Text('CHECK DIA CHI'),
        ),
      )
    ]);
    final checkIn = Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[]);

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Check In Bệnh Nhân',
                textAlign: TextAlign.left,
              ),
              ElevatedButton(onPressed: scanQR, child: Text('Quét QR')),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
            decoration: BoxDecoration(gradient: primaryGradient),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: step == "checkthe"
                ? checkThe
                : (step == "checkdiachi" ? checkDiaChi : (checkIn)),
          ),
        ));
  }
}
