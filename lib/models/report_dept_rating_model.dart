class ReportDeptRatingModel {
  String dept;
  String deptName;
  String code;
  String alljob;
  String norating;
  String start1;
  String start2;
  String start3;
  String start4;
  String start5;

  ReportDeptRatingModel(
      {this.dept,
      this.deptName,
      this.code,
      this.alljob,
      this.norating,
      this.start1,
      this.start2,
      this.start3,
      this.start4,
      this.start5});

  ReportDeptRatingModel.fromJson(Map<String, dynamic> json) {
    dept = json['dept'];
    deptName = json['deptName'];
    code = json['code'];
    alljob = json['alljob'];
    norating = json['norating'];
    start1 = json['start1'];
    start2 = json['start2'];
    start3 = json['start3'];
    start4 = json['start4'];
    start5 = json['start5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
    data['code'] = this.code;
    data['alljob'] = this.alljob;
    data['norating'] = this.norating;
    data['start1'] = this.start1;
    data['start2'] = this.start2;
    data['start3'] = this.start3;
    data['start4'] = this.start4;
    data['start5'] = this.start5;
    return data;
  }
}
