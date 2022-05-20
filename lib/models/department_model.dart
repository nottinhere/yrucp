class DepartmentModel {
  String dpId;
  String dpName;
  String code;
  String accessToken;
  int memInDept;

  DepartmentModel({this.dpId, this.dpName, this.code, this.accessToken});

  DepartmentModel.fromJson(Map<String, dynamic> json) {
    dpId = json['dp_id'];
    dpName = json['dp_name'];
    code = json['code'];
    accessToken = json['access_token'];
    memInDept = json['memInDept'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dp_id'] = this.dpId;
    data['dp_name'] = this.dpName;
    data['code'] = this.code;
    data['access_token'] = this.accessToken;
    data['memInDept'] = this.memInDept;
    return data;
  }
}
