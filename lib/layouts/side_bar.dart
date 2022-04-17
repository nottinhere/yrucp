import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:yrusv/models/menu_item.dart';
// import 'package:yrusv/providers/app_controller.dart';
// import 'package:yrusv/widgets/side_bar_menu_item.dart';
// import 'package:yrusv/widgets/workspace_item.dart';
// import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
// import 'package:get/get.dart';
// import '../constants.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/pages/my_service.dart';
import 'package:yrusv/pages/list_complain.dart';
import 'package:yrusv/pages/list_complain_admin.dart';
import 'package:yrusv/pages/list_faq.dart';
import 'package:yrusv/pages/list_staff.dart';
import 'package:yrusv/pages/list_department.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatefulWidget {
  final UserModel userModel;

  SideBar({Key key, this.userModel}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  UserModel myUserModel;
  // PageController page = PageController();

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideMenu(
          // controller: page,
          style: SideMenuStyle(
            displayMode: SideMenuDisplayMode.auto,
            hoverColor: Colors.blue[100],
            selectedColor: Colors.lightBlue,
            selectedTitleTextStyle: TextStyle(color: Colors.white),
            selectedIconColor: Colors.white,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.all(Radius.circular(10)),
            // ),
            // backgroundColor: Colors.blueGrey[700]
          ),
          title: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 70,
                  maxWidth: 70,
                ),
                child: Image.asset(
                  'images/logo_master.png',
                ),
              ),
              Text('คุณ : ${myUserModel.personName}'),
              Text('แผนก : ${myUserModel.department}'),
              Divider(
                indent: 8.0,
                endIndent: 8.0,
              ),
            ],
          ),
          footer: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'YRU service',
              style: TextStyle(fontSize: 15),
            ),
          ),
          items: [
            // SideMenuItem(
            //   priority: 0,
            //   title: 'Dashboard',
            //   onTap: () {},
            //   icon: Icon(Icons.home),
            //   badgeContent: Text(
            //     '3',
            //     style: TextStyle(color: Colors.white),
            //   ),
            // ),
            SideMenuItem(
              priority: 1,
              title: 'หน้าหลัก',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return MyService(
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).pushAndRemoveUntil(
                    materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
                    (Route<dynamic> route) {
                  return false;
                });
              },
              icon: Icon(Icons.home),
            ),
            SideMenuItem(
              priority: 1,
              title: 'รายการขอใช้บริการ',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListComplain(
                    index: 0,
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.supervisor_account),
            ),
            SideMenuItem(
              priority: 2,
              title: 'รายการถาม-ตอบ',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListFaq(
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.file_copy_rounded),
            ),
            SideMenuItem(
              priority: 3,
              title: 'จัดการคำขอบริการ',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListComplainAdmin(
                    index: 0,
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.download),
            ),
            SideMenuItem(
              priority: 4,
              title: 'จัดการแผนก',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListDept(
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.settings),
            ),
            SideMenuItem(
              priority: 5,
              title: 'จัดการรายชื่อ',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListUser(
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.settings),
            ),
            SideMenuItem(
              priority: 6,
              title: 'จัดการข้อมูลถาม-ตอบ',
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListFaq(
                    userModel: myUserModel,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              icon: Icon(Icons.settings),
            ),
            SideMenuItem(
              priority: 7,
              title: 'ออกจากระบบ',
              onTap: () async {
                logOut();
              },
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ],
    );
  }
}
