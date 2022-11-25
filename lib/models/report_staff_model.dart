class ReportStaffModel {
  String staff;
  String dept;
  String deptName;
  String code;
  String countjob;
  String alljob;
  String inprocess;
  String unread;
  String opened;
  String onwork;
  String complete;
  String incomplete;
  String cancel;

  ReportStaffModel(
      {this.staff,
      this.dept,
      this.deptName,
      this.code,
      this.countjob,
      this.alljob,
      this.inprocess,
      this.unread,
      this.opened,
      this.onwork,
      this.complete,
      this.incomplete,
      this.cancel});

  ReportStaffModel.fromJson(Map<String, dynamic> json) {
    staff = json['staff'];
    dept = json['dept'];
    deptName = json['deptName'];
    code = json['code'];
    countjob = json['countjob'];
    alljob = json['alljob'];
    inprocess = json['inprocess'];
    unread = json['unread'];
    opened = json['opened'];
    onwork = json['onwork'];
    complete = json['complete'];
    incomplete = json['incomplete'];
    cancel = json['cancel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['staff'] = this.staff;
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
    data['code'] = this.code;
    data['countjob'] = this.countjob;
    data['alljob'] = this.alljob;
    data['inprocess'] = this.inprocess;
    data['unread'] = this.unread;
    data['opened'] = this.opened;
    data['onwork'] = this.onwork;
    data['complete'] = this.complete;
    data['incomplete'] = this.incomplete;
    data['cancel'] = this.cancel;
    return data;
  }
}
