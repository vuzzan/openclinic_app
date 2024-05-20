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
import 'dart:async';
import 'dart:math' as math;

class QRReadPage extends StatefulWidget {
  const QRReadPage({super.key});

  @override
  State<QRReadPage> createState() => _QrReadPageState();
}

class _QrReadPageState extends State<QRReadPage> with TickerProviderStateMixin {
  TextEditingController txtMatheCCCD = new TextEditingController();
  TextEditingController txtMatheBHYT = new TextEditingController();
  TextEditingController txtTenBenhNhan = new TextEditingController();
  TextEditingController txtNgaySinh = new TextEditingController();
  TextEditingController txtDiaChi = new TextEditingController();
  TextEditingController txtHSD = new TextEditingController();
  TextEditingController txtGioiTinh = new TextEditingController();
  //-----
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
  //-----
  DateTime selectedDate = DateTime.now();
  String apiRoot = "";
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
  //-----
  bool _isButtonDisabled = true;
  bool checkEmpty = true;
  bool checkNameEmpty = true;
  bool checkDateBirthday = true;
  String errorDateBirthday = "";
  //-----
  var token = "";
  var step = "checkthe"; // checkthe, checkdiachi, checkin (chon bs va pk)
  Map<String, dynamic> mapDV = {};
  List<dynamic> mapBS = [];
  //-----
  late AnimationController _controller;
  static const List<IconData> icons = const [Icons.settings, Icons.logout];

  //
  void initState() {
    super.initState();
    setState(() {
      _controller = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      step = "checkthe";
      _ValueDV = "";
      _ValueBS = "";
      apiRoot = "";
      errorDateBirthday = "Ngày không được để trống";
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
      apiRoot =
          (prefs.getString('host') == null ? "" : prefs.getString('host'))!;
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
      //buscarCameras();
      print(mapDV);
      print(mapDV.keys);
      print(_ValueDV);
      print(CLINIC_MACSKCB);
      print(CLINIC_ID);
      print(apiRoot);
      print("init state END--------------------------");
    });
  }

  // Future<void> buscarCameras() async {
  //   cameras = await availableCameras();
  //   controller = CameraController(cameras[0], ResolutionPreset.medium);
  //   controller.initialize().then((_) {
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {});
  //   });
  // }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Quay Về', true, ScanMode.QR);
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

  void ReturnDataText(arrValSend) {
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
      String CCCD_BHYT = arrValSend[0];
      //datalength > 11 ? BHYT : CCCD
      String birthday =
          values.length > countCCCD ? arrValSend[2] : arrValSend[3];
      String namePatient =
          values.length > countCCCD ? arrValSend[1] : arrValSend[2];
      if (birthday.length > 8) {
        //giu nguyen 12/12/2000
      } else {
        // 12122000=>12/12/2000
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

  Future<void> CheckThe() async {
    UpdateDateTime();
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
            ),
          );
        });

    Response response;
    try {
      Dio _dio = new Dio();
      String url = apiRoot + "/app/checkin/senddoublecheck.php";
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
      final code = ValResponse["code"];
      print(code.runtimeType);

      if (code == 0) {
        //get token true
        final checkCode = ValResponse["data"]["checkCode"];
        print(checkCode.runtimeType);
        if (checkCode == "000") {
          Navigator.of(context).pop();
          setState(() {
            step = "checkdiachi";
            GT_THE_TU = ValResponse["data"]["strTuNgay"];
            GT_THE_DEN = ValResponse["data"]["strDenNgay"];
            THOIDIEM_NAMNAM = ValResponse["data"]["strThoidiem5Nam"];
            String value = "Kiểm tra thẻ thành công !!!";
            showInSnackBar(value, false);
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
          Navigator.of(context).pop();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("erorr", ValResponse["data"]["checkText"]);
          Navigator.pushNamed(context, showError);
        }
      } else {
        //get token fail

        String error = ValResponse["data"];
        showInSnackBar(error, true);
        Navigator.of(context).pop();
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
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
            ),
          );
        });

    Response response;
    try {
      Dio _dio = new Dio();
      String url = apiRoot + "/app/checkin/loaddv.php";
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
        String val = "Kiểm tra địa chỉ thành công !!!";
        Navigator.of(context).pop();
        setState(() {
          step = "checkin";
          showInSnackBar(val, false);
        });
      } else {
        //sai
        Navigator.of(context).pop();
        var error = "Sai Địa Chỉ Xin Mời Nhập Lại";
        showInSnackBar(error, true);
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
      String url = apiRoot + "/app/checkin/mstdata.php";
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
            "MA_DKBD": CLINIC_MACSKCB,
            //"MA_DKBD": "49172", //debug
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
        String content = body["res"]["KETQUA"] + " xin mời Checkin";
        showInSnackBar(content, false);
        setState(() {
          _isButtonDisabled = false;
          print(body["res"]["MA_LK"]);
          MaLK = body["res"]["MA_LK"];
        });
      } else {
        var error = body["res"]["KETQUA"];
        showInSnackBar(error, true);
      }
      print("RESPONSE XacNhan END : --------------------------");
    } catch (e) {
      print(e);
    }
  }

  Future<void> CheckInBHYT() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
            ),
          );
        });
    try {
      Navigator.of(context).pop();
      Response response;
      print("RESPONSE CheckInBHYT : --------------------------");
      print(MaLK);
      print(CLINIC_ID);
      Dio _dio = new Dio();
      String url = apiRoot + "/app/checkin/appcheckin.php";
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

  void showInSnackBar(String value, bool isError) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(value,
            style: TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center),
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.only(bottom: 100, left: 10, right: 10),
        backgroundColor: isError
            ? Color.fromARGB(255, 255, 46, 46)
            : Color.fromARGB(255, 46, 255, 140),
        //contentType: ContentType.failure,
      ));
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
        apiRoot + "/app/checkin/apiclient.php",
      );
      var token = response.toString();
      final body = json.decode(token);
      print(body);
    } catch (e) {
      print(e);
    }
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

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void UpdateDateTime() {
    String DateTime = txtNgaySinh.text;
    String ngay = "";
    String thang = "";
    String thang1 = "";
    String thang2 = "";
    String nam = "";
    print(DateTime);
    print("DateTime.length truoc par:" + DateTime.length.toString());
    if (DateTime.length < 8) {
      if (isNumeric(DateTime)) {
        //check nummber and null
        print("La 1 so nguyen");
        print("DateTime.length: " + DateTime.length.toString());
        if (DateTime.length < 4) {
          print("STRING < 4");
          setState(() {
            checkDateBirthday = false;
            errorDateBirthday = "Định dạng cần nhập là DD/MM/YY";
          });
        } else {
          if (DateTime.length == 4) {
            if (int.parse(DateTime) > 1900 && int.parse(DateTime) < 2025) {
              DateTime = "01/01/" + DateTime;
            } else {
              ngay = DateTime.substring(0, 1);
              thang = DateTime.substring(1, 2);
              nam = DateTime.substring(2, 4);
              if (int.parse(nam) < 23) {
                DateTime = "0" + ngay + "/" + "0" + thang + "/" + "20" + nam;
              } else {
                DateTime = "0" + ngay + "/" + "0" + thang + "/" + "19" + nam;
              }
            }
          } else if (DateTime.length == 7) {
            ngay = DateTime.substring(0, 2);
            thang1 = DateTime.substring(2, 3);
            thang2 = DateTime.substring(1, 3);
            nam = DateTime.substring(3, 7);
            if (int.parse(thang2) > 12) {
              if (int.parse(ngay) > 31) {
                ngay = DateTime.substring(0, 1);
                DateTime = "0" + ngay + "/" + thang2 + "/" + nam;
              } else {
                DateTime = ngay + "/0" + thang1 + "/" + nam;
              }
            } else {
              if (int.parse(ngay) > 31) {
                ngay = DateTime.substring(0, 1);
                DateTime = "0" + ngay + "/" + thang2 + "/" + nam;
              } else {
                DateTime = ngay + "/0" + thang1 + "/" + nam;
              }
            }
          } else if (DateTime.length == 6) {
            ngay = DateTime.substring(0, 2);
            thang = DateTime.substring(2, 4);
            nam = DateTime.substring(4, 6);
            if (int.parse(nam) < 23) {
              if (int.parse(ngay) > 31 || int.parse(thang) > 12) {
                ngay = DateTime.substring(0, 1);
                thang = DateTime.substring(1, 2);
                nam = DateTime.substring(2, 6);
                DateTime = "0" + ngay + "/0" + thang + "/" + nam;
              } else {
                DateTime = ngay + "/" + thang + "/" + "20" + nam;
              }
            } else {
              if (int.parse(ngay) > 31 || int.parse(thang) > 12) {
                ngay = DateTime.substring(0, 1);
                thang = DateTime.substring(1, 2);
                nam = DateTime.substring(2, 6);
                DateTime = "0" + ngay + "/0" + thang + "/" + nam;
              } else {
                DateTime = ngay + "/" + thang + "/" + "19" + nam;
              }
            }
          } else if (DateTime.length == 8) {
            ngay = DateTime.substring(0, 2);
            thang = DateTime.substring(2, 4);
            nam = DateTime.substring(4, 8);
            DateTime = ngay + "/" + thang + "/" + nam;
          }
          print(DateTime);
          setState(() {
            checkDateBirthday = true;
            txtNgaySinh..text = DateTime;
          });
        }
      } else {
        print("DateTime kh phai so La :" + DateTime);
        if (DateTime.isEmpty) {
          setState(() {
            checkDateBirthday = false;
            errorDateBirthday = "Không được để rỗng";
          });
        } else {
          setState(() {
            checkDateBirthday = false;
            errorDateBirthday = "Không được nhập chữ VD:(29/02/2024)";
          });
        }
      }
    }
  }

  void CheckTenBenhNhan() {
    String tenBN = txtTenBenhNhan.text;
    print(tenBN);
    if (tenBN.length == 0) {
      //CheckMaThe();
      print("tenBN.length: " + tenBN.length.toString());
      setState(() {
        checkNameEmpty = false;
      });
    } else {
      setState(() {
        checkNameEmpty = true;
      });
    }
  }

  void CheckMaThe() {
    String MaThe = txtMatheCCCD.text;
    print(MaThe);
    if (MaThe.length == 0) {
      //CheckTenBenhNhan();
      print("MaThe.length: " + MaThe.length.toString());
      setState(() {
        checkEmpty = false;
      });
    } else {
      setState(() {
        checkEmpty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Color.fromARGB(255, 253, 190, 190);
    Color foregroundColor = Theme.of(context).disabledColor;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );

    final checkThe =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Focus(
        child: TextFormField(
          onEditingComplete: () {
            print('Tên Bệnh Nhân editing complete');
            CheckMaThe();
            FocusScope.of(context).nextFocus();
          },
          autofocus: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(15),
          ],
          controller: txtMatheCCCD..text,
          decoration: InputDecoration(
            labelText: 'Mã Thẻ/CCCD',
            labelStyle: TextStyle(color: Colors.white),
            errorText: checkEmpty ? null : 'Mã không được để trống',
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
        onFocusChange: (hasFocus) {
          hasFocus ? print('Focus MAThe: ') : CheckMaThe();
        },
      ),
      Focus(
        child: TextFormField(
          onEditingComplete: () {
            print('Tên Bệnh Nhân editing complete');
            CheckTenBenhNhan();
            FocusScope.of(context).nextFocus();
          },
          controller: txtTenBenhNhan..text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: InputDecoration(
            labelText: 'Tên Bệnh Nhân',
            labelStyle: TextStyle(color: Colors.white),
            errorText: checkNameEmpty ? null : 'Tên không được để trống',
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
        onFocusChange: (hasFocus) {
          hasFocus ? print('Focus Ten Benh Nhan: ') : CheckTenBenhNhan();
        },
      ),
      Focus(
        child: TextFormField(
          controller: txtNgaySinh..text,
          onEditingComplete: () {
            print('NgaySinh editing complete');
            UpdateDateTime();
            FocusScope.of(context).nextFocus();
          },
          decoration: InputDecoration(
            errorText: checkDateBirthday ? null : errorDateBirthday,
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: () => setState(() {
                _selectDate(context);
              }),
              icon: const Icon(Icons.date_range_rounded),
              iconSize: 35,
            ),
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
        onFocusChange: (hasFocus) {
          hasFocus ? print('FocusNgaySinh: ') : UpdateDateTime();
        },
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
    return WillPopScope(
        onWillPop: () async {
          var val = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Xác Nhận"),
                  content: Text("Nhấn OK Để Trở Về"),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('OK')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No')),
                  ],
                );
              });
          if (val != null) {
            return Future.value(val);
          } else {
            return Future.value(false);
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
                          : (step == "CheckInBHYT"
                              ? sendCheckBHYT
                              : checkThe))),
            ),
          ),
          floatingActionButton: new Column(
            mainAxisSize: MainAxisSize.min,
            children: new List.generate(icons.length, (int index) {
              Widget child = new Container(
                height: 55.0,
                width: 56.0,
                alignment: FractionalOffset.topCenter,
                child: new ScaleTransition(
                  scale: new CurvedAnimation(
                    parent: _controller,
                    curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                        curve: Curves.easeOut),
                  ),
                  child: new FloatingActionButton(
                    heroTag: null,
                    backgroundColor: backgroundColor,
                    mini: true,
                    child: new Icon(icons[index],
                        color: foregroundColor, size: 30.0),
                    onPressed: () async {
                      if (index == 1) {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        await preferences.remove('username');
                        await preferences.remove('password');
                        // await preferences.clear(); // clear data username,password,host
                        Navigator.pushNamed(context, landingViewRoute);
                      } else {
                        Navigator.pushNamed(context, settingPage);
                      }
                    },
                  ),
                ),
              );
              return child;
            }).toList()
              ..add(
                new FloatingActionButton(
                  heroTag: null,
                  child: new AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return new Transform(
                        transform: new Matrix4.rotationZ(
                            _controller.value * 0.5 * math.pi),
                        alignment: FractionalOffset.center,
                        child: new Icon(
                            _controller.isDismissed ? Icons.add : Icons.close,
                            color: Colors.black),
                      );
                    },
                  ),
                  onPressed: () {
                    if (_controller.isDismissed) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                ),
              ),
          ),
        ));
  }
}
