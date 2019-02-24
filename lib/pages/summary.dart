import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//my own imports
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/home.dart';
import 'package:money_manager/pages/income_screen.dart';
import 'package:money_manager/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/ads.dart';
import 'package:money_manager/pages/expense_screen.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import '../utils/categorySum.dart';
class Summary extends StatefulWidget {
  final String date;

  Summary(this.date);

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  final List<Master> transactionsList = <Master>[];
  final List<Master> expenseTransactionsList = <Master>[];

  final List<CategoryModel> categoryList = <CategoryModel>[];
List<CircularStackEntry> data = <CircularStackEntry>[];

bool visible;
SharedPreferences preferences;
double totalIncome = 0.0;
double totalExpense = 0.0;
double incomeForTheDate = 0.0;
double expenseForTheDate = 0.0;
int expenseTransactions = 0;
int incomeTransactions = 0;
double currentBalance = 0.0;
var now = new DateTime.now();
var day = new DateFormat('dd');
var weekDay = new DateFormat('EEEE');
var month = new DateFormat('MMM');
var year = new DateFormat('y');
var db = new DatabaseHelper();
static List<CategorySum> categorySumList = [];
bool showGraph = false;

@override
void initState() {
  super.initState();
  Ads.setBannerAd();
  categorySumList.clear();
  getTransaction();
  getBalance();

} //  the initial

// we will use this method to retrieve the transactions
void getTransaction() async {
  int currentDay = int.parse(day.format(now));
  String currentMonth = month.format(now);
  String yearString = year.format(now);
  int currentYear =int.parse(yearString);
  List checkCategories = [];
  List transactions;
  transactions = await db.getTransactionsForSummary();
  for (int i = 0; i < transactions.length; i++) {
    Color givenColor = Colors.deepOrange;
    if(i == 0){
      givenColor = Colors.red;
    }else if(i == 1){
      givenColor = Colors.green;

    }else if(i == 2){
      givenColor = Colors.blue;

    }else if(i == 3){
      givenColor = Colors.yellow;

    }else if(i == 4){
      givenColor = Colors.purple;

    }
    Master master = Master.map(transactions[i]);

    if(widget.date == 'today'){
      if(master.transactionType == 'expense'){

        double sum = await db.sumTransaction( currentMonth, currentYear, master.categorytype, master.transactionType, day: currentDay);
        CategorySum categorySum = new CategorySum(master.categorytype, sum, givenColor);
        if(checkCategories.contains(master.categorytype)){
          print("elements exists");
        }else {
          categorySumList.insert(0, categorySum);
        }

        checkCategories.insert(0, master.categorytype);
      }
    }else if(widget.date == 'this month'){
      if(master.transactionType == 'expense'){

        double sum = await db.sumTransaction(currentMonth, currentYear, master.categorytype, master.transactionType);
        CategorySum categorySum = new CategorySum(master.categorytype, sum, givenColor);
        if(checkCategories.contains(master.categorytype)){
          print("elements exists");
        }else {
          categorySumList.insert(0, categorySum);
        }

        checkCategories.insert(0, master.categorytype);
      }
    }else if(widget.date == 'yesterday'){
      if(currentDay > 1 && currentDay <= 31){
        int yesterday = currentDay - 1;
        if(master.transactionType == 'expense'){

          double sum = await db.sumTransaction(currentMonth, currentYear, master.categorytype, master.transactionType, day: yesterday);
          CategorySum categorySum = new CategorySum(master.categorytype, sum, givenColor);
          if(checkCategories.contains(master.categorytype)){
            print("elements exists");
          }else {
            categorySumList.insert(0, categorySum);
          }

          checkCategories.insert(0, master.categorytype);
        }
      }else if(currentDay == 1){
        if(currentMonth == 'Aug' || currentMonth == 'May' || currentMonth == 'Jul' || currentMonth == 'Dec'){
          int yesterday = 30;
          if(master.transactionType == 'expense'){

            double sum = await db.sumTransaction(currentMonth, currentYear, master.categorytype, master.transactionType, day: yesterday);
            CategorySum categorySum = new CategorySum(master.categorytype, sum, givenColor);
            if(checkCategories.contains(master.categorytype)){
              print("elements exists");
            }else {
              categorySumList.insert(0, categorySum);
            }

            checkCategories.insert(0, master.categorytype);
          }
        }else if(currentMonth == 'Mar'){
          if(master.transactionType == 'expense'){
            int yesterday = 28;
            double sum = await db.sumTransaction(currentMonth, currentYear, master.categorytype, master.transactionType, day: yesterday);
            CategorySum categorySum = new CategorySum(master.categorytype, sum, givenColor);
            if(checkCategories.contains(master.categorytype)){
              print("elements exists");
            }else {
              categorySumList.insert(0, categorySum);
            }

            checkCategories.insert(0, master.categorytype);
          }
        }}

    }


    setState(() {
      if(master == null){
        print("NUUUUUUL");
      }else{
        if(widget.date == 'today'){
          if(master.transactionType == "income" && master.transactionDay == currentDay.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
            incomeForTheDate += master.amount;

            transactionsList.insert(0, master);

            print(transactionsList.length);
            incomeTransactions += 1;
          }else if(master.transactionType == "expense" && master.transactionDay == currentDay.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
            expenseForTheDate = expenseForTheDate + master.amount;
            expenseTransactionsList.insert(0, master);
            expenseTransactions += 1;

          }
        }else if(widget.date == "this month"){
          if(master.transactionType == "income" && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
            incomeForTheDate = totalIncome + master.amount;
            incomeTransactions += 1;
            transactionsList.insert(0, master);
            print(transactionsList.length);
          }else if(master.transactionType == "expense" && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
            expenseForTheDate = expenseForTheDate + master.amount;
            expenseTransactions += 1;
            expenseTransactionsList.insert(0, master);

          }
        }else if(widget.date == 'yesterday'){
          if(currentDay > 1 && currentDay <= 31){
             int yesterday = currentDay - 1;
            if(master.transactionType == "income" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
              incomeForTheDate += master.amount;
              transactionsList.insert(0, master);
              print(transactionsList.length);
              incomeTransactions += 1;

            }else if(master.transactionType == "expense" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
              expenseForTheDate = expenseForTheDate + master.amount;
              expenseTransactions += 1;
              expenseTransactionsList.insert(0, master);

            }
          }else if(currentDay == 1){
            if(currentMonth == 'Aug' || currentMonth == 'May' || currentMonth == 'Jul' || currentMonth == 'Dec'){
              int yesterday = 30;
              if(master.transactionType == "income" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
                incomeForTheDate += master.amount;
                transactionsList.insert(0, master);
                print(transactionsList.length);
                incomeTransactions += 1;
              }else if(master.transactionType == "expense" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
                expenseForTheDate = expenseForTheDate + master.amount;
                expenseTransactions += 1;
                expenseTransactionsList.insert(0, master);

              }
            }else if(currentMonth == 'Mar'){
              int yesterday = 28;
              if(master.transactionType == "income" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
                incomeForTheDate += master.amount;
                transactionsList.insert(0, master);
                print(transactionsList.length);
                incomeTransactions += 1;
              }else if(master.transactionType == "expense" && master.transactionDay == yesterday.toString() && master.transactionMonth == currentMonth && master.transactionYear == currentYear){
                expenseForTheDate = expenseForTheDate + master.amount;
                expenseTransactions += 1;
                expenseTransactionsList.insert(0, master);

              }
            }
          }

        }


      }

    });

  }


  for (int step = 0; step < categorySumList.length; step++) {
    for ( int i = 0; i < categorySumList.length - step - 1; i++) {
      if (categorySumList[i].categoryAmount < categorySumList[i + 1].categoryAmount) {
        double temp = categorySumList[i].categoryAmount;
        categorySumList[i].categoryAmount = categorySumList[i+1].categoryAmount;
        categorySumList[i+1].categoryAmount = temp;
      }
    }
  }

}

void swap(List list, int i) {
  int temp = list[i];
  list[i] = list[i+1];
  list[i+1] = temp;
}

void getBalance() async {
//    we need to do this so that we can reset the totals when we are calling them from the addTransaction method
  totalIncome = 0.0;
  totalExpense = 0.0;
  String currentDay = day.format(now);
  String currentMonth = month.format(now);
  String yearString = year.format(now);
  int currentYear =int.parse(yearString);
  if(widget.date == 'today'){
    List transactions;
    transactions = await db.getAllTransactionsOnDate(currentDay, currentMonth, currentYear);
    for (int i = 0; i < transactions.length; i++) {
      Master master = Master.map(transactions[i]);
      setState(() {
        if(master == null){
          print("NUUUUUUL");
        }else{
          if(master.transactionType == "income"){
            totalIncome = totalIncome + master.amount;
          }else{
            totalExpense = totalExpense + master.amount;
          }
        }
      });
    }
    print("$totalIncome");
    print("$totalExpense");

    setState(() {
      currentBalance = totalIncome - totalExpense;
      if(currentBalance < 0){
        currentBalance = 0.0;
      }
    });
  }else if(widget.date == 'yesterday'){
    int yesterday = int.parse(currentDay) - 1;
    int today = int.parse(currentDay);
    String yesterdayString = yesterday.toString();
    if(today > 1 && today <= 31){
      List transactions;
      transactions = await db.getAllTransactionsOnDate(yesterdayString, currentMonth, currentYear);
      for (int i = 0; i < transactions.length; i++) {
        Master master = Master.map(transactions[i]);
        setState(() {
          if(master == null){
            print("NUUUUUUL");
          }else{
            if(master.transactionType == "income"){
              totalIncome = totalIncome + master.amount;
            }else{
              totalExpense = totalExpense + master.amount;
            }
          }
        });
      }
      print("$totalIncome");
      print("$totalExpense");

      setState(() {
        currentBalance = totalIncome - totalExpense;
        if(currentBalance < 0){
          currentBalance = 0.0;
        }
      });
    }else if(today == 1){
      if(currentMonth == 'Aug' || currentMonth == 'May' || currentMonth == 'Jul' || currentMonth == 'Dec'){
        String yesterdayString = 30.toString();
        List transactions;
        transactions = await db.getAllTransactionsOnDate(yesterdayString, currentMonth, currentYear);
        for (int i = 0; i < transactions.length; i++) {
          Master master = Master.map(transactions[i]);
          setState(() {
            if(master == null){
              print("NUUUUUUL");
            }else{
              if(master.transactionType == "income"){
                totalIncome = totalIncome + master.amount;
              }else{
                totalExpense = totalExpense + master.amount;
              }
            }
          });
        }
        print("$totalIncome");
        print("$totalExpense");

        setState(() {
          currentBalance = totalIncome - totalExpense;
          if(currentBalance < 0){
            currentBalance = 0.0;
          }
        });
      }else if(currentMonth == 'Mar'){
        String yesterdayString = 28.toString();
        List transactions;
        transactions = await db.getAllTransactionsOnDate(yesterdayString, currentMonth, currentYear);
        for (int i = 0; i < transactions.length; i++) {
          Master master = Master.map(transactions[i]);
          setState(() {
            if(master == null){
              print("NUUUUUUL");
            }else{
              if(master.transactionType == "income"){
                totalIncome = totalIncome + master.amount;
              }else{
                totalExpense = totalExpense + master.amount;
              }
            }
          });
        }
        print("$totalIncome");
        print("$totalExpense");

        setState(() {
          currentBalance = totalIncome - totalExpense;
          if(currentBalance < 0){
            currentBalance = 0.0;
          }
        });
      }
    }
  }else if(widget.date == 'this month'){
    List transactions;
    transactions = await db.getAllTransactionsOnMonth(currentMonth, currentYear);
    for (int i = 0; i < transactions.length; i++) {
      Master master = Master.map(transactions[i]);
      setState(() {
        if(master == null){
          print("NUUUUUUL");
        }else{
          if(master.transactionType == "income"){
            totalIncome = totalIncome + master.amount;
          }else{
            totalExpense = totalExpense + master.amount;
          }
        }
      });
    }
    print("$totalIncome");
    print("$totalExpense");

    setState(() {
      currentBalance = totalIncome - totalExpense;
      if(currentBalance < 0){
        currentBalance = 0.0;
      }
    });
  }
}

@override
Widget build(BuildContext context) {
//    this code is going to give us the width of the screen
  return WillPopScope(
    onWillPop: () async => false,
    child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.close), onPressed: (){
            setState(() {
              categorySumList.clear();
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
          }),
          title: new Text("Summary"),
          backgroundColor: Colors.blue.shade900,
          centerTitle: false,
          elevation: 1.0,
          bottom: TabBar(
            tabs: [
              Tab(text: "Expenses",),
              Tab(text: "Income"),
            ],
          ),
        ),

        body: TabBarView(children: [
//        FIRST TAB
          new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    alignment: Alignment.center,
                    child: ListTile(title:  Padding(
                      padding: const EdgeInsets.only(bottom:8.0),
                      child: Text("Expenses summary for ${widget.date}", style: TextStyle(fontSize: 20.0, color: Colors.blue.shade900, fontWeight: FontWeight.bold),),
                    ),
                      subtitle: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("Expenses: \$ $totalExpense"),
                          ),

                          Expanded(
                            child: Text("Transactions:  $expenseTransactions"),
                          ),

                          FlatButton(
                              textColor: Colors.blue.shade900,
                              onPressed: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExpenseView(expenseTransactionsList)));
                              }, child: new Text("view"))
                        ],
                      ),)),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Visibility(
                  visible: categorySumList.length > 0,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text("Your top expense categories are:", style: TextStyle(color: Colors.grey),)),
                ),
              ),
              Expanded(child: ListView.builder(
                  itemCount: categorySumList.length,
                  itemBuilder: (context, index){
                    return _showHeader(index, categorySumList);}))
            ],
          ),

//        SECOND TAB
          new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    alignment: Alignment.center,
                    child: ListTile(title:  Padding(
                      padding: const EdgeInsets.only(bottom:8.0),
                      child: Text("Incomes summary ${widget.date}", style: TextStyle(fontSize: 20.0, color: Colors.blue.shade900, fontWeight: FontWeight.bold),),
                    ),
                      subtitle: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("Incomes: \$ $totalIncome"),
                          ),

                          Expanded(
                            child: Text("Transactions:  ${transactionsList.length}"),
                          ),

                          FlatButton(
                              textColor: Colors.blue.shade900,
                              onPressed: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ViewIncome(transactionsList)));
                              }, child: new Text("view"))
                        ],
                      ),)),
              ),
              Divider(),
              Text("Incomes per category", style: TextStyle(fontSize: 16.0, color: Colors.grey, fontWeight: FontWeight.bold),),
              Divider(),

              Expanded(
                child: ListView.builder(
                    itemCount: transactionsList.length,
                    itemBuilder: (context, int index){
                      return ListTile(
                        title: Text(transactionsList[index].categorytype),
                        trailing:  new Text("+ ${transactionsList[index].amount}",  style: TextStyle(color: Colors.grey, fontSize: 16.0)),
                      );
                    }),
              ),
            ],
          ),
        ]),

//      bottomNavigationBar: new Container(
//        color: Colors.white,
//        child: Row(
//          children: <Widget>[
//            Visibility(
////              visible: transactionsList.isEmpty ?? false,
//              child: Expanded(
//                child: ListTile(
//                  title: new Text("Balance:"),
//                  subtitle: _viewBalance(),
//                ),
//              ),
//            ),
//
////            Expanded(
////
////                child:  Row(
////                    children: <Widget>[
////                      Padding(
////                        padding: const EdgeInsets.only(left:50.0),
////                        child: new Icon(Icons.settings, color: Colors.blue.shade900,),
////                      ),
////                      Padding(
////                        padding: const EdgeInsets.only(left: 8.0),
////                        child: new Text("Settings", style: TextStyle(color: Colors.blue.shade900),),
////                      ),
////
////                    ])),
//          ],
//        ),
//      ),
      ),
    ),
  );


}


Widget _viewBalance() {
  if(totalExpense > totalIncome){
    return new Text("You have negative balance", style: TextStyle(color: Colors.red, fontSize: 16.0),);

  }else{
    return  new Text("\$$currentBalance", style: TextStyle(color: Colors.green, fontSize: 20.0, fontWeight: FontWeight.bold),);

  }
}

  Widget _showHeader(int index, List<CategorySum> categorySumList) {
    if(categorySumList[index].categoryAmount == null){
      return Container();
    }else{
      return ListTile(
        leading: Icon(Icons.category, color: Colors.grey,),
        title: Text(categorySumList[index].categoryName),
        trailing:  new Text("- \$ ${categorySumList[index].categoryAmount}",  style: TextStyle(color: Colors.grey, fontSize: 16.0))
      );
    }
  }

}

