class ReportProblemModel {
  String pId;
  String problemName;
  String dept;
  String deptName;
  String countjob;
  String alljob;
  String unread;
  String opened;
  String onwork;
  String inprocess;
  String complete;
  String incomplete;
  String cancel;

  ReportProblemModel(
      {this.pId,
      this.problemName,
      this.dept,
      this.deptName,
      this.countjob,
      this.alljob,
      this.unread,
      this.opened,
      this.onwork,
      this.inprocess,
      this.complete,
      this.incomplete,
      this.cancel});

  ReportProblemModel.fromJson(Map<String, dynamic> json) {
    pId = json['p_id'];
    problemName = json['ProblemName'];
    dept = json['dept'];
    deptName = json['deptName'];
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
    data['p_id'] = this.pId;
    data['ProblemName'] = this.problemName;
    data['dept'] = this.dept;
    data['deptName'] = this.deptName;
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
