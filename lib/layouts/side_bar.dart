import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:io';
import 'package:yrusv/main.dart';
import 'package:yrusv/models/user_model.dart';
// import 'package:easy_sidemenu/easy_sidemenu.dart';
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
import 'package:yrusv/pages/changepassword.dart';

import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_problem.dart';
import 'package:yrusv/pages/list_report_dept_support.dart';
import 'package:yrusv/pages/list_report_mysupport.dart';

class SideBar extends StatefulWidget {
  final UserModel userModel;
  final int curSelectMenu;

  SideBar({Key key, this.userModel, this.curSelectMenu}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  UserModel myUserModel;
  PageController page = PageController();
  int selectedIndex;
  int currentcSelectMenu;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    currentcSelectMenu = widget.curSelectMenu;
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // exit(0);
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyApp();
    });

    html.window.location.href =
        "https://app.oss.yru.ac.th/yrusv/api/yrupassport-logout.php"; // or any website your want

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
  // int selectedIndexStaff = 0;

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
          selectedIndex: currentcSelectMenu,
          items: (myUserModel.level == 1 || myUserModel.level == 2)
              ? const [
                  SideNavigationBarItem(
                    icon: Icons.dashboard,
                    label: 'หน้าหลัก',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.checklist,
                    label: 'รายการขอใช้บริการ',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.playlist_add_check,
                    label: 'รายงาน',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.question_answer,
                    label: 'รายการถาม-ตอบ',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.password,
                    label: 'เปลี่ยนรหัสผ่าน',
                  ),
                  // SideNavigationBarItem(
                  //   icon: Icons.source,
                  //   label: 'รายงานผู้รับผิดชอบ',
                  // ),
                  SideNavigationBarItem(
                    icon: Icons.logout,
                    label: 'ออกจากระบบ',
                  ),
                ]
              : const [
                  SideNavigationBarItem(
                    icon: Icons.dashboard,
                    label: 'หน้าหลัก',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.checklist,
                    label: 'รายการขอใช้บริการ',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.playlist_add_check,
                    label: 'รายงาน',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.question_answer,
                    label: 'รายการถาม-ตอบ',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.password,
                    label: 'เปลี่ยนรหัสผ่าน',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.logout,
                    label: 'ออกจากระบบ',
                  ),
                ],
          onTap: (indexTabST) {
            // print('indexTabST menu >> $indexTabST');
            if (myUserModel.level == 1 || myUserModel.level == 2) {
              if (indexTabST == 0) {
                Navigator.of(context).pushNamed(Home.route);
              } else if (indexTabST == 1) {
                Navigator.of(context).pushNamed(ListComplain.route);
              } else if (indexTabST == 2) {
                Navigator.of(context).pushNamed(ListReportMySupport.route);
              } else if (indexTabST == 3) {
                Navigator.of(context).pushNamed(ListFaq.route);
              } else if (indexTabST == 4) {
                Navigator.of(context).pushNamed(ChangePassword.route);
              } else if (indexTabST == 5) {
                Navigator.of(context).pushNamed(ListReportSelectDept.route);
              } else if (indexTabST == 6) {
                logOut();
              }
            } else {
              if (indexTabST == 0) {
                Navigator.of(context).pushNamed(Home.route);
              } else if (indexTabST == 1) {
                Navigator.of(context).pushNamed(ListComplain.route);
              } else if (indexTabST == 2) {
                Navigator.of(context).pushNamed(ListReportMySupport.route);
              } else if (indexTabST == 3) {
                Navigator.of(context).pushNamed(ListFaq.route);
              } else if (indexTabST == 4) {
                Navigator.of(context).pushNamed(ChangePassword.route);
              } else if (indexTabST == 5) {
                logOut();
              }
            }
          },
          theme: SideNavigationBarTheme(
            itemTheme: const SideNavigationBarItemTheme(
                unselectedItemColor: Colors.black,
                selectedItemColor: Color.fromARGB(255, 128, 19, 0),
                // iconSize: 32.5,
                labelTextStyle: TextStyle(
                    fontSize: 16,
                    // !! Won't work !! Custom text style colors gets overridden
                    // by unselectedItemColor and selectedItemColor
                    color: Colors.black)),
            togglerTheme: SideNavigationBarTogglerTheme.standard(),
            dividerTheme: SideNavigationBarDividerTheme.standard(),
          ),
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
  final int curSelectMenu;

  AdminSideBar({Key key, this.userModel, this.curSelectMenu}) : super(key: key);

  @override
  _AdminSideBarState createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
  UserModel myUserModel;
  PageController page = PageController();
  int selectedIndex;
  int currentcSelectMenu;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    currentcSelectMenu = widget.curSelectMenu;
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
    html.window.location.href =
        "https://app.oss.yru.ac.th/yrusv/api/yrupassport-logout.php"; // or any website your want

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
    Center(
      child: Text('ออกจากระบบ'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // selectedIndex =
    //     (selectedIndex == null || selectedIndex == 0) ? 0 : selectedIndex;

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
          selectedIndex: currentcSelectMenu,
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
              icon: Icons.playlist_add_check,
              label: 'รายงาน',
            ),
            SideNavigationBarItem(
              icon: Icons.question_answer,
              label: 'รายการถาม-ตอบ',
            ),
            SideNavigationBarItem(
              icon: Icons.password,
              label: 'เปลี่ยนรหัสผ่าน',
            ),
            // SideNavigationBarItem(
            //   icon: Icons.source,
            //   label: 'รายงานผู้รับผิดชอบ',
            // ),
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
              icon: Icons.group_work,
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
          onTap: (indexTab) {
            if (indexTab == 0) {
              Navigator.of(context).pushNamed(Home.route);
            } else if (indexTab == 1) {
              Navigator.of(context).pushNamed(ListComplain.route);
            } else if (indexTab == 2) {
              Navigator.of(context).pushNamed(ListReportMySupport.route);
            } else if (indexTab == 3) {
              Navigator.of(context).pushNamed(ListFaq.route);
            } else if (indexTab == 4) {
              Navigator.of(context).pushNamed(ChangePassword.route);
            } else if (indexTab == 5) {
              Navigator.of(context).pushNamed(ListReportDept.route);
            } else if (indexTab == 6) {
              Navigator.of(context).pushNamed(ListComplainAdmin.route);
            } else if (indexTab == 7) {
              Navigator.of(context).pushNamed(ListDept.route);
            } else if (indexTab == 8) {
              Navigator.of(context).pushNamed(ListProblem.route);
            } else if (indexTab == 9) {
              Navigator.of(context).pushNamed(ListUser.route);
            } else if (indexTab == 10) {
              Navigator.of(context).pushNamed(ListFaq.route);
            } else if (indexTab == 11) {
              logOut();
            }
          },
          theme: SideNavigationBarTheme(
            itemTheme: const SideNavigationBarItemTheme(
                unselectedItemColor: Colors.black,
                selectedItemColor: Color.fromARGB(255, 128, 19, 0),
                // iconSize: 32.5,
                labelTextStyle: TextStyle(
                    fontSize: 16,
                    // !! Won't work !! Custom text style colors gets overridden
                    // by unselectedItemColor and selectedItemColor
                    color: Colors.black)),
            togglerTheme: SideNavigationBarTogglerTheme.standard(),
            dividerTheme: SideNavigationBarDividerTheme.standard(),
          ),
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
