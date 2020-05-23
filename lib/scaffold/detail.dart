import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptnsupplier/models/product_all_model.dart';
import 'package:ptnsupplier/models/user_model.dart';
import 'package:ptnsupplier/scaffold/detail_cart.dart';
import 'package:ptnsupplier/utility/my_style.dart';
import 'package:ptnsupplier/utility/normal_dialog.dart';

class Detail extends StatefulWidget {
  final ProductAllModel productAllModel;
  final UserModel userModel;

  Detail({Key key, this.productAllModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Explicit
  ProductAllModel currentProductAllModel;
  ProductAllModel productAllModel;
  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID

  String txtdeal = '', txtfree = '', txtprice = '', txtnote = '';
  String memberID;

  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      getProductWhereID();
      readCart();
    });
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel != null) {
      id = currentProductAllModel.id.toString();
      String url = '${MyStyle().getProductWhereId}$id';
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      print('result = $result');

      var itemProducts = result['itemsProduct'];
      for (var map in itemProducts) {
        print('map = $map');

        setState(() {
          productAllModel = ProductAllModel.fromJson(map);

          Map<String, dynamic> priceListMap = map['price_list'];
        });
      } // for
    }
  }

  Widget showTitle() {
    return Text(
      productAllModel.title,
      style: TextStyle(
        fontSize: 19.0,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(0xff, 56, 80, 82),
      ),
    );
  }

  Widget showImage() {
    return Card(
      child: Container(
        // width: MediaQuery.of(context).size.width * 1.00,
        padding: new EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'Code :' + productAllModel.productCode,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                  'Stock : ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    // color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
                Text(
                  productAllModel.percentStock + '%',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    // color: Color.fromARGB(0xff, 16, 149, 161),
                  ),
                ),
              ],
            ),
            Image.network(
              productAllModel.emotical,
              width: MediaQuery.of(context).size.width * 0.16,
            ),
          ],
        ),
      ),
    );
  }

  Widget showStock() {
    return Card(
      child: Container(
        // width: MediaQuery.of(context).size.width * 1.00,
        padding: new EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Icon(Icons.restaurant, color: Colors.green[500]),
                Text('ขาย/เดือน'),
                Text(
                  productAllModel.cMin,
                  style: TextStyle(
                    fontSize: 19.0,
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
                  productAllModel.sumStock,
                  style: TextStyle(
                    fontSize: 19.0,
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
                  productAllModel.unitOrderShow,
                  style: TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dealBox() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,
      width: MediaQuery.of(context).size.width * 0.45,
      padding: EdgeInsets.only(left: 10.0, right: 20.0),
      child: Column(
        children: <Widget>[
          Text('ดึล :'),
          TextFormField(
            style: TextStyle(color: Colors.black),
            initialValue:
                productAllModel.dealOrder.toString(), // set default value
            keyboardType: TextInputType.number,
            onChanged: (string) {
              txtdeal = string.trim();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.0,
              ),
              prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
              //border: InputBorder.none,
              hintText: 'ดึล',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget freeBox() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,
      width: MediaQuery.of(context).size.width * 0.45,
      padding: EdgeInsets.only(left: 20.0, right: 10.0),
      child: Column(
        children: <Widget>[
          Text('แถม :'),
          TextFormField(
            style: TextStyle(color: Colors.black),
            initialValue:
                productAllModel.freeOrder.toString(), // set default value
            keyboardType: TextInputType.number,
            onChanged: (string) {
              txtfree = string.trim();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.0,
              ),
              prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
              // border: InputBorder.none,
              hintText: 'แถม',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget priceBox() {
    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,
      width: MediaQuery.of(context).size.width * 0.45,
      padding: EdgeInsets.only(left: 10.0, right: 20.0),
      child: Column(
        children: <Widget>[
          Text('ราคา :'),
          TextFormField(
            style: TextStyle(color: Colors.black),
            initialValue: productAllModel.priceOrder, // set default value
            keyboardType: TextInputType.number,
            onChanged: (string) {
              txtprice = string.trim();
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.0,
              ),
              prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
              // border: InputBorder.none,
              hintText: 'ราคา',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget noteBox() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextField(
        onChanged: (value) {
          txtnote = value.trim();
        },
        keyboardType: TextInputType.multiline,
        maxLines: 2,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
            labelText: 'Note :'),
      ),
    );
  }

  Widget showFormDeal() {
    return Card(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              dealBox(),
              freeBox(),
            ],
          ),
          Row(
            children: <Widget>[
              priceBox(),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  children: <Widget>[
                    Text('ราคาขาย'),
                    Text(
                      productAllModel.priceSale +
                          '/' +
                          productAllModel.unitOrderShow,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(0xff, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          noteBox(),
          //  Row(children: <Widget>[priceBox(),priceBox(),],),
          //  Row(children: <Widget>[noteBox()],),
        ],
      ),
    );
  }

  Future<void> submitThread() async {
    try {
      var medID = currentProductAllModel.id;
      String url =
          'http://ptnpharma.com/apisupplier//json_submit_deal.php?memberId=$memberID&medId=$medID&deal_order=$txtdeal&free_order=$txtfree&price_order=$txtprice&note=$txtnote'; //'';

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
            title: Text('Complete'),
            content: Text('แก้ไขดีลเรียบร้อย'),
            actions: <Widget>[
              FlatButton(
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
          child: RaisedButton(
            color: Color.fromARGB(0xff, 13, 163, 93),
            onPressed: () {
              memberID = myUserModel.id.toString();
              var medID = currentProductAllModel.id;
              print(
                  'memberId=$memberID&medId=$medID&deal_order=$txtdeal&free_order=$txtfree&price_order=$txtprice&note=$txtnote');

              submitThread();
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget showPackage(int index) {
    return Text(productAllModel.unitOrderShow);
  }

  Widget showChoosePricePackage(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        showDetailPrice(index),
        // incDecValue(index),
      ],
    );
  }

  Widget showDetailPrice(int index) {
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
          return showChoosePricePackage(index); // showDetailPrice(index);
        },
      ),
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnsupplier.com/api/json_loadmycart.php?memberId=$memberId';

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
          //showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('แก้ไขข้อมูลสต๊อก'),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget addButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: Colors.lightGreen,
                child: Text(
                  'Update deal',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String productID = id;
                  String memberID = myUserModel.id.toString();

                  int index = 0;
                  List<bool> status = List();

                  bool sumStatus = true;
                  if (status.length == 1) {
                    sumStatus = status[0];
                  } else {
                    sumStatus = status[0] && status[1];
                  }

                  if (sumStatus) {
                    normalDialog(
                        context, 'Do not choose item', 'Please choose item');
                  } else {}
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> addCart(
      String productID, String unitSize, int qTY, String memberID) async {
    String url =
        'http://ptnsupplier.com/api/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberID=$memberID';

    http.Response response = await http.get(url).then((response) {
      print('upload ok');
      readCart();
      MaterialPageRoute materialPageRoute =
          MaterialPageRoute(builder: (BuildContext buildContext) {
        return DetailCart(
          userModel: myUserModel,
        );
      });
      Navigator.of(context).push(materialPageRoute);
    });
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
        showTitle(),
        showImage(),
        showStock(),
        showFormDeal(),
        submitButton(),
        //showPrice(),
      ],
    );
  }
}
