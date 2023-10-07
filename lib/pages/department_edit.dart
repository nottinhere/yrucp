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
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:url_encoder/url_encoder.dart';

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
  String txtcode = '';
  String txttoken = '';
  String memberID;
  String strhelperID;
  String staffHeader;
  String currentHeader;
  int page = 1, dp = 1;
  String searchString = '';

  String _mySelection;
  // Method
  @override
  void initState() {
    super.initState();
    selectDeptModel = widget.deptAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readDepartment();
      readStaff();
      readStaffHead();
    });
  }

  List dataDV;
  Future<void> readDepartment() async {
    int memberId = myUserModel.id;
    String selectId = selectDeptModel.dpId.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_department.php?selectId=$selectId';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    setState(() {
      Map<String, dynamic> map = result['data'];
      DepartmentModel selectDeptModel = DepartmentModel.fromJson(map);
      txtname = selectDeptModel.dpName;
      txtcode = selectDeptModel.code;
      txttoken = selectDeptModel.accessToken;
    });
  }

  List dataST;
  Future<void> readStaff() async {
    String selectId = selectDeptModel.dpId.toString();
    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_staff.php?dept=$selectId';

    http.Response response = await http.get(urlST);
    var result = json.decode(response.body);
    var itemStaff = result['itemsData'];

    setState(() {
      for (var map in itemStaff) {
        String personID = map['id'].toString();
        String personName = map['person_name'];
        String level = map['level'].toString();
        String department = map['department'].toString();
      }
    });

    setState(() {
      dataST = itemStaff;
    });
  }

  Future<void> readStaffHead() async {
    String selectId = selectDeptModel.dpId.toString();
    String urlSTH =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_staff.php?dept=$selectId&level=2';
    // // print('urlSTH >> $urlSTH');

    http.Response response = await http.get(urlSTH);
    var result = json.decode(response.body);
    var itemStaff = result['itemsData'];

    setState(() {
      for (var map in itemStaff) {
        String personID = map['id'].toString();
        String level = map['level'].toString();
        currentHeader = personID;
        _mySelection = personID;
      }
    });
    // print('_mySelection >> $_mySelection');
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

        width: MediaQuery.of(context).size.width * 0.63,
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Column(
                    children: [
                      Column(
                        children: <Widget>[
                          Text('Code :'),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              initialValue: txtcode, // set default value
                              onChanged: (string) {
                                txtcode = string.trim();
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),

                                contentPadding: EdgeInsets.only(
                                  top: 6.0,
                                ),
                                prefixIcon:
                                    Icon(Icons.mode_edit, color: Colors.grey),
                                // border: InputBorder.none,
                                hintText: 'Code',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      mySizebox(),
                      Column(
                        children: [
                          Text('หัวหน้างาน :'),
                          Container(
                            width: 400,
                            height: 47,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                                items: dataST.map((item) {
                                  return new DropdownMenuItem(
                                    child: new Text(item['person_name']),
                                    value: item['id'].toString(),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      /*   */
                    ],
                  ),
                  mySizebox(),
                  Column(
                    children: [
                      Column(
                        children: [
                          Text('งาน :'),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              initialValue: txtname, // set default value
                              onChanged: (string) {
                                txtname = string.trim();
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),

                                contentPadding: EdgeInsets.only(
                                  top: 6.0,
                                ),
                                prefixIcon:
                                    Icon(Icons.mode_edit, color: Colors.grey),
                                // border: InputBorder.none,
                                hintText: 'งาน',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      mySizebox(),
                      Column(
                        children: [
                          Text('Access Token :'),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              initialValue: txttoken, // set default value
                              onChanged: (string) {
                                txttoken = string.trim();
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),

                                contentPadding: EdgeInsets.only(
                                  top: 6.0,
                                ),
                                prefixIcon:
                                    Icon(Icons.mode_edit, color: Colors.grey),
                                // border: InputBorder.none,
                                hintText: 'Access Token',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    if (txtcode.isEmpty || txtname.isEmpty) {
      // Have space
      normalDialog(context, 'กรุณาตรวจสอบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      String selectId = selectDeptModel.dpId.toString();
      txttoken = txttoken.replaceAll('+', '%2B'); //   (text: txttoken);
      try {
        memberID = myUserModel.id.toString();
        String url =
            'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_department.php?memberId=$memberID&selectId=$selectId&action=edit&name=$txtname&code=$txtcode&token=$txttoken&curHead=$currentHeader&newHead=$_mySelection'; //'';
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
            title: Text('ดำเนินการเรียบร้อย'),
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
    String selectId = selectDeptModel.dpId.toString();

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
              //     'memberId=$memberID&selectId=$selectId&action=edit&name=$txtname&staff=$_mySelection');

              submitThread();
            },
            child: Text(
              'แก้ไขข้อมูล',
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
        title: Text('แก้ไขข้อมูลงาน'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 7)
              : SideBar(userModel: myUserModel, curSelectMenu: 7),
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
        // showPhoto(),
      ],
    );
  }
}
