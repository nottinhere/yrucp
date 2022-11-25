import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:yrusv/models/product_all_model.dart';
// import 'package:yrusv/models/promote_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/models/news_model.dart';

import 'package:yrusv/pages/list_complain.dart';
import 'package:yrusv/pages/list_complain_admin.dart';
import 'package:yrusv/pages/list_faq.dart';
import 'package:yrusv/pages/list_staff.dart';
import 'package:yrusv/pages/list_department.dart';

// import 'package:yrusv/pages/detail_news.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*   remove this code  */
// import 'package:yrusv/pages/list_product.dart';
// import 'package:yrusv/pages/list_product_outofstock.dart';
// import 'package:yrusv/pages/list_product_overstock.dart';
// import 'package:yrusv/pages/list_product_losesale.dart';
// import 'package:yrusv/pages/list_product_highdemand.dart';
// import 'package:yrusv/pages/list_product_monthlyreport.dart';
// import 'package:yrusv/pages/list_product_alert.dart';
/*      ----- -----    */

class Home extends StatefulWidget {
  final UserModel userModel;

  Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  // List<Widget> promoteLists = List();
  // List<String> urlImages = List();
  // List<String> urlImagesSuggest = List();

  int amontCart = 0, banerIndex = 0, suggessIndex = 0, newsIndex = 0;
  UserModel myUserModel;
  // List<ProductAllModel> promoteModels = List();

  NewsModel newsModel;
  String imageNews = '';
  String subjectNews = '';

  // Method
  @override
  void initState() {
    super.initState();
    // readPromotion();
    // readNews();
    myUserModel = widget.userModel;
  }

  // Future<void> readNews() async {
  //   String url = 'http://ptnpharma.com/apisupplier/json_supnewsdetail.php';
  //   http.Response response = await http.get(url);
  //   var result = json.decode(response.body);
  //   var mapItemNews =
  //       result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
  //   for (var map in mapItemNews) {
  //     NewsModel newsModel = NewsModel.fromJson(map);
  //     String urlImage = newsModel.photo;
  //     String subject = newsModel.subject;
  //     setState(() {
  //       subjectNews = subject;
  //       imageNews = urlImage;
  //     });
  //   }
  // }

  // Future<void> readPromotion() async {
  //   String url = 'http://ptnpharma.com/apisupplier/json_promotion.php';
  //   http.Response response = await http.get(url);
  //   var result = json.decode(response.body);
  //   var mapItemProduct =
  //       result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
  //   for (var map in mapItemProduct) {
  //     PromoteModel promoteModel = PromoteModel.fromJson(map);
  //     ProductAllModel productAllModel = ProductAllModel.fromJson(map);
  //     String urlImage = promoteModel.photo;
  //     setState(() {
  //       promoteModels.add(productAllModel);
  //       promoteLists.add(showImageNetWork(urlImage));
  //       urlImages.add(urlImage);
  //     });
  //   }
  // }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void routeToListComplain(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListComplain(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget profileBox() {
    String login = myUserModel.subject;
    // String loginStatus = myUserModel.status;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.lightBlue.shade50,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_user.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  '$login', // 'ผู้แทน : $login',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click profile');
          // routeToListComplain(0);
        },
      ),
    );
  }

  Widget productBox() {
    String login = myUserModel.subject;
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.lightBlue.shade50,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click product');
          routeToListComplain(0);
        },
      ),
    );
  }

  Widget logoutSquareBox() {
    String login = myUserModel.subject;
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.lightBlue.shade50,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_logout.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click square logout');
          logOut();
        },
      ),
    );
  }

  Widget logoutBox() {
    String login = myUserModel.subject;
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.lightBlue.shade50,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_logout.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click logout');
          logOut();
        },
      ),
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  // Widget newsBox() {
  //   String login = myUserModel.subject;
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.9,
  //     // height: 80.0,
  //     child: GestureDetector(
  //       child: Card(
  //         // color: Colors.lightBlue.shade50,
  //         child: Container(
  //           padding: EdgeInsets.all(16.0),
  //           alignment: AlignmentDirectional(0.0, 0.0),
  //           child: Column(
  //             children: <Widget>[
  //               Text(
  //                 subjectNews, // 'ผู้แทน : $login',
  //                 style: TextStyle(
  //                     fontSize: 20.0,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black),
  //               ),
  //               SizedBox(
  //                 width: 10.0,
  //                 height: 8.0,
  //               ),
  //               Image.network(
  //                 imageNews,
  //                 width: MediaQuery.of(context).size.width * 0.9,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       onTap: () {
  //         // print('This is News');
  //         // int index;
  //         MaterialPageRoute materialPageRoute =
  //             MaterialPageRoute(builder: (BuildContext buildContext) {
  //           return DetailNews(
  //             // index: index,
  //             userModel: myUserModel,
  //           );
  //         });
  //         Navigator.of(context).push(materialPageRoute);
  //       },
  //     ),
  //   );
  // }

  Widget ViewQA() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/question-answer.png'),
                ),
                Text(
                  'ถาม-ตอบ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click listUser');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListFaq(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget Complainbox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_checkmark.png'),
                ),
                Text(
                  'ขอใช้บริการ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          routeToListComplain(0);
        },
      ),
    );
  }

  Widget ManageComplain() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_checkmark_admin.png'),
                ),
                Text(
                  'ขอใช้บริการ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListComplainAdmin(
              index: 0,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget ManageCategorybox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_category.png'),
                ),
                Text(
                  'งาน',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListDept(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget ManageUserbox() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_user_admin.png'),
                ),
                Text(
                  'จัดการรายชื่อ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click listUser');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListUser(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget ManageQA() {
    // all product
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      width: 150.0,
      height: 150.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/q-a.png'),
                ),
                Text(
                  'ถาม-ตอบ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click listUser');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListFaq(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget LogoutBox() {
    // losesale
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      width: 150.0,
      height: 150.0,

      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_logout.png'),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click square logout');
          logOut();
        },
      ),
    );
  }

  Widget LogoutAdminBox() {
    // losesale
    return Container(
      // width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      width: 150.0,
      height: 150.0,

      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 70.0,
                  child: Image.asset('images/icon_logout_admin.png'),
                ),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click square logout');
          logOut();
        },
      ),
    );
  }

  Widget row1Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Complainbox(),
        ViewQA(),
        LogoutBox(),
      ],
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 10.0,
    );
  }

  Widget homeMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      // color: Colors.green.shade50,
      // height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          row1Menu(),
          mySizebox(),
        ],
      ),
    );
  }

  Widget row1MenuAdmin() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ManageComplain(),
        ManageCategorybox(),
        ManageUserbox(),
        ManageQA(),
        LogoutAdminBox(),
      ],
    );
  }

  Widget adminMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      // color: Colors.green.shade50,
      // height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          row1MenuAdmin(),
          mySizebox(),
          // row2MenuAdmin(),
          mySizebox(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          headTitle('ข้อมูลของคุณ', Icons.verified_user),
          profileBox(),
          //    headTitle('Seggest Item',Icons.thumb_up),
          //  suggest(),
          headTitle('เมนู', Icons.home),
          homeMenu(),

          headTitle('ผู้ดูแลระบบ', Icons.admin_panel_settings),
          adminMenu(),

          // headTitle('ข่าวสาร', Icons.bookmark),
          // newsBox(),
        ],
      ),
    );
  }

  Widget headTitle(String string, IconData iconData) {
    // Widget  แทน object ประเภทไดก็ได้
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            size: 24.0,
            color: MyStyle().textColor,
          ),
          mySizebox(),
          Text(
            string,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyStyle().textColor,
            ),
          ),
        ],
      ),
    );
  }
}
