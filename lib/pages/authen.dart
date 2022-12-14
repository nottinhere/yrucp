import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/main.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/popup_model.dart';
import 'package:yrusv/pages/my_service.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/pages/detail_popup.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/pages/route.dart';

import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Explicit
  String user, password; // default value is null
  final formKey = GlobalKey<FormState>();
  UserModel userModel;
  bool remember = false; // false => unCheck      true = Check
  bool status = true;

  PopupModel popupModel;
  String subjectPopup = '';
  String imagePopup = '';
  String statusPopup = '';
  String gotoPath = '';

  // Method
  @override
  void initState() {
    super.initState();
    checkLogin();
    setState(() {
      final uri = Uri.parse(Uri.base.toString());
      gotoPath = uri.fragment;
    });
  }

  Future<void> checkLogin() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      user = sharedPreferences.getString('User');
      password = sharedPreferences.getString('Password');

      if (user != null) {
        checkAuthen();
      } else {
        setState(() {
          status = false;
        });
      }
    } catch (e) {}
  }

  Widget rememberCheckbox() {
    return Container(
      width: 250.0,
      child: Theme(
        data: Theme.of(context)
            .copyWith(unselectedWidgetColor: MyStyle().textColor),
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Remember me',
            style: TextStyle(color: MyStyle().textColor),
          ),
          value: remember,
          onChanged: (bool value) {
            setState(() {
              remember = value;
            });
          },
        ),
      ),
    );
  }

  // Method
  Widget loginButton() {
    return Container(
      width: 250.0,
      child: ElevatedButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12.0),
        // ),
        // color: MyStyle().textColor,
        child: Text('Login',
            style: TextStyle(
              color: Colors.white,
            )),
        onPressed: () {
          formKey.currentState.save();
          // print(
          //   'user = $user,password = $password',
          // );
          checkAuthen();
        },
      ),
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // exit(0);
    // exit(0);
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyApp();
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget okButtonLogin(BuildContext buildContext) {
    return TextButton(
      child: Text('OK'),
      onPressed: () {
        logOut();
        Navigator.of(buildContext).pop(); // pop คือการทำให้มันหายไป
        // MaterialPageRoute materialPageRoute =
        //     MaterialPageRoute(builder: (BuildContext buildContext) {
        //   return Authen();
        // });
        // Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Future<void> normalDialogLogin(
    BuildContext buildContext,
    String title,
    String message,
  ) async {
    showDialog(
      context: buildContext,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: showTitle(title),
          content: Text(message),
          actions: <Widget>[okButtonLogin(buildContext)],
        );
      },
    );
  }

  Future<void> checkAuthen() async {
    if (user.isEmpty || password.isEmpty) {
      // Have space
      normalDialog(context, 'กรุณาตรวจสอบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      // var en_password = md5.convert(utf8.encode(password)).toString();
      // en_password = sha1.convert(utf8.encode(en_password)).toString();
      // var uri = 'us=$user&pw=$en_password';
      // Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
      // String query_string = stringToBase64Url.encode(uri);

      // String url = '${MyStyle().getUserWhereUserAndPass}?code=' + query_string;
      // print('url = $url');
      // http.Response response = await http
      //     .get(url); // await จะต้องทำงานใน await จะเสร็จจึงจะไปทำ process ต่อไป

      String url = '${MyStyle().getUserWhereUserAndPass}';
      http.Response response = await http
          .post(Uri.parse(url), body: {'user': user, 'password': password});
      // print('url = $url || user = $user || password = $password');
      var result = json.decode(response.body);

      int statusInt = result['status'];

      if (statusInt == 0) {
        String message = result['message'];
        normalDialogLogin(context, 'ข้อมูลไม่ถูกต้อง', message);
      } else if (statusInt == 1) {
        Map<String, dynamic> map = result['data'];
        // print('map = $map');

        int userStatus = map['status'];
        // print('userStatus = $userStatus');

        userModel = UserModel.fromJson(map);
        if (remember) {
          saveSharePreference();
        } else {
          routeToMyService();
        }
      }
    }
  }

  void gotoService() {
    // print('Before gotoroute > ' + gotoPath);

    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return RoutePage(userModel: userModel, gotoURL: gotoPath);
    });

    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
        (Route<dynamic> route) {
      return false;
    });
  }

  Future<void> saveSharePreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('User', user);
    sharedPreferences.setString('Password', password);

//    routeToMyService(statusPopup);  // with popup
    routeToMyService(); // with popup
  }

  void routeToMyService() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return RoutePage(userModel: userModel, gotoURL: gotoPath);
    });
    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
        (Route<dynamic> route) {
      return false;
    });
  }

  Widget userForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      height: 35.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.grey[800]),
        // initialValue: 'nott', // set default value
        onSaved: (String string) {
          user = string.trim();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            top: 6.0,
          ),
          prefixIcon: Icon(Icons.account_box, color: Colors.grey[800]),
          border: InputBorder.none,
          hintText: 'Username ::',
          hintStyle: TextStyle(color: Colors.grey[800]),
        ),
      ),
    );
  }

  Widget mySizeBox() {
    return SizedBox(
      height: 10.0,
    );
  }

  Widget passwordForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      height: 35.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.grey[800]),
        // initialValue: '909090', // set default value
        onSaved: (String string) {
          password = string.trim();
        },
        obscureText: true, // hide text key replace with
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            top: 6.0,
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.grey[800],
          ),
          border: InputBorder.none,
          hintText: 'Password ::',
          hintStyle: TextStyle(color: Colors.grey[800]),
        ),
      ),
    );
  }

  Widget showLogo() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: Image.asset('images/logo_master.png'),
    );
  }

  Widget showAppName() {
    return Text(
      ' ',
      style: TextStyle(
        fontSize: MyStyle().h1,
        color: MyStyle().mainColor,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        fontFamily: MyStyle().fontName,
      ),
    );
  }

  Widget showProcess() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserModel myUserModel;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: Home.route,
      home: Scaffold(
        body: SafeArea(
          child: status ? mainContent() : mainContent(),
        ),
      ),
    );
  }

  Container mainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.white, MyStyle().bgColor],
          radius: 1.5,
        ),
      ),
      child: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, //
              children: <Widget>[
                showLogo(),
                mySizeBox(),
                showAppName(),
                mySizeBox(),
                userForm(),
                mySizeBox(),
                passwordForm(),
                mySizeBox(),
                rememberCheckbox(),
                mySizeBox(),
                loginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
