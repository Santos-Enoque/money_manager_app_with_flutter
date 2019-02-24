class Master{
  String categorytype;
  double amount;
  String transactionDay;
  String transactionWeekDay;
  String transactionMonth;
  int transactionYear;
  String transactionType;
  String transactionDescription;
  int id;


  Master( this.transactionDay, this.transactionWeekDay, this.transactionMonth, this.transactionYear, this.amount, this.transactionType,{this.transactionDescription ,this.categorytype});

  Master.map(dynamic obj){
    this.id = obj["id"];
    this.amount = obj['amount'];
    this.transactionDay = obj['transactionDay'];
    this.transactionWeekDay = obj['transactionWeekDay'];
    this.transactionMonth = obj['transactionMonth'];
    this.transactionYear = obj['transactionYear'];
    this.transactionType = obj['transactionType'];
    this.transactionDescription = obj['transactionDescription'];
    this.categorytype = obj['category'];

  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["transactionDay"] = transactionDay;
    map["transactionWeekDay"] = transactionWeekDay;
    map["transactionMonth"] = transactionMonth;
    map["transactionYear"] = transactionYear;

    map["amount"] = amount;
    map["transactionType"] = transactionType;
    map["transactionDescription"] = transactionDescription;
    map["category"] = categorytype;

    return map;
  }

  Master.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.amount = map["amount"];
    this.transactionDay = map["dateTime"];
    this.transactionWeekDay = map["transactionWeekDay"];
    this.transactionMonth = map["transactionMonth"];
    this.transactionYear = map["transactionYear"];
    this.transactionType = map["transactionType"];
    this.transactionDescription = map["transactionDescription"];
    this.categorytype = map["category"];
  }


}