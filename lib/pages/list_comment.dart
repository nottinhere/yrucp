import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/report_dept_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_report_problem.dart';
import 'package:yrusv/pages/list_report_staff.dart';
import 'package:yrusv/pages/list_report_detail.dart';
import 'package:yrusv/pages/list_report_request.dart';
import 'package:yrusv/pages/list_report_rating.dart';

import 'package:uipickers/uipickers.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';

class ListComment extends StatefulWidget {
  static const String route = '/ListComment';

  final int index;
  final UserModel userModel;
  ListComment({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListCommentState createState() => _ListCommentState();
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

class _ListCommentState extends State<ListComment> {
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
        'https://app.oss.yru.ac.th/yrusv/api/json_data_comment.php?memberId=$memberId&start=$selectedStartDate&end=$selectedEndDate&page=$page'; //'';
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
              dept: filterComplainAllModels[index].subject,
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
          complainAllModels.clear();
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
              complainAllModels.clear();
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
        onTap: () {},
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
              complainAllModels.clear();
              readReport();
            });
          }),
    );
  }

  Widget showContent() {
    return complainAllModels.length == 0
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
        title: Text('ข้อแนะนำเพิ่มเติม'),
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
