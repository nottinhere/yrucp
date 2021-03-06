class UserModel {
  int id;
  String code;
  String user;
  String pass;
  String subject;
  String personName;
  String personContact;
  String personLineid;
  String personFacebook;
  int department;
  String departmentName;
  int level;
  int status;

  UserModel(
      {this.id,
      this.code,
      this.user,
      this.pass,
      this.subject,
      this.personName,
      this.personContact,
      this.personLineid,
      this.personFacebook,
      this.department,
      this.departmentName,
      this.level,
      this.status});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    user = json['user'];
    pass = json['pass'];
    subject = json['subject'];
    personName = json['person_name'];
    personContact = json['person_contact'];
    personLineid = json['person_lineid'];
    personFacebook = json['person_facebook'];
    department = json['department'];
    departmentName = json['departmentName'];
    level = json['level'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['user'] = this.user;
    data['pass'] = this.pass;
    data['subject'] = this.subject;
    data['person_name'] = this.personName;
    data['person_contact'] = this.personContact;
    data['person_lineid'] = this.personLineid;
    data['person_facebook'] = this.personFacebook;
    data['department'] = this.department;
    data['departmentName'] = this.departmentName;
    data['level'] = this.level;
    data['status'] = this.status;
    return data;
  }
}
