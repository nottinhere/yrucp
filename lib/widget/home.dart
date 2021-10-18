import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptnsupplier/models/product_all_model.dart';
import 'package:ptnsupplier/models/promote_model.dart';
import 'package:ptnsupplier/models/user_model.dart';
import 'package:ptnsupplier/models/news_model.dart';

import 'package:ptnsupplier/scaffold/detail.dart';
import 'package:ptnsupplier/scaffold/list_product.dart';
import 'package:ptnsupplier/scaffold/list_product_outofstock.dart';
import 'package:ptnsupplier/scaffold/list_product_overstock.dart';
import 'package:ptnsupplier/scaffold/list_product_losesale.dart';
import 'package:ptnsupplier/scaffold/list_product_highdemand.dart';
import 'package:ptnsupplier/scaffold/list_product_monthlyreport.dart';
import 'package:ptnsupplier/scaffold/list_product_alert.dart';
import 'package:ptnsupplier/scaffold/detail_news.dart';
import 'package:ptnsupplier/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final UserModel userModel;

  Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  List<Widget> promoteLists = List();
  List<String> urlImages = List();
  List<String> urlImagesSuggest = List();

  int amontCart = 0, banerIndex = 0, suggessIndex = 0, newsIndex = 0;
  UserModel myUserModel;
  List<ProductAllModel> promoteModels = List();

  NewsModel newsModel;
  String imageNews = '';
  String subjectNews = '';

  // Method
  @override
  void initState() {
    super.initState();
    readPromotion();
    readNews();
    myUserModel = widget.userModel;
  }

  Future<void> readNews() async {
    String url = 'http://ptnpharma.com/apisupplier/json_supnewsdetail.php';
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemNews) {
      // PromoteModel promoteModel = PromoteModel.fromJson(map);
      NewsModel newsModel = NewsModel.fromJson(map);
      String urlImage = newsModel.photo;
      String subject = newsModel.subject;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง arra
        subjectNews = subject;
        imageNews = urlImage;
      });
    }
  }

  Future<void> readPromotion() async {
    String url = 'http://ptnpharma.com/apisupplier/json_promotion.php';
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        promoteModels.add(productAllModel);
        promoteLists.add(showImageNetWork(urlImage));
        urlImages.add(urlImage);
      });
    }
  }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showCarouseSlider() {
    return GestureDetector(
      onTap: () {
        print('You Click index is $banerIndex');

        MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => Detail(
              // productAllModel: promoteModels[banerIndex],
              ),
        );
        Navigator.of(context).push(route).then((value) {});
      },
      child: CarouselSlider(
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        pauseAutoPlayOnTouch: Duration(seconds: 5),
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 5),
        items: promoteLists,
        onPageChanged: (int index) {
          banerIndex = index;
          // print('index = $index');
        },
      ),
    );
  }

  Widget promotion() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      height: MediaQuery.of(context).size.height * 0.20,
      child:
          promoteLists.length == 0 ? myCircularProgress() : showCarouseSlider(),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget profileBox() {
    String login = myUserModel.subject;
    int loginStatus = myUserModel.status;

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
          print('You click profile');
          // routeToListProduct(0);
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
          print('You click product');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget outOfStockBox() {
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
                  'ขาดสต๊อก',
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
          print('You click out of stock');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductOutofstock(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget overStockBox() {
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
                  '้นสต๊อก',
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
          print('You click over stock');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductOverstock(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget loseSaleBox() {
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
                  'ไม่เคลื่อนไหว',
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
          print('You click over stock');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductLosesale(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget reportBox() {
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
                  'สรุปการขาย',
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
          print('You click monthly report');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductReport(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
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
          print('You click square logout');
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
          print('You click logout');
          logOut();
        },
      ),
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    exit(0);
  }

  Widget newsBox() {
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
            child: Column(
              children: <Widget>[
                Text(
                  subjectNews, // 'ผู้แทน : $login',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  width: 10.0,
                  height: 8.0,
                ),
                Image.network(
                  imageNews,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('This is News');
          // int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailNews(
              // index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget row1Left() {
    // all product
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
                  child: Image.asset('images/icon_drugs.png'),
                ),
                Text(
                  'รายการสินค้า',
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
          print('You click promotion');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget row1Right() {
    // outofstock
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
                  child: Image.asset('images/icon_outofstock.png'),
                ),
                Text(
                  'ขาดสต๊อก',
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
          print('You click newproduct');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductOutofstock(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget row2Left() {
    // overstock
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
                  child: Image.asset('images/icon_overstock3.png'),
                ),
                Text(
                  'ล้นสต๊อก',
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
          print('You click updateprice');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductOverstock(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget row2Right() {
    // losesale
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
                  child: Image.asset('images/icon_losesale.png'),
                ),
                Text(
                  'ไม่เคลื่อนไหว',
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
          print('You click recommend');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductLosesale(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  // Widget row3Left() {
  //   // all product
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.45,
  //     // height: 80.0,
  //     child: GestureDetector(
  //       child: Card(
  //         // color: Colors.green.shade100,
  //         child: Container(
  //           padding: EdgeInsets.all(16.0),
  //           alignment: AlignmentDirectional(0.0, 0.0),
  //           child: Column(
  //             children: <Widget>[
  //               Container(
  //                 width: 70.0,
  //                 child: Image.asset('images/icon_highdemand.png'),
  //               ),
  //               Text(
  //                 'ต้องการใช้งาน',
  //                 style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       onTap: () {
  //         print('You click promotion');
  //         MaterialPageRoute materialPageRoute =
  //             MaterialPageRoute(builder: (BuildContext buildContext) {
  //           return ListProductHighdemand(
  //             userModel: myUserModel,
  //           );
  //         });
  //         Navigator.of(context).push(materialPageRoute);
  //       },
  //     ),
  //   );
  // }

  Widget row3Left() {
    // overstock
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
                  child: Image.asset('images/icon_report.png'),
                ),
                Text(
                  'สรุปการขาย',
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
          print('You click monthly report');
          int index;
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductReport(
              index: index,
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget row3Right() {
    // losesale
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
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
          print('You click square logout');
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
        row1Left(),
        row1Right(),
      ],
    );
  }

  Widget row2Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row2Left(),
        row2Right(),
      ],
    );
  }

  Widget row3Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row3Left(),
        row3Right(),
      ],
    );
  }

  // Widget row4Menu() {
  //   return Row(
  //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     // mainAxisSize: MainAxisSize.max,
  //     mainAxisSize: MainAxisSize.min,
  //     children: <Widget>[
  //       // row4Left(),
  //       // row4Right(),
  //     ],
  //   );
  // }

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
          row2Menu(),
          mySizebox(),
          row3Menu(),
          mySizebox(),
          // row4Menu(),
          // logoutBox(),
          mySizebox(),
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
          headTitle('ข่าวสาร', Icons.bookmark),
          newsBox(),
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
