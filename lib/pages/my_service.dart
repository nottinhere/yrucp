import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/widgets/home.dart';

import 'package:yrusv/pages/changepassword.dart';
import 'package:yrusv/pages/list_faq.dart';

class MyService extends StatefulWidget {
  final UserModel userModel;
  MyService({Key key, this.userModel}) : super(key: key);

  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  //Explicit
  UserModel myUserModel;
  Widget currentWidget = Home();
  String qrString;

  // Method
  @override
  void initState() {
    super.initState(); // จะทำงานก่อน build

    setState(() {
      myUserModel = widget.userModel;
    });
    //readCart();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // onGenerateRoute: generateRoute,
      debugShowCheckedModeBanner: false,
      initialRoute: Home.route,
      routes: {
        Home.route: (context) => Home(
              userModel: myUserModel,
            ),
        // ListFaq.route: (context) => ListFaq(
        //       userModel: myUserModel,
        //     ),
        // ChangePassword.route: (context) => ChangePassword(
        //       userModel: myUserModel,
        //     ),
      },
    );
  }
}
