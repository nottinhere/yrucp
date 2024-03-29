class ReportDeptModel {
  String dept;
  String deptName;
  String code;
  String countjob;
  String alljob;
  String unread;
  String opened;
  String onwork;
  String inprocess;
  String complete;
  String incomplete;
  String cancel;

  ReportDeptModel(
      {this.dept,
      this.deptName,
      this.code,
      this.countjob,
      this.alljob,
      this.unread,
      this.opened,
      this.onwork,
      this.inprocess,
      this.complete,
      this.incomplete,
      this.cancel});

  ReportDeptModel.fromJson(Map<String, dynamic> json) {
    dept = json['dept'];
    deptName = json['deptName'];
    code = json['code'];
    countjob = json['countjob'];
    alljob = json['alljob'];
    unread = json['unread'];
    opened = json['opened'];
    onwork = json['onwork'];
    inprocess = json['inprocess'];
    complete = json['complete'];
    incomplete = json['incomplete'];
    cancel = json['cancel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
    data['code'] = this.code;
    data['countjob'] = this.countjob;
    data['alljob'] = this.alljob;
    data['unread'] = this.unread;
    data['opened'] = this.opened;
    data['onwork'] = this.onwork;
    data['inprocess'] = this.inprocess;
    data['complete'] = this.complete;
    data['incomplete'] = this.incomplete;
    data['cancel'] = this.cancel;
    return data;
  }
}
