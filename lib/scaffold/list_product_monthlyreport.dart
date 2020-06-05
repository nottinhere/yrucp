import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptnsupplier/models/product_report_model.dart';
import 'package:ptnsupplier/models/user_model.dart';
import 'package:ptnsupplier/utility/my_style.dart';

// import 'detail_view.dart';
// import 'detail_cart.dart';

class ListProductReport extends StatefulWidget {
  final int index;
  final UserModel userModel;
  ListProductReport({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListProductState createState() => _ListProductState();
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

class _ListProductState extends State<ListProductReport> {
  // Explicit
  int myIndex;
  List<ProductReportModel> productReportModel = List(); // set array
  List<ProductReportModel> filterProductReportModel = List();
  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';
  String totalPrice = '';
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
      // readCart();
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
        //   if (amountListView > filterProductReportModel.length) {
        //     amountListView = filterProductReportModel.length;
        //   }
        // });
      }
    });
  }

  Future<void> readData() async {
    // String url = MyStyle().readAllProduct;
    int memberId = myUserModel.id;
    String url =
        'http://ptnpharma.com/apisupplier/json_product_monthlyreport.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // if (myIndex != 0) {
    //   url = '${MyStyle().readProductWhereMode}$myIndex';
    // }

    http.Response response = await http.get(url);
    print('url readData ##################+++++++++++>>> $url');
    var result = json.decode(response.body);
    // print('result = $result');
    // print('url ListProduct ====>>>> $url');
    // print('result ListProduct ========>>>>> $result');

    var itemProducts = result['itemsProduct'];

    for (var map in itemProducts) {
      ProductReportModel productAllModel = ProductReportModel.fromJson(map);
      setState(() {
        productReportModel.add(productAllModel);
        filterProductReportModel = productReportModel;
      });
    }

    setState(() {
      totalPrice = result['totalPrice'];
    });
  }

  Widget showPercentStock(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Code : ' + filterProductReportModel[index].code,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
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
          width: MediaQuery.of(context).size.width * 0.90, //0.7 - 50,
          child: Text(
            filterProductReportModel[index].name,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showReport(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            // Icon(Icons.timer, color: Colors.green[500]),
            Text('ขายออก'),
            Text(
              filterProductReportModel[index].approveValue,
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
            Text('ไม่่จัดส่ง'),
            Text(
              filterProductReportModel[index].rejectValue,
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
            Text('ดำเนินการ'),
            Text(
              filterProductReportModel[index].waitValue,
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
            Text('หน่วย'),
            Text(
              filterProductReportModel[index].unit +
                  '(' +
                  filterProductReportModel[index].subtract +
                  ')',
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

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 5.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width *
          0.95, // MediaQuery.of(context).size.width * 0.80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showPercentStock(index),
          showName(index),
          showReport(index),
          // showDeal(index),
        ],
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          //
          color: Colors.greenAccent.shade200,
          width: 3.0,
        ),
        bottom: BorderSide(
          //
          color: Colors.greenAccent.shade200,
          width: 3.0,
        ),
      ),
    );
  }

  Widget showProductItem() {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productReportModel.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  EdgeInsets.only(top: 3.0, bottom: 3.0, left: 6.0, right: 6.0),
              child: Card(
                // color: Color.fromRGBO(235, 254, 255, 1.0),

                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      showText(index),
                      // showImage(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {},
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

  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
      child: ListTile(
        trailing: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print('searchString ===>>> $searchString');
              setState(() {
                page = 1;
                productReportModel.clear();
                readData();
              });
            }),
        title: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: 'Search'),
          onChanged: (String string) {
            searchString = string.trim();
          },
        ),
      ),
    );
  }

  Widget selectMonthButton() {
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
              productReportModel.clear();
              readData();
            });
          }),
    );
  }

  Widget showContent() {
    return filterProductReportModel.length == 0
        ? showProductItem() // showProgressIndicate()
        : showProductItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().barColor, //Colors.yellow.shade700,
        title: Text('สรุปการขายต่อเดือน'),
        actions: <Widget>[
          //  showCart(),
        ],
      ),
      // body: filterProductReportModel.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Column(
        children: <Widget>[
          selectMonthButton(),
          searchForm(),
          showContent(),
        ],
      ),
    );
  }
}
