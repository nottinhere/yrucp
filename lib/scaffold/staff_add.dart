import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrucp/models/staff_all_model.dart';
import 'package:yrucp/models/user_model.dart';
import 'package:yrucp/models/division_model.dart';
import 'package:yrucp/scaffold/detail_cart.dart';
import 'package:yrucp/utility/my_style.dart';
import 'package:yrucp/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrucp/widget/home.dart';

class AddUser extends StatefulWidget {
  final UserModel userModel;

  AddUser({Key key, this.userModel}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class Helper {
  final int id;
  final String name;

  Helper({
    this.id,
    this.name,
  });
}

class _AddUserState extends State<AddUser> {
  // Explicit

  StaffModel staffAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID

  String txtuser = '', txtname = '', txtcontact = '', txtdiv = '';
  String memberID;
  String strhelperID;

  int page = 1, dv = 1;
  String searchString = '';

  List<StaffModel> staffModels = List(); // set array
  List<StaffModel> filterStaffModels = List();

  List<StaffModel> _listhelpers = [];

  String _mySelection, _myHelperSelection;

  // static List<StaffModel> _helpers = [];
  var _items;

  final _multiSelectKey = GlobalKey<FormFieldState>();

  // Method
  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readDivision();
    });
  }

  List dataDV;
  Future<void> readDivision() async {
    String urlDV =
        'https://nottinhere.com/demo/yru/yrucp/apiyrucp/json_data_division.php';
    print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemDivisions = result['itemsProduct'];

    setState(() {
      for (var map in itemDivisions) {
        String dvID = map['dv_id'];
        String dvName = map['dv_name'];
      } // for
    });

    setState(() {
      dataDV = itemDivisions;
    });
    print('dataDV >> $dataDV');
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget showSubject() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            'xxxxxxxxxxxxxxx',
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 20.0,
    );
  }

  Widget showHeader() {
    return Card(
      child: Container(
        // width: MediaQuery.of(context).size.width * 1.00,
        padding: new EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      'หมายเลขเรื่อง :',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 16, 149, 161),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'วันที่รับแจ้ง : ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,

                        // color: Color.fromARGB(0xff, 16, 149, 161),
                      ),
                    ),
                  ],
                ),
                // Image.network(
                //   complainAllModel.emotical,
                //   width: MediaQuery.of(context).size.width * 0.16,
                // ),
              ],
            ),
            mySizebox(),
          ],
        ),
      ),
    );
  }

  Widget complainBox() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,

      width: MediaQuery.of(context).size.width * 0.63,
      padding: EdgeInsets.only(left: 10.0, right: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Text('User :'),
                mySizebox(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    style: TextStyle(color: Colors.black),
                    // initialValue: complainAllModel.postby, // set default value
                    onChanged: (string) {
                      txtuser = string.trim();
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        top: 6.0,
                      ),
                      prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
                      // border: InputBorder.none,
                      hintText: 'User',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                mySizebox(),
                Text('ชื่อ - นามสกุล :'),
                mySizebox(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    style: TextStyle(color: Colors.black),
                    // initialValue: complainAllModel.postby, // set default value
                    onChanged: (string) {
                      txtname = string.trim();
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        top: 6.0,
                      ),
                      prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
                      // border: InputBorder.none,
                      hintText: 'ชื่อ - นามสกุล',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('เบอร์ติดต่อ :'),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: TextFormField(
                    style: TextStyle(color: Colors.black),
                    // initialValue: complainAllModel.postby, // set default value
                    keyboardType: TextInputType.number,
                    onChanged: (string) {
                      txtcontact = string.trim();
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        top: 6.0,
                      ),
                      prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
                      // border: InputBorder.none,
                      hintText: 'เบอร์ติดต่อ',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                mySizebox(),
                Text('แผนก :'),
                Center(
                  child: DropdownButton(
                    value: _mySelection,
                    onChanged: (String newVal) {
                      setState(() => _mySelection = newVal);
                    },
                    items: dataDV.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(item['dv_name']),
                        value: item['dv_id'].toString(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    try {
      String url =
          'https://nottinhere.com/demo/yru/yrucp/apiyrucp/json_submit_manage_staff.php?memberId=$memberID&action=add&user=$txtuser&name=$txtname&contact=$txtcontact&division=$_mySelection'; //'';
      print('submitURL >> $url');
      await http.get(url).then((value) {
        confirmSubmit();
      });
    } catch (e) {}
  }

  Future<void> confirmSubmit() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Complete'),
            content: Text('แก้ไขรายชื่อเรียบร้อย'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    backProcess();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void backProcess() {
    Navigator.of(context).pop();
  }

  Widget submitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 30.0),
          child: RaisedButton(
            color: Color.fromARGB(0xff, 13, 163, 93),
            onPressed: () {
              memberID = myUserModel.id.toString();
              // var cpID = currentComplainAllModel.id;
              print(
                  'memberId=$memberID&action=add&user=$txtuser&name=$txtname&contact=$txtcontact&division=$_mySelection');

              submitThread();
            },
            child: Text(
              'เพิ่มรายชื่อ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget Logout() {
    return GestureDetector(
      onTap: () {
        Logout();
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/icon_logout_white.png'),
          ],
        ),
      ),
    );
  }

  Widget Home() {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return Home();
        });
        Navigator.of(context).pop();
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/home.png'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          // Home(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('รายละเอียดเรื่องร้องเรียน (Leader)'),
      ),
      body: showController(),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget addButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: Colors.lightGreen,
                child: Text(
                  'Update deal',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String productID = id;
                  String memberID = myUserModel.id.toString();

                  int index = 0;
                  List<bool> status = List();

                  bool sumStatus = true;
                  if (status.length == 1) {
                    sumStatus = status[0];
                  } else {
                    sumStatus = status[0] && status[1];
                  }

                  if (sumStatus) {
                    normalDialog(
                        context, 'Do not choose item', 'Please choose item');
                  } else {}
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(15.0),
      children: <Widget>[
        // showTitle(),

        showHeader(),
        // showSubject(),
        complainBox(),
        submitButton(),
        // showPhoto(),
      ],
    );
  }
}
