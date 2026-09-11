class CategoryListModel {
  List<CategoryProduct>? products;
  int? total;
  int? totalPages;
  int? perPage;
  int? currentPage;

  CategoryListModel(
      {this.products,
      this.total,
      this.totalPages,
      this.perPage,
      this.currentPage});

  CategoryListModel.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <CategoryProduct>[];
      json['products'].forEach((v) {
        products!.add(new CategoryProduct.fromJson(v));
      });
    }
    total = json['total'];
    totalPages = json['total_pages'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['total_pages'] = this.totalPages;
    data['per_page'] = this.perPage;
    data['current_page'] = this.currentPage;
    return data;
  }
}

class CategoryProduct {
  int? id;
  String? name;
  String? slug;
  int? parent;
  String? description;
  String? display;
  Image? image;

  CategoryProduct(
      {this.id,
      this.name,
      this.slug,
      this.parent,
      this.description,
      this.display,
      this.image});

  CategoryProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    parent = json['parent'];
    description = json['description'];
    display = json['display'];
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['parent'] = this.parent;
    data['description'] = this.description;
    data['display'] = this.display;
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    return data;
  }
}

class Image {
  String? src;

  Image({this.src});

  Image.fromJson(Map<String, dynamic> json) {
    src = json['src'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    return data;
  }
}


