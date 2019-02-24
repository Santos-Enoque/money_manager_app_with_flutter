import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/pages/expense.dart';
import 'package:money_manager/pages/income.dart';
import 'package:money_manager/pages/income_edit.dart';
import 'package:money_manager/pages/summary.dart';
import 'package:money_manager/utils/monthlyExpenseSharedPref.dart';
import '../utils/functions.dart';
import '../pages/home.dart';

class AlertDialogs{
  BuildContext context;
  Functions _functions = new Functions();

  AlertDialogs(this.context);

  MonthlyExpenseLimitPref monthlyExpenseLimitPref = new MonthlyExpenseLimitPref();






//  SUMMARY ALERT =================
  void summaryAlert(context) {
    var alert = new AlertDialog(
      content:
      new Text("Show summary from?"),

      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Summary("today")));
            },
            child: new Text("Today")),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Summary("yesterday")));
            },
            child: new Text("Yesterday")),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Summary("this month")));
            },
            child: new Text("This month")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

//  INCOME ALERT
  void showIncomeAlert(_incomeAmountController) {
    _incomeAmountController.text = "00.0";
    var alert = new AlertDialog(
      content:
      new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: _incomeAmountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "add income",
                  hintText: "income amount"),
            ),
          )
        ],
      ),

      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              double amount = double.parse(_incomeAmountController.text);
              String transactionType = "income";
              _functions.addTransaction(amount, transactionType, context);
            },
            child: new Text("Add")),
        new FlatButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddIncome(_incomeAmountController.text)));
            },
            child: new Text("more")),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("Cancel")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

//  EXPENSE ALERT
  void showExpenseDialog(_expenseAmountController) {
    _expenseAmountController.text = "00.0";
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: _expenseAmountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "add Expense",
                  hintText: "enter amount"),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              double amount = double.parse(_expenseAmountController.text);
              String transactionType = "expense";
              _functions.addTransaction(amount, transactionType, context);
            },
            child: new Text("Add")),
        new FlatButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddExpense(_expenseAmountController.text)));
            },
            child: new Text("more")),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("Cancel")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }


//  GOAL ALERT
  void setGoal(_expenseAmountController) {
    _expenseAmountController.text = "00.0";
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: _expenseAmountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Set monthly goal",
                  hintText: "enter amount"),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async{
              double amount = double.parse(_expenseAmountController.text);
             await monthlyExpenseLimitPref.setExpenseAmount(amount);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: new Text("Set")),
        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("Cancel")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  // ***************** CATEGORY DIALOG ****************************
  void showCategoryAlert(_categoryController) {
    _categoryController.text = "";
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: _categoryController,
              autofocus: true,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "add category",
                  hintText: "category name"),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _functions.addCategory(_categoryController.text, context, "income");
            },
            child: new Text("+ Income category")),

        new FlatButton(
            onPressed: () {
              _functions.addCategory(_categoryController.text, context, "expense");
            },
            child: new Text("+ Expense category")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  //   ================ DELETE ALERT ================
  void deleteDatabaseAlert() {
    var alert = new AlertDialog(
      content: new Text("Dou you want to delete all the data from the database?"),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _functions.deleteRecords(context);
            },
            child: new Text("Yes")),

        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("No")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  //   ================ CLOSE ALERT ================
  void closeApp() {
    var alert = new AlertDialog(
      content: new Text("Dou you want to close the app?"),
      actions: <Widget>[
        new FlatButton(
            onPressed: ()=> exit(0),
            child: new Text("Yes")),

        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("No")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }
}