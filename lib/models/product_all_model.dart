class ProductAllModel {
  String title;
  String productCode;
  String photo;
  String price;
  String unit;
  String stock;
  String id;

  ProductAllModel(
      {this.title,
      this.productCode,
      this.photo,
      this.price,
      this.unit,
      this.stock,
      this.id});

  ProductAllModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    price = json['price'];
    unit = json['unit'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    data['price'] = this.price;
    data['unit'] = this.unit;
    data['stock'] = this.stock;
    data['id'] = this.id;
    return data;
  }
}
