import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/staff_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/pages/detail_cart.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:yrusv/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:uipickers/uipickers.dart';
import 'package:time_picker_widget/time_picker_widget.dart';
import 'package:intl/intl.dart';
import 'package:yrusv/layouts/side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  static const String route = '/Detail';

  final ComplainAllModel complainAllModel;
  final UserModel userModel;

  Detail({Key key, this.complainAllModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class Helper {
  final int id;
  final String name;

  Helper({
    this.id,
    this.name,
  });
}

class _DetailState extends State<Detail> {
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
      txtnote = '',
      txttousermsg = '';

  String memberID;
  String strhelperID;

  int page = 1;
  String dp = '1';
  String searchString = '';

  List<StaffModel> staffModels = List(); // set array
  List<StaffModel> filterStaffModels = List();
  List<StaffModel> _selectedHelper = List();
  List<StaffModel> _selectedDBHelper = [];
  List<StaffModel> _listhelpers = [];

  String _mySelection, _myHelperSelection;

  String _mySelectionPB;
  // static List<StaffModel> _helpers = [];

  int selectedItem = 0;
  DateTime selectedDate; //  = DateTime.now()

  String selectedTime;

  List<int> _availableHours = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23
  ];
  List<int> _availableMinutes = [
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
  ];

  var _items;

  final _multiSelectKey = GlobalKey<FormFieldState>();

  // Method
  @override
  void initState() {
    super.initState();
    currentComplainAllModel = widget.complainAllModel;
    myUserModel = widget.userModel;
    // _selectedHelper = _helpers;
    setState(() {
      getProductWhereID();
      readStaff();
      readProblem();
    });
  }

  showMessage(BuildContext context, String message) => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 16,
              ),
              Icon(
                Icons.warning,
                color: Colors.amber,
                size: 56,
              ),
              SizedBox(
                height: 12,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF231F20),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Color(0xFFE8ECF3)))),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                        color: Color(0xFF2058CA),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      });

  Future<void> getProductWhereID() async {
    if (currentComplainAllModel != null) {
      id = currentComplainAllModel.id.toString();
      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_data_complaindetail.php?id=$id';
      // print('url = $url');
      http.Response response = await http.get(url);
      var result = json.decode(response.body);

      var itemProducts = result['itemsData'];

      // var inputFormat = DateFormat('MMM  dd,yyyy');
      // DateTime inputDate = DateTime.parse(complainAllModel.appointdate);

      // var outputFormat = DateFormat('MMM  dd,yyyy');
      // var outputDate = outputFormat.format(inputDate);

      for (var map in itemProducts) {
        setState(() {
          complainAllModel = ComplainAllModel.fromJson(map);

          // DateTime outputDate = new DateFormat("MM dd,yyyy").parse('20220322');

          // // print('outputDate >> $outputDate');

          // Map<String, dynamic> priceListMap = map['price_list'];
          _mySelection =
              (complainAllModel.staff == '-') ? null : complainAllModel.staff;
          _myHelperSelection =
              (complainAllModel.helper == '-') ? '' : complainAllModel.helper;

          strhelperID =
              (complainAllModel.helper == '-') ? '' : complainAllModel.helper;

          if (complainAllModel.appointdate == '-') {
            selectedDate = DateTime.now();
          } else {
            DateTime dateApt =
                DateTime.parse((complainAllModel.appointdate).toString());
            selectedDate = dateApt;
          }

          selectedTime = (complainAllModel.appointtime == '-' ||
                  complainAllModel.appointtime == '00:00')
              ? DateFormat.Hm().format(DateTime.now())
              : complainAllModel.appointtime;
        });
      } // for
    }
  }

  List dataST;
  String myDBhelper;
  String dept;

  List<String> listHelperDB = [];
  Future<void> readStaff() async {
    int memberId = myUserModel.id;
    String myDBhelper = currentComplainAllModel.helper;
    dept = currentComplainAllModel.department_id;
    // print('dept -> $dept');

    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_staff.php?memberId=$memberId&searchKey=$searchString&page=$page&dept=$dept&active=1';
    // print('urlST = $urlST');

    // print('Here is error');
    http.Response responseST = await http.get(urlST);
    // print('Here is error');

    var result = json.decode(responseST.body);
    var itemDivisions = result['itemsData'];
    if (myDBhelper != '-') {
      listHelperDB = myDBhelper.split(',').toList();
    }

    _selectedDBHelper.clear();

    setState(() {
      int i = 0;
      for (var map in itemDivisions) {
        int personID = map['id'];
        String personName = map['person_name'];

        _listhelpers.add(
          StaffModel(
            id: personID,
            subject: personName,
          ),
        );

        if (listHelperDB.contains(personID.toString())) {
          // print('exists personID >> $personID , personName >> $personName');
          _selectedDBHelper.add(_listhelpers[i]);
        }
        i = i + 1;
      } // for
    });

    setState(() {
      _items = _listhelpers
          .map((helper) => MultiSelectItem<StaffModel>(helper, helper.subject))
          .toList();
      // // print('<< _items >> $_items');
      // // print('<< _listhelpers >> $_listhelpers');
      dataST = itemDivisions;
    });
  }

  List dataPB;
  Future<void> readProblem() async {
    String urlPB =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_problem.php?allRow=1';
    // print('urlDV >> $urlPB');

    http.Response response = await http.get(urlPB);
    var result = json.decode(response.body);
    var itemDepartments = result['itemsData'];

    setState(() {
      for (var map in itemDepartments) {
        String pbID = map['p_id'];
        String pbName = map['subject'];
        String dpID = map['dp_id'];
        String dpName = map['dp_name'];
      } // for
    });

    setState(() {
      dataPB = itemDepartments;
    });
    // print('dataPB >> $dataPB');
  }

  Future<void> launchLink(String url, {bool isNewTab = true}) async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
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
        mySizebox(),
        Column(
          children: [
            // Icon(Icons.timer, color: Colors.green[500]),
            Text(
              'รายละเอียด',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              complainAllModel.detail,
              style: TextStyle(
                fontSize: 16.0,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
          ],
        ),
        mySizebox(),
      ],
    );
  }

  Widget showResponsible() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            // Icon(Icons.restaurant, color: Colors.green[500]),
            Text('ผู้แจ้ง'),
            Text(
              complainAllModel.postby,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
          ],
        ),
      ],
    );
    // return Text('na');
  }

  Widget showResponsible_staff() {
    // // print('_selectedDBHelper in >> $_selectedDBHelper');
    if (myUserModel.level == 3) {
      _mySelection = myUserModel.id.toString();
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromARGB(179, 22, 141, 11), width: 2),
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
                Column(
                  children: [
                    Text('วันนัดหมาย'),
                    SizedBox(
                        width: 200,
                        height: 34,
                        child: AdaptiveDatePicker(
                          //type: AdaptiveDatePickerType.material,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().add(Duration(days: -7)),
                          lastDate: DateTime.now().add(Duration(days: 1460)),
                          onChanged: (date) {
                            setState(() => selectedDate = date);
                          },
                        )),
                  ],
                ),
                Column(
                  children: [
                    // Icon(Icons.restaurant, color: Colors.green[500]),
                    Text('เวลานัดหมาย'),
                    Center(
                      child: InkWell(
                        child: Container(
                          child: Center(
                            child: Text(
                              selectedTime ??
                                  complainAllModel
                                      .appointtime, // selectedTime ?? '00.00',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey.shade200,
                          ),
                          width: 200,
                          height: 35,
                        ),

                        onTap: () =>
                            // DEMO --------------
                            showCustomTimePicker(
                                context: context,
                                builder: (BuildContext context, Widget child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child,
                                  );
                                },
                                onFailValidation: (context) => showMessage(
                                    context, 'Unavailable selection.'),
                                initialTime: TimeOfDay(
                                    hour: _availableHours.first,
                                    minute: _availableMinutes.first),
                                selectableTimePredicate: (time) =>
                                    _availableHours.indexOf(time.hour) != -1 &&
                                    _availableMinutes.indexOf(time.minute) !=
                                        -1).then((time) => setState(
                                () => selectedTime = time?.format(context))),
                        // --------------
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    // Icon(Icons.kitchen, color: Colors.green[500]),
                    Text('ผู้รับผิดชอบ'),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.grey.shade200,
                      ),
                      width: 200,
                      height: 35,
                      child: DropdownButton(
                        alignment: Alignment.center,
                        underline: Container(color: Colors.transparent),
                        value: _mySelection,
                        onChanged: (myUserModel.level == 3)
                            ? null
                            : (String newVal) {
                                setState(() => _mySelection = newVal);
                              },
                        items: dataST.map((item) {
                          return new DropdownMenuItem(
                            child: new Text(item['person_name']),
                            value: item['id'].toString(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  children: [
                    Text('ผู้ช่วย'),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: MultiSelectBottomSheetField<StaffModel>(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.shade200,
                        ),
                        key: _multiSelectKey,
                        initialChildSize: 0.7,
                        maxChildSize: 0.95,
                        initialValue: _selectedDBHelper,
                        // initialValue: [_selectedDBHelper[0], _selectedDBHelper[1]],
                        title: Text("ทีมงาน"),
                        buttonText: Text("เลือกทีมงาน"),
                        items: _items,
                        searchable: true,
                        buttonIcon: Icon(
                          Icons.supervisor_account_sharp,
                          color: Colors.blue,
                        ),
                        validator: (values) {
                          if (values == null || values.isEmpty) {
                            return "Required";
                          }
                          List<String> names =
                              values.map((e) => e.subject).toList();
                          if (names.contains("Frog")) {
                            return "Frogs are weird!";
                          }
                          return null;
                        },
                        onConfirm: (values) {
                          setState(() {
                            _selectedHelper = values;
                            List<int> listhelperID =
                                _selectedHelper.map((e) => e.id).toList();
                            strhelperID = listhelperID.join(',');
                          });
                          _multiSelectKey.currentState.validate();
                        },
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (item) {
                            setState(() {
                              _selectedHelper.remove(item);
                              List<int> listhelperID =
                                  _selectedHelper.map((e) => e.id).toList();
                              strhelperID = listhelperID.join(',');
                            });
                            _multiSelectKey.currentState.validate();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    noteBox(),
                  ],
                ),
              ],
            ),
            submitButton(),
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
            showAppoint()
          ],
        ),
      ),
    );
  }

  Widget showFixStartdate() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      child: Column(
        children: <Widget>[
          Text(
            'วันเริ่มงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
              child: Column(children: <Widget>[
            Text(
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
      width: MediaQuery.of(context).size.width * 0.20,
      child: Column(
        children: <Widget>[
          Text(
            'วันจบงาน',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Text(
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

  Widget showAppoint() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      width: MediaQuery.of(context).size.width * 0.19,
      child: Column(
        children: <Widget>[
          Text(
            'ผู้รับผิดชอบ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Text(
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

  Widget noteBox() {
    txtnote = complainAllModel.note;
    return Container(
      width: MediaQuery.of(context).size.width * 0.33,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          Text(
            'ข้อมูลเพิ่มเติม',
            style: TextStyle(
                // decoration: TextDecoration.underline,
                ),
          ),
          TextFormField(
            initialValue: txtnote,
            onChanged: (value) {
              txtnote = value.trim();
            },
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: InputDecoration(
              // suffixIcon: Icon(Icons.mode_edit, color: Colors.blue),
              fillColor: Colors.grey.shade200,
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

  Widget replyBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.66,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          // Icon(Icons.kitchen, color: Colors.green[500]),
          Text(
            'ข้อความตอบกลับ',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.60,
            height: 40,
            // margin: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.black45),
              color: Colors.white,
            ),
            child: Text(
              complainAllModel.reply,
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

  Widget touserBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.66,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Column(
        children: [
          // Icon(Icons.kitchen, color: Colors.green[500]),
          Text(
            'ข้อความตอบกลับผู้แจ้งเรื่อง',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.60,
            height: 40,
            // margin: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.black45),
              color: Colors.white,
            ),
            child: Text(
              complainAllModel.tousermsg,
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

  Widget showFormDeal() {
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
                showFixStartdate(),
                showFixEnddate(),
                // showEvaluation(),
              ],
            ),
            // noteBox(),
            replyBox(),
            touserBox(),
            //  Row(children: <Widget>[priceBox(),priceBox(),],),
            //  Row(children: <Widget>[noteBox()],),
          ],
        ),
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

  Widget transferBox() {
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
                'โอนย้ายไปยังแผนกอื่น',
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
            Column(
              children: [
                // Icon(Icons.kitchen, color: Colors.green[500]),
                Text('ย้ายไปแผนก'),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.shade200,
                  ),
                  width: 800,
                  height: 35,
                  child: DropdownButton(
                    alignment: Alignment.center,
                    underline: Container(color: Colors.transparent),
                    value: _mySelectionPB,
                    onChanged: (String newVal) {
                      setState(() => _mySelectionPB = newVal);
                    },
                    items: dataPB.map((item) {
                      return new DropdownMenuItem(
                        child: new Text(
                            '(' + item['dp_name'] + ')  ' + item['subject']),
                        value: item['p_id'].toString(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            submitTransferButton(),
          ],
        ),
      ),
    );
  }

  Future<void> submitThread() async {
    id = currentComplainAllModel.id.toString();
    // String url = '${MyStyle().getProductWhereId}$id';
    String urlSelectCP =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_complaindetail.php?id=$id';
    print('urlSelectCP = $urlSelectCP');
    http.Response response = await http.get(urlSelectCP);
    var resultSelectCP = json.decode(response.body);

    Map<String, dynamic> map = resultSelectCP['itemsData'][0];
    ComplainAllModel dataSelectCP = ComplainAllModel.fromJson(map);
    var selectStaff = dataSelectCP.staff;
    var selectStatus = dataSelectCP.status;
    print('selectStaff = $selectStaff');

    // //try {
    if (selectStatus == '1' || selectStatus == '2') {
      // if (selectStaff == '-') {
      var medID = currentComplainAllModel.id;
      var cpID = currentComplainAllModel.id;

      currentComplainAllModel.helper = strhelperID;

      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_submit_staff.php?memberId=$memberID&cpID=$cpID&assignTo=$_mySelection&note=$txtnote&helper=$strhelperID&selectedDate=$selectedDate&selectedTime=$selectedTime'; //'';
      // print('submitURL >> $url');
      await http.get(url).then((value) {
        confirmSubmit();
      });
      // } else {
      //   normalDialog(
      //       context, 'ไม่สามารถแก้ไขได้', 'เนื่องจากงานได้เริ่มดำเนินการแล้ว');
      // }
    } else {
      normalDialog(
          context, 'ไม่สามารถแก้ไขได้', 'เนื่องจากงานได้เริ่มดำเนินการแล้ว');
    }
    //} catch (e) {}
  }

  Future<void> confirmSubmit() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('แก้ไขเรียบร้อย'),
            content: Text('แก้ไขข้อมูลเรียบร้อย'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.pop(context, true);
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
              // print(
              //     'memberId=$memberID&cpID=$cpID&assignTo=$_mySelection&note=$txtnote');

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

  Future<void> confirmTransferSubmit() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ดำเนินการเรียบร้อย'),
            content: Text('โอนเรื่องเรียบร้อย'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigator.pop(context);
                    backTransferProcess();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void backTransferProcess() {
    Navigator.of(context).pop();
    // Navigator.pop(context);
  }

  Future<void> submitTransferThread() async {
    try {
      var medID = currentComplainAllModel.id;
      var cpID = currentComplainAllModel.id;
      var fromDV = currentComplainAllModel.department;
      var postdate = currentComplainAllModel.postdate;

      currentComplainAllModel.helper = strhelperID;

      String url =
          'https://app.oss.yru.ac.th/yrusv/api/json_submit_transfer.php?memberId=$memberID&cpID=$cpID&selectedPB=$_mySelectionPB&fromDV=$fromDV&postdate=$postdate'; //'';
      print('submitURL >> $url');
      await http.get(url).then((value) {
        confirmTransferSubmit();
      });
    } catch (e) {}
  }

  Widget submitTransferButton() {
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
              // print(
              //     'memberId=$memberID&cpID=$cpID&assignTo=$_mySelection&note=$txtnote');

              submitTransferThread();
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

  Widget showPhoto() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 - 50,
      child: Image.network(
        complainAllModel.postby,
        fit: BoxFit.contain,
      ),
    );
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
        backgroundColor: MyStyle().barColor,
        title: Text('รายการขอใช้บริการ :: กำหนดผู้ปฏิบัติงาน'),
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 1)
              : SideBar(userModel: myUserModel, curSelectMenu: 1),
          Expanded(child: showDetailList()),
        ],
      ),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showDetailList() {
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
        // showResponsible(),
        (complainAllModel.status != '6' && complainAllModel.status != '7')
            ? showResponsible_staff()
            : Container(),
        (complainAllModel.status != '6' && complainAllModel.status != '7')
            ? showFormDeal()
            : Container(),

        // feedbackBox(),
        if (complainAllModel.status == '1' || complainAllModel.status == '2')
          transferBox(),
        // showPhoto(),
      ],
    );
  }
}
