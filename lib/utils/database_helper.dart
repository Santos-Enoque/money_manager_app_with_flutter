import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_sum.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
//  bool wasCalled = true;

  factory DatabaseHelper() => _instance;


  final String tableIncomeExpense = "incomeExpenseTable";
  final String incomeExpenseId = "id";
  final String incomeExpenseAmount = "amount";
  final String incomeExpenseCategory = "category";
  final String transactionType = "transactionType";
  final String transactionDescription = "transactionDescription";
  final String transactionDay = "transactionDay";
  final String transactionWeekDay = "transactionWeekDay";
  final String transactionMonth = "transactionMonth";
  final String transactionYear = "transactionYear";


  final String tableCategory = "categoryTable";
  final String columncategoryId = "category_id";
  final String columncategoryName = "category_name";
  final String columnCategoryType = "category_type";



  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(
        documentDirectory.path, "maindb.db"); //home://directory/files/maindb.db

    var ourDb = await openDatabase(path, version: 2, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int newVersion) async {

    await db.execute(
        "CREATE TABLE $tableIncomeExpense($incomeExpenseId INTEGER PRIMARY KEY, $incomeExpenseAmount FLOAT, $incomeExpenseCategory TEXT, $transactionType TEXT, $transactionDescription TEXT, $transactionDay TEXT, $transactionWeekDay TEXT, $transactionMonth TEXT, $transactionYear INTEGER)");

//      TODO: dont forget to put this table up to date with the fields that you defined above
    await db.execute(
        "CREATE TABLE $tableCategory($columncategoryId INTEGER PRIMARY KEY, $columncategoryName TEXT, $columnCategoryType TEXT)");


  }

  //CRUD - CREATE, READ, UPDATE , DELETE

  //Insertion
  Future<int> insertTransaction(Master master) async {
    var dbClient = await db;
    if(master.transactionType == "income"){
//      _balanceUpdate(master.amount);
    int res = await dbClient.insert("$tableIncomeExpense", master.toMap());
    return res;}
    else{
      int res = await dbClient.insert("$tableIncomeExpense", master.toMap());
      return res;
    }
  }

  Future<int> insertCategory(CategoryModel category) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableCategory", category.toMap());
    return res;
  }

//  Future<int> InsertExpense(ExpenseModel expense) async {
//    var dbClient = await db;
//    int res = await dbClient.insert("$tableExpense", expense.toMap());
//    return res;
//  }
//


//  Future<int> InsertDa(Income income) async {
//    var dbClient = await db;
//    int res = await dbClient.insert("$tableIncome", income.toMap());
//    return res;
//  }

//  //======== methods to get data from the database
  Future<List> getAllTransactions() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense");
    return result.toList();
  }

  Future<List> getAllTransactionsOnDate(String day, String month, int year) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense WHERE $transactionDay =? AND $transactionMonth =? AND $transactionYear =? ", [day, month, year]);
    return result.toList();
  }

  Future<List> getAllTransactionsOnMonth(String month, int year) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense WHERE  $transactionMonth =? AND $transactionYear =? ", [month, year]);
    return result.toList();
  }

  Future<List> getTransactionsForSummary() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense");
    return result.toList();
  }


  Future<List> getAllCategories() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableCategory");
    return result.toList();
  }

  Future deleteAllTransactions() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("DELETE FROM $tableIncomeExpense");
    return result;
  }

  Future<List> getAllIncome() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense WHERE $transactionType =?", ['income']);

    return result.toList();
  }

  Future<List> getAllExpenses() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense WHERE $transactionType =?", ['expense']);

    return result.toList();
  }

  Future sumTransaction(month, year, category, transaction, {day}) async {
    var dbClient = await db;
    var result;

    if(day == null){
      result = await dbClient.rawQuery("SELECT SUM($incomeExpenseAmount) FROM $tableIncomeExpense WHERE $transactionType =? AND $incomeExpenseCategory =? AND $transactionMonth =? AND $transactionYear =?", [ transaction, category, month, year]);

    }else{
      result = await dbClient.rawQuery("SELECT SUM($incomeExpenseAmount) FROM $tableIncomeExpense WHERE $transactionType =? AND $incomeExpenseCategory =? AND $transactionMonth =? AND $transactionYear =? AND $transactionDay =?", [ transaction, category, month, year, day.toString()]);
    }

    return result[0]["SUM(amount)"];
  }






//
//  Future<int> getCount() async {
//    var dbClient = await db;
//    return Sqflite.firstIntValue(
//        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableUser"));
//  }
//
//  to get a single transaction
  Future<Master> getSingleTransaction(int id) async {
    var dbClient = await db;

    var result = await dbClient
        .rawQuery("SELECT * FROM $tableIncomeExpense WHERE $incomeExpenseId = $id");
    if (result.length == 0) return null;
    return new Master.fromMap(result.first);
  }

//  Future<List> getSpentSoFar(String month) async {
//    var dbClient = await db;
//    var data = [month];
//    var result = await dbClient.rawQuery("SELECT * FROM $tableIncomeExpense WHERE" + transactionMonth + "=", data);
//    if (result.length == 0) return null;
//    return result.toList();
//  }

  Future<CategoryModel> getSingleCategory(int id) async {
    var dbClient = await db;

    var result = await dbClient
        .rawQuery("SELECT * FROM $tableCategory WHERE $columncategoryId = $id");
    if (result.length == 0) return null;
    return new CategoryModel.fromMap(result.first);
  }

  Future<int> deleteCategory(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableCategory, where: "$columncategoryId = ?", whereArgs: [id]);
  }

  Future<int> deleteTransaction(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableIncomeExpense, where: "$incomeExpenseId = ?", whereArgs: [id]);
  }

  Future<int> updateCategory(String name, int id) async {
    var dbClient = await db;
    return await dbClient.update(tableCategory, {"category_name": name},
        where: "$columncategoryId = ?", whereArgs: [id]);
  }

  Future<int> updateIncome(double amount, String description, String category, int id) async {
    var dbClient = await db;
    return await dbClient.update(tableIncomeExpense, {"amount": amount, "transactionDescription": description, "category": category},
        where: "$incomeExpenseId = ?", whereArgs: [id]);
  }

  Future<int> updateExpense(double amount, String description, String category, int id) async {
    var dbClient = await db;
    return await dbClient.update(tableIncomeExpense, {"amount": amount, "transactionDescription": description, "category": category},
    where: "$incomeExpenseId = ?", whereArgs: [id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}


