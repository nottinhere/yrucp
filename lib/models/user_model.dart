class UserModel {
  String id;
  String code;
  String user;
  String pass;
  String name;
  String subject;
  String contact;
  String status;

  UserModel(
      {this.id,
      this.code,
      this.user,
      this.pass,
      this.name,
      this.subject,
      this.contact,
      this.status});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    user = json['user'];
    pass = json['pass'];
    name = json['name'];
    subject = json['subject'];
    contact = json['contact'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['user'] = this.user;
    data['pass'] = this.pass;
    data['name'] = this.name;
    data['subject'] = this.subject;
    data['contact'] = this.contact;
    data['status'] = this.status;
    return data;
  }
}