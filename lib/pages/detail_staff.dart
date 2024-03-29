import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/constants.dart';
import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/pages/detail_cart.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailStaff extends StatefulWidget {
  static const String route = '/detailstaff';

  final ComplainAllModel complainAllModel;
  final UserModel userModel;

  DetailStaff({Key key, this.complainAllModel, this.userModel})
      : super(key: key);

  @override
  _DetailStaffState createState() => _DetailStaffState();
}

class _DetailStaffState extends State<DetailStaff> {
  // Explicit
  ComplainAllModel currentComplainAllModel;
  ComplainAllModel complainAllModel;
  StaffModel staffAllModel;

  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID

  String txtdeal = '',
      txtfree = '',
      txtprice = '',
      txtreply = '',
      txttousermsg = '';
  String memberID;

  int page = 1, dp = 1;
  String searchString = '';

  List<StaffModel> staffModels = List(); // set array
  List<StaffModel> filterStaffModels = List();
  String _mySelection;

  bool isButtonCheckinActive = true;
  bool isButtonCheckoutActive = true;

  // Method
  @override
  void initState() {
    super.initState();
    currentComplainAllModel = widget.complainAllModel;
    myUserModel = widget.userModel;

    setState(() {
      getProductWhereID();
      readCart();
      readStaff();
    });
  }

  Future<void> getProductWhereID() async {
    if (currentComplainAllModel != null) {
      id = currentComplainAllModel.id.toString();
      // String url = '${MyStyle().getProductWhereId}$id';
      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_data_complaindetail.php?id=$id';
      // print('url = $url');
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      // print('result = $result');

      var itemProducts = result['itemsData'];
      for (var map in itemProducts) {
        setState(() {
          complainAllModel = ComplainAllModel.fromJson(map);
          Map<String, dynamic> priceListMap = map['price_list'];
          _mySelection =
              (complainAllModel.staff == '-') ? null : complainAllModel.staff;
          isButtonCheckinActive = (complainAllModel.startdate_fix == '-' &&
                  complainAllModel.staff != '-')
              ? true
              : false;
          isButtonCheckoutActive = (complainAllModel.enddate_fix == '-') &&
                  complainAllModel.staff != '-'
              ? true
              : false;
        });
      } // for
    }
  }

  List dataST;
  Future<void> readStaff() async {
    int memberId = myUserModel.id;
    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_staff.php?memberId=$memberId&searchKey=$searchString&page=$page&dp=$dp';
    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemDivisions = result['itemsData'];
    setState(() {
      dataST = itemDivisions;
    });
  }

  Future<void> launchLink(String url, {bool isNewTab = true}) async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
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

  Widget unreadTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
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
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Color.fromARGB(255, 84, 122, 153),
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

  Widget inprocessTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
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
      width: MediaQuery.of(context).size.width * 0.10,
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
      width: MediaQuery.of(context).size.width * 0.10,
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

  Widget cancelTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.purple,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  "ยกเลิกโดยผู้ใช้งาน",
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

  Widget adminRejectTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.purple,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  "ยกเลิกโดยผู้ดูแล",
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

  Widget showTag() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 5.0,
          height: 8.0,
        ),
        (complainAllModel.status == '1') ? unreadTag() : Container(),
        (complainAllModel.status == '2') ? openedTag() : Container(),
        (complainAllModel.status == '3') ? inprocessTag() : Container(),
        (complainAllModel.status == '4') ? completeTag() : Container(),
        (complainAllModel.status == '5') ? incompleteTag() : Container(),
        (complainAllModel.status == '6') ? cancelTag() : Container(),
        (complainAllModel.status == '7') ? adminRejectTag() : Container(),
        SizedBox(
          width: 5.0,
          height: 8.0,
        )
      ],
    );
  }

  Widget showSubject() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            complainAllModel.subject,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showAttachfile() {
    final uri = Uri.parse(complainAllModel.attachTarget);
    // print('uri >> $uri');
    return Container(
      width: MediaQuery.of(context).size.width * 0.08, //0.7 - 50,
      height: 100,
      child: GestureDetector(
        onTap: () => _launchInBrowser(uri),
        child: InkWell(
          mouseCursor: MaterialStateMouseCursor.clickable,
          child: Card(
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(5.0),
                  width: 65.0,
                  child: Image.asset(complainAllModel.attachIcon),
                ),
                Text('เปิดไฟล์แนบ'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showResponsible() {
    // // print('_selectedDBHelper in >> $_selectedDBHelper');

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromARGB(235, 211, 211, 211), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.90, //0.7 - 50,
              child: Text(
                'การนัดหมาย',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
            new Divider(
              color: Colors.green.shade300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.12, //0.7 - 50,
                  height: 170,
                  child: Card(
                    color: Colors.blueGrey.shade50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 100.0,
                          child: Image.asset('images/icon_clock.png'),
                        ),
                        Text('วันนัดหมาย'),
                        Text(complainAllModel.appointdate +
                            '  ' +
                            complainAllModel.appointtime),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.12, //0.7 - 50,
                  height: 170,
                  child: Card(
                    color: Colors.blueGrey.shade50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 100.0,
                          child: Image.asset('images/icon_location.png'),
                        ),
                        Text('สถานที่นัดหมาย'),
                        Text(complainAllModel.location),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.12, //0.7 - 50,
                  height: 170,
                  child: Card(
                    color: Colors.blueGrey.shade50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          width: 100.0,
                          child: Image.asset('images/icon_staff.png'),
                        ),
                        Text('ผู้รับผิดชอบ'),
                        Text(complainAllModel.staff_name),
                      ],
                    ),
                  ),
                ),
                // (complainAllModel.attachIcon == '-')
                //     ? Container()
                //     : showAttachfile(),
              ],
            ),
            Container(
              padding: new EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: SelectableText(
                      'ผู้ช่วย :: ' + complainAllModel.helper_name,
                      style: TextStyle(
                        fontSize: 18.0,
                        // fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ),
                  Container(
                    child: SelectableText(
                      'ข้อมูลเพิ่มเติม :: ' + complainAllModel.note,
                      style: TextStyle(
                        fontSize: 18.0,
                        // fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // return Text('na');
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 20.0,
    );
  }

  Widget showHeader() {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromARGB(235, 211, 211, 211), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        // width: MediaQuery.of(context).size.width * 1.00,
        padding: new EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SelectableText(
                      'หมายเลขเรื่อง :${complainAllModel.id}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 16, 149, 161),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),

                Column(
                  children: <Widget>[
                    SelectableText('หมวดหมู่'),
                    SelectableText(
                      complainAllModel.problem,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),

                Column(
                  children: <Widget>[
                    SelectableText('งานที่รับผิดชอบ'),
                    SelectableText(
                      complainAllModel.department,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    Column(
                      children: <Widget>[
                        SelectableText(
                          'วันที่รับแจ้ง : ${complainAllModel.postdate} ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            // decoration: TextDecoration.underline,

                            // color: Color.fromARGB(0xff, 16, 149, 161),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        // Icon(Icons.restaurant, color: Colors.green[500]),
                        SelectableText(
                          'ผู้แจ้ง : ' + complainAllModel.postby,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(0xff, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        // Icon(Icons.restaurant, color: Colors.green[500]),
                        SelectableText(
                          'เบอร์ติดต่อ : ' + complainAllModel.contactnumber,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(0xff, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Image.network(
                //   complainAllModel.emotical,
                //   width: MediaQuery.of(context).size.width * 0.16,
                // ),
              ],
            ),
            mySizebox(),
            new Divider(
              color: Colors.grey.shade400,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Column(
                //   children: <Widget>[
                //     Text(
                //       'YRU passport',
                //       style: TextStyle(
                //         fontSize: 20.0,
                //         fontWeight: FontWeight.bold,
                //         color: Color.fromARGB(0xff, 16, 149, 161),
                //         // decoration: TextDecoration.underline,
                //       ),
                //     ),
                //   ],
                // ),

                Column(
                  children: <Widget>[
                    SelectableText('ชื่อผู้แจ้ง'),
                    SelectableText(
                      complainAllModel.ps_fullname,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),

                Column(
                  children: <Widget>[
                    SelectableText('Position'),
                    SelectableText(
                      complainAllModel.ps_positionname,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),

                Column(
                  children: <Widget>[
                    SelectableText('Department'),
                    SelectableText(
                      complainAllModel.ps_deptname,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),

                // Image.network(
                //   complainAllModel.emotical,
                //   width: MediaQuery.of(context).size.width * 0.16,
                // ),
              ],
            ),
            mySizebox(),
            new Divider(
              color: Colors.pink,
            ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Column(
                    children: [
                      // Container(
                      //   width: MediaQuery.of(context).size.width *
                      //       0.90, //0.7 - 50,
                      //   child: Text(
                      //     'เรื่อง : ' + complainAllModel.subject,
                      //     style: MyStyle().h3bStyle,
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.90, //0.7 - 50,
                        child: SelectableText(
                          'สถานที่ : ' + complainAllModel.location,
                          style: MyStyle().h3bStyle,
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          // Icon(Icons.timer, color: Colors.green[500]),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              'รายละเอียด',
                              style: TextStyle(
                                fontSize: 18.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              complainAllModel.detail,
                              style: TextStyle(
                                fontSize: 18.0,
                                // fontWeight: FontWeight.bold,
                                color: Color.fromARGB(0xff, 0, 0, 0),
                              ),
                            ),
                          ),
                          // SizedBox(height: 20),
                          // Column(
                          //   children: [
                          //     // Icon(Icons.timer, color: Colors.green[500]),
                          //     Align(
                          //       alignment: Alignment.centerLeft,
                          //       child: Text(
                          //         'เอกสารเพิ่มเติม',
                          //         style: TextStyle(
                          //           fontSize: 18.0,
                          //           decoration: TextDecoration.underline,
                          //         ),
                          //       ),
                          //     ),
                          //     (complainAllModel.attachIcon == '-')
                          //         ? ListTile(
                          //             title: Text('ไม่มีเอกสารแนบ'),
                          //             onTap: () {
                          //               null;
                          //             })
                          //         : ListTile(
                          //             title: Text(
                          //               'กดดูเอกสารแนบ',
                          //               style: TextStyle(
                          //                 fontSize: 18.0,
                          //                 color:
                          //                     Color.fromARGB(255, 8, 33, 173),
                          //                 decoration: TextDecoration.underline,
                          //               ),
                          //             ),
                          //             onTap: () {
                          //               launchLink(
                          //                   complainAllModel.attachTarget,
                          //                   isNewTab: true);
                          //             }),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                (complainAllModel.attachIcon == '-')
                    ? Container()
                    : showAttachfile(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget complainBox() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,

      width: MediaQuery.of(context).size.width * 0.55,
      padding: EdgeInsets.only(left: 10.0, right: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.90, //0.7 - 50,
              child: SelectableText(
                'ข้อมูลการเข้าปฎิบัติงาน',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
            new Divider(
              color: Colors.green.shade300,
            ),
            showAppoint()
          ],
        ),
      ),
    );
  }

  Widget showFixStartdate() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: <Widget>[
          SelectableText(
            'วันเริ่มงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
              child: Column(children: <Widget>[
            SelectableText(
              complainAllModel.startdate_fix,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
          ])),
        ],
      ),
    );
  }

  Widget showFixEnddate() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: <Widget>[
          SelectableText(
            'วันจบงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          SelectableText(
            complainAllModel.enddate_fix,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(0xff, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget showAppoint() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: <Widget>[
          SelectableText(
            'ผู้รับผิดชอบ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          SelectableText(
            complainAllModel.staff_name,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(0xff, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget replyBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Icon(Icons.kitchen, color: Colors.green[500]),
          SelectableText(
            'ข้อความตอบกลับหัวหน้างาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          TextFormField(
            readOnly: (complainAllModel.status == '4') ? true : false,
            onChanged: (value) {
              txtreply = value.trim();
            },
            initialValue: complainAllModel.reply,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: InputDecoration(
              // suffixIcon: Icon(Icons.mode_edit, color: Colors.blue),
              fillColor: Colors.grey.shade100,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: const BorderSide(color: Colors.white, width: 0.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: const BorderSide(color: Colors.white, width: 0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget touserBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Icon(Icons.kitchen, color: Colors.green[500]),
          SelectableText(
            'ข้อความตอบกลับผู้แจ้งเรื่อง',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          TextFormField(
            readOnly: (complainAllModel.status == '4') ? true : false,
            onChanged: (value) {
              txttousermsg = value.trim();
            },
            initialValue: complainAllModel.tousermsg,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: InputDecoration(
              // suffixIcon: Icon(Icons.mode_edit, color: Colors.blue),
              fillColor: Colors.grey.shade100,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: const BorderSide(color: Colors.white, width: 0.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: const BorderSide(color: Colors.white, width: 0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showFormDeal() {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromARGB(179, 22, 141, 11), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.90, //0.7 - 50,
              child: Text(
                'ข้อมูลการเข้าปฎิบัติงาน',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
            new Divider(
              color: Colors.green.shade300,
            ),
            Row(
              children: <Widget>[
                showAppoint(),
                showAppointStartdate(),
                showAppointEnddate(),
              ],
            ),
            // noteBox(),
            replyBox(),
            touserBox(),
            (complainAllModel.status == '4') ? Container() : submitButton(),

            //  Row(children: <Widget>[priceBox(),priceBox(),],),
            //  Row(children: <Widget>[noteBox()],),
          ],
        ),
      ),
    );
  }

  Widget startdateBtn() {
    int post_id = complainAllModel.id;
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: GestureDetector(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onSurface: Colors.grey,
          ),
          child: (isButtonCheckinActive == true)
              ? const SelectableText('ลงเวลาเข้า',
                  style: TextStyle(color: Colors.white))
              : const SelectableText('ลงเวลาเข้า',
                  style: TextStyle(color: Colors.black)),
          onPressed: isButtonCheckinActive
              ? () {
                  // print('You click checkin');
                  checkIn();
                  setState(() {
                    isButtonCheckinActive = false;
                    DateTime now = DateTime.now();
                    complainAllModel.startdate_fix =
                        DateFormat('dd/MM/yyyy HH:mm').format(now).toString();
                    // startdateShow();
                  });
                }
              : null,
        ),
      ),
    );
  }

  Future<void> checkIn() async {
    memberID = myUserModel.id.toString();
    var cpID = currentComplainAllModel.id;

    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_checkin.php?memberId=$memberID&cpID=$cpID'; //'';

    await http.get(url).then((value) {
      // confirmSubmit();
    });
  }

  Widget startdateShow() {
    return Container(
        child: Column(children: <Widget>[
      SelectableText(
        complainAllModel.startdate_fix,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(0xff, 0, 0, 0),
        ),
      ),
    ]));
  }

  Widget showAppointStartdate() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: <Widget>[
          SelectableText(
            'วันเริ่มงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          startdateBtn(),
          startdateShow(),
        ],
      ),
    );
  }

  Widget enddateBtn() {
    int post_id = complainAllModel.id;
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: GestureDetector(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onSurface:
                (isButtonCheckinActive == true) ? Colors.black : Colors.grey,
          ),
          child: (isButtonCheckoutActive == true)
              ? const SelectableText('ลงเวลาออก',
                  style: TextStyle(color: Colors.white))
              : const SelectableText('ลงเวลาออก',
                  style: TextStyle(color: Colors.black)),
          onPressed: (isButtonCheckoutActive && isButtonCheckinActive == false)
              ? () {
                  // print('You click checkout');
                  checkOut();
                  setState(() {
                    isButtonCheckoutActive = false;
                    DateTime now = DateTime.now();
                    complainAllModel.enddate_fix =
                        DateFormat('dd/MM/yyyy HH:mm').format(now).toString();
                    // startdateShow();
                  });
                }
              : null,
        ),
      ),
    );
  }

  Widget enddateShow() {
    return Container(
        child: Column(children: <Widget>[
      SelectableText(
        complainAllModel.enddate_fix,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(0xff, 0, 0, 0),
        ),
      ),
    ]));
  }

  Widget showAppointEnddate() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Column(
        children: <Widget>[
          SelectableText(
            'วันจบงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          enddateBtn(),
          enddateShow(),
        ],
      ),
    );
  }

  Future<void> checkOut() async {
    //  postID = post_id;
    memberID = myUserModel.id.toString();
    var cpID = currentComplainAllModel.id;

    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_checkout.php?memberId=$memberID&cpID=$cpID'; //'';

    await http.get(url).then((value) {
      // confirmSubmit();
    });
  }

  Future<void> submitThread() async {
    try {
      var medID = currentComplainAllModel.id;
      var cpID = currentComplainAllModel.id;

      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_submit_reply.php?memberId=$memberID&cpID=$cpID&reply=$txtreply&tousermsg=$txttousermsg'; //'';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 30.0),
          child: ElevatedButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered))
                    return Colors.blue.shade700; //<-- SEE HERE
                  return null; // Defer to the widget's default.
                },
              ),
            ),
            // color: Color.fromARGB(0xff, 13, 163, 93),
            onPressed: () {
              memberID = myUserModel.id.toString();
              var cpID = currentComplainAllModel.id;
              // print('memberId=$memberID&cpID=$cpID&reply=$txtreply');
              submitThread();
            },
            child: Text(
              'บันทึก',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget usermsgBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.50,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          // Icon(Icons.kitchen, color: Colors.green[500]),
          Text(
            'ข้อความจากผู้แจ้ง',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.50,
            height: 40,
            // margin: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.black45),
              color: Colors.white,
            ),
            child: Text(
              complainAllModel.usermsg,
              style: TextStyle(
                fontSize: 16.0,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showEvaluation() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      child: Column(
        children: <Widget>[
          Text(
            'ผลประเมิน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 80),
            child: Row(
              children: <Widget>[
                for (var i = 0; i < complainAllModel.rating; i++)
                  Image.asset(
                    'images/star.png',
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget feedbackBox() {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromARGB(235, 211, 211, 211), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.90, //0.7 - 50,
              child: Text(
                'ข้อแนะนำจากผู้แจ้ง',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                  // decoration: TextDecoration.underline,
                ),
              ),
            ),
            new Divider(
              color: Colors.green.shade300,
            ),
            Row(
              children: <Widget>[
                showEvaluation(),
                usermsgBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showPhoto() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 - 50,
      child: Image.network(
        complainAllModel.postby,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget showPackage(int index) {
    return Text(complainAllModel.postby);
  }

  Widget showChoosePricePackage(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        showDetailStaffPrice(index),
        // incDecValue(index),
      ],
    );
  }

  Widget showDetailStaffPrice(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        showPackage(index),
      ],
    );
  }

  Widget showPrice() {
    return Container(
      height: 150.0,
      // color: Colors.grey,
      child: ListView.builder(
        // itemCount: unitSizeModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return showChoosePricePackage(index); // showDetailStaffPrice(index);
        },
      ),
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url = 'http://yrusv.com/api/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];

    for (var map in cartList) {
      setState(() {
        amontCart++;
      });
    }
  }

  Widget Logout() {
    return GestureDetector(
      onTap: () {
        Logout();
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/icon_logout_white.png'),
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
        leading: new IconButton(
          icon: new Icon(Icons.backspace),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: MyStyle().barColor,
        title: Text('รายการขอใช้บริการ :: รายละเอียดงาน'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 1)
              : SideBar(userModel: myUserModel, curSelectMenu: 1),
          Expanded(child: showDetailStaffList()),
        ],
      ),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showDetailStaffList() {
    return Stack(
      children: <Widget>[
        showController(),
        // addButton(),
      ],
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(15.0),
      children: <Widget>[
        // showTitle(),
        showTag(),
        showHeader(),
        // showSubject(),
        (complainAllModel.status != '6' && complainAllModel.status != '7')
            ? showResponsible()
            : Container(),
        (complainAllModel.status != '6' && complainAllModel.status != '7')
            ? showFormDeal()
            : Container(),
        // feedbackBox(),

        // showPhoto(),
      ],
    );
  }
}
