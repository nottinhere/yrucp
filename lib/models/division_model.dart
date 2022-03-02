class DivisionModel {
  String dvId;
  String dvName;

  DivisionModel({this.dvId, this.dvName});

  DivisionModel.fromJson(Map<String, dynamic> json) {
    dvId = json['dv_id'];
    dvName = json['dv_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dv_id'] = this.dvId;
    data['dv_name'] = this.dvName;
    return data;
  }
}
