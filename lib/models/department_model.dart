class DepartmentModel {
  String dpId;
  String dpName;
  String code;
  String accessToken;
  int status;
  int memInDept;
  int cateInDept;
  int postInDept;

  DepartmentModel(
      {this.dpId,
      this.dpName,
      this.code,
      this.accessToken,
      this.memInDept,
      this.cateInDept,
      this.postInDept});

  DepartmentModel.fromJson(Map<String, dynamic> json) {
    dpId = json['dp_id'];
    dpName = json['dp_name'];
    code = json['code'];
    accessToken = json['access_token'];
    status = json['status'];
    memInDept = json['memInDept'];
    cateInDept = json['cateInDept'];
    postInDept = json['postInDept'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dp_id'] = this.dpId;
    data['dp_name'] = this.dpName;
    data['code'] = this.code;
    data['access_token'] = this.accessToken;
    data['status'] = this.status;
    data['memInDept'] = this.memInDept;
    data['cateInDept'] = this.cateInDept;
    data['postInDept'] = this.postInDept;
    return data;
  }
}
