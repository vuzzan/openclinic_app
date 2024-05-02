import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:openclinic/utils/colors.dart';
import 'package:openclinic/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      controller: user..text = "3000000001",
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
      controller: pass..text = "abc123",
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
            // SizedBox(
            //   width: 200.0,
            //   height: 20.0,
            //   child: const Card(child: Text('Hello World!')),
            // ),
            Text(
              status_msg,
              style: TextStyle(
                  height: 2,
                  //fontWeight: FontWeight.w800,
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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, ""),
        child: Center(
          child: Text(
            'QUÊN PASSWORD?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    final newUser = Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, "registerViewRoute"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'New User?',
            //   style: TextStyle(
            //     color: Colors.white70,
            //     fontSize: 18.0,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            Text(
              'Tạo mới !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
          decoration: BoxDecoration(gradient: primaryGradient),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //logo,
              pageTitle,
              loginForm,
              loginBtn,
              forgotPassword,
              newUser
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    //Navigator.pushNamed(context, "homeViewRoute");
    Response response;
    try {
      var userText = user.text;
      var passText = pass.text;
      print(userText);
      print(passText);
      Dio _dio = new Dio();
      response = await _dio.post("http://app.vnem.com/app/login/login.php",
          data: FormData.fromMap({
            //"func": "jwt",
            "func": "login",
            "email": userText,
            "password": passText,
          }), onSendProgress: (int sent, int total) {
        //print("Dio send: $sent $total");
      });

      var token = response.toString();
      final body = json.decode(token);
      print("response : ");
      print(body);
      print(body['cid']);
      //var header = Utils.parseJwtHeader(token);
      //var payload = Utils.parseJwtPayLoad(token);
      // print(payload);
      // Create storage
      // FlutterSecureStorage storage = FlutterSecureStorage();
      // // Write value
      // await storage.write(key: 'jwt', value: token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("login", token);
      print("Login OK");
      //_token = token;
      //return {"result": true, "reason": "Login successful"};
      Navigator.pushNamed(context, "ScanBarcode");
    } catch (e) {
      print(e);
    }
  }
}
