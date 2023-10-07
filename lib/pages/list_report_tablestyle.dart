import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_model.dart';
import 'package:yrusv/models/report_staff_model.dart';
import 'package:yrusv/models/report_dept_model.dart';
import 'package:yrusv/models/report_problem_model.dart';

import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_report_problem.dart';
import 'package:yrusv/pages/list_report_staff.dart';
import 'package:yrusv/pages/list_report_detail.dart';
import 'package:yrusv/pages/list_report_request.dart';
import 'package:yrusv/pages/list_report_rating.dart';
import 'package:yrusv/pages/list_comment.dart';
import 'package:yrusv/pages/list_report_tablestyle.dart';

import 'package:uipickers/uipickers.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ListReportTeble extends StatefulWidget {
  static const String route = '/ListReportTeble';

  final int index;
  final UserModel userModel;
  ListReportTeble({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListReportTebleState createState() => _ListReportTebleState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListReportTebleState extends State<ListReportTeble> {
  // List<ComplainAllModel> complainAllModels = List(); // set array
  // List<ComplainAllModel> filterComplainAllModels = List();
  // ComplainAllModel selectComplainAllModel;

  List<ReportStaffModel> reportStaffModels = List(); // set array
  List<ReportStaffModel> filterReportStaffModels = List();
  ReportStaffModel selectReportStaffModel;

  List<ReportDeptModel> reportDeptModels = List(); // set array
  List<ReportDeptModel> filterReportDeptModels = List();
  ReportDeptModel selectReportDeptModel;

  List<ReportProblemModel> reportProblemModels = List(); // set array
  List<ReportProblemModel> filterReportProblemModels = List();
  ReportProblemModel selectReportProblemModel;

  // Explicit
  int myIndex;

  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';

  int amountListView = 6, page = 1;
  String sort = 'asc';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
  int totolpage;

  DateTime selectedStartDate =
      DateTime.now().add(Duration(days: -60)); //  = DateTime.now()
  DateTime selectedEndDate = DateTime.now(); //  = DateTime.now()

  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index;
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readReport(); // read  ข้อมูลมาแสดง
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        readReport();
      }
    });
  }

  Future<void> readReport() async {
    String memberId = myUserModel.id.toString();

    //////////////    Read Staff //////////////////
    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report_staff.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['data'];
    int i = 0;
    int len = (filterReportStaffModels.length);

    for (var map in item) {
      ReportStaffModel reportStaffModel = ReportStaffModel.fromJson(map);
      setState(() {
        reportStaffModels.add(reportStaffModel);
        filterReportStaffModels = reportStaffModels;
      });
    }

    //////////////    Read Request by Dept //////////////////
    String urlDept =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';

    http.Response responseDept = await http.get(urlDept);
    var resultDept = json.decode(responseDept.body);
    var itemDept = resultDept['data'];
    // print('item >> $item');
    int j = 0;
    int lenDept = (filterReportDeptModels.length);

    for (var map in itemDept) {
      ReportDeptModel reportDeptModel = ReportDeptModel.fromJson(map);
      setState(() {
        reportDeptModels.add(reportDeptModel);
        filterReportDeptModels = reportDeptModels;
      });
    }
    //////////////    Read Request by Problem  //////////////////
    String urlPB =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report_problem.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';

    http.Response responsePB = await http.get(urlPB);
    var resultPB = json.decode(responsePB.body);
    var itemPB = resultPB['data'];
    int iPB = 0;
    int lenPB = (filterReportProblemModels.length);

    for (var map in itemPB) {
      ReportProblemModel reportProblemModel = ReportProblemModel.fromJson(map);
      setState(() {
        reportProblemModels.add(reportProblemModel);
        filterReportProblemModels = reportProblemModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterReportProblemModels[(len + i)].dept}  ||  ${filterReportProblemModels[(len + i)].deptName}');
    }
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget showData(int index) {
    // print('index >> $filterReportStaffModels');
    return Container(
      width: MediaQuery.of(context).size.width * 0.96,
      height: 30.0,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportStaffModels[index].staff,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportStaffModels[index].deptName,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].alljob,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].unread,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].opened,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 84, 122, 153),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].onwork,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].complete,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportStaffModels[index].cancel,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showData(index),
        ],
      ),
    );
  }

  Widget showDataDP(int index) {
    // print('index >> $filterReportStaffModels');
    return Container(
      width: MediaQuery.of(context).size.width * 0.97,
      height: 30.0,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportDeptModels[index].deptName,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportDeptModels[index].deptName,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].alljob,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].unread,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].opened,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 84, 122, 153),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].onwork,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].complete,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportDeptModels[index].cancel,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showTextDP(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showDataDP(index),
        ],
      ),
    );
  }

  Widget showDataPB(int index) {
    // print('index >> $filterReportStaffModels');
    return Container(
      width: MediaQuery.of(context).size.width * 0.97,
      height: 30.0,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportProblemModels[index].problemName,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.23,
            child: Text(
              filterReportProblemModels[index].deptName,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].alljob,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].unread,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].opened,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 84, 122, 153),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].onwork,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].complete,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            child: Text(
              filterReportProblemModels[index].cancel,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showTextPB(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showDataPB(index),
        ],
      ),
    );
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
              String memberId = myUserModel.id.toString();

              // print(
              //     'memberId=$memberID&start=$cpID&end=$_mySelection&note=$txtnote');

              submitThread();
            },
            child: Text(
              'ค้นหา',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> submitThread() async {
    try {
      String memberId = myUserModel.id.toString();
      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_select_report.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate'; //'';
      // print('submitURL >> $url');
      await http.get(url).then((value) {
        setState(() {
          page = 1;
          filterReportStaffModels.clear();
          readReport();
        });
      });
    } catch (e) {}
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          //
          color: Colors.blueGrey.shade100,
          width: 1.0,
        ),
        bottom: BorderSide(
          //
          color: Colors.blueGrey.shade100,
          width: 1.0,
        ),
      ),
    );
  }

  Widget showProductItem() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: filterReportStaffModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
              child: InkWell(
                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 2.0, top: 2.0),
                  child: Row(
                    children: <Widget>[
                      showText(index),
                      // showImage(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              // MaterialPageRoute materialPageRoute =
              //     MaterialPageRoute(builder: (BuildContext buildContext) {
              //   return Detail(
              //     productAllModel: filterProductAllModels[index],
              //     userModel: myUserModel,
              //   );
              // });
              // Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showProductItemDP() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: filterReportDeptModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
              child: InkWell(
                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 2.0, top: 2.0),
                  child: Row(
                    children: <Widget>[
                      showTextDP(index),
                      // showImage(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              // MaterialPageRoute materialPageRoute =
              //     MaterialPageRoute(builder: (BuildContext buildContext) {
              //   return Detail(
              //     productAllModel: filterProductAllModels[index],
              //     userModel: myUserModel,
              //   );
              // });
              // Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showProductItemPB() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: filterReportProblemModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
              child: InkWell(
                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 2.0, top: 2.0),
                  child: Row(
                    children: <Widget>[
                      showTextPB(index),
                      // showImage(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              // MaterialPageRoute materialPageRoute =
              //     MaterialPageRoute(builder: (BuildContext buildContext) {
              //   return Detail(
              //     productAllModel: filterProductAllModels[index],
              //     userModel: myUserModel,
              //   );
              // });
              // Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showProgressIndicate() {
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
  }

  Widget searchFormTXT() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
      child: ListTile(
        title: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: 'Search'),
          onChanged: (String string) {
            searchString = string.trim();
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              page = 1;
              filterReportStaffModels.clear();
              readReport();
            });
          },
        ),
      ),
    );
  }

  Widget reportViewbySupport() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 0) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  'สรุปจากผู้รับผิดชอบ',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
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

  Widget reportViewbyProblem() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 1) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  'สรุปจากประเภทงาน',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportProblemDept(
          //     index: 1,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportProblemDept.route);
        },
      ),
    );
  }

  Widget reportViewbyStaff() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 2) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  'สรุปรายบุคคล',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportStaff(
          //     index: 2,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportStaff.route);
        },
      ),
    );
  }

  Widget reportViewbyRequest() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 3) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  ' สรุปการขอใช้บริการ',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // routeToListComplain(1);
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportReqDept(
          //     index: 3,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportReqDept.route);
        },
      ),
    );
  }

  Widget reportViewbyRating() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 4) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  ' สรุปการประเมิน',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // routeToListComplain(1);
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListReportRatingDept(
          //     index: 4,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListReportRatingDept.route);
        },
      ),
    );
  }

  Widget viewListcomment() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 5) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  'ดูข้อแนะนำเพิ่มเติม',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(ListComment.route);
        },
      ),
    );
  }

  Widget reportViewTablestyle() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (myIndex == 6) ? Colors.blue.shade600 : Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  ' ตารางสรุปข้อมูล',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget topMenu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.75,
        child: Row(
          children: [
            reportViewbySupport(),
            reportViewbyProblem(),
            reportViewbyStaff(),
            reportViewbyRequest(),
            reportViewbyRating(),
            viewListcomment(),
            reportViewTablestyle(),
          ],
        ),
      ),
    );
  }

  Widget searchForm() {
    String memberId = myUserModel.id.toString();
    String dept = myUserModel.department.toString();
    String urlDL =
        'https://app.oss.yru.ac.th/line/export/report_support.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate'; //'';
    final uri = Uri.parse(urlDL);

    return Container(
      // decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
      child: Row(
        children: [
          Column(
            children: [
              Text('ตั้งแต่'),
              SizedBox(
                  width: 200,
                  height: 34,
                  child: AdaptiveDatePicker(
                    //type: AdaptiveDatePickerType.material,
                    initialDate: selectedStartDate,
                    firstDate: DateTime.now().add(Duration(days: -365)),
                    lastDate: DateTime.now().add(Duration(days: 1460)),
                    onChanged: (date) {
                      setState(() => selectedStartDate = date);
                    },
                  )),
            ],
          ),
          Column(
            children: [
              Text('จนถึง'),
              SizedBox(
                  width: 200,
                  height: 34,
                  child: AdaptiveDatePicker(
                    //type: AdaptiveDatePickerType.material,
                    initialDate: selectedEndDate,
                    firstDate: DateTime.now().add(Duration(days: -365)),
                    lastDate: DateTime.now().add(Duration(days: 1460)),
                    onChanged: (date) {
                      setState(() => selectedEndDate = date);
                    },
                  )),
            ],
          ),
          Column(
            children: [Text(''), submitButton()],
          ),
          Column(
            children: [
              Text(''),
              Container(
                width: MediaQuery.of(context).size.width * 0.12,
                // height: 80.0,
                child: InkWell(
                  mouseCursor: MaterialStateMouseCursor.clickable,
                  child: Card(
                    color: Colors.green.shade700,
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                          Text(
                            ' รายงานสรุปผู้รับผิดชอบ',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    _launchInBrowser(uri);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget clearButton() {
    return Container(
      child: TextButton.icon(
          // color: Colors.red,
          icon: Icon(Icons.search_off_sharp), //`Icon` to display
          label: Text('ล้างการค้นหา'), //`Text` to display
          onPressed: () {
            // print('searchString ===>>> $searchString');
            setState(() {
              page = 1;
              // sort = (sort == 'asc') ? 'desc' : 'asc';
              searchString = '';
              filterReportStaffModels.clear();
              readReport();
            });
          }),
    );
  }

  Widget showContent() {
    return filterReportStaffModels.length == 0
        ? showProductItem() // showProgressIndicate()
        : showProductItem();
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().barColorAdmin,
        title: Text('รายงาน :: ข้อมูลสรุปรูปแบบตาราง'),
        actions: <Widget>[
          // AddStaff(),
        ],
      ),
      // body: filterProductAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 5)
              : SideBar(userModel: myUserModel, curSelectMenu: 5),
          Expanded(
            child: Column(
              children: <Widget>[
                topMenu(),
                searchForm(),
                // clearButton(),
                // showContent(),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'สรุปงานรายบุคคล',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 16, 149, 161),
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade300, //
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'รายชื่อ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'ฝ่ายรับผิดชอบ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Center(
                          child: Text(
                            'ทั้งหมด',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ไม่ตรวจสอบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.055,
                          child: Text(
                            'ตรวจสอบแล้ว',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 84, 122, 153),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ดำเนินการ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'เรียบร้อบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                showProductItemDP(),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'สรุปงานรายบุคคล',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 16, 149, 161),
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade300, //
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'รายชื่อ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'ฝ่ายรับผิดชอบ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Center(
                          child: Text(
                            'ทั้งหมด',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ไม่ตรวจสอบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.055,
                          child: Text(
                            'ตรวจสอบแล้ว',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 84, 122, 153),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ดำเนินการ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'เรียบร้อบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                showProductItemPB(),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'สรุปงานรายบุคคล',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 16, 149, 161),
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade300, //
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'รายชื่อ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Text(
                          'ฝ่ายรับผิดชอบ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Center(
                          child: Text(
                            'ทั้งหมด',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ไม่ตรวจสอบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.055,
                          child: Text(
                            'ตรวจสอบแล้ว',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 84, 122, 153),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ดำเนินการ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'เรียบร้อบ',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                showProductItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
