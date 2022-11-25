import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/userlevel_model.dart';

import 'package:yrusv/models/department_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:flutter_switch/flutter_switch.dart';

class EditUser extends StatefulWidget {
  final UserModel userAllModel;

  UserModel userModel;

  EditUser({Key key, this.userAllModel, this.userModel}) : super(key: key);

  @override
  _EditUserState createState() => _EditUserState();
}

class Helper {
  final int id;
  final String name;

  Helper({
    this.id,
    this.name,
  });
}

class _EditUserState extends State<EditUser> {
  // Explicit

  StaffModel staffAllModel;
  // DepartmentModel departmentModel;

  int amontCart = 0;
  UserModel myUserModel;
  UserModel selectUserModel;

  String id; // productID
  bool isToggledLevel;
  String txtuser = '', txtname = '', txtcontact = '', txtdiv = '';
  String memberID;
  String strhelperID;

  int page = 1, dp = 1;
  String searchString = '';

  List<StaffModel> staffModels = []; // set array
  List<StaffModel> filterStaffModels = [];

  String _mySelection;

  // Method
  @override
  void initState() {
    super.initState();
    selectUserModel = widget.userAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readDepartment();
      readUserlevel();
      readStaff();
    });
  }

  List dataDV;
  Future<void> readDepartment() async {
    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_department.php';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemDepartments = result['itemsData'];

    setState(() {
      for (var map in itemDepartments) {
        String dpID = map['dp_id'];
        String dpName = map['dp_name'];
      } // for
    });

    setState(() {
      dataDV = itemDepartments;
    });
    // // print('dataDV >> $dataDV');
  }

  List dataLV;
  Future<void> readUserlevel() async {
    String urlLV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_userlevel.php';
    // print('urlLV >> $urlLV');

    http.Response response = await http.get(urlLV);
    var result = json.decode(response.body);
    var itemUserlevel = result['itemsData'];

    setState(() {
      for (var map in itemUserlevel) {
        String lvID = map['lv_id'];
        String lvName = map['lv_name'];
      } // for
    });

    setState(() {
      dataLV = itemUserlevel;
    });
    // print('dataLV >> $dataLV');
  }

  List dataST;
  Future<void> readStaff() async {
    int memberId = myUserModel.id;
    String selectId = selectUserModel.id.toString();
    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_staff.php?memberId=$memberId&selectId=$selectId';
    http.Response response = await http.get(urlST);
    var result = json.decode(response.body);
    setState(() {
      Map<String, dynamic> map = result['data'];
      UserModel selectUserModel = UserModel.fromJson(map);
      txtuser = selectUserModel.user;
      txtname = selectUserModel.personName;
      txtcontact = selectUserModel.personContact;
      isToggledLevel = (selectUserModel.level == 1) ? true : false;

      // print('selectUserModel >> $selectUserModel');
      _mySelection = (selectUserModel.department == '-')
          ? null
          : selectUserModel.department.toString();
    });
  }

  Future<void> resetPassword() async {
    int memberId = myUserModel.id;
    String selectId = selectUserModel.id.toString();

    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_resetpassword.php?memberId=$memberId&selectId=$selectId';
    // print('url >> $urlST');
    http.Response response = await http.get(urlST);
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }

  void confirmChange() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ยืนยันการรีเซ็ตรหัสผ่าน'),
            content: Text('รีเซ็ตรหัสผ่านเป็น :: yruserviceteam'),
            actions: <Widget>[
              cancelButton(),
              comfirmButton(),
            ],
          );
        });
  }

  Widget comfirmButton() {
    return TextButton(
      child: Text('Confirm'),
      onPressed: () {
        resetPassword();
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 20.0,
    );
  }

  Widget formBox() {
    return Card(
      child: Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,

        width: MediaQuery.of(context).size.width * 0.95,
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Column(
                children: <Widget>[
                  Text('User :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      initialValue: selectUserModel.user, // set default value
                      onChanged: (string) {
                        txtuser = string.trim();
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),

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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      initialValue:
                          selectUserModel.personName, // set default value
                      onChanged: (string) {
                        txtname = string.trim();
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),

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
              Column(
                children: <Widget>[
                  Text('เบอร์ติดต่อ :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      initialValue:
                          selectUserModel.personContact, // set default value
                      keyboardType: TextInputType.number,
                      onChanged: (string) {
                        txtcontact = string.trim();
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),

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
                  Column(
                    children: [
                      Text('งาน :'),
                      Container(
                        width: 400,
                        height: 47,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: DropdownButton(
                            alignment: Alignment.center,
                            underline: Container(color: Colors.transparent),
                            value: _mySelection,
                            onChanged: (String newVal) {
                              setState(() => _mySelection = newVal);
                            },
                            items: dataDV.map((item) {
                              return new DropdownMenuItem(
                                child: new Text(item['dp_name']),
                                value: item['dp_id'].toString(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text('Reset password :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.orangeAccent // Background color
                          ),
                      onPressed: () {
                        // print('Reset password');
                        confirmChange();
                      },
                      child: const Text(
                        'Reset password',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  mySizebox(),
                  Column(
                    children: [
                      Text('ผู้ดูแลระบบ :'),
                      Container(
                        width: 200,
                        height: 47,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: FlutterSwitch(
                            height: 20.0,
                            width: 40.0,
                            padding: 4.0,
                            toggleSize: 15.0,
                            borderRadius: 10.0,
                            activeColor: Colors.green,
                            value: isToggledLevel,
                            onToggle: (value) {
                              setState(() {
                                isToggledLevel = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    if (txtuser.isEmpty ||
        txtname.isEmpty ||
        txtcontact.isEmpty ||
        _mySelection == null) {
      // Have space
      normalDialog(context, 'กรุณาตรวจสอบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      String selectId = selectUserModel.id.toString();

      try {
        String url =
            'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_staff.php?memberId=$memberID&selectId=$selectId&action=edit&user=$txtuser&name=$txtname&contact=$txtcontact&department=$_mySelection&isToggledLevel=$isToggledLevel'; //'';
        // print('submitURL >> $url');
        await http.get(url).then((value) {
          confirmSubmit();
        });
      } catch (e) {}
    }
  }

  Future<void> confirmSubmit() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Complete'),
            content: Text('แก้ไขข้อมูลเรียบร้อย'),
            actions: <Widget>[
              TextButton(
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
    String selectId = selectUserModel.id.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 30.0),
          child: ElevatedButton(
            // color: Color.fromARGB(0xff, 13, 163, 93),
            onPressed: () {
              memberID = myUserModel.id.toString();
              // var cpID = currentComplainAllModel.id;
              // print(
              //     'memberId=$memberID&selectId=$selectId&action=edit&user=$txtuser&name=$txtname&contact=$txtcontact&department=$_mySelection');

              submitThread();
            },
            child: Text(
              'แก้ไขรายชื่อ',
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
        backgroundColor: MyStyle().barColorAdmin,
        title: Text('แก้ไขข้อมูลรายชื่อ'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel)
              : SideBar(userModel: myUserModel),
          Expanded(child: showController()),
        ],
      ),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(15.0),
      children: <Widget>[
        formBox(),
        submitButton(),
      ],
    );
  }
}
