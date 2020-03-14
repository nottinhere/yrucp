import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ptnsupplier/models/promote_model.dart';
import 'package:ptnsupplier/models/user_model.dart';
import 'package:ptnsupplier/scaffold/list_product.dart';

class Home extends StatefulWidget {

  final UserModel userModel;
  Home ({Key key,this.userModel}):super(key:key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  List<Widget> promoteLists = List();
  List<String> urlImages = List();
  UserModel myUserModel;

  // Method
  @override
  void initState() {
    super.initState();
    readPromotion();
    myUserModel = widget.userModel;
  }

  Future<void> readPromotion() async {
    String url = 'http://www.ptnpharma.com/apisupplier/json_promotion.php';
    Response response = await get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      String urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        promoteLists.add(Image.network(urlImage));
        urlImages.add(urlImage);
      });
    }
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showCarouseSlider() {
    return CarouselSlider(
      enlargeCenterPage: true,
      aspectRatio: 16 / 9,
      pauseAutoPlayOnTouch: Duration(seconds: 5),
      autoPlay: true,
      autoPlayAnimationDuration: Duration(seconds: 5),
      items: promoteLists,
    );
  }

  Widget promotion() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      height: MediaQuery.of(context).size.height * 0.25,
      child:
          promoteLists.length == 0 ? myCircularProgress() : showCarouseSlider(),
    );
  }

  Widget suggest() {
    return Container(
      color: Colors.grey.shade400,
      height: MediaQuery.of(context).size.height * 0.25,
      child:
          promoteLists.length == 0 ? myCircularProgress() : showCarouseSlider(),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        //userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget topLeft() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Promotion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
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

  Widget topRight() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'New Product',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click newproduct');
          routeToListProduct(1);
        },
      ),
    );
  }

  Widget bottomLeft() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Update Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click updateprice');
          routeToListProduct(2);
        },
      ),
    );
  }

  Widget bottomRight() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Recommend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click recommend');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget productMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'recommend',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click recommend');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget bottomMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bottomLeft(),
        bottomRight(),
      ],
    );
  }

  Widget topMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        topLeft(),
        topRight(),
      ],
    );
  }

  Widget homeMenu() {
    return Container(
     margin: EdgeInsets.only(top: 20.0),
     alignment: Alignment(0.0, 0.0),
      color: Colors.grey.shade50,
      height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          topMenu(),
          bottomMenu(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Text(
            'Promotion today',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          promotion(),
          //  suggest(),
          //  homeMenu(),
          homeMenu(),
        ],
      ),
    );
  }
}
