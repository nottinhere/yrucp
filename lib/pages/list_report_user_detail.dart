import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/pages/detail.dart';
import 'package:yrusv/pages/detail_staff.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:intl/intl.dart';

import 'detail.dart';
import 'detail_cart.dart';

import 'package:uipickers/uipickers.dart';

import 'package:yrusv/layouts/side_bar.dart';
import 'package:yrusv/layouts/top_bar.dart';

class ListComplainByUser extends StatefulWidget {
  final int index;
  final UserModel userModel;
  final String staffID;
  final DateTime datestart;
  final DateTime dateend;
  ListComplainByUser(
      {Key key,
      this.index,
      this.userModel,
      this.staffID,
      this.datestart,
      this.dateend})
      : super(key: key);

  @override
  _ListComplainByUserState createState() => _ListComplainByUserState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  DateTime selectedStartDate =
      DateTime.now().add(Duration(days: -60)); //  = DateTime.now()
  DateTime selectedEndDate = DateTime.now(); //  = DateTime.now()

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListComplainByUserState extends State<ListComplainByUser> {
  // Explicit
  int myIndex;
  List<ComplainAllModel> complainAllModels = []; // set array
  List<ComplainAllModel> filterComplainAllModels = [];
  ComplainAllModel currentComplainAllModel;
  ComplainAllModel complainAllModel;
  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';

  String staffID = '';

  int amountListView = 6, page = 1;
  String sort = 'asc';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
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
    staffID = widget.staffID;
    selectedStartDate = widget.datestart;
    selectedEndDate = widget.dateend;

    createController(); // เมื่อ scroll to bottom
    setState(() {
      readData(); // read  ข้อมูลมาแสดง
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        readData();

        // // print('in the end');

        // setState(() {
        //   amountListView = amountListView + 2;
        //   if (amountListView > filterComplainAllModels.length) {
        //     amountListView = filterComplainAllModels.length;
        //   }
        // });
      }
    });
  }

  Future<void> readData() async {
    int memberId = myUserModel.id;

    // Admin view all job
    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_complain_by_user.php?memberId=$memberId&staff=$staffID&start=$selectedStartDate&end=$selectedEndDate&page=$page&sort=$sort';
    // print('url >> $url');

    http.Response response = await http.get(url);
    var result = json.decode(response.body);

    var itemProducts = result['itemsData'];

    int i = 0;
    int len = (filterComplainAllModels.length);

    for (var map in itemProducts) {
      ComplainAllModel complainAllModel = ComplainAllModel.fromJson(map);
      setState(() {
        complainAllModels.add(complainAllModel);
        filterComplainAllModels = complainAllModels;
      });
      // print(
      //     ' >> ${len} =>($i)  ${filterComplainAllModels[(len + i)].id}  ||  ${filterComplainAllModels[(len + i)].subject}');

      i = i + 1;
    }
  }

  Future<void> updateDatalist(index) async {
    // print('Here is updateDatalist function');

    String id = filterComplainAllModels[index].id.toString();
    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_complaindetail.php?id=$id';
    // // print('url = $url');
    http.Response response = await http.get(url);
    var result = json.decode(response.body);

    var itemProducts = result['itemsData'];
    for (var map in itemProducts) {
      setState(() {
        complainAllModel = ComplainAllModel.fromJson(map);
        filterComplainAllModels[index].staff_name = complainAllModel.staff_name;
        filterComplainAllModels[index].appointdate =
            complainAllModel.appointdate;
        filterComplainAllModels[index].appointtime =
            complainAllModel.appointtime;
      });
    } // for
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  void routeToListComplain(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      // return ListComplain(
      //   index: index,
      //   userModel: myUserModel,
      // );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget Logout() {
    return GestureDetector(
      onTap: () {
        logOut();
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/icon_logout_white.png'),
            // Text(
            //   '$amontCart',
            //   style: TextStyle(
            //     backgroundColor: Colors.blue.shade600,
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget unreadTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.red.shade700,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'ยังไม่ตรวจสอบ',
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
          // print('You click promotion');
          // routeToListComplain(2);
        },
      ),
    );
  }

  Widget openedTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'ตรวจสอบแล้ว',
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
          // print('You click update price');
          // routeToListComplain(3);
        },
      ),
    );
  }

  Widget allJob() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
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
                  'งานทั้งหมด',
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
          routeToListComplain(0);
        },
      ),
    );
  }

  Widget unassignJob() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.13,
      // height: 80.0,
      child: GestureDetector(
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
                  ' งานที่ยังไม่ระบุผู้รับผิดชอบ',
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
          routeToListComplain(1);
        },
      ),
    );
  }

  Widget allMyDeptJob() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.11,
      // height: 80.0,
      child: GestureDetector(
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
                  ' งานในฝ่ายของท่าน',
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
          routeToListComplain(2);
        },
      ),
    );
  }

  Widget unassignMyDeptJob() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.14,
      // height: 80.0,
      child: GestureDetector(
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
                  ' งานในฝ่ายยังไม่ระบุผู้รับผิดชอบ',
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
          routeToListComplain(3);
        },
      ),
    );
  }

  Widget myJob() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
      // height: 80.0,
      child: GestureDetector(
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
                  ' งานของท่าน',
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
          routeToListComplain(4);
        },
      ),
    );
  }

  Widget topMenu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          children: [
            if (myUserModel.level == 1) allJob(),
            if (myUserModel.level == 1) unassignJob(),
            if (myUserModel.level == 2) allMyDeptJob(),
            if (myUserModel.level == 2) unassignMyDeptJob(),
            if (myUserModel.level == 3) myJob(),
            if (myUserModel.level == 3) unassignMyDeptJob(),
          ],
        ),
      ),
    );
  }

  Widget inprocessTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.orange.shade800,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'กำลังดำเนินการ',
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
          // print('You click new item');
          // routeToListComplain(1);
        },
      ),
    );
  }

  Widget completeTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade800,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'ดำเนินการเสร็จสิ้น',
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
          // print('You click not receive');
          // routeToListComplain(4);
        },
      ),
    );
  }

  Widget incompleteTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'ไม่สามารถนำเนินการได้',
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
          // print('You click not receive');
          // routeToListComplain(4);
        },
      ),
    );
  }

  Widget cancelTag(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.red.shade800,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  filterComplainAllModels[index].textstatus,
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
          // print('You click not receive');
          // routeToListComplain(4);
        },
      ),
    );
  }

  Widget L1_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: (filterComplainAllModels[index].status == '4')
              ? Colors.blue.shade200
              : Colors.blue.shade600,
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
                  ' กำหนดงาน',
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
          // print('You are boss');
          if (filterComplainAllModels[index].status == '4') {
            null;
          } else {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return Detail(
                complainAllModel: filterComplainAllModels[index],
                userModel: myUserModel,
              );
            });
            // Navigator.of(context).push(materialPageRoute);
            Navigator.of(context)
                .push(materialPageRoute)
                .then((value) => setState(() {
                      // readData();
                      updateDatalist(index);
                    }));
          }
        },
      ),
    );
  }

  Widget L2_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
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
                  ' รายละเอียดงาน',
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
          // print('You are staff');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailStaff(
              complainAllModel: filterComplainAllModels[index],
              userModel: myUserModel,
            );
          });

          Navigator.of(context)
              .push(materialPageRoute)
              .then((value) => setState(() {
                    // readData();
                    showTag(index);
                  }));
        },
      ),
    );
  }

  Widget L3_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.09,
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
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                ),
                Text(
                  ' ขอทำงานนี้',
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
          // print('You are boss');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return Detail(
              complainAllModel: filterComplainAllModels[index],
              userModel: myUserModel,
            );
          });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context)
              .push(materialPageRoute)
              .then((value) => setState(() {
                    // readData();
                    updateDatalist(index);
                  }));
        },
      ),
    );
  }

  Widget showTag(index) {
    return Row(
      children: <Widget>[
        (filterComplainAllModels[index].status == '1')
            ? unreadTag()
            : Container(),
        (filterComplainAllModels[index].status == '2')
            ? openedTag()
            : Container(),
        (filterComplainAllModels[index].status == '3')
            ? inprocessTag()
            : Container(),
        (filterComplainAllModels[index].status == '4')
            ? completeTag()
            : Container(),
        (filterComplainAllModels[index].status == '5')
            ? incompleteTag()
            : Container(),
        SizedBox(
          width: 5.0,
          height: 8.0,
        )
      ],
    );
  }

  Widget showNumber(int index) {
    String selectedDate;

    if (filterComplainAllModels[index].appointdate == '-') {
      selectedDate = '-';
    } else {
      DateTime dateApt = DateTime.parse(
          (filterComplainAllModels[index].appointdate).toString());
      selectedDate = DateFormat('dd/MM/yyyy').format(dateApt);
      ;
    }

    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.67,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'หมายเลขเรื่อง :   ${filterComplainAllModels[index].id}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                ),
              ),
              Text(
                'ผู้แจ้ง :   ${filterComplainAllModels[index].postby}',
                style: TextStyle(
                  fontSize: 13.0,
                  // fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
              Text(
                'วันที่รับแจ้ง :   ${filterComplainAllModels[index].postdate}',
                style: TextStyle(
                  fontSize: 13.0,
                  // fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
              Text(
                'วันที่นัดหมาย :   ${selectedDate}   ${filterComplainAllModels[index].appointtime} ',
                style: TextStyle(
                  fontSize: 16.0,
                  // fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showSubject(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            filterComplainAllModels[index].subject,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showResponsible(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.19,
          child: Column(
            children: [
              // Icon(Icons.restaurant, color: Colors.green[500]),
              Text('หมวดหมู่'),
              Text(
                filterComplainAllModels[index].problem,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.22,
          child: Column(
            children: [
              // Icon(Icons.timer, color: Colors.green[500]),
              Text('แผนกรับผิดชอบ'),
              Text(
                filterComplainAllModels[index].department,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Column(
            children: [
              // Icon(Icons.kitchen, color: Colors.green[500]),
              Text('ผู้รับผิดชอบ'),
              Text(
                filterComplainAllModels[index].staff_name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.2,
        //   child: Row(
        //     children: [
        //       (myUserModel.level == 1 || myUserModel.level == 2)
        //           ? L1_btn(index)
        //           : Container(),
        //       L2_btn(index),
        //       (myUserModel.level == 3 && myIndex == 3)
        //           ? L3_btn(index)
        //           : Container(),
        //     ],
        //   ),
        // )
      ],
    );
    // return Text('na');
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(children: [
            showNumber(index),
            // showDatapost(index),
            showTag(index)
          ]),
          showSubject(index),
          showResponsible(index)
        ],
      ),
    );
  }

  // Widget showImage(int index) {
  //   return Row(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(5.0),
  //         width: MediaQuery.of(context).size.width * 0.06,
  //         child: Image.network(filterComplainAllModels[index].emotical),
  //       ),
  //       Container(
  //         padding: EdgeInsets.all(5.0),
  //         // width: MediaQuery.of(context).size.width * 0.15,
  //         // child: Image.network(filterComplainAllModels[index].photo),
  //         width: 50,
  //         height: 50,
  //         decoration: new BoxDecoration(
  //             image: new DecorationImage(
  //           fit: BoxFit.cover,
  //           alignment: FractionalOffset.topCenter,
  //           image: new NetworkImage(filterComplainAllModels[index].photo),
  //         )),
  //       ),
  //     ],
  //   );
  // }

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
              //     complainAllModel: filterComplainAllModels[index],
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

  Widget sortButton() {
    return Container(
      child: TextButton.icon(
          // color: Colors.red,
          icon: Icon(Icons.sort), //`Icon` to display
          label: Text('เรียงตามสต๊อกคงเหลือ'), //`Text` to display
          onPressed: () {
            // print('searchString ===>>> $searchString');
            setState(() {
              page = 1;
              sort = (sort == 'asc') ? 'desc' : 'asc';
              complainAllModels.clear();
              readData();
            });
          }),
    );
  }

  Widget refreshButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: TextButton.icon(
              // color: Colors.red,
              icon: Icon(Icons.refresh), //`Icon` to display
              label: Text('รีเฟรชข้อมูลล่าสุด'), //`Text` to display
              onPressed: () {
                // print('searchString ===>>> $searchString');
                setState(() {
                  page = 1;
                  // sort = (sort == 'asc') ? 'desc' : 'asc';
                  complainAllModels.clear();
                  readData();
                });
              }),
        ),
        Container(
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
                  readData();
                });
              }),
        ),
      ],
    );
  }

  Widget showContent() {
    return filterComplainAllModels.length == 0
        ? showProductItem() // showProgressIndicate()
        : showProductItem();
  }

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 1.0, right: 1.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/shopping_cart.png'),
            Text(
              '$amontCart',
              style: TextStyle(
                backgroundColor: Colors.blue.shade600,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
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
        actions: <Widget>[
          // Home(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('รายการขอใช้บริการ'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 0)
              : SideBar(userModel: myUserModel, curSelectMenu: 0),
          Expanded(
            child: Column(
              children: <Widget>[
                // topMenu(),
                searchForm(),
                refreshButton(),
                showContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
