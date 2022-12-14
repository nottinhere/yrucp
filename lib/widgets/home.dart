import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/main.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_model.dart';

import 'package:yrusv/pages/changepassword.dart';
import 'package:yrusv/pages/list_complain.dart';
import 'package:yrusv/pages/list_complain_admin.dart';
import 'package:yrusv/pages/list_faq.dart';
import 'package:yrusv/pages/list_staff.dart';
import 'package:yrusv/pages/list_department.dart';
import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_problem.dart';
import 'package:yrusv/pages/list_report_dept_support.dart';
import 'package:yrusv/pages/list_report_mysupport.dart';

import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yrusv/layouts/side_bar.dart';

class Home extends StatefulWidget {
  static const String route = '/home';

  final UserModel userModel;

  Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel myUserModel;
  ScrollController _scrollController;

  List<ReportDeptModel> reportDeptModels = List(); // set array
  List<ReportDeptModel> filterReportDeptModels = List();
  ReportDeptModel selectReportDeptModel;
  ScrollController scrollController = ScrollController();

  // Method
  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    _scrollController = ScrollController();

    setState(() {
      readReport(); // read  ข้อมูลมาแสดง
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> readReport() async {
    String memberId = myUserModel.id.toString();
    String dept = myUserModel.department.toString();
    DateTime selectedStartDate =
        DateTime.now().add(Duration(days: -60)); //  = DateTime.now()

    // DateTime selectedStartDate = DateTime.now(); //
    DateTime selectedEndDate = DateTime.now(); //  = DateTime.now()

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate'; //'';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['data'];
    // print('item >> $item');
    int i = 0;
    int len = (filterReportDeptModels.length);

    for (var map in item) {
      ReportDeptModel reportDeptModel = ReportDeptModel.fromJson(map);
      setState(() {
        reportDeptModels.add(reportDeptModel);
        filterReportDeptModels = reportDeptModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterReportDeptModels[(len + i)].dept}  ||  ${filterReportDeptModels[(len + i)].deptName}');
    }
    // print('Count row >> ${filterReportDeptModels.length}');
  }

  void routeToListComplain(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListComplain(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // exit(0);
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyApp();
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget ListComplainbox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_bluecheckmark.png'),
                ),
                Text(
                  'รายการ   ขอใช้บริการ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // routeToListComplain((myUserModel.level == 1)
          //     ? 0
          //     : (myUserModel.level == 2)
          //         ? 2
          //         : 4);
          Navigator.of(context).pushNamed(ListComplain.route);
        },
      ),
    );
  }

  Widget ReportDeptComplain() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_report_team_blue.png'),
                ),
                Text(
                  'รายงาน',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportSelectDept(
          //     index: 0,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportSelectDept.route);
        },
      ),
    );
  }

  Widget ReportMyComplain() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_report_blue.png'),
                ),
                Text(
                  'รายงาน',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  'ของท่าน',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportMySupport(
          //     index: 0,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportMySupport.route);
        },
      ),
    );
  }

  Widget ViewQA() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/question-answer.png'),
                ),
                Text(
                  'ถาม-ตอบ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click ListFaq');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListFaq(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);

          // Navigator.pushNamed(
          //   context,
          //   ListFaq.route,
          // );

          // ListFaq.route

          Navigator.of(context).pushNamed(ListFaq.route);
        },
      ),
    );
  }

  Widget ChangePasswordbox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_reset_password.png'),
                ),
                Text(
                  'เปลี่ยนรหัสผ่าน',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ChangePassword(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ChangePassword.route);
        },
      ),
    );
  }

  Widget ReportComplain() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_report.png'),
                ),
                Text(
                  'รายงาน',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportDept(
          //     index: 0,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportDept.route);
        },
      ),
    );
  }

  Widget ManageComplain() {
    // all product
    return Container(
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_checkmark_admin.png'),
                ),
                Text(
                  'จัดการคำขอ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListComplainAdmin(
          //     index: 0,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListComplainAdmin.route);
        },
      ),
    );
  }

  Widget ManageDeptbox() {
    // all product
    return Container(
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_department.png'),
                ),
                Text(
                  'บริหารจัดการ   ผู้รับผิดชอบ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListDept(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListDept.route);
        },
      ),
    );
  }

  Widget ManageCategorybox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_category.png'),
                ),
                Text(
                  'ประเภทงาน',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListProblem(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListProblem.route);
        },
      ),
    );
  }

  Widget ManageUserbox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_user_admin.png'),
                ),
                Text(
                  'จัดการรายชื่อ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click listUser');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListUser(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListUser.route);
        },
      ),
    );
  }

  Widget ManageQA() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/q-a.png'),
                ),
                Text(
                  'ถาม-ตอบ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click listUser');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListFaq(
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListFaq.route);
        },
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          //
          color: Colors.blueGrey.shade100,
          width: 2.0,
        ),
        bottom: BorderSide(
          //
          color: Colors.blueGrey.shade100,
          width: 2.0,
        ),
      ),
    );
  }

  Widget showData(int index) {
    // print('index >> $filterReportDeptModels');
    return Row(
      children: <Widget>[
        Container(
          // width: MediaQuery.of(context).size.width * 0.90,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Card(
                child: Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Column(
                    children: [
                      Text(
                        '[${filterReportDeptModels[index].code}] ',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(0xff, 16, 149, 161),
                        ),
                      ),
                      Container(
                        height: 15.0,
                      ),
                      Text(
                        filterReportDeptModels[index].deptName,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(0xff, 16, 149, 161),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    children: [
                      AllJobbox(index),
                      UnreadJobbox(index),
                      InProcessJobbox(index),
                      CompleteJobbox(index),
                    ],
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget AllJobbox(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 190.0,
      height: 110.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'เรื่องทั้งหมด',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      height: 15.0,
                    ),
                    Text(
                      filterReportDeptModels[index].alljob + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget UnreadJobbox(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 190.0,
      height: 110.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.red.shade500,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'ยังไม่ตรวจสอบ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      height: 15.0,
                    ),
                    Text(
                      filterReportDeptModels[index].unread + ' งาน',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget InProcessJobbox(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 190.0,
      height: 110.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.orange.shade600,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'ระหว่างดำเนินการ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      height: 15.0,
                    ),
                    Text(
                      filterReportDeptModels[index].inprocess + ' งาน',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CompleteJobbox(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 190.0,
      height: 110.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.green.shade500,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'ดำเนินการเสร็จสิ้น',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Container(
                      height: 15.0,
                    ),
                    Text(
                      filterReportDeptModels[index].complete + ' งาน',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showText(int index) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showData(index),
          // showName(index),
        ],
      ),
    );
  }

  Widget showProductItem() {
    return Container(
      height: 140.0,
      // padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width * 0.80,
      child: Expanded(
        child: ListView.builder(
          itemCount: reportDeptModels.length,
          itemBuilder: (BuildContext buildContext, int index) {
            return Card(
              child: Row(
                children: <Widget>[
                  showText(index),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget LogoutBox() {
    // losesale
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      width: 150.0,
      height: 150.0,

      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_logout.png'),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click square logout');
          logOut();
        },
      ),
    );
  }

  Widget LogoutAdminBox() {
    // losesale
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      width: 150.0,
      height: 150.0,

      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_logout_admin.png'),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click square logout');
          logOut();
        },
      ),
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 10.0,
    );
  }

  Widget headTitle(String string, IconData iconData) {
    // Widget  แทน object ประเภทไดก็ได้
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            size: 24.0,
            color: MyStyle().textColor,
          ),
          mySizebox(),
          Text(
            string,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyStyle().textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget homeMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListComplainbox(),
              ReportMyComplain(),
              ViewQA(),
              ChangePasswordbox(),
              (myUserModel.level == 1 || myUserModel.level == 2)
                  ? ReportDeptComplain()
                  : Container(),
              LogoutBox(),
            ],
          ),
          mySizebox(),
        ],
      ),
    );
  }

  Widget adminMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          headTitle('ผู้ดูแลระบบ', Icons.admin_panel_settings),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ReportComplain(),
              ManageComplain(),
              ManageDeptbox(),
              ManageCategorybox(),
              ManageUserbox(),
              ManageQA(),
              LogoutAdminBox(),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /****************************** */
    // Route<dynamic> generateRoute(RouteSettings settings) {
    //   print('settings.name >> ' + settings.name);
    //   var uri = Uri.parse(settings.name);
    //   switch (uri.path) {
    //     case Home.route:
    //       return MaterialPageRoute(builder: (_) => Home());
    //       break;
    //     case ListFaq.route:
    //       return MaterialPageRoute(
    //           builder: (_) => ListFaq(
    //                 userModel: myUserModel,
    //               ));
    //       break;
    //     case ChangePassword.route:
    //       return MaterialPageRoute(
    //           builder: (_) => ChangePassword(
    //                 userModel: myUserModel,
    //               ));
    //       break;
    //   }
    // }
    /****************************** */

    return // MaterialApp(
        // onGenerateRoute: generateRoute,
        // debugShowCheckedModeBanner: false,
        // // initialRoute: Home.route,
        // routes: {
        //   Home.route: (context) => Home(
        //       // userModel: myUserModel,
        //       ),
        //   ListFaq.route: (context) => ListFaq(
        //         userModel: myUserModel,
        //       ),
        //   ChangePassword.route: (context) => ChangePassword(
        //         userModel: myUserModel,
        //       ),
        // },
        //home:
        Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().barColor,
        title: Text('หน้าหลัก'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel)
              : SideBar(userModel: myUserModel),
          Expanded(
            child: Column(
              children: <Widget>[
                headTitle('เมนู', Icons.home),
                homeMenu(),
                (myUserModel.level == 1) ? adminMenu() : Container(),
                // (myUserModel.level == 1 || myUserModel.level == 2)
                //     ? Center(child: showProductItem())
                //     : Container(),
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }
}
