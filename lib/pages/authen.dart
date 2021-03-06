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

  // Method
  @override
  void initState() {
    super.initState();
    checkLogin();
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
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: MyStyle().textColor,
        child: Text('Login',
            style: TextStyle(
              color: Colors.white,
            )),
        onPressed: () {
          formKey.currentState.save();
          print(
            'user = $user,password = $password',
          );
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
    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        logOut();
        Navigator.of(buildContext).pop(); // pop ?????????????????????????????????????????????????????????
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
      normalDialog(context, 'Have space', '???????????????????????????????????????????????????????????????');
    } else {
      String url =
          '${MyStyle().getUserWhereUserAndPass}?username=$user&password=$password';
      print('url = $url');

      http.Response response = await http
          .get(url); // await ??????????????????????????????????????? await ???????????????????????????????????????????????? process ???????????????
      var result = json.decode(response.body);

      int statusInt = result['status'];
      print('statusInt = $statusInt');

      if (statusInt == 0) {
        String message = result['message'];
        normalDialogLogin(context, '????????????????????????????????????????????????', message);
      } else if (statusInt == 1) {
        Map<String, dynamic> map = result['data'];
        print('map = $map');

        int userStatus = map['status'];
        print('userStatus = $userStatus');

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
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyService(
        userModel: userModel,
      );
    });

    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear ???????????????????????????????????? route with out airrow back
        (Route<dynamic> route) {
      return false;
    });
  }

  void gotoPopupdetail() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailPopup(
        // index: index,
        userModel: userModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void _onBasicAlertPressed(context) {
    var alertStyle = AlertStyle(
      isCloseButton: false,
      isOverlayTapDismiss: false,
      titleStyle: TextStyle(
        color: Colors.red,
      ),
    );

    Alert(
      context: context,
      style: alertStyle,
      title: "?????????????????? !!!",
      desc: subjectPopup,
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => gotoService(),
          color: Color.fromRGBO(255, 77, 77, 1.0),
        ),
        DialogButton(
          child: Text(
            "??????????????????????????????",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => gotoPopupdetail(),
          color: Color.fromRGBO(51, 153, 255, 1.0),
        ),
      ],
    ).show();
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
      return MyService(
        userModel: userModel,
      );
    });
    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear ???????????????????????????????????? route with out airrow back
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
    return Scaffold(
      body: SafeArea(
        child: status ? mainContent() : mainContent(),
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
