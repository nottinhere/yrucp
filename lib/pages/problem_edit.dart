import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/problem_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:yrusv/models/user_model.dart';

class EditProb extends StatefulWidget {
  final ProblemModel probAllModel;

  UserModel userModel;

  EditProb({Key key, this.probAllModel, this.userModel}) : super(key: key);

  @override
  _EditProbState createState() => _EditProbState();
}

class _EditProbState extends State<EditProb> {
  // Explicit

  StaffModel staffAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  ProblemModel selectProbModel;

  String id; // productID

  String txtsubject = '';
  String txtdpid = '';
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
    selectProbModel = widget.probAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readProblem();
      readDepartment();
    });
  }

  List dataPB;
  Future<void> readProblem() async {
    int memberId = myUserModel.id;
    String selectId = selectProbModel.pId.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_problem.php?selectId=$selectId';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    setState(() {
      Map<String, dynamic> map = result['data'];
      ProblemModel selectProbModel = ProblemModel.fromJson(map);
      txtsubject = selectProbModel.subject;
      txtdpid = selectProbModel.dpId;
      _mySelection = (selectProbModel.dpId == '-')
          ? null
          : selectProbModel.dpId.toString();
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
          child: Row(
            children: [
              Column(
                children: <Widget>[
                  Text('หมวดหมู่ปัญหา :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      initialValue: txtsubject, // set default value
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
              mySizebox(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    if (txtsubject.isEmpty || _mySelection == null) {
      // Have space
      normalDialog(context, 'กรุณาตรวจสอบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      String selectId = selectProbModel.pId.toString();
      try {
        String url =
            'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_problem.php?memberId=$memberID&selectId=$selectId&action=edit&subject=$txtsubject&dp_id=$_mySelection'; //'';
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
    String selectId = selectProbModel.pId.toString();

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
              //     'memberId=$memberID&selectId=$selectId&action=edit&name=$txtsubject&staff=$_mySelection');

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
        title: Text('แก้ไขข้อมูลหมวดหมู่'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 8)
              : SideBar(userModel: myUserModel, curSelectMenu: 8),
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
