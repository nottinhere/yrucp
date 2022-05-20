class ReportDeptDetailModel {
  String staff;
  String dept;
  String deptName;
  String countjob;

  ReportDeptDetailModel({this.staff, this.dept, this.deptName, this.countjob});

  ReportDeptDetailModel.fromJson(Map<String, dynamic> json) {
    staff = json['staff'];
    dept = json['dept'];
    deptName = json['deptName'];
    countjob = json['countjob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['staff'] = this.staff;
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
    data['countjob'] = this.countjob;
    return data;
  }
}
