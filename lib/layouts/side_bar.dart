import 'package:flutter/material.dart';
import 'dart:io';
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
import 'package:side_navigation/side_navigation.dart';

class SideBar extends StatefulWidget {
  final UserModel userModel;

  SideBar({Key key, this.userModel}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  UserModel myUserModel;
  PageController page = PageController();

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

  List<Widget> views = const [
    Center(
      child: Text('หน้าหลัก'),
    ),
    Center(
      child: Text('รายการขอใช้บริการ'),
    ),
    Center(
      child: Text('รายการถาม-ตอบ'),
    ),
    Center(
      child: Text('จัดการคำขอบริการ'),
    ),
    Center(
      child: Text('จัดการแผนก'),
    ),
    Center(
      child: Text('จัดการรายชื่อ'),
    ),
    Center(
      child: Text('จัดการข้อมูลถาม-ตอบ'),
    ),
    Center(
      child: Text('ออกจากระบบ'),
    ),
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideNavigationBar(
          // selectedIndex: selectedIndex,
          items: const [
            SideNavigationBarItem(
              icon: Icons.dashboard,
              label: 'หน้าหลัก',
            ),
            SideNavigationBarItem(
              icon: Icons.checklist,
              label: 'รายการขอใช้บริการ',
            ),
            SideNavigationBarItem(
              icon: Icons.question_answer,
              label: 'รายการถาม-ตอบ',
            ),
            SideNavigationBarItem(
              icon: Icons.check_circle_outline,
              label: 'จัดการคำขอบริการ',
            ),
            SideNavigationBarItem(
              icon: Icons.group,
              label: 'จัดการแผนก',
            ),
            SideNavigationBarItem(
              icon: Icons.person_outline_rounded,
              label: 'จัดการรายชื่อ',
            ),
            SideNavigationBarItem(
              icon: Icons.question_answer_outlined,
              label: 'จัดการข้อมูลถาม-ตอบ',
            ),
            SideNavigationBarItem(
              icon: Icons.logout,
              label: 'ออกจากระบบ',
            ),
          ],
          onTap: (index) {
            print('index mwnu >> $index');
            if (index == 0) {
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
            } else if (index == 1) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListComplain(
                  index: 0,
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 2) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListFaq(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 3) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListComplainAdmin(
                  index: 0,
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 4) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListDept(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 5) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListUser(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 6) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListFaq(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 7) {
              logOut();
            }
          },
        ),

        /// Make it take the rest of the available width
        // Expanded(
        //   child: views.elementAt(selectedIndex),
        // ),
      ],
    );
  }
}
