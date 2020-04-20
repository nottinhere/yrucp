class ProductAllModel {
  String title;
  String productCode;
  String photo;
  Null priceList;
  String sumStock;
  String cMin;
  int subtract;
  String percentStock;
  String emotical;
  int id;

  ProductAllModel(
      {this.title,
      this.productCode,
      this.photo,
      this.priceList,
      this.sumStock,
      this.cMin,
      this.subtract,
      this.percentStock,
      this.emotical,
      this.id});

  ProductAllModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    priceList = json['price_list'];
    sumStock = json['sum_stock'];
    cMin = json['c_min'];
    subtract = json['subtract'];
    percentStock = json['percentStock'];
    emotical = json['emotical'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    data['price_list'] = this.priceList;
    data['sum_stock'] = this.sumStock;
    data['c_min'] = this.cMin;
    data['subtract'] = this.subtract;
    data['percentStock'] = this.percentStock;
    data['emotical'] = this.emotical;
    data['id'] = this.id;
    return data;
  }
}
