class ComplainAllModel {
  String subject;
  String detail;
  String location;
  String appointdate;
  String appointtime;
  String postdate;
  String postby;
  String status;
  String problem;
  String textstatus;
  String department;
  String department_id;
  String staff;
  String staff_name;
  String helper;
  String helper_name;
  String attachIcon;
  String attachTarget;
  String ps_fullname;
  String ps_position;
  String ps_positionname;
  String ps_dept;
  String ps_deptname;
  String startdate_fix;
  String enddate_fix;
  String note;
  String reply;
  int rating;
  String usermsg;
  int id;

  ComplainAllModel(
      {this.subject,
      this.detail,
      this.location,
      this.appointdate,
      this.appointtime,
      this.postdate,
      this.postby,
      this.status,
      this.problem,
      this.textstatus,
      this.department,
      this.department_id,
      this.staff,
      this.staff_name,
      this.helper,
      this.helper_name,
      this.attachIcon,
      this.attachTarget,
      this.ps_fullname,
      this.ps_position,
      this.ps_positionname,
      this.ps_dept,
      this.ps_deptname,
      this.startdate_fix,
      this.enddate_fix,
      this.note,
      this.reply,
      this.rating,
      this.usermsg,
      this.id});

  ComplainAllModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    detail = json['detail'];
    location = json['location'];
    appointdate = json['appointdate'];
    appointtime = json['appointtime'];
    postdate = json['postdate'];
    postby = json['postby'];
    status = json['status'];
    problem = json['problem'];
    textstatus = json['textstatus'];
    department = json['department'];
    department_id = json['department_id'];
    staff = json['staff'];
    staff_name = json['staff_name'];
    helper = json['helper'];
    helper_name = json['helper_name'];
    attachIcon = json['attach_icon'];
    attachTarget = json['attach_target'];
    ps_fullname = json['ps_fullname'];
    ps_position = json['ps_position'];
    ps_positionname = json['ps_positionname'];
    ps_dept = json['ps_dept'];
    ps_deptname = json['ps_deptname'];
    startdate_fix = json['startdate_fix'];
    enddate_fix = json['enddate_fix'];
    note = json['note'];
    reply = json['reply'];
    rating = json['rating'];
    usermsg = json['usermsg'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['detail'] = this.detail;
    data['location'] = this.location;
    data['appointdate'] = this.appointdate;
    data['appointtime'] = this.appointtime;
    data['postdate'] = this.postdate;
    data['postby'] = this.postby;
    data['status'] = this.status;
    data['problem'] = this.problem;
    data['textstatus'] = this.textstatus;
    data['department'] = this.department;
    data['department_id'] = this.department_id;
    data['staff'] = this.staff;
    data['staff_name'] = this.staff_name;
    data['helper'] = this.helper;
    data['helper_name'] = this.helper_name;
    data['attach_icon'] = this.attachIcon;
    data['attach_target'] = this.attachTarget;
    data['ps_fullname'] = this.ps_fullname;
    data['ps_position'] = this.ps_position;
    data['ps_positionname'] = this.ps_positionname;
    data['ps_dept'] = this.ps_dept;
    data['ps_deptname'] = this.ps_deptname;
    data['startdate_fix'] = this.startdate_fix;
    data['enddate_fix'] = this.enddate_fix;
    data['note'] = this.note;
    data['reply'] = this.reply;
    data['rating'] = this.rating;
    data['usermsg'] = this.usermsg;
    data['id'] = this.id;
    return data;
  }
}
