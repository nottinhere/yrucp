import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:yrusv/models/user_model.dart';
import 'package:yrusv/widgets/home.dart';

import 'package:yrusv/pages/list_complain.dart';
import 'package:yrusv/pages/list_report_mysupport.dart';
import 'package:yrusv/pages/list_faq.dart';
import 'package:yrusv/pages/changepassword.dart';

import 'package:yrusv/pages/list_complain_admin.dart';
import 'package:yrusv/pages/list_department.dart';
import 'package:yrusv/pages/list_problem.dart';
import 'package:yrusv/pages/list_staff.dart';
import 'package:yrusv/pages/detail.dart';

import 'package:yrusv/pages/list_report_support.dart';
import 'package:yrusv/pages/list_report_problem.dart';
import 'package:yrusv/pages/list_report_staff.dart';
import 'package:yrusv/pages/list_report_request.dart';
import 'package:yrusv/pages/list_report_rating.dart';
import 'package:yrusv/pages/list_comment.dart';

import 'package:yrusv/pages/list_report_dept_support.dart';
import 'package:yrusv/pages/list_report_dept_rating.dart';

import 'package:yrusv/pages/faq_add.dart';
import 'package:yrusv/pages/department_add.dart';
import 'package:yrusv/pages/problem_add.dart';
import 'package:yrusv/pages/staff_add.dart';

void main() {
  runApp(RoutePage());
}

class RoutePage extends StatefulWidget {
  final UserModel userModel;
  final String gotoURL;

  const RoutePage({Key key, this.userModel, this.gotoURL}) : super(key: key);

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  UserModel myUserModel;
  String initialURL;
  // Method
  @override
  void initState() {
    super.initState(); // จะทำงานก่อน build
    setState(() {
      myUserModel = widget.userModel;
      initialURL = widget.gotoURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialURL != '/' ? initialURL : Home.route,
      routes: {
        Home.route: (context) => Home(
              userModel: myUserModel,
            ),
        ListComplain.route: (context) => ListComplain(
              index: (myUserModel.level == 1)
                  ? 0
                  : (myUserModel.level == 2)
                      ? 2
                      : 4,
              userModel: myUserModel,
            ),
        ListReportMySupport.route: (context) => ListReportMySupport(
              index: 0,
              userModel: myUserModel,
            ),
        ListFaq.route: (context) => ListFaq(
              userModel: myUserModel,
            ),
        ChangePassword.route: (context) => ChangePassword(
              userModel: myUserModel,
            ),
        ListComplainAdmin.route: (context) => ListComplainAdmin(
              index: 0,
              userModel: myUserModel,
            ),
        ListDept.route: (context) => ListDept(
              userModel: myUserModel,
            ),
        ListProblem.route: (context) => ListProblem(
              userModel: myUserModel,
            ),
        ListUser.route: (context) => ListUser(
              userModel: myUserModel,
            ),
        ListReportDept.route: (context) => ListReportDept(
              index: 0,
              userModel: myUserModel,
            ),
        ListReportProblemDept.route: (context) => ListReportProblemDept(
              index: 1,
              userModel: myUserModel,
            ),
        ListReportStaff.route: (context) => ListReportStaff(
              index: 2,
              userModel: myUserModel,
            ),
        ListReportReqDept.route: (context) => ListReportReqDept(
              index: 3,
              userModel: myUserModel,
            ),
        ListReportRatingDept.route: (context) => ListReportRatingDept(
              index: 4,
              userModel: myUserModel,
            ),
        ListComment.route: (context) => ListComment(
              index: 5,
              userModel: myUserModel,
            ),
        ListReportSelectDept.route: (context) => ListReportSelectDept(
              index: 0,
              userModel: myUserModel,
            ),
        ListReportRatingSelectDept.route: (context) =>
            ListReportRatingSelectDept(
              index: 1,
              userModel: myUserModel,
            ),
        AddFaq.route: (context) => AddFaq(
              userModel: myUserModel,
            ),
        AddDept.route: (context) => AddDept(
              userModel: myUserModel,
            ),
        AddProb.route: (context) => AddProb(
              userModel: myUserModel,
            ),
        AddUser.route: (context) => AddUser(
              userModel: myUserModel,
            ),
        // Detail.route: (context) => Detail(
        //       complainAllModel: complainAllModel,
        //       userModel: myUserModel,
        //     ),
      },
      // onGenerateRoute: (settings) {
      //   if (settings.name == Detail.route) {
      //     Map<String, dynamic> args =
      //         new Map<String, dynamic>.from(settings.arguments);
      //     return MaterialPageRoute(
      //         builder: (_) => Detail(
      //               complainAllModel: args['complainAllModel'],
      //               userModel: myUserModel,
      //             )); // Pass it to BarPage.

      //   }
      //   return null; // Let `onUnknownRoute` handle this behavior.
      // },
    );
  }
}
