class ComplainAllModel {
  String subject;
  String detail;
  String location;
  String appointdate;
  String postdate;
  String postby;
  String status;
  String textstatus;
  String division;
  String staff;
  String staff_name;
  String startdate_fix;
  String enddate_fix;
  int id;

  ComplainAllModel(
      {this.subject,
      this.detail,
      this.location,
      this.appointdate,
      this.postdate,
      this.postby,
      this.status,
      this.textstatus,
      this.division,
      this.staff,
      this.staff_name,
      this.startdate_fix,
      this.enddate_fix,
      this.id});

  ComplainAllModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    detail = json['detail'];
    location = json['location'];
    appointdate = json['appointdate'];
    postdate = json['postdate'];
    postby = json['postby'];
    status = json['status'];
    textstatus = json['textstatus'];
    division = json['division'];
    staff = json['staff'];
    staff_name = json['staff_name'];
    startdate_fix = json['startdate_fix'];
    enddate_fix = json['enddate_fix'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['detail'] = this.detail;
    data['location'] = this.location;
    data['appointdate'] = this.appointdate;
    data['postdate'] = this.postdate;
    data['postby'] = this.postby;
    data['status'] = this.status;
    data['textstatus'] = this.textstatus;
    data['division'] = this.division;
    data['staff'] = this.staff;
    data['staff_name'] = this.staff_name;
    data['startdate_fix'] = this.startdate_fix;
    data['enddate_fix'] = this.enddate_fix;
    data['id'] = this.id;
    return data;
  }
}
