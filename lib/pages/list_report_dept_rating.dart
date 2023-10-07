import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_rating_model.dart';
import 'package:yrusv/models/report_problem_model.dart';

import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/pages/list_report_dept_support.dart';
import 'package:yrusv/pages/list_report_mysupport.dart';
import 'package:yrusv/pages/list_report_dept_support.dart';
import 'package:yrusv/pages/list_report_dept_rating.dart';

import 'package:yrusv/pages/list_report_rating.dart';
import 'package:yrusv/pages/list_comment.dart';

import 'package:uipickers/uipickers.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ListReportRatingSelectDept extends StatefulWidget {
  static const String route = '/ListReportRatingSelectDepartment';

  final int index;
  final UserModel userModel;
  ListReportRatingSelectDept({Key key, this.index, this.userModel})
      : super(key: key);

  @override
  _ListReportRatingSelectDeptState createState() =>
      _ListReportRatingSelectDeptState();
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

class _ListReportRatingSelectDeptState
    extends State<ListReportRatingSelectDept> {
  List<ReportDeptRatingModel> reportDeptRatingModels = List(); // set array
  List<ReportDeptRatingModel> filterReportDeptRatingModels = List();
  ReportDeptRatingModel selectReportDeptRatingModel;

  List<ComplainAllModel> complainAllModels = List(); // set array
  List<ComplainAllModel> filterComplainAllModels = List();
  ComplainAllModel selectComplainAllModel;

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
      readReportComment(); // read  ข้อมูลมาแสดง
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
    String dept = myUserModel.department.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report_rating.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['data'];
    // print('item >> $item');
    int i = 0;
    int len = (filterReportDeptRatingModels.length);

    for (var map in item) {
      ReportDeptRatingModel reportDeptRatingModel =
          ReportDeptRatingModel.fromJson(map);
      setState(() {
        reportDeptRatingModels.add(reportDeptRatingModel);
        filterReportDeptRatingModels = reportDeptRatingModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterReportDeptRatingModels[(len + i)].dept}  ||  ${filterReportDeptRatingModels[(len + i)].deptName}');
    }
    // print('Count row >> ${filterReportDeptRatingModels.length}');
  }

  Future<void> readReportComment() async {
    String memberId = myUserModel.id.toString();
    String dept = myUserModel.department.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_comment.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['itemsData'];
    // print('item >> $item');
    int i = 0;
    int len = (filterComplainAllModels.length);

    for (var map in item) {
      ComplainAllModel complainAllModel = ComplainAllModel.fromJson(map);
      setState(() {
        complainAllModels.add(complainAllModel);
        filterComplainAllModels = complainAllModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterComplainAllModels[(len + i)].rating}  ||  ${filterComplainAllModels[(len + i)].usermsg}');
    }
    // print('Count row >> ${filterComplainAllModels.length}');
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget showData(int index) {
    // print('index >> $filterReportDeptRatingModels');
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.97,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Card(
                child: Container(
                  height: 70.0,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Column(
                    children: [
                      Text(
                        '[${filterReportDeptRatingModels[index].code}] ',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(0xff, 16, 149, 161),
                        ),
                      ),
                      Container(
                        height: 15.0,
                      ),
                      Text(
                        filterReportDeptRatingModels[index].deptName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(0xff, 16, 149, 161),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: Row(
                    children: [
                      norating(index),
                      star5(index),
                      star4(index),
                      star3(index),
                      star2(index),
                      star1(index),
                    ],
                  )),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.18,
              //   child: Row(
              //     children: [detail_btn(index)],
              //   ),
              // )
            ],
          ),
        ),
      ],
    );
  }

  Widget showName(int index) {
    // print('showName');
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            'Dept : ' + filterReportDeptRatingModels[index].deptName,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showData(index),
          // showName(index),
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
      String dept = myUserModel.id.toString();

      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_select_report.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate'; //'';
      // print('submitURL >> $url');
      await http.get(url).then((value) {
        setState(() {
          page = 1;
          reportDeptRatingModels.clear();
          readReport();
        });
      });

      String urlPB =
          'https://app.oss.yru.ac.th/yrusv/api/json_data_comment.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';
      // print('submitURL >> $url');
      await http.get(urlPB).then((value) {
        setState(() {
          page = 1;
          complainAllModels.clear();
          readReportComment();
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

  Widget showProductItem() {
    return Container(
      height: 120.0,
      child: ListView.builder(
        controller: scrollController,
        itemCount: reportDeptRatingModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return InkWell(
            mouseCursor: MaterialStateMouseCursor.clickable,
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
              child: Card(
                // color: Color.fromRGBO(235, 254, 255, 1.0),

                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
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
              reportDeptRatingModels.clear();
              readReport();
            });
          },
        ),
      ),
    );
  }

  Widget reportViewMySupport() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.12,
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
                  'รายงาน',
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
          Navigator.of(context).pushNamed(ListReportMySupport.route);
        },
      ),
    );
  }

  Widget reportViewbyDeptSupport() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.12,
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
                  'รายงานสรุปของแผนก',
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
          Navigator.of(context).pushNamed(ListReportSelectDept.route);
        },
      ),
    );
  }

  Widget reportViewbyDeptRating() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.12,
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
        onTap: () {},
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
          color: Colors.blue.shade600,
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
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListComment(
              index: 3,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget norating(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Text(
                      'ไม่ได้ให้ตะแนน ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].norating + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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

  Widget star1(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].start1 + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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

  Widget star2(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].start2 + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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

  Widget star3(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].start3 + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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

  Widget star4(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].start4 + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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

  Widget star5(int index) {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        hoverColor: Colors.blue.shade100,
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(8.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 5.0,
                    ),
                    Text(
                      filterReportDeptRatingModels[index].start5 + ' งาน',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
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
      height: 80.0,
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
                      filterReportDeptRatingModels[index].start1 + ' งาน',
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
      height: 80.0,
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
                      filterReportDeptRatingModels[index].start1 + ' งาน',
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
      height: 80.0,
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
                      filterReportDeptRatingModels[index].start1 + ' งาน',
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
        width: MediaQuery.of(context).size.width * 0.45,
        child: Row(
          children: [
            reportViewMySupport(),
            reportViewbyDeptSupport(),
            reportViewbyDeptRating(),
          ],
        ),
      ),
    );
  }

  Widget showDataComment(int index) {
    // print('index >> $filterComplainAllModels');
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.30,
                child: Text(
                  filterComplainAllModels[index].department.toString() +
                      ' : ' +
                      filterComplainAllModels[index].problem.toString(),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Text(
                  filterComplainAllModels[index].usermsg,
                  style: TextStyle(
                    fontSize: 16.0,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showTextComment(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showDataComment(index),
        ],
      ),
    );
  }

  Widget showCommentItem() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: complainAllModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  EdgeInsets.only(top: 0.0, bottom: 0.0, left: 4.0, right: 4.0),
              child: Card(
                // color: Color.fromRGBO(235, 254, 255, 1.0),

                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                  child: Row(
                    children: <Widget>[
                      showTextComment(index),
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

  Widget searchForm() {
    String memberId = myUserModel.id.toString();
    String dept = myUserModel.department.toString();

    String urlDL =
        'https://app.oss.yru.ac.th/line/export/report_rating.php?memberId=$memberId&dept=$dept&start=$selectedStartDate&end=$selectedEndDate'; //'';
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
                            ' รายงานการประเมิน',
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
              reportDeptRatingModels.clear();
              readReport();
            });
          }),
    );
  }

  Widget showContent() {
    return reportDeptRatingModels.length == 0
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
        title: Text('รายงาน :: สรุปการประเมิน'),
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
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 2)
              : SideBar(userModel: myUserModel, curSelectMenu: 2),
          Expanded(
            child: Column(
              children: <Widget>[
                topMenu(),
                searchForm(),
                // clearButton(),
                Container(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'ประเมินคะแนน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(0xff, 16, 149, 161),
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                showContent(),
                Container(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'ข้อแนะนำเพิ่มเติม',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(0xff, 16, 149, 161),
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                showCommentItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
