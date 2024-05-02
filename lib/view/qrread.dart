import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class QRReadPage extends StatefulWidget {
  const QRReadPage({super.key});

  @override
  State<QRReadPage> createState() => _QrReadPageState();
}

class _QrReadPageState extends State<QRReadPage> {
  String qrResult = 'Nhấn vào đây để quét QR CODE';
  var valSend = <String>{};
  var token = "";
  void initState() {
    super.initState();
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
      response = await _dio.post("https://vnem.com/test/senddoublecheck.php",
          //"https://vnem.com/test/checkthe.json",
          onSendProgress: (int sent, int total) {});
      var token = response.toString();
      final body = json.decode(token);
      print("CHECK THE");
      print(body);
      Navigator.pushNamed(context, "QRReadPage");
    } catch (e) {
      print(e);
    }
  }

  GetValue1() {
    String strCCCD = '111111111111|000000000|tên|12122000|địa chỉ chỉ|08072021';
    String theBHYT =
        'GD4494920711100|4cc6b0c6a16e67204de1baa16e68205469e1babf6e|02/01/1953|1|4c6f6e6720587579c3aa6e20312c205468e1bb8b207472e1baa56e204e616d205068c6b0e1bb9b632c20487579e1bb876e2044757920587579c3aa6e2c2054e1bb896e68205175e1baa36e67204e616d|49 - 895|22/07/2020|-|30/06/2020|49074920711100|-|4|22/07/2025|3163aee3cd56aceb-7102|';
    print(theBHYT);
    GetValue(theBHYT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quét QR code'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                '$qrResult',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(onPressed: scanQR, child: Text('Quét QR')),
              //-----------
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: GetValue1, child: Text('test send data')),
              SizedBox(
                height: 30,
              ),
              //----------
            ],
          ),
        ));
  }
}
