import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
import 'dart:async';

class QRReadPage extends StatefulWidget {
  const QRReadPage({super.key});

  @override
  State<QRReadPage> createState() => _QrReadPageState();
}

class _QrReadPageState extends State<QRReadPage> {
  TextEditingController txtMatheCCCD = new TextEditingController();
  TextEditingController txtMatheBHYT = new TextEditingController();
  TextEditingController txtTenBenhNhan = new TextEditingController();
  TextEditingController txtNgaySinh = new TextEditingController();
  TextEditingController txtDiaChi = new TextEditingController();
  TextEditingController txtHSD = new TextEditingController();
  TextEditingController txtGioiTinh = new TextEditingController();

  TextEditingController txtMA_LK = new TextEditingController(); //
  TextEditingController txtSTT = new TextEditingController(); //
  TextEditingController txtMA_BN = new TextEditingController(); //
  TextEditingController txtHO_TEN = new TextEditingController();
  TextEditingController txtSO_CCCD = new TextEditingController();
  TextEditingController txtNGAY_SINH = new TextEditingController();
  TextEditingController txtGIOI_TINH = new TextEditingController();
  TextEditingController txtMA_THE_BHYT = new TextEditingController();
  TextEditingController txtMA_DKBD = new TextEditingController();
  TextEditingController txtGT_THE_TU = new TextEditingController();
  TextEditingController txtGT_THE_DEN = new TextEditingController();
  TextEditingController txtMA_DOITUONG_KCB = new TextEditingController();
  TextEditingController txtNGAY_VAO = new TextEditingController();
  TextEditingController txtMA_LOAI_KCB = new TextEditingController();
  TextEditingController txtMA_CSKCB = new TextEditingController();
  TextEditingController txtMA_DICH_VU = new TextEditingController(); //
  TextEditingController txtTEN_DICH_VU = new TextEditingController();
  TextEditingController txtNGAY_YL = new TextEditingController();

  DateTime selectedDate = DateTime.now();
  String NV_ID = "";
  String NV_NAME = "";
  String CLINIC_ID = "";
  String CLINIC_MACSKCB = "";
  String qrResult = '';
  String _ValueDV = "";
  String _ValueBS = "";
  String U_ID_BS = "";
  String U_Name_BS = "";
  String BS = "";
  String MACCHN = "";
  String DIA_CHI = "";
  String GT_THE_TU = "";
  String GT_THE_DEN = "";
  String THOIDIEM_NAMNAM = "";
  int MaLK = 0;
  String MATINH_CU_TRU = "";
  String MAHUYEN_CU_TRU = "";
  String MAXA_CU_TRU = "";

  bool _isButtonDisabled = true;
  var token = "";
  var step = "checkthe"; // checkthe, checkdiachi, checkin (chon bs va pk)
  Map<String, dynamic> mapDV = {};
  List<dynamic> mapBS = [];
  void initState() {
    super.initState();
    setState(() {
      step = "checkthe";
      _ValueDV = "";
      _ValueBS = "";
      selectedDate = DateTime.now();
    });
    initToken();
  }

  Future<void> initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("login")!;
    final Value = json.decode(token);

    print("init state pageReadQr-------------------");
    print(Value);

    setState(() {
      NV_ID = Value["info"]["U_ID"];
      NV_NAME = Value["info"]["U_NAME"];
      CLINIC_ID = Value["info"]["CLINIC_ID"];
      CLINIC_MACSKCB = Value["info"]["CLINIC_MACSKCB"];

      for (final item in Value["mst"]["data"]) {
        if (item["LIST_BS"] == null) {
          // No add
        } else {
          mapDV[item["TEN_DVKT"]] = item["LIST_BS"];
          if (_ValueDV == "") {
            _ValueDV = item["TEN_DVKT"];
          }
        }
      }
      if (mapDV[_ValueDV].length > 0) {
        _ValueBS = mapDV[_ValueDV][0]["TEN_NHANVIEN"];
        //print("Default = " + _ValueBS);

        // Auto update list BS
        mapBS = mapDV[_ValueDV];
        //print("DefaultmapBS= " + _ValueBS);
      }

      print(mapDV);
      print(mapDV.keys);
      print(_ValueDV);
      print(CLINIC_MACSKCB);
      print(CLINIC_ID);
      print("init state END--------------------------");
    });
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

  Future<void> Checkin_del() async {
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

      // response = await _dio.post(
      //     //"https://vnem.com/test/senddoublecheck.php",
      //     "https://vnem.com/test/senddoublecheck.php",
      //     data: FormData.fromMap({"r": "3"}),
      //     onSendProgress: (int sent, int total) {});
      // var tokenCheck = response.toString();
      String url =
          "http://saigon.webhop.me:8282/app/checkin/senddoublecheck.php";
      response = await _dio.post(url,
          data: FormData.fromMap({
            "TEN_BENH_NHAN": txtTenBenhNhan.text,
            "NGAY_SINH": txtNgaySinh.text,
            "MA_THE": txtMatheCCCD.text,
            "NV_ID": NV_ID,
            "NV_NAME": NV_NAME,
            "CLINIC_ID": CLINIC_ID
          }),
          onSendProgress: (int sent, int total) {});
      var tokenCheck = response.toString();
      print("RESPONSE CHECK THE: --------------------------");
      final ValResponse = json.decode(tokenCheck);
      print(ValResponse);
      print(ValResponse["code"]);
      print(ValResponse["data"]["strMathe"]);
      print(ValResponse["data"]["strHoTen"]);
      print(ValResponse["data"]["strDiaChi"]);
      print(ValResponse["data"]["strTuNgay"]);
      print(ValResponse["data"]["strDenNgay"]);
      print(ValResponse["data"]["gioitinh"]);
      print(ValResponse["data"]["strThoidiem5Nam"]);
      final checkCode = ValResponse["data"]["checkCode"];
      if (checkCode == "000") {
        setState(() {
          step = "checkdiachi";
          GT_THE_TU = ValResponse["data"]["strTuNgay"];
          GT_THE_DEN = ValResponse["data"]["strDenNgay"];
          THOIDIEM_NAMNAM = ValResponse["data"]["strThoidiem5Nam"];
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              content: Text("Kiểm tra thẻ thành công !!!",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center),
              dismissDirection: DismissDirection.up,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 90,
                  left: 10,
                  right: 10),

              backgroundColor: Color.fromARGB(255, 46, 255, 140),
              //contentType: ContentType.failure,
            ));
          txtMatheBHYT..text = ValResponse["data"]["strMathe"];
          txtGioiTinh
            ..text = ValResponse["data"]["gioitinh"] == 1 ? "Nam" : "Nữ";
          txtTenBenhNhan..text = ValResponse["data"]["strHoTen"];
          txtNgaySinh..text = ValResponse["data"]["strNgaySinh"];
          txtDiaChi..text = ValResponse["data"]["strDiaChi"];
          txtHSD
            ..text = "Từ ngày: " +
                ValResponse["data"]["strTuNgay"] +
                " đến ngày: " +
                ValResponse["data"]["strDenNgay"];
        });
      } else {
        // check sai thẻ
        setState(() {
          step = "showerror";
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("erorr", ValResponse["data"]["checkText"]);
        Navigator.pushNamed(context, showError);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> CheckDiaChi() async {
    var DIA_CHI = txtDiaChi.text;
    var values = DIA_CHI.split(',');

    MAHUYEN_CU_TRU = values[2];
    MAXA_CU_TRU = values[1];
    MATINH_CU_TRU = values[3];
    Response response;
    try {
      Dio _dio = new Dio();
      String url = "http://saigon.webhop.me:8282/app/checkin/loaddv.php";
      response = await _dio.post(url,
          data: FormData.fromMap({
            "func": "sendCheckDiaChi",
            "DIA_CHI": DIA_CHI,
            "SMAHUYEN_CU_TRU": MAHUYEN_CU_TRU,
            "SMAXA_CU_TRU": MAXA_CU_TRU,
            "SMATINH_CU_TRU": MATINH_CU_TRU,
            "CLINIC_ID": CLINIC_ID
          }),
          onSendProgress: (int sent, int total) {});
      var tokenCheck = response.toString();
      //final body = json.decode(token);
      print("RESPONSE CHECK DIA CHI: --------------------------");
      final ValResponse = json.decode(tokenCheck);
      print(ValResponse);
      if (ValResponse["data"] != false) {
        setState(() {
          step = "checkin";
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              duration: Duration(seconds: 2),
              content: Text("Kiểm tra địa chỉ thành công !!!",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  textAlign: TextAlign.center),
              dismissDirection: DismissDirection.up,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 90,
                  left: 10,
                  right: 10),
              backgroundColor: Color.fromARGB(255, 46, 255, 140),
            ));
        });
      } else {
        //sai
        var content = "Sai Địa Chỉ Xin Mời Nhập Lại";
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
                duration: Duration(seconds: 2),
                content: Text(content,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center),
                dismissDirection: DismissDirection.up,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 350,
                    left: 10,
                    right: 10),
                backgroundColor: Color.fromARGB(255, 255, 0, 0)),
            //contentType: ContentType.failure,
          );
      }
      print("END RESPONSE CHECK DIA CHI: -------------------------------");

      print("CHECK DIACHI done");
      //Navigator.pushNamed(context, postCheckViewRoute);
    } catch (e) {
      print(e);
    }
  }

  Future<void> XacNhan() async {
    Response response;
    try {
      print("RESPONSE XacNhan : --------------------------");
      Dio _dio = new Dio();
      String KETQUA_CODE;
      String url = "http://saigon.webhop.me:8282/app/checkin/mstdata.php";
      response = await _dio.post(url,
          data: FormData.fromMap({
            "TEN_BENH_NHAN": txtTenBenhNhan.text,
            "GIOI_TINH": txtGioiTinh.text,
            "DIA_CHI": txtDiaChi.text,
            "GT_THE_TU": GT_THE_TU,
            "GT_THE_DEN": GT_THE_DEN,
            "NGAY_SINH": txtNgaySinh.text,
            "MA_THE": txtMatheBHYT.text,
            "MA_LK": "0",
            //"MA_DKBD": CLINIC_MACSKCB,
            "MA_DKBD": "49172", //debug
            "NV_ID": NV_ID,
            "NV_NAME": NV_NAME,
            "U_ID": U_ID_BS,
            "U_NAME": U_Name_BS,
            "DV_TEN": _ValueDV,
            "BS": BS,
            "BS_TEN": _ValueBS,
            "BS_DIACHI": DIA_CHI,
            "NGAY_CAP": "",
            "MA_QUAN_LY": "",
            "TEN_CHA_ME": "",
            "MA_DT_SONG": "",
            "THOIDIEM_NAMNAM": THOIDIEM_NAMNAM,
            "CHUOI_KIEM_TRA": "",
            "TEXT_TAMTHU": "",
            "CAN_NANG": "",
            "SO_CCCD": txtMatheCCCD.text,
            "MATINH_CU_TRU": "", //
            "MAHUYEN_CU_TRU": "", //
            "MAXA_CU_TRU": "", //
            "CLINIC_ID": CLINIC_ID
          }),
          onSendProgress: (int sent, int total) {});
      var tokenCheck = response.toString();
      final body = json.decode(tokenCheck);
      print(body);

      //KETQUA_CODE = body["res"]["MA_LK"] == null ? "0" : body["res"]["MA_LK"];
      if (body["res"]["KETQUA_CODE"] == null ||
          body["res"]["KETQUA_CODE"] == 0) {
        var content = body["res"]["KETQUA"] + " xin mời Checkin";
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
                duration: Duration(seconds: 2),
                content: Text(content,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    textAlign: TextAlign.center),
                dismissDirection: DismissDirection.up,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height - 350,
                    left: 10,
                    right: 10),
                backgroundColor: Colors.green),
            //contentType: ContentType.failure,
          );
        setState(() {
          _isButtonDisabled = false;
          print(body["res"]["MA_LK"]);
          MaLK = body["res"]["MA_LK"];
        });
      } else {
        var error = body["res"]["KETQUA"];
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Text(error,
                style: TextStyle(fontSize: 20, color: Colors.black),
                textAlign: TextAlign.center),
            dismissDirection: DismissDirection.up,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 350,
                left: 10,
                right: 10),
            backgroundColor: Color.fromARGB(255, 255, 46, 46),
            //contentType: ContentType.failure,
          ));
      }

      print("RESPONSE XacNhan END : --------------------------");
    } catch (e) {
      print(e);
    }
  }

  Future<void> CheckInBHYT() async {
    try {
      Response response;
      print("RESPONSE CheckInBHYT : --------------------------");
      print(MaLK);
      print(CLINIC_ID);
      Dio _dio = new Dio();
      String url = "http://saigon.webhop.me:8282/app/checkin/appcheckin.php";
      response = await _dio.post(url,
          data: FormData.fromMap({"ma_lk": MaLK, "CLINIC_ID": CLINIC_ID}),
          onSendProgress: (int sent, int total) {});
      var tokenCheck = response.toString();
      final body = json.decode(tokenCheck);
      print(body);
      setState(() {
        step = "CheckInBHYT";
        txtMA_LK..text = body["MA_LK"];
        txtSTT..text = body["STT"];
        txtMA_BN..text = body["MA_BN"];
        txtHO_TEN..text = body["HO_TEN"];
        txtSO_CCCD..text = body["SO_CCCD"];
        txtNGAY_SINH..text = body["NGAY_SINH"];
        txtGIOI_TINH..text = body["GIOI_TINH"] == 0 ? "Nữ" : "Nam";
        txtMA_THE_BHYT..text = body["MA_THE_BHYT"];
        txtMA_DKBD..text = body["MA_DKBD"];
        txtGT_THE_TU..text = body["GT_THE_TU"];
        txtGT_THE_DEN..text = body["GT_THE_DEN"];
        txtMA_DOITUONG_KCB..text = body["MA_DOITUONG_KCB"];
        txtNGAY_VAO..text = body["NGAY_VAO"];
        txtMA_LOAI_KCB..text = body["MA_LOAI_KCB"];
        txtNGAY_YL..text = body["NGAY_YL"];
        txtMA_CSKCB..text = body["MA_CSKCB"];
        txtMA_DICH_VU..text = body["MA_DICH_VU"];
        txtTEN_DICH_VU..text = body["TEN_DICH_VU"];
      });
      print("RESPONSE CheckInBHYT END : --------------------------");
    } catch (e) {
      print(e);
    }
  }

  void GetValueBS(String valueBS) {
    var values = valueBS.split(' ');
    BS = values.last;
    for (var val in mapBS) {
      if (val["TEN_NHANVIEN"] == valueBS) {
        setState(() {
          MACCHN = val["MACCHN"];
          DIA_CHI = val["DIA_CHI"];
          U_ID_BS = val["U_ID"];
          U_Name_BS = val["U_NAME"];
        });
      }
    }
    print(BS);
    print(MACCHN);
    print(DIA_CHI);
    print(U_ID_BS);
    print(U_Name_BS);
  }

  SendBHYT() async {
    //Navigator.pushNamed(context, "homeViewRoute");
    Response response;
    try {
      Dio _dio = new Dio();
      response = await _dio.post(
        "http://saigon.webhop.me:8282/app/checkin/apiclient.php",
      );
      var token = response.toString();
      final body = json.decode(token);
      print(body);
    } catch (e) {
      print(e);
    }
  }

  ReturnDataText(arrValSend) {
    //{049200008083, 206274468, Lương Mạnh Việt, 12122000, Nam, Tổ 11, Khôi Phố Long Xuyên 2, Nam Phước, Duy Xuyên, Quảng Nam, 08072021}
    //{GD4494920688744, Lương Mạnh Việt, 12/12/2000, 1, Long Xuyên 2, Thị trấn Nam Phước, Huyện Duy Xuyên, Tỉnh Quảng Nam, 49 - 159, 01/01/2024, -, 15/12/2023, 49074920688744, 4,  01/10/2021, 15a2a19f2e849284-7102, $
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
      txtMatheCCCD..text = CCCD_BHYT;
      txtTenBenhNhan..text = namePatient;
      txtNgaySinh..text = birthday;
      print(" CCCD_BHYT = " + CCCD_BHYT);
      print(" Tên Bệnh Nhân = " + namePatient);
      print(" Ngày sinh = " + birthday);
      print("FILL DATA DONE ----------------");
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2025));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        var valueDate = selectedDate.toString().split(" ");
        var dateTime = valueDate[0].toString().split("-");
        txtNgaySinh..text = dateTime[2] + "/" + dateTime[1] + "/" + dateTime[0];
        print(dateTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );

    final checkThe =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      TextFormField(
        controller: txtMatheCCCD..text = "049200008083",
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
        controller: txtTenBenhNhan..text = "Lương Mạnh Việt",
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
        onTap: () => _selectDate(context),
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
            gradient: chatBubbleGradient2),
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
        controller: txtMatheBHYT..text,
        decoration: InputDecoration(
          labelText: 'Mã Thẻ BHYT',
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
        controller: txtGioiTinh..text,
        decoration: InputDecoration(
          labelText: 'Giới tính',
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
      TextFormField(
        maxLines: null,
        controller: txtDiaChi..text,
        decoration: InputDecoration(
          labelText: 'Địa Chỉ',
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            LineIcons.addressCard,
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
        maxLines: null,
        controller: txtHSD..text,
        decoration: InputDecoration(
          labelText: 'Hạn Sử Dụng',
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            LineIcons.checkCircle,
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
            gradient: chatBubbleGradient2),
        child: TextButton(
          onPressed: CheckDiaChi,
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

    final checkIn =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      DropdownButtonFormField<String>(
        isExpanded: true,
        icon: const Icon(LineIcons.list, color: Colors.black),
        dropdownColor: Colors.white,
        decoration: InputDecoration(
            labelText: "Chọn Dịch Vụ",
            prefixIcon: Icon(
              LineIcons.medicalBook,
              color: Color.fromARGB(255, 179, 255, 0),
            ),
            border: OutlineInputBorder()),
        style: TextStyle(color: Colors.black, fontSize: 22),
        //hint: Text('Chọn dịch vụ'),
        value: _ValueDV,
        onChanged: (newValue) {
          setState(
            () {
              _ValueDV = newValue!;
              print(_ValueDV);
              print(mapDV[_ValueDV]);
              if (mapDV[_ValueDV].length > 0) {
                _ValueBS = mapDV[_ValueDV][0]["TEN_NHANVIEN"];
                print("Default = " + _ValueBS);
                GetValueBS(_ValueBS);
                // Auto update list BS
                mapBS = mapDV[_ValueDV];
                print("DefaultmapBS= " + _ValueBS);
              }
            },
          );
        },
        items: mapDV.keys.map(
          (String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          },
        ).toList(),
      ),
      SizedBox(
        width: 20.0,
        height: 20.0,
      ),
      DropdownButtonFormField<String>(
        isExpanded: true,
        icon: const Icon(
          LineIcons.list,
          color: Colors.black,
        ),
        dropdownColor: Colors.white,
        decoration: InputDecoration(
            labelText: "Chọn Bác Sĩ",
            prefixIcon: Icon(
              LineIcons.doctor,
              color: Color.fromARGB(255, 179, 255, 0),
            ),
            border: OutlineInputBorder()),
        style: TextStyle(color: Colors.black, fontSize: 22),
        //hint: Text('Chọn Bác sĩ'),
        value: _ValueBS,
        onChanged: (newValue) {
          setState(
            () {
              _ValueBS = newValue!;
              print(_ValueBS);
              print(mapBS);
              GetValueBS(_ValueBS);
            },
          );
        },
        items: mapBS.map(
          (obj) {
            //print(mapDV.containsKey(_ValueDV));
            return DropdownMenuItem<String>(
              value: obj["TEN_NHANVIEN"],
              child: Text(obj["TEN_NHANVIEN"]),
            );
          },
        ).toList(),
      ),
      SizedBox(
        width: 20.0,
        height: 20.0,
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 40.0),
              height: 60.0,
              //width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                border: Border.all(color: Colors.white),
                gradient: chatBubbleGradient2,
              ),
              child: TextButton(
                onPressed: XacNhan,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black87,
                  minimumSize: Size(88, 36),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
                child: Text("Xác Nhận"),
              ),
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(top: 40.0),
            height: 60.0,
            //width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: Colors.white),
              gradient: chatBubbleGradient2,
            ),
            child: TextButton(
              onPressed: _isButtonDisabled ? null : CheckInBHYT,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                minimumSize: Size(88, 36),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              child: Text('CHECK IN'),
            ),
          )),
        ],
      ),
    ]);
    final sendCheckBHYT =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Row(
        //row1
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtTEN_DICH_VU..text,
              decoration: InputDecoration(
                labelText: 'Tên Dịch Vụ',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtNGAY_YL..text,
              decoration: InputDecoration(
                labelText: 'Ngày Y Lệnh',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //2
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtHO_TEN..text,
              decoration: InputDecoration(
                labelText: 'Họ Tên',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtGIOI_TINH..text,
              decoration: InputDecoration(
                labelText: 'Giới Tính',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //3
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtMA_THE_BHYT..text,
              decoration: InputDecoration(
                labelText: 'Mã Thẻ BHYT',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtSO_CCCD..text,
              decoration: InputDecoration(
                labelText: 'Số CCCD',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //4
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtNGAY_SINH..text,
              decoration: InputDecoration(
                labelText: 'Ngày Sinh',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtNGAY_VAO..text,
              decoration: InputDecoration(
                labelText: 'Ngày vào',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //5
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtGT_THE_TU..text,
              decoration: InputDecoration(
                labelText: 'Từ Ngày',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtGT_THE_DEN..text,
              decoration: InputDecoration(
                labelText: 'Đến Ngày',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //7
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtMA_DKBD..text,
              decoration: InputDecoration(
                labelText: 'MÃ DKBD',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtMA_CSKCB..text,
              decoration: InputDecoration(
                labelText: 'MÃ CSKCB',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //8
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtMA_LK..text,
              decoration: InputDecoration(
                labelText: 'Mã Liên kết',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtSTT..text,
              decoration: InputDecoration(
                labelText: 'Số Thứ tự',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        //9
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: txtMA_BN..text,
              decoration: InputDecoration(
                labelText: 'MÃ Bệnh Nhân',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
          SizedBox(width: 10, height: 10),
          Expanded(
            child: TextFormField(
              controller: txtMA_DICH_VU..text,
              decoration: InputDecoration(
                labelText: 'Mã Dịch Vụ',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.white,
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.only(top: 40.0),
            height: 60.0,
            //width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: Colors.white),
              gradient: chatBubbleGradient2,
            ),
            child: TextButton(
              onPressed: SendBHYT,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: Size(88, 36),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              child: Text('Gởi BHYT'),
            ),
          )),
        ],
      ),
    ]);
    return Scaffold(
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
              Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: scanQR, child: Text('Quét Mã'))),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 50.0, left: 30.0, right: 30.0),
            decoration: BoxDecoration(gradient: primaryGradient),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: step == "checkthe"
                ? checkThe
                : (step == "checkdiachi"
                    ? checkDiaChi
                    : (step == "checkin"
                        ? checkIn
                        : (step == "CheckInBHYT" ? sendCheckBHYT : checkThe))),
          ),
        ));
  }
}
