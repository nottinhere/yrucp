import 'package:flutter/material.dart';
import 'dart:io';
import 'package:yrusv/main.dart';
import 'package:yrusv/models/user_model.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/widgets/home.dart';
import 'package:yrusv/pages/my_service.dart';
import 'package:yrusv/pages/list_complain.dart';
import 'package:yrusv/pages/list_complain_admin.dart';
import 'package:yrusv/pages/list_faq.dart';
import 'package:yrusv/pages/list_staff.dart';
import 'package:yrusv/pages/list_department.dart';
import 'package:yrusv/pages/list_problem.dart';
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
    print('$myUserModel');
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // exit(0);
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyApp();
    });
    // Navigator.of(context).push(materialPageRoute);
    // exit(0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
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
      child: Text('ออกจากระบบ'),
    ),
    Center(
      child: Text('------'),
    ),
    Center(
      child: Text('xxx'),
    ),
    Center(
      child: Text('123456'),
    ),
  ];
  int selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideNavigationBar(
          header: SideNavigationBarHeader(
              image: CircleAvatar(
                child: Image.asset('images/logo.png'),
              ),
              title: Text(myUserModel.personName),
              subtitle: Text('(${myUserModel.levelName}) ' +
                  ' ${myUserModel.departmentName} ')),
          selectedIndex: selectedIndex,
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
              icon: Icons.checklist,
              label: 'รายงาน',
            ),
            SideNavigationBarItem(
              icon: Icons.question_answer,
              label: 'รายการถาม-ตอบ',
            ),
            SideNavigationBarItem(
              icon: Icons.checklist,
              label: 'เปลี่ยนรหัสผ่าน',
            ),
            SideNavigationBarItem(
              icon: Icons.logout,
              label: 'ออกจากระบบ',
            ),
          ],
          onTap: (index) {
            // print('index mwnu >> $index');
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
                  index: (myUserModel.level == 2) ? 2 : 4,
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

/************************************************ */

class AdminSideBar extends StatefulWidget {
  final UserModel userModel;

  AdminSideBar({Key key, this.userModel}) : super(key: key);

  @override
  _AdminSideBarState createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
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
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));

    exit(0);
    // MaterialPageRoute materialPageRoute =
    //     MaterialPageRoute(builder: (BuildContext buildContext) {
    //   return MyApp();
    // });
    // Navigator.of(context).push(materialPageRoute);
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
      child: Text('รายงานสรุป'),
    ),
    Center(
      child: Text('จัดการคำขอ'),
    ),
    Center(
      child: Text('จัดการผู้รับผิดชอบ'),
    ),
    Center(
      child: Text('จัดการประเภทงาน'),
    ),
    Center(
      child: Text('จัดการข้อมูลรายชื่อ'),
    ),
    Center(
      child: Text('จัดการข้อมูลถาม-ตอบ'),
    ),
    // Center(
    //   child: Text('ออกจากระบบ'),
    // ),
  ];

  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SideNavigationBar(
          header: SideNavigationBarHeader(
              image: CircleAvatar(
                child: Image.asset('images/logo.png'),
              ),
              title: Text(myUserModel.personName),
              subtitle: Text('(${myUserModel.levelName}) ' +
                  ' ${myUserModel.departmentName} ')),
          selectedIndex: selectedIndex,
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
              icon: Icons.list_alt_outlined,
              label: 'รายงานสรุป',
            ),
            SideNavigationBarItem(
              icon: Icons.check_circle_outline,
              label: 'จัดการคำขอ',
            ),
            SideNavigationBarItem(
              icon: Icons.group,
              label: 'จัดการผู้รับผิดชอบ',
            ),
            SideNavigationBarItem(
              icon: Icons.group,
              label: 'จัดการประเภทงาน',
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
            print('index menu >> $index');
            if (index == 0) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return MyService(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);

              // Navigator.of(context).pushAndRemoveUntil(
              //     materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
              //     (Route<dynamic> route) {
              //   return false;
              // });
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
                return ListReportDept(
                  index: 0,
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 4) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListComplainAdmin(
                  index: 0,
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 5) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListDept(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 6) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListProblem(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 7) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListUser(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 8) {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return ListFaq(
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
            } else if (index == 9) {
              logOut();
            }
          },
        ),

        // Make it take the rest of the available width
        // Center(
        //   child: Expanded(
        //     child: views.elementAt(selectedIndex),
        //   ),
        // ),
      ],
    );
  }
}
