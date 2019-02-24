class BalanceModel {
  double balance;


  BalanceModel.map(dynamic obj) {
    this.balance = obj['balance'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["balance"] = balance;
    return map;
  }

  BalanceModel.fromMap(Map<String, dynamic> map) {
    this.balance = map["balance"];
  }
}
