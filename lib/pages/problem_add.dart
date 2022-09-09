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

class AddProb extends StatefulWidget {
  final UserModel userModel;

  AddProb({Key key, this.userModel}) : super(key: key);

  @override
  _AddProbState createState() => _AddProbState();
}

class _AddProbState extends State<AddProb> {
  // Explicit

  DepartmentModel departmentAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  DepartmentModel myDeptModel;
  String id; // productID

  String txtsubject = '';
  String memberID;
  String strhelperID;

  int page = 1, dp = 1;
  String searchString = '';
  String _mySelection;

  // Method
  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    setState(() {
      readDepartment();
    });
  }

  List dataDV;
  Future<void> readDepartment() async {
    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_department.php';
    print('urlDV >> $urlDV');

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
    print('dataDV >> $dataDV');
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
          child: Row(
            children: [
              Column(
                children: <Widget>[
                  Text('หมวดหมู่ปัญหา :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      // initialValue: complainAllModel.postby, // set default value
                      onChanged: (string) {
                        txtsubject = string.trim();
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
                        hintText: '',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              mySizebox(),
              Column(
                children: [
                  Text('แผนกรับผิดชอบ :'),
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
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    if (txtsubject.isEmpty || _mySelection == null) {
      // Have space
      normalDialog(context, 'Have space', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      try {
        memberID = myUserModel.id.toString();
        String url =
            'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_problem.php?memberId=$memberID&action=add&subject=$txtsubject&dp_id=$_mySelection'; //'';
        print('submitURL >> $url');
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
            content: Text('แก้ไขรายชื่อเรียบร้อย'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 30.0),
          child: ElevatedButton(
            // color: Color.fromARGB(0xff, 13, 163, 93),
            onPressed: () {
              // var deptID = myDeptModel.dpId.toString();
              // var cpID = currentComplainAllModel.id;
              // print('deptId=$deptID&action=add&name=$txtsubject');

              submitThread();
            },
            child: Text(
              'เพิ่มข้อมูล',
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
        title: Text('เพิ่มข้อมูลหมวดหมู่'),
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
        // showPhoto(),
      ],
    );
  }
}
