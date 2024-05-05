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
        print("qrResult :---------");
        print(qrResult);
        print("qrResult END ------------------");
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
    //var valSend = <String>{};
    var valSend = [];
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
    print("valSend : ");
    print(valSend);
    print("end ---------------- ");
    ReturnDataText(valSend);
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

  ReturnDataText(arrValSend) {
    //{049200008083, 206274468, Lương Mạnh Việt, 12122000, Nam, Tổ 11, Khôi Phố Long Xuyên 2, Nam Phước, Duy Xuyên, Quảng Nam, 08072021}
    //{GD4494920688744, Lương Mạnh Việt, 12/12/2000, 1, Long Xuyên 2, Thị trấn Nam Phước, Huyện Duy Xuyên, Tỉnh Quảng Nam, 49 - 159, 01/01/2024, -, 15/12/2023, 49074920688744, 4,  01/10/2021, 15a2a19f2e849284-7102, $
    //   TextEditingController txtMathe = new TextEditingController();
    // TextEditingController txtTenBenhNhan = new TextEditingController();
    // TextEditingController txtNgaySinh = new TextEditingController();
    String dataToCheck = "";
    int countCCCD = 11;
    arrValSend.forEach((element) {
      dataToCheck = dataToCheck + element + '|'; //data to fill
    });
    dataToCheck = dataToCheck.substring(
        0, dataToCheck.length - 1); // remove '|' cuoi cung
    print(dataToCheck);
    print("dataToCheck DONE ----------------");
    var values = dataToCheck.split('|');
    setState(() {
      //fill to textField
      //datalength>11 ? BHYT : CCCD
      String CCCD_BHYT = arrValSend[0];
      String birthday =
          values.length > countCCCD ? arrValSend[2] : arrValSend[3];
      String namePatient =
          values.length > countCCCD ? arrValSend[1] : arrValSend[2];
      if (birthday.length > 8) {
        //giu nguyen 12/12/2000
      } else {
        // 121220=>12/12/2000
        String day = birthday.substring(0, 2);
        String month = birthday.substring(2, 4);
        String year = birthday.substring(4);
        birthday = "$day/$month/$year";
      }
      txtMathe..text = CCCD_BHYT;
      txtTenBenhNhan..text = namePatient;
      txtNgaySinh..text = birthday;
      print(" CCCD_BHYT = " + CCCD_BHYT);
      print(" Tên Bệnh Nhân = " + namePatient);
      print(" Ngày sinh = " + birthday);
      print("FILL DATA DONE ----------------");
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    final checkThe =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      TextFormField(
        controller: txtMathe..text,
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
        controller: txtTenBenhNhan..text,
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
        controller: txtNgaySinh..text,
        decoration: InputDecoration(
          labelText: 'Ngày Sinh',
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            LineIcons.birthdayCake,
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
        controller: txtMathe..text,
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
        controller: txtTenBenhNhan..text,
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
        controller: txtNgaySinh..text,
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
