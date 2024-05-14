import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/_routing/routes.dart';
import 'package:openclinic/utils/colors.dart';
import 'package:openclinic/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  var status_msg = "";
  String username = "";
  String password = "";
  String apiRoot = "";
  @override
  void initState() {
    super.initState();
    setState(() {
      username = "";
      password = "";
      apiRoot = "";
      checkLoginStatus();
    });
  }

  void checkLoginStatus() async {
    // dang nhap to login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = (prefs.getString('username') == null
          ? ""
          : prefs.getString('username'))!;
      password = (prefs.getString('password') == null
          ? ""
          : prefs.getString('password'))!;
      apiRoot =
          (prefs.getString('host') == null ? "" : prefs.getString('host'))!;
      user..text = username;
      pass..text = password;

      print(" data SharedPreferences in login page");
      print("username : " + username);
      print("password : " + password);
      print("APIroot : " + apiRoot);
    });

    if (username.length > 0 && password.length > 0) {
      // co user pass to log
      print("Da Dang Nhap");
      _login();
    } else {
      // return login
      print("Chua Dang Nhap");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    final logo = Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AvailableImages.appLogo,
          fit: BoxFit.cover,
        ),
      ),
    );

    final pageTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Openclinic",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 45.0,
          ),
        ),
        Text(
          "Đăng nhập hệ thống!",
          //textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );

    final emailField = TextFormField(
      controller: user..text,
      onChanged: (value) => {
        setState(() {
          username = value;
        })
      },
      decoration: InputDecoration(
        labelText: 'Login ID',
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

    final passwordField = TextFormField(
      controller: pass..text,
      onChanged: (value) => {
        setState(() {
          password = value;
        })
      },
      decoration: InputDecoration(
        labelText: 'Password',
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

    final loginForm = Padding(
      padding: EdgeInsets.only(top: 30.0),
      //padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            emailField,
            passwordField,
            Text(
              status_msg,
              style: TextStyle(
                  height: 2,
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 255, 255, 255)),
            )
          ],
        ),
      ),
    );

    final loginBtn = Container(
      margin: EdgeInsets.only(top: 40.0),
      height: 60.0,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: TextButton(
        onPressed: status_msg == 'Đang đăng nhập...'
            ? null
            : () {
                _login();
              },
        style: TextButton.styleFrom(
          foregroundColor: Colors.black87,
          minimumSize: Size(88, 36),
          //padding: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
        ),
        child: Text(
          status_msg == 'Đang đăng nhập...' ? 'CHỜ...' : 'ĐĂNG NHẬP',
        ),
      ),
    );

    final forgotPassword = Padding(
      padding: EdgeInsets.only(top: 50.0),
      // child: InkWell(
      //   onTap: () => Navigator.pushNamed(context, ""),
      //   child: Center(
      //     child: Text(
      //       'QUÊN PASSWORD?',
      //       style: TextStyle(
      //         color: Colors.white70,
      //         fontSize: 18.0,
      //         fontWeight: FontWeight.w600,
      //       ),
      //     ),
      //   ),
      // ),
    );

    final newUser = Padding(
      padding: EdgeInsets.only(top: 20.0),
      // child: InkWell(
      //   onTap: () => Navigator.pushNamed(context, "registerViewRoute"),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       Text(
      //         'Tạo mới !',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 18.0,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
    return WillPopScope(
      onWillPop: () async {
        var val = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Xác Nhận"),
                content: Text("Nhấn OK Thoát"),
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
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
            decoration: BoxDecoration(gradient: primaryGradient),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                pageTitle,
                loginForm,
                loginBtn,
                forgotPassword,
                newUser
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.pushNamed(context, settingPage);
            if (username.length > 0 && password.length > 0) {
              saveLoginInfo(username, password);
            }
          },
          icon: Icon(Icons.add_link),
          label: Text("Nhập host tại đây"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void saveLoginInfo(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
  }

  void _login() async {
    //Navigator.pushNamed(context, "homeViewRoute");

    var userText = "";
    var passText = "";
    if (username.length > 0 && password.length > 0) {
      // check get user pass in shareRef
      userText = username;
      passText = password;
      print("data in sharedRef");
    } else {
      //getdata in textfield
      userText = user.text;
      passText = pass.text;
      print("data in TextField");
    }
    print(userText);
    print(passText);
    print(apiRoot);
    try {
      if (userText.length > 0 && passText.length > 0) {
        //saveLoginInfo(userText, passText);
      }

      Dio _dio = new Dio();
      Response response;
      var token;
      try {
        response = await _dio.post(apiRoot + "/app/login/login.php",
            data: FormData.fromMap({
              "device": "app",
              "func": "login",
              "email": userText,
              "password": passText,
            }), onSendProgress: (int sent, int total) {
          //print("Dio send: $sent $total");
        });
        print(response);
        token = response.toString();
      } on DioError catch (e) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Text("Host không chính xác, Vui lòng nhập lại Host!!!",
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

      final body = json.decode(token);
      if (body['status'] == "false") {
        // CHECK LOGIN
        var error = body['reason'];
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
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("login", token);
        print("Login successful");
        Navigator.pushNamed(context, qrCodeReadViewRoute);
      }
    } catch (e) {
      print(e);
    }
  }
}
