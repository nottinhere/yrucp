class UserLevelModel {
  String lvId;
  String lvName;

  UserLevelModel({this.lvId, this.lvName});

  UserLevelModel.fromJson(Map<String, dynamic> json) {
    lvId = json['lv_id'];
    lvName = json['lv_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lv_id'] = this.lvId;
    data['lv_name'] = this.lvName;
    return data;
  }
}
