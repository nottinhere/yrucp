import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yrusv/models/product_all_model.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail.dart';
import 'detail_cart.dart';

class ListProduct extends StatefulWidget {
  final int index;
  final UserModel userModel;
  ListProduct({Key key, this.index, this.userModel}) : super(key: key);

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

class _ListProductState extends State<ListProduct> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // set array
  List<ProductAllModel> filterProductAllModels = List();
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

  Future<void> readData() async {
    // String url = MyStyle().readAllProduct;
    int memberId = myUserModel.id;
    String url =
        'http://ptnpharma.com/apisupplier/json_data_product.php?memberId=$memberId&searchKey=$searchString&page=$page&sort=$sort';
    if (myIndex != 0) {
      url = '${MyStyle().readProductWhereMode}$myIndex';
    }

    http.Response response = await http.get(url);
    // print('url readData ##################+++++++++++>>> $url');
    var result = json.decode(response.body);
    // // print('result = $result');
    // // print('url ListProduct ====>>>> $url');
    // // print('result ListProduct ========>>>>> $result');

    var itemProducts = result['itemsData'];

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      setState(() {
        productAllModels.add(productAllModel);
        filterProductAllModels = productAllModels;
      });
    }
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget promotionTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade400,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'โปรโมชัน',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click promotion');
          // routeToListProduct(2);
        },
      ),
    );
  }

  Widget updatepriceTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade400,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'จะปรับราคา',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click update price');
          // routeToListProduct(3);
        },
      ),
    );
  }

  Widget newproductTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade400,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สินค้าใหม่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click new item');
          // routeToListProduct(1);
        },
      ),
    );
  }

  Widget notreceiveTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blue.shade400,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สั่งแล้วไม่ได้รับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click not receive');
          // routeToListProduct(4);
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
                  filterProductAllModels[index].itemStatusText,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          // print('You click not receive');
          // routeToListProduct(4);
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
        SizedBox(
          width: 5.0,
          height: 8.0,
        ),
        filterProductAllModels[index].itemStatus != 1
            ? cancelTag(index)
            : Container(),
        (filterProductAllModels[index].promotion == 1 &&
                filterProductAllModels[index].itemStatus == 1)
            ? promotionTag()
            : Container(),
        (filterProductAllModels[index].newproduct == 1 &&
                filterProductAllModels[index].itemStatus == 1)
            ? newproductTag()
            : Container(),
        (filterProductAllModels[index].updateprice == 1 &&
                filterProductAllModels[index].itemStatus == 1)
            ? updatepriceTag()
            : Container(),
        SizedBox(
          width: 5.0,
          height: 8.0,
        )
      ],
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
                'Code : ' + filterProductAllModels[index].productCode,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 16, 149, 161),
                ),
              ),
              Text(
                'In stock : ' +
                    filterProductAllModels[index].percentStock +
                    '%',
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

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75, //0.7 - 50,
          child: Text(
            filterProductAllModels[index].title,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showStock(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            // Icon(Icons.restaurant, color: Colors.green[500]),
            Text('ขาย/เดือน'),
            Text(
              filterProductAllModels[index].cMin,
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
            Text('สต๊อก'),
            Text(
              filterProductAllModels[index].sumStock,
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
              filterProductAllModels[index].unitOrderShow,
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
      width: MediaQuery.of(context).size.width * 0.79,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          showPercentStock(index),
          showName(index),
          showTag(index),
          showStock(index)
        ],
      ),
    );
  }

  Widget showImage(int index) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5.0),
          width: MediaQuery.of(context).size.width * 0.06,
          child: Image.network(filterProductAllModels[index].emotical),
        ),
        Container(
          padding: EdgeInsets.all(5.0),
          // width: MediaQuery.of(context).size.width * 0.15,
          // child: Image.network(filterProductAllModels[index].photo),
          width: 50,
          height: 50,
          decoration: new BoxDecoration(
              image: new DecorationImage(
            fit: BoxFit.cover,
            alignment: FractionalOffset.topCenter,
            image: new NetworkImage(filterProductAllModels[index].photo),
          )),
        ),
      ],
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
        itemCount: productAllModels.length,
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
                      showImage(index),
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
              productAllModels.clear();
              readData();
            });
          },
        ),
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
              productAllModels.clear();
              readData();
            });
          }),
    );
  }

  Widget showContent() {
    return filterProductAllModels.length == 0
        ? showProductItem() // showProgressIndicate()
        : showProductItem();
  }

  Future<void> readCart() async {
    String memberId = myUserModel.id.toString();
    // print(memberId);
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
        backgroundColor: MyStyle().barColor,
        title: Text('รายการสินค้า'),
        actions: <Widget>[
          //  showCart(),
        ],
      ),
      // body: filterProductAllModels.length == 0
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
