import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_detail_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uipickers/uipickers.dart';

import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:yrusv/pages/list_report_user_detail.dart';

class ListReportDeptDetail extends StatefulWidget {
  final int index;
  final UserModel userModel;
  final String dept;
  final DateTime datestart;
  final DateTime dateend;
  ListReportDeptDetail(
      {Key key,
      this.index,
      this.userModel,
      this.dept,
      this.datestart,
      this.dateend})
      : super(key: key);

  @override
  _ListReportDeptDetailState createState() => _ListReportDeptDetailState();
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

class _ListReportDeptDetailState extends State<ListReportDeptDetail> {
  List<ReportDeptDetailModel> reportDeptModels = List(); // set array
  List<ReportDeptDetailModel> filterReportDeptDetailModels = List();
  ReportDeptDetailModel selectReportDeptModel;

  // Explicit
  int myIndex;

  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';
  String myDept = '';

  DateTime datestart;
  DateTime dateend;

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
    myDept = widget.dept;
    selectedStartDate = widget.datestart;
    selectedEndDate = widget.dateend;
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
    String dept = myUserModel.id.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_report_detail.php?memberId=$memberId&dept=$myDept&start=$selectedStartDate&end=$selectedEndDate'; //'';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var item = result['data'];
    // print('item >> $item');
    int i = 0;
    int len = (filterReportDeptDetailModels.length);

    for (var map in item) {
      ReportDeptDetailModel reportDeptModel =
          ReportDeptDetailModel.fromJson(map);
      setState(() {
        reportDeptModels.add(reportDeptModel);
        filterReportDeptDetailModels = reportDeptModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterReportDeptDetailModels[(len + i)].dept}  ||  ${filterReportDeptDetailModels[(len + i)].deptName}');
    }
    // print('Count row >> ${filterReportDeptDetailModels.length}');
  }

  // Future<void> updateDatalist(index) async {
  //   // print('Here is updateDatalist function');

  //   String memberId = myUserModel.id.toString();
  //   String selectId = filterReportDeptDetailModels[index].dept;
  //   String urlST =
  //       'https://app.oss.yru.ac.th/yrusv/api/json_select_staff.php?memberId=$memberId&selectId=$selectId';

  //   http.Response response = await http.get(urlST);
  //   var resultSL = json.decode(response.body);
  //   var itemSelect = resultSL['data'];

  //   selectReportDeptDetailModel = ReportDeptDetailModel.fromJson(itemSelect);
  //   setState(() {
  //     filterReportDeptDetailModels[index].deptName = selectReportDeptDetailModel.deptName;
  //     filterReportDeptDetailModels[index].code = selectReportDeptDetailModel.code;
  //     filterReportDeptDetailModels[index].countjob = selectReportDeptDetailModel.countjob;
  //   });
  // }

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
            return ListComplainByUser(
              index: 0,
              userModel: myUserModel,
              staffID: filterReportDeptDetailModels[index].staffID,
              datestart: selectedStartDate,
              dateend: selectedEndDate,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Widget showData(int index) {
    // print('index >> $filterReportDeptDetailModels');
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Text(
                  filterReportDeptDetailModels[index].staff + '',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.18,
                child: Text(
                  'จำนวนงาน : ' + filterReportDeptDetailModels[index].countjob,
                  style: TextStyle(
                    fontSize: 16.0,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.18,
                child: Row(
                  children: [
                    isNumeric(filterReportDeptDetailModels[index].staffID)
                        ? detail_btn(index)
                        : Container()
                  ],
                ),
              )
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
            'Dept : ' + filterReportDeptDetailModels[index].deptName,
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
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: reportDeptModels.length,
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

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

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
              reportDeptModels.clear();
              readReport();
            });
          },
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
              reportDeptModels.clear();
              readReport();
            });
          }),
    );
  }

  Widget showContent() {
    return reportDeptModels.length == 0
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
        title: Text('รายงานสรุปรายบุคคล'),
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
