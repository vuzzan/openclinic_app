import 'dart:convert';
import 'package:clean_dialog/clean_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openclinic/_routing/routes.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String hostAddress = '';
  TextEditingController _hostController = TextEditingController();
  var token = "";
  var username = "";
  var password = "";
  bool checkSetting = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      token = "";
      hostAddress = "";
      checkSetting = false; //chua login
      initToken();
      GetValueSetting();
    });
  }

  Future<void> GetValueSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hostAddress =
          (prefs.getString('host') == null ? "" : prefs.getString('host'))!;
    });
  }

  Future<void> initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = (prefs.getString("login") == null ? "" : prefs.getString("login"))!;
    username = (prefs.getString('username') == null
        ? ""
        : prefs.getString('username'))!;
    password = (prefs.getString('password') == null
        ? ""
        : prefs.getString('password'))!;
    print("data SharedPreferences in setting page");
    print(username);
    print(password);

    if (token.length == 0) {
      print("token: null-----");
      checkSetting = false; //chua login
    } else {
      checkSetting = true; //da login
      //da login
    }
  }

  void _showDialogWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CleanDialog(
        title: 'Error',
        content: 'Bạn Chưa Nhập Host',
        backgroundColor: const Color(0XFFbe3a2c),
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
        actions: [
          CleanDialogActionButtons(
            actionTitle: 'Quay lại',
            onPressed: () => Navigator.pop(context),
          ),
          CleanDialogActionButtons(
            actionTitle: 'Nhập lại',
            textColor: const Color(0XFF27ae61),
            onPressed: () {
              Navigator.pop(context);
              _showHostInputDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showHostInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nhập địa chỉ host'),
          content: TextField(
            controller: _hostController,
            decoration: InputDecoration(hintText: "Nhập tại đây"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Lưu'),
              onPressed: () {
                setState(() {
                  hostAddress = _hostController.text;
                  print(hostAddress);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> saveHost(String host) async {
    print("host : " + host);
    print(host);
    if (host.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('host');
      prefs.setString('host', host);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingSecs = SettingsSection(
      title: Text(hostAddress == '' ? "Nhập host tại đây" : "Địa chỉ host"),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
          leading: Icon(Icons.link),
          title: Text(hostAddress == '' ? "Nhấn vào đây để nhập" : "Tên host"),
          value: Text(hostAddress),
          onPressed: (context) {
            _showHostInputDialog(context);
          },
        ),
      ],
    );
    final SettingHost = SettingsList(
      sections: [SettingSecs],
    );
    final SettingPage = SettingsList(
      sections: [SettingSecs],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: checkSetting
          ? SettingPage //true =? da login -> setting page
          : SettingHost, //false => chua login -> settinghost
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (await saveHost(hostAddress)) {
            Navigator.pushNamed(context, landingViewRoute);
            //Navigator.pop(context);
          } else {
            _showDialogWarning(context);
          }
        },
        backgroundColor: Color.fromARGB(255, 253, 190, 190),
        icon: Icon(Icons.login),
        label: Text("Đăng Nhập"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
