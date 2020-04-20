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
  Null discount;
  Null endyearPromotion;
  Null note;
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
      this.discount,
      this.endyearPromotion,
      this.note,
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
    discount = json['discount'];
    endyearPromotion = json['endyear_promotion'];
    note = json['note'];
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
    data['discount'] = this.discount;
    data['endyear_promotion'] = this.endyearPromotion;
    data['note'] = this.note;
    data['status'] = this.status;
    return data;
  }
}
