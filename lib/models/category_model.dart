class CategoryModel{
   String category_name;
   String category_type;
   int category_id;


  CategoryModel(this.category_name, this.category_type,);

  CategoryModel.map(dynamic obj){
    this.category_id = obj["category_id"];
    this.category_name = obj['category_name'];
    this.category_type = obj['category_type'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["category_id"] = category_id;
    map["category_name"] = category_name;
    map["category_type"] = category_type;

    return map;
  }

  CategoryModel.fromMap(Map<String, dynamic> map) {
    this.category_id = map["category_id"];
    this.category_name = map["category_name"];
    this.category_type = map["category_type"];

  }


}