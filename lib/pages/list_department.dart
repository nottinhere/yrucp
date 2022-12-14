import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/department_model.dart';
import 'package:yrusv/pages/department_add.dart';
import 'package:yrusv/pages/department_edit.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';

class ListDept extends StatefulWidget {
  static const String route = '/ListDepartment';

  final int index;
  final UserModel userModel;

  ListDept({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListDeptState createState() => _ListDeptState();
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

class _ListDeptState extends State<ListDept> {
  List<UserModel> userModels = List(); // set array
  List<DepartmentModel> deptModels = List(); // set array
  List<DepartmentModel> filterDeptModels = List();
  DepartmentModel selectDeptModel;

  // Explicit
  int myIndex;

  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';

  int amountListView = 50, page = 1;
  String sort = 'asc';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
  bool visible = true;
  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index;
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readDept(); // read  ข้อมูลมาแสดง
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        readDept();

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

  Future<void> readDept() async {
    String memberId = myUserModel.id.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_department.php?memberId=$memberId&searchKey=$searchString&page=$page';
    // print('urlDV >> ${urlDV}');
    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemProducts = result['itemsData'];

    for (var map in itemProducts) {
      DepartmentModel deptModel = DepartmentModel.fromJson(map);
      setState(() {
        deptModels.add(deptModel);
        filterDeptModels = deptModels;
      });
    }
    // print('Count row >> ${filterDeptModels.length}');
  }

  Future<void> updateDatalist(index) async {
    String selectId = filterDeptModels[index].dpId;

    String urlSL =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_department.php?selectId=$selectId';

    http.Response responseSL = await http.get(urlSL);
    var resultSL = json.decode(responseSL.body);
    var itemSelect = resultSL['data'];

    selectDeptModel = DepartmentModel.fromJson(itemSelect);
    setState(() {
      // print('itemSelect = ${selectDeptModel.dpName}');
      filterDeptModels[index].dpName = selectDeptModel.dpName;
      filterDeptModels[index].code = selectDeptModel.code;
      filterDeptModels[index].status = selectDeptModel.status;
    });
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget deleteButton(int index) {
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {
        confirmDelete(index);
      },
    );
  }

  void confirmDelete(int index) {
    String titleName = filterDeptModels[index].dpName;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ยืนยันการลบข้อมูล'),
            content: Text('คุณต้องการลบข้อมูล : $titleName'),
            actions: <Widget>[
              cancelButton(),
              comfirmButton(index),
            ],
          );
        });
  }

  Widget comfirmButton(int index) {
    return TextButton(
      child: Text('Confirm'),
      onPressed: () {
        deleteCart(
          index,
        );
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> deleteCart(int index) async {
    String selectId = filterDeptModels[index].dpId.toString();
    String memberID = myUserModel.id.toString();

    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_department.php?memberId=$memberID&selectId=$selectId&action=delete'; //'';

    // print('selectId = $selectId  ,url = $url');

    await http.get(url).then((response) {
      setState(() {
        page = 1;
        deptModels.clear();
        readDept();
      });
      // readDept();
    });
  }

  Future<void> changeStatus(index) async {
    int memberId = myUserModel.id;
    String selectId = filterDeptModels[index].dpId;
    String nextStatus = (filterDeptModels[index].status == '0') ? '1' : '0';

    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_changestatusdept.php?memberId=$memberId&selectId=$selectId&status=$nextStatus';
    // print('url >> $urlST');
    http.Response response = await http.get(urlST);

    await http.get(urlST).then((response) {
      setState(() {
        page = 1;
        filterDeptModels.clear();
        readDept();
      });
      // readDept();
    });
  }

  Widget status_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
      // height: 80.0,
      child: InkWell(
        mouseCursor: MaterialStateMouseCursor.clickable,
        child: Card(
          color: (filterDeptModels[index].status == '0')
              ? Colors.grey.shade500
              : Colors.blue.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  (filterDeptModels[index].status == '0')
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: Colors.white,
                ),
                Text(
                  (filterDeptModels[index].status == '0')
                      ? ' ปิดการใช้งาน'
                      : ' เปิดใช้งาน',
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
          changeStatus(index);
        },
      ),
    );
  }

  Widget edit_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
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
                  Icons.edit,
                  color: Colors.white,
                ),
                Text(
                  ' แก้ไขข้อมูล',
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
          // print('Edit BTN');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return EditDept(
              deptAllModel: filterDeptModels[index],
              userModel: myUserModel,
            );
          });
          // Navigator.of(context).push(materialPageRoute);
          Navigator.of(context)
              .push(materialPageRoute)
              .then((value) => setState(() {
                    // readDept();
                    updateDatalist(index);
                    //showTag(index);
                    // showResponsible(index);
                  }));
        },
      ),
    );
  }

  Widget delete_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.08,
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
                  Icons.delete,
                  color: Colors.white,
                ),
                Text(
                  ' ลบข้อมูล',
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
          // print('Delete BTN');
          confirmDelete(index);
        },
      ),
    );
  }

  Widget showBTN(int index) {
    return Row(
      children: [
        (filterDeptModels[index].status == '1') ? edit_btn(index) : Container(),
        (filterDeptModels[index].status == '1')
            ? delete_btn(index)
            : Container(),
        status_btn(index),
      ],
    );
  }

  Widget showPercentStock(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                ' [ ' +
                    filterDeptModels[index].code +
                    ' ]  ชื่องาน : ' +
                    filterDeptModels[index].dpName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                ),
              ),
              (filterDeptModels[index].memInDept > 0)
                  ? showBTN(index)
                  : Text(
                      'กรุณาเพิ่มสมาชิกเข้ากลุ่มงาน',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            'Dept : ' + filterDeptModels[index].dpName.toString(),
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
          showPercentStock(index),
          // showName(index),
        ],
      ),
    );
  }

  Widget AddDepartment() {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return AddDept(
            userModel: myUserModel,
          );
        });
        // Navigator.of(context).push(materialPageRoute);
        Navigator.of(context)
            .push(materialPageRoute)
            .then((value) => setState(() {
                  page = 1;
                  deptModels.clear();
                  readDept();
                }));
      },
      child: Card(
        color: Colors.blue.shade600,
        child: Container(
          height: 50,
          // padding: EdgeInsets.all(2.0),
          // alignment: AlignmentDirectional(0.0, 0.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              Text(
                ' เพิ่มข้อมูล',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
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
        itemCount: filterDeptModels.length,
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

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
      child: ListTile(
        // trailing: IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       // print('searchString ===>>> $searchString');
        //       setState(() {
        //         page = 1;
        //         productAllModels.clear();
        //         readDept();
        //       });
        //     }),
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
              deptModels.clear();
              readDept();
            });
          },
        ),
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
              deptModels.clear();
              readDept();
            });
          }),
    );
  }

  Widget showContent() {
    return userModels.length == 0
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
        title: Text('จัดการผู้รับผิดชอบ'),
        actions: <Widget>[
          AddDepartment(),
        ],
      ),
      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel)
              : SideBar(userModel: myUserModel),
          Expanded(
            child: Column(
              children: <Widget>[
                searchForm(),
                clearButton(),
                showContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
