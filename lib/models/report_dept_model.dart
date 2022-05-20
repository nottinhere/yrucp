class ReportDeptModel {
  String dept;
  String deptName;
  String code;
  String countjob;

  ReportDeptModel({this.dept, this.deptName, this.code, this.countjob});

  ReportDeptModel.fromJson(Map<String, dynamic> json) {
    dept = json['dept'];
    deptName = json['deptName'];
    code = json['code'];
    countjob = json['countjob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
    data['code'] = this.code;
    data['countjob'] = this.countjob;
    return data;
  }
}
