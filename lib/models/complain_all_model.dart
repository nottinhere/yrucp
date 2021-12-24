class ComplainAllModel {
  String subject;
  String detail;
  String location;
  String postdate;
  String postby;
  String status;
  String textstatus;
  String division;
  String staff;
  int id;

  ComplainAllModel(
      {this.subject,
      this.detail,
      this.location,
      this.postdate,
      this.postby,
      this.status,
      this.textstatus,
      this.division,
      this.staff,
      this.id});

  ComplainAllModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    detail = json['detail'];
    location = json['location'];
    postdate = json['postdate'];
    postby = json['postby'];
    status = json['status'];
    textstatus = json['textstatus'];
    division = json['division'];
    staff = json['staff'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['detail'] = this.detail;
    data['location'] = this.location;
    data['postdate'] = this.postdate;
    data['postby'] = this.postby;
    data['status'] = this.status;
    data['textstatus'] = this.textstatus;
    data['division'] = this.division;
    data['staff'] = this.staff;
    data['id'] = this.id;
    return data;
  }
}
