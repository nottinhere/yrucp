import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/faq_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';

class AddFaq extends StatefulWidget {
  final UserModel userModel;

  AddFaq({Key key, this.userModel}) : super(key: key);

  @override
  _AddFaqState createState() => _AddFaqState();
}

class _AddFaqState extends State<AddFaq> {
  // Explicit

  FaqModel faqAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  FaqModel myFaqModel;
  String id; // productID

  String txtquestion = '', txtanswer = '';
  String memberID;
  String strhelperID;

  int page = 1, dp = 1;
  String searchString = '';

  // Method
  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    setState(() {
      readFaq();
    });
  }

  List dataDV;
  Future<void> readFaq() async {
    String urlDV = 'https://app.oss.yru.ac.th/yrusv/api/json_data_division.php';
    print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemDivisions = result['itemsData'];

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

        width: MediaQuery.of(context).size.width * 0.90,
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Column(
                children: <Widget>[
                  Text('คำถาม :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      // initialValue: complainAllModel.postby, // set default value
                      onChanged: (string) {
                        txtquestion = string.trim();
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
                        hintText: 'คำถาม',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text('คำตอบ :'),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      minLines:
                          6, // any number you need (It works as the rows for the textarea)
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(color: Colors.black),
                      // initialValue: complainAllModel.postby, // set default value
                      onChanged: (string) {
                        txtanswer = string.trim();
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
                        hintText: 'คำตอบ',
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
    String memberID = myUserModel.id.toString();

    try {
      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_faq.php?memberId=$memberID&action=add&question=$txtquestion&answer=$txtanswer'; //'';
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
              // var faqID = myFaqModel.dpId.toString();
              // var cpID = currentComplainAllModel.id;
              // print('faqId=$faqID&action=add&name=$txtname');

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
        title: Text('เพิ่มข้อมูลถาม-ตอบ'),
      ),
      body: Row(
        children: [
          SideBar(userModel: myUserModel),
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
