import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/department_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widget/home.dart';

class EditDept extends StatefulWidget {
  final DepartmentModel deptAllModel;

  UserModel userModel;

  EditDept({Key key, this.deptAllModel, this.userModel}) : super(key: key);

  @override
  _EditDeptState createState() => _EditDeptState();
}

class _EditDeptState extends State<EditDept> {
  // Explicit

  StaffModel staffAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  DepartmentModel selectDeptModel;

  String id; // productID

  String txtname = '';
  String memberID;
  String strhelperID;

  int page = 1, dp = 1;
  String searchString = '';

  List<StaffModel> staffModels = List(); // set array
  List<StaffModel> filterStaffModels = List();

  var _items;

  // Method
  @override
  void initState() {
    super.initState();
    selectDeptModel = widget.deptAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readDepartment();
      // readStaff();
    });
  }

  // List dataDV;
  // Future<void> readDepartment() async {
  //   String urlDV =
  //       'https://nottinhere.com/demo/yru/yrusv/apiyrusv/json_data_division.php';
  //   print('urlDV >> $urlDV');

  //   http.Response response = await http.get(urlDV);
  //   var result = json.decode(response.body);
  //   var itemDivisions = result['itemsData'];

  //   setState(() {
  //     for (var map in itemDivisions) {
  //       String dvID = map['dv_id'];
  //       String dvName = map['dv_name'];
  //     } // for
  //   });

  //   setState(() {
  //     dataDV = itemDivisions;
  //   });
  //   // print('dataDV >> $dataDV');
  // }

  List dataST;
  Future<void> readDepartment() async {
    int memberId = myUserModel.id;
    String selectId = selectDeptModel.dpId.toString();

    String urlDV =
        'https://nottinhere.com/demo/yru/yrusv/apiyrusv/json_data_department.php&selectId=$selectId';
    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    setState(() {
      Map<String, dynamic> map = result['data'];
      DepartmentModel selectDeptModel = DepartmentModel.fromJson(map);
      txtname = selectDeptModel.dpName;
    });
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

  Widget formBox() {
    return Card(
      child: Container(
        // decoration: MyStyle().boxLightGreen,

        width: MediaQuery.of(context).size.width * 0.63,
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Text('แผนก :'),
                  mySizebox(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      initialValue: selectDeptModel.dpName, // set default value
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    String selectId = selectDeptModel.dpId.toString();

    try {
      String url =
          'https://nottinhere.com/demo/yru/yrusv/apiyrusv/json_submit_manage_department.php?memberId=$memberID&selectId=$selectId&action=edit&name=$txtname'; //'';
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
    String selectId = selectDeptModel.dpId.toString();

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
                  'memberId=$memberID&selectId=$selectId&action=edit&name=$txtname');

              submitThread();
            },
            child: Text(
              'แก้ไขชื่อแผนก',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
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
        title: Text('แก้ไขข้อมูลแผนก'),
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
        formBox(),
        submitButton(),
        // showPhoto(),
      ],
    );
  }
}