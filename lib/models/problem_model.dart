class ProblemModel {
  String pId;
  String subject;
  String dpId;
  String dpName;
  int postInCate;
  int status;

  ProblemModel(
      {this.pId,
      this.subject,
      this.dpId,
      this.dpName,
      this.postInCate,
      this.status});

  ProblemModel.fromJson(Map<String, dynamic> json) {
    pId = json['p_id'];
    subject = json['subject'];
    dpId = json['dp_id'];
    dpName = json['dp_name'];
    postInCate = json['postInCate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['p_id'] = this.pId;
    data['subject'] = this.subject;
    data['dp_id'] = this.dpId;
    data['dp_name'] = this.dpName;
    data['postInCate'] = this.postInCate;
    data['status'] = this.status;
    return data;
  }
}
