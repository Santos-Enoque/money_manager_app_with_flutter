import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/ads.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/pages/home.dart';
import 'package:money_manager/utils/database_helper.dart';


class Functions{
  var db = new DatabaseHelper();
  BuildContext myContext;

  Functions({this.myContext});

  Widget displayDate(String transactionDay, String transactionMonth, int transactionYear, transactionWeekDay) {
    var now = new DateTime.now();
    var dayFormatter = new DateFormat('dd');
    int currentDate = int.parse(dayFormatter.format(now));
    int intTransactionDay = int.parse(transactionDay);


    var month = new DateFormat('MMM');
    var year = new DateFormat('y');

    String monthString = month.format(now);
    String yearString = year.format(now);
    int currentYear =int.parse(yearString);

    if(intTransactionDay == currentDate && transactionMonth == monthString && transactionYear == currentYear){
      return  Text('Today');
    }else if(currentDate - intTransactionDay == 1 && transactionMonth == monthString && transactionYear == currentYear){
      return  Text('Yesterday');
    }else{
      return  Text(transactionWeekDay +'- $transactionDay -'+transactionMonth);
    }

  }


//  this method will add income and expenses to our database
  void addTransaction(double amount, String transaction, BuildContext context,
      {String category, String description}) async {
    var now = new DateTime.now();
    var day = new DateFormat('dd');
    var weekDay = new DateFormat('EEEE');
    var month = new DateFormat('MMM');
    var year = new DateFormat('y');

    String getDayString = day.format(now);
    print(getDayString);
    String weekDayString = weekDay.format(now);
    String monthString = month.format(now);
    String yearString = year.format(now);
    int convertYear =int.parse(yearString);



    //Add transaction
    int transactionId = await db.insertTransaction(
        new Master(day.format(now), weekDayString, monthString, convertYear, amount, transaction, categorytype: category ?? 'others', transactionDescription: description));
    if(transaction == "expense"){
      Ads.showFullScreenAd();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    print(transactionId);
  }


// this will return a different amount depending on the transaction
  Widget returnAmount(String transactiontype, String category ,double amount) {
    if(transactiontype == "income"){
      switch(category){
        case null:
          return new Row(
              children: <Widget>[
                new Text("+ ${amount}",
                  style: TextStyle(color: Colors.green, fontSize: 20.0),),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: new Text(
                    "", style: TextStyle(color: Colors.green.shade200),),
                ),
              ]);
          break;
        default:
          return new Row(
              children: <Widget>[
                new Text("+ ${amount}",
                  style: TextStyle(color: Colors.green, fontSize: 20.0),),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: new Text(
                    "$category", style: TextStyle(color: Colors.green.shade200),),
                ),
              ]);
          break;
      }
    }else{
      switch(category){
        case null:
          return new Row(
              children: <Widget>[
                new Text("- ${amount}",
                  style: TextStyle(color: Colors.red.shade900, fontSize: 20.0),),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: new Text(
                    "", style: TextStyle(color: Colors.red.shade200),),
                ),
              ]);
          break;
        default:
          return new Row(
              children: <Widget>[
                new Text("- ${amount}",
                  style: TextStyle(color: Colors.red.shade900, fontSize: 20.0),),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: new Text(
                    "$category", style: TextStyle(color: Colors.red.shade200),),
                ),
              ]);
          break;
      }
    }
  }

  //  this method will return a different icon depending on the transaction
  Widget returnIcon(String transactionType) {
    if(transactionType == "income"){
      return Icon(Icons.attach_money, color: Colors.green,);
    }else{
      return Icon(Icons.money_off, color: Colors.red.shade900,);
    }
  }

  void addCategory(String categoryName, context, categoryType) async{
    int categoryId = await db.insertCategory(CategoryModel(categoryName, categoryType));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    print(categoryId);
  }

//  DELETE RECORD
  void deleteRecords(givenContext) async{
    var delete = await db.deleteAllTransactions();
    print(delete);
    Navigator.pushReplacement(givenContext, MaterialPageRoute(builder: (context)=> Home()));
  }


}