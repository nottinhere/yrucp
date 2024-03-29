import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/faq_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';

class EditFaq extends StatefulWidget {
  final FaqModel faqAllModel;

  UserModel userModel;

  EditFaq({Key key, this.faqAllModel, this.userModel}) : super(key: key);

  @override
  _EditFaqState createState() => _EditFaqState();
}

class _EditFaqState extends State<EditFaq> {
  // Explicit

  FaqModel faqAllModel;
  // DivisionModel divisionModel;

  int amontCart = 0;
  UserModel myUserModel;
  FaqModel selectFaqModel;

  String id; // productID

  String txtquestion = '', txtanswer = '';
  String memberID;
  String strhelperID;

  int page = 1, dp = 1;
  String searchString = '';

  List<FaqModel> faqModels = []; // set array
  List<FaqModel> filterFaqModels = [];

  var _items;

  // Method
  @override
  void initState() {
    super.initState();
    selectFaqModel = widget.faqAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      readFaq();
    });
  }

  List dataST;
  Future<void> readFaq() async {
    int memberId = myUserModel.id;
    String selectId = selectFaqModel.id.toString();
    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_faq.php?memberId=$memberId&selectId=$selectId';
    // print('urlST >> $urlST');
    http.Response response = await http.get(urlST);
    var result = json.decode(response.body);
    // print('result >> $result');

    setState(() {
      Map<String, dynamic> map = result['data'];
      FaqModel selectFaqModel = FaqModel.fromJson(map);
      txtquestion = selectFaqModel.question;
      txtanswer = selectFaqModel.answer;
      // print('$txtquestion >> $txtanswer');
    });
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
    String showquestion = selectFaqModel.question.toString();
    String showanswer = selectFaqModel.answer.toString();

    // // print('question >> ' + selectFaqModel.question);
    // // print('answer >> ' + selectFaqModel.answer);

    // print('showquestion >> ' + showquestion);
    // print('showanswer >> ' + showanswer);
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
                      initialValue: showquestion, // set default value
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
                      initialValue: showanswer, // set default value
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
    if (txtquestion.isEmpty || txtanswer.isEmpty) {
      // Have space
      normalDialog(context, 'กรุณาตรวจสอบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      String selectId = selectFaqModel.id.toString();

      try {
        String url =
            'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_faq.php?memberId=$memberID&selectId=$selectId&action=edit&question=$txtquestion&answer=$txtanswer'; //'';
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
    String selectId = selectFaqModel.id.toString();

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
              //     'memberId=$memberID&selectId=$selectId&action=edit&question=$txtquestion&answer=$txtanswer');

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
        title: Text('แก้ไขข้อมูลถาม-ตอบ'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 3)
              : SideBar(userModel: myUserModel, curSelectMenu: 3),
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
