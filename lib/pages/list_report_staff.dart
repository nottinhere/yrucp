import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_model.dart';
import 'package:yrusv/models/report_staff_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_report_request.dart';
import 'package:yrusv/pages/list_report_problem.dart';
import 'package:yrusv/pages/list_report_detail.dart';
import 'package:yrusv/pages/list_report_rating.dart';
import 'package:yrusv/pages/list_comment.dart';

import 'package:uipickers/uipickers.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';

class ListReportStaff extends StatefulWidget {
  static const String route = '/ListReportStaff';

  final int index;
  final UserModel userModel;
  ListReportStaff({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListReportStaffState createState() => _ListReportStaffState();
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

class _ListReportStaffState extends State<ListReportStaff> {
  List<ReportStaffModel> reportStaffModels = List(); // set array
  List<ReportStaffModel> filterReportStaffModels = List();
  ReportStaffModel selectReportStaffModel;

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

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report_staff.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['data'];
    // print('item >> $item');
    int i = 0;
    int len = (filterReportStaffModels.length);

    for (var map in item) {
      ReportStaffModel reportStaffModel = ReportStaffModel.fromJson(map);
      setState(() {
        reportStaffModels.add(reportStaffModel);
        filterReportStaffModels = reportStaffModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterReportStaffModels[(len + i)].dept}  ||  ${filterReportStaffModels[(len + i)].deptName}');
    }
    // print('Count row >> ${filterReportStaffModels.length}');
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget detail_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.speaker_notes_outlined,
                  color: Colors.white,
                ),
                Text(
                  ' รายละเอียด',
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
          // print('Detail BTN');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListReportDeptDetail(
              index: 0,
              userModel: myUserModel,
              dept: filterReportStaffModels[index].dept,
              datestart: selectedStartDate,
              dateend: selectedEndDate,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget showData(int index) {
    // print('index >> $filterReportStaffModels');
    return Container(
      width: MediaQuery.of(context).size.width * 0.97,
      height: 30.0,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.30,
            child: Text(
              filterReportStaffModels[index].staff,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.30,
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
              filterReportStaffModels[index].inprocess,
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
              filterReportStaffModels[index].complete,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showName(int index) {
    // print('showName');
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            'Dept : ' + filterReportStaffModels[index].code,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: showData(index),
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
          reportStaffModels.clear();
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
        itemCount: reportStaffModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
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
              reportStaffModels.clear();
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
        onTap: () {},
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
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return ListComment(
          //     index: 5,
          //     userModel: myUserModel,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context).pushNamed(ListComment.route);
        },
      ),
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
                      filterReportStaffModels[index].alljob + ' งาน',
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
                      filterReportStaffModels[index].unread + ' งาน',
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
                      filterReportStaffModels[index].inprocess + ' งาน',
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
                      filterReportStaffModels[index].complete + ' งาน',
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

  Widget topMenu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.65,
        child: Row(
          children: [
            reportViewbySupport(),
            reportViewbyProblem(),
            reportViewbyStaff(),
            reportViewbyRequest(),
            reportViewbyRating(),
            viewListcomment(),
          ],
        ),
      ),
    );
  }

  Widget searchForm() {
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
              reportStaffModels.clear();
              readReport();
            });
          }),
    );
  }

  Widget showContent() {
    return reportStaffModels.length == 0
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
        title: Text('สรุปรายบุคคล'),
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
              ? AdminSideBar(userModel: myUserModel)
              : SideBar(userModel: myUserModel),
          Expanded(
            child: Column(
              children: <Widget>[
                topMenu(),
                searchForm(),
                // clearButton(),
                showContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
