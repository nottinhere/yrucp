import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/complain_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/pages/detail.dart';
import 'package:yrusv/pages/detail_staff.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yrusv/widgets/home.dart';

import 'detail.dart';
import 'detail_cart.dart';

class ListComplain extends StatefulWidget {
  final int index;
  final UserModel userModel;

  ListComplain({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListComplainState createState() => _ListComplainState();
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

class _ListComplainState extends State<ListComplain> {
  // Explicit
  int myIndex;
  List<ComplainAllModel> complainAllModels = List(); // set array
  List<ComplainAllModel> filterComplainAllModels = List();
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
      readData(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        readData();

        // print('in the end');

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
    // String url = MyStyle().readAllProduct;
    int memberId = myUserModel.id;
    // String url =
    //     'http://ptnpharma.com/apisupplier/json_data_product.php?memberId=$memberId&searchKey=$searchString&page=$page&sort=$sort';

    String url =
        'https://app.oss.yru.ac.th/yrusv/api/json_data_complain.php?memberId=$memberId&searchKey=$searchString&page=$page&sort=$sort';

    if (myIndex != 0) {
      url = '${MyStyle().readProductWhereMode}$myIndex';
    }

    http.Response response = await http.get(url);
    print('url readData ##################+++++++++++>>> $url');
    var result = json.decode(response.body);
    // print('result = $result');
    // print('url ListComplain ====>>>> $url');
    // print('result ListComplain ========>>>>> $result');

    var itemProducts = result['itemsData'];

    for (var map in itemProducts) {
      ComplainAllModel complainAllModel = ComplainAllModel.fromJson(map);
      setState(() {
        complainAllModels.add(complainAllModel);
        filterComplainAllModels = complainAllModels;
      });
    }
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
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
          print('You click promotion');
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
          print('You click update price');
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
          print('You click new item');
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
                  'ดำเนินการเรียบร้อบ',
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
          print('You click not receive');
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
          print('You click not receive');
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
          print('You click not receive');
          // routeToListComplain(4);
        },
      ),
    );
  }

  Widget L1_btn(index) {
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
                  'Assign (L1)',
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
          print('You are boss');
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
                    readData();
                    //showTag(index);
                    showResponsible(index);
                  }));
        },
      ),
    );
  }

  Widget L2_btn(index) {
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
                  'Detail (L2)',
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
          print('You are staff');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailStaff(
              complainAllModel: filterComplainAllModels[index],
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget showTag(index) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // SizedBox(
        //   width: 5.0,
        //   height: 8.0,
        // ),
        // filterComplainAllModels[index].status != 1
        //     ? cancelTag(index)
        //     : Container(),

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
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.65,
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
                'วันที่รับแจ้ง :   ${filterComplainAllModels[index].postdate}',
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
        Column(
          children: [
            // Icon(Icons.restaurant, color: Colors.green[500]),
            Text('ผู้แจ้ง'),
            Text(
              filterComplainAllModels[index].postby,
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
        Column(
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
        Row(
          children: [L1_btn(index), L2_btn(index)],
        )
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
        //         complainAllModels.clear();
        //         readData();
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
              complainAllModels.clear();
              readData();
            });
          },
        ),
      ),
    );
  }

  Widget sortButton() {
    return Container(
      child: FlatButton.icon(
          // color: Colors.red,
          icon: Icon(Icons.sort), //`Icon` to display
          label: Text('เรียงตามสต๊อกคงเหลือ'), //`Text` to display
          onPressed: () {
            print('searchString ===>>> $searchString');
            setState(() {
              page = 1;
              sort = (sort == 'asc') ? 'desc' : 'asc';
              complainAllModels.clear();
              readData();
            });
          }),
    );
  }

  Widget showContent() {
    return filterComplainAllModels.length == 0
        ? showProductItem() // showProgressIndicate()
        : showProductItem();
  }

  Future<void> readCart() async {
    String memberId = myUserModel.id.toString();
    print(memberId);
    String url =
        'http://ptnpharma.com/apisupplier/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];

    for (var map in cartList) {
      setState(() {
        amontCart++;
      });
    }
  }

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
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
          Home(),
          // Logout(),
          // showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('ขอใช้บริการ'),
      ),
      // body: filterComplainAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Column(
        children: <Widget>[
          searchForm(),
          sortButton(),
          showContent(),
        ],
      ),
    );
  }
}
