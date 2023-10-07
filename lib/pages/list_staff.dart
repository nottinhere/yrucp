import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/pages/staff_add.dart';
import 'package:yrusv/pages/staff_edit.dart';

import 'detail.dart';
import 'detail_cart.dart';
import 'package:yrusv/layouts/side_bar.dart';

class ListUser extends StatefulWidget {
  static const String route = '/ListUser';

  final int index;
  final UserModel userModel;
  ListUser({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListUserState createState() => _ListUserState();
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

class _ListUserState extends State<ListUser> {
  List<UserModel> userModels = List(); // set array
  List<UserModel> filterUserModels = List();
  UserModel selectUserModel;

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

  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index;
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readStaff(); // read  ข้อมูลมาแสดง
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        readStaff();

        // // print('in the end');

        // setState(() {
        //   amountListView = amountListView + 2;
        //   if (amountListView > filterProductAllModels.length) {
        //     amountListView = filterProductAllModels.length;
        //   }
        // });
      }
    });
  }

  Future<void> readStaff() async {
    String memberId = myUserModel.id.toString();

    String urlDV =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_staff.php?memberId=$memberId&searchKey=$searchString&page=$page';
    // print('urlDV >> $urlDV');

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemProducts = result['itemsData'];

    for (var map in itemProducts) {
      UserModel userModel = UserModel.fromJson(map);
      setState(() {
        userModels.add(userModel);
        filterUserModels = userModels;
      });
    }
    // print('Count row >> ${filterUserModels.length}');
  }

  Future<void> updateDatalist(index) async {
    // print('Here is updateDatalist function');

    String memberId = myUserModel.id.toString();
    int selectId = filterUserModels[index].id;
    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_select_staff.php?memberId=$memberId&selectId=$selectId';

    http.Response response = await http.get(urlST);
    var resultSL = json.decode(response.body);
    var itemSelect = resultSL['data'];

    selectUserModel = UserModel.fromJson(itemSelect);
    setState(() {
      filterUserModels[index].personName = selectUserModel.personName;
      filterUserModels[index].personContact = selectUserModel.personContact;
      filterUserModels[index].departmentName = selectUserModel.departmentName;
      filterUserModels[index].levelName = selectUserModel.levelName;
    });
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('ยกเลิก'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
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
    String titleName = filterUserModels[index].personName;

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
      child: Text('ยืนยัน'),
      onPressed: () {
        deleteCart(
          index,
        );
        // Navigator.of(context).pop();
      },
    );
  }

  Future<void> deleteCart(int index) async {
    String selectId = filterUserModels[index].id.toString();
    String memberID = myUserModel.id.toString();

    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_manage_staff.php?memberId=$memberID&selectId=$selectId&action=delete'; //'';

    // print('selectId = $selectId  ,url = $url');

    await http.get(url).then((response) {
      setState(() {
        page = 1;
        filterUserModels.clear();
        readStaff();
      });
      // readStaff();
    });
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushNamed(ListUser.route);
  }

  Future<void> changeStatus(index) async {
    int memberId = myUserModel.id;
    String selectId = filterUserModels[index].id.toString();
    int nextStatus = (filterUserModels[index].status == 0) ? 1 : 0;

    String urlST =
        'https://app.oss.yru.ac.th/yrusv/api/json_submit_changestatusstaff.php?memberId=$memberId&selectId=$selectId&status=$nextStatus';
    // print('url >> $urlST');
    http.Response response = await http.get(urlST);
    // Navigator.of(context, rootNavigator: true).pop();

    await http.get(urlST).then((response) {
      setState(() {
        page = 1;
        filterUserModels.clear();
        readStaff();
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
          color: (filterUserModels[index].status == 0)
              ? Colors.grey.shade500
              : Colors.blue.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Icon(
                  (filterUserModels[index].status == 0)
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: Colors.white,
                ),
                Text(
                  (filterUserModels[index].status == 0)
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
            return EditUser(
              userAllModel: filterUserModels[index],
              userModel: myUserModel,
            );
          });
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
          color: (filterUserModels[index].postInMem == 0)
              ? Colors.blue.shade600
              : Colors.grey.shade500,
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
                  ' ลบข้อมูล ',
                  //    + '(' + filterUserModels[index].postInMem.toString() + ')'
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
          (filterUserModels[index].postInMem == 0)
              ? confirmDelete(index)
              : null;
        },
      ),
    );
  }

  Widget showData(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.32,
                child: Text(
                  'ชื่อ : ' + filterUserModels[index].personName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.11,
                child: Text(
                  'Contact : ' + filterUserModels[index].personContact,
                  style: TextStyle(
                    fontSize: 16.0,
                    // fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (filterUserModels[index].status == 1)
                        ? edit_btn(index)
                        : Container(),
                    (filterUserModels[index].status == 1)
                        ? delete_btn(index)
                        : Container(),
                    status_btn(index),
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
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            '( สถานะ : ' +
                filterUserModels[index].levelName.toString() +
                ' ) งาน : ' +
                filterUserModels[index].departmentName.toString(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          showData(index),
          showName(index),
        ],
      ),
    );
  }

  Widget AddStaff() {
    return InkWell(
      mouseCursor: MaterialStateMouseCursor.clickable,
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return AddUser(
            userModel: myUserModel,
          );
        });
        // Navigator.of(context).push(materialPageRoute);
        Navigator.of(context)
            .push(materialPageRoute)
            .then((value) => setState(() {
                  page = 1;
                  filterUserModels.clear();
                  readStaff();
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
        itemCount: userModels.length,
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
        //         readStaff();
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
              userModels.clear();
              readStaff();
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
              userModels.clear();
              readStaff();
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
        title: Text('จัดการข้อมูลรายชื่อ'),
        actions: <Widget>[
          AddStaff(),
        ],
      ),
      // body: filterProductAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Row(
        children: [
          (myUserModel.level == 1)
              ? AdminSideBar(userModel: myUserModel, curSelectMenu: 9)
              : SideBar(userModel: myUserModel, curSelectMenu: 9),
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
