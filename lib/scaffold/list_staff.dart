import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrucp/models/product_all_model.dart';
import 'package:yrucp/models/user_model.dart';
import 'package:yrucp/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrucp/widget/home.dart';
import 'package:yrucp/scaffold/staff_add.dart';
import 'package:yrucp/scaffold/staff_edit.dart';

import 'detail.dart';
import 'detail_cart.dart';

class ListUser extends StatefulWidget {
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

        // print('in the end');

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
        'https://nottinhere.com/demo/yru/yrucp/apiyrucp/json_data_staff.php?memberId=$memberId&searchKey=$searchString&page=$page';

    http.Response response = await http.get(urlDV);
    var result = json.decode(response.body);
    var itemProducts = result['itemsProduct'];

    for (var map in itemProducts) {
      UserModel userModel = UserModel.fromJson(map);
      setState(() {
        userModels.add(userModel);
        filterUserModels = userModels;
      });
    }
    print('Count row >> ${filterUserModels.length}');
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget edit_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Edit',
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
          print('Edit BTN');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return EditUser(
              userAllModel: filterUserModels[index],
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget delete_btn(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.10,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.grey.shade600,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Delete',
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
          print('Edit BTN');
        },
      ),
    );
  }

  Widget showPercentStock(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Name : ' + filterUserModels[index].personName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                ),
              ),
              Text(
                'Contact : ' + filterUserModels[index].personContact,
                style: TextStyle(
                  fontSize: 16.0,
                  // fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
              Row(
                children: [edit_btn(index), delete_btn(index)],
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
            'Dept : ' + filterUserModels[index].division.toString(),
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
          showName(index),
        ],
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

  Widget AddStaff() {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return AddUser(
            userModel: myUserModel,
          );
        });
        Navigator.of(context).push(materialPageRoute);
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/add-icon.png'),
          ],
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
                  EdgeInsets.only(top: 3.0, bottom: 3.0, left: 6.0, right: 6.0),
              child: Card(
                // color: Color.fromRGBO(235, 254, 255, 1.0),

                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
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
        //       print('searchString ===>>> $searchString');
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
              // readUser();
            });
          },
        ),
      ),
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
        backgroundColor: MyStyle().barColor,
        title: Text('รายชื่อผู้ปฎิบัติงาน'),
        actions: <Widget>[
          Home(),
          AddStaff(),
        ],
      ),
      // body: filterProductAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Column(
        children: <Widget>[
          searchForm(),
          showContent(),
        ],
      ),
    );
  }
}
