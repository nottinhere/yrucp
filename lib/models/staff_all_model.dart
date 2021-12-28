class StaffModel {
  String user;
  String personName;
  String personContact;
  String division;
  String status;
  int id;

  StaffModel(
      {this.user,
      this.personName,
      this.personContact,
      this.division,
      this.status,
      this.id});

  StaffModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    personName = json['person_name'];
    personContact = json['person_contact'];
    division = json['division'];
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = this.user;
    data['person_name'] = this.personName;
    data['person_contact'] = this.personContact;
    data['division'] = this.division;
    data['status'] = this.status;
    data['id'] = this.id;
    return data;
  }
}
