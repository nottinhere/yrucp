class ProblemModel {
  String pId;
  String subject;
  String dpId;

  ProblemModel({this.pId, this.subject, this.dpId});

  ProblemModel.fromJson(Map<String, dynamic> json) {
    pId = json['p_id'];
    subject = json['subject'];
    dpId = json['dp_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['p_id'] = this.pId;
    data['subject'] = this.subject;
    data['dp_id'] = this.dpId;
    return data;
  }
}
