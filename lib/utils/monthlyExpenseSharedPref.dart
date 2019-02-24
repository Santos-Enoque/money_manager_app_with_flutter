import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class MonthlyExpenseLimitPref{
  final String showMonthlyExpense = "ShowExpense";
  final String monthlyExpenseAmount = "ExpenseAmount";

  Future<bool> showExpenseBanner() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(showMonthlyExpense) ?? true;
  }

  Future<bool> setExpenseBanner(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(showMonthlyExpense, value);
  }

  Future<double> getExpenseAmount() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(monthlyExpenseAmount) ?? 0.0;
  }

  Future setExpenseAmount(double val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(monthlyExpenseAmount, val);
  }
}