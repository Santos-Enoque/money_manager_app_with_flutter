import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:money_manager/ads.dart';
//my own imports
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/categories.dart';
import 'package:money_manager/pages/income_edit.dart';
import 'package:money_manager/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/utils/functions.dart';
import 'package:money_manager/components/alert_dialogs.dart';
import '../utils/monthlyExpenseSharedPref.dart';


const appId = "ca-app-pub-2268528231851864~4382979249";
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MonthlyExpenseLimitPref monthlyExpenseLimitPref = new MonthlyExpenseLimitPref();
  Functions _functions;
  AlertDialogs _alertDialogs;
  var now = new DateTime.now().toString();
  var db = new DatabaseHelper();

//  variables to handle the switch
  var _showMonthlyGoal = false;
  double monthlyExpenseVal = 0.0;

//  variables to handle the input fields
  TextEditingController _incomeAmountController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();
  TextEditingController _expenseAmountController = new TextEditingController();
  TextEditingController _setGoalController = new TextEditingController();


  List<Master> transactionsList = <Master>[];
  final List<CategoryModel> categoryList = <CategoryModel>[];


//  lets create a list of the available choices
  List<Choice> choices = const <Choice>[
    const Choice(title: "add income", icon: Icons.attach_money),
    const Choice(title: "add expense", icon: Icons.money_off),
    const Choice(title: "add category", icon: Icons.category)
  ];

  //  lets create a list of the available choices
  List<Choice> choices2 = const <Choice>[
//    const Choice(title: "view incomes", icon: Icons.attach_money),
//    const Choice(title: "view expenses", icon: Icons.money_off),
    const Choice(title: "view categories", icon: Icons.category)
  ];

  SharedPreferences preferences;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double currentBalance = 0.0;
  double spentSoFar = 0.0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool showAd = false;


//  instance of the shared prefs
  @override
  void initState() {
    super.initState();
    _showGoalOrNot();
    _getGoalValue();

      Ads.init(appId, testing: true);
    if(showAd == true){
      Ads.showFullScreenAd();
    }

    _functions = new Functions(myContext: context);
    _alertDialogs = new AlertDialogs(context);
    getSpentSoFar();
    getTransaction();
    getBalance();
    clearCategoryAmount();
  } //  the initial state

  @override
  Widget build(BuildContext context) {

//    this code is going to give us the width of the screen
    final mediaQuerydata = MediaQuery.of(context);
    final size = mediaQuerydata.size.width;

    return Scaffold(
      appBar: AppBar(
        title: new Text("Home"),
        backgroundColor: Colors.blue.shade900,
        centerTitle: false,
        elevation: 1.0,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            icon: Icon(Icons.add),
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Colors.blue.shade900,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),

          PopupMenuButton<Choice>(
            icon: Icon(Icons.remove_red_eye),
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices2.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Colors.blue.shade900,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: Colors.blue.shade900),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),

        ],
      ),

      drawer: _getDrawer(),
      body: WillPopScope(
        onWillPop: () { _alertDialogs.closeApp();},
        child: InkWell(
          onDoubleTap: (){
            _alertDialogs.showExpenseDialog(_expenseAmountController);
          },
          onTap: (){
            _alertDialogs.showIncomeAlert(_incomeAmountController);
          },
          child: new Column(
            children: <Widget>[
           _showGoalAtScreen(),
              Visibility(
                visible: transactionsList.length > 0,
                child: Expanded(
                  child: ListView.builder(
                      itemCount:transactionsList.length,
                      itemBuilder: (context, int index){
                    return Card(color: Colors.grey.shade50,
                      child: ListTile(
                        leading: _functions.returnIcon(transactionsList[index].transactionType),
                        title: _functions.returnAmount(transactionsList[index].transactionType, transactionsList[index].categorytype ,transactionsList[index].amount),
                        subtitle: _functions.displayDate(transactionsList[index].transactionDay, transactionsList[index].transactionMonth, transactionsList[index].transactionYear, transactionsList[index].transactionWeekDay),
                        trailing: FlatButton(onPressed: (){
                          viewDialog(index, transactionsList, context);
                        }, child: Icon(Icons.more_horiz)),
                      ),
                    );}),
                ),
              ),
              Visibility(
                visible: transactionsList.length <= 0,
                child: Padding(
                  padding: const EdgeInsets.only(top:60.0),
                  child: new ListTile(title: ListTile(
                      title: Icon(Icons.monetization_on, color: Colors.grey, size: 70.0,),
                      subtitle: new Center(child: Text("Tap to add  income!", style: TextStyle(color: Colors.grey, fontSize: 16.0),))),
                  subtitle: new Center(child: Text("Double tap to add  expense!", style: TextStyle(color: Colors.grey, fontSize: 16.0),)),),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: new Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[

           Expanded(
             child: ListTile(
               title: new Text("Balance:"),
               subtitle: _viewBalance(),
             ),
           ),

           Expanded(
             child: ListTile(
               title: new Text("Spent so far:"),
               subtitle: _viewExpence(),
             ),
           ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: MaterialButton(
                            onPressed: (){
                              _alertDialogs.summaryAlert(context);
                            },
                            child: Material(
                                color: Colors.blue.shade900,
                                borderRadius: BorderRadius.circular(20.0),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                                  child: new Text("Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ))),
                      ),


          ],
        ),
      ),
    );
  }




  //  *****************  DIALOG ********************
  void  viewDialog(int index, List<Master> transactionsList, BuildContext context) {
    if(transactionsList[index].categorytype == null && transactionsList[index].transactionDescription == null ){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList[index].transactionType}  \$${transactionsList[index].amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("No description for this transaction!"),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditIncome(transactionsList[index].amount,  transactionsList[index].id)
                    ));
                  },
                  child: new Text("edit"),
                ),

                FlatButton(
                  onPressed:(){
                    Navigator.pop(context);
                deleteTransaction(transactionsList[index].id, transactionsList[index].amount);
                  },
                  child: new Text("delete"),
                )
              ],
            );
          });
    }else if(transactionsList[index].categorytype == null){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList[index].transactionType}  \$${transactionsList[index].amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("Description:"),
                subtitle: new Text("${transactionsList[index].transactionDescription}"),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditIncome(transactionsList[index].amount,  transactionsList[index].id)
                    ));
                  },
                  child: new Text("edit"),
                ),

                FlatButton(
                  onPressed:(){
                    Navigator.pop(context);
                    deleteTransaction(transactionsList[index].id, transactionsList[index].amount);

                  },
                  child: new Text("delete"),
                )
              ],
            );
          });
    }else if(transactionsList[index].transactionDescription == null){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList[index].categorytype} ${transactionsList[index].transactionType}  \$${transactionsList[index].amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("No description for this transaction!"),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditIncome(transactionsList[index].amount,  transactionsList[index].id)
                    ));
                  },
                  child: new Text("edit"),
                ),

                FlatButton(
                  onPressed:(){
                    Navigator.pop(context);
                    deleteTransaction(transactionsList[index].id, transactionsList[index].amount);

                  },
                  child: new Text("delete"),
                )
              ],
            );
          });
    }else{
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList[index].categorytype} ${transactionsList[index].transactionType}  \$${transactionsList[index].amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("Description:"),
                subtitle: new Text("${transactionsList[index].transactionDescription}"),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditIncome(transactionsList[index].amount,  transactionsList[index].id)
                    ));
                  },
                  child: new Text("edit"),
                ),

                FlatButton(
                  onPressed:(){
                    Navigator.pop(context);
                    deleteTransaction(transactionsList[index].id, transactionsList[index].amount);

                  },
                  child: new Text("delete"),
                )
              ],
            );
          });
    }

  }
  //  ============== METHODS==============================

// we will use this method to retrieve the transactions
  void getTransaction() async {
    List transactions;
    transactions = await db.getAllTransactions();
    for (int i = 0; i < transactions.length; i++) {
      Master master = Master.map(transactions[i]);
      setState(() {
        transactionsList.insert(0, master);
//        getBalance(transactionsList.length);
        print(transactionsList.length);
      });
    }
  }

  void getSpentSoFar() async {
    var now = new DateTime.now();
    var month = new DateFormat('MMM');
    String currentMonth = month.format(now);

    List transactions;
    transactions = await db.getAllTransactions();
    for (int i = 0; i < transactions.length; i++) {
      Master master = Master.map(transactions[i]);
      if(master.transactionMonth == currentMonth && master.transactionType == "expense"){
        setState(() {
          spentSoFar = spentSoFar + master.amount;
        });
      }
    }
  }

  void getBalance() async {
//    we need to do this so that we can reset the totals when we are calling them from the addTransaction method
    totalIncome = 0.0;
    totalExpense = 0.0;
    List transactions;
    transactions = await db.getAllTransactions();
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

  void deleteTransaction(id, amount) {
    var alert = new AlertDialog(
      content: new Text("Dou you want to delete this transaction from the database?"),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              db.deleteTransaction(id);
              setState(() {
                transactionsList = <Master>[];
                spentSoFar = spentSoFar - amount;
              });
              getTransaction();
              getBalance();
              Navigator.pop(context);
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

  void onItemMenuPress(Choice choice) {
    if (choice.title == "add income") {
      _alertDialogs.showIncomeAlert(_incomeAmountController);
    } else if (choice.title == "add expense") {
      _alertDialogs.showExpenseDialog(_expenseAmountController);
    } else if (choice.title == "view incomes") {
//      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewIncome()));
    }else if (choice.title == "view expenses") {
//      Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseView()));
    }else if (choice.title == "add category") {
      _alertDialogs.showCategoryAlert(_categoryController);
    }else if (choice.title == "view categories") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Categories()));
    }
  }

  void _onChanged1(bool value) async{
    monthlyExpenseLimitPref.setExpenseBanner(value);
    setState(() => _showMonthlyGoal = value);}

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Min, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Semoney',
      'Dont forget to record your expenses today',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

 Widget _viewBalance() {
    if(totalExpense > totalIncome){
     return new Text("You have negative balance", style: TextStyle(color: Colors.red, fontSize: 16.0),);

   }else{
    return  new Text("\$$currentBalance", style: TextStyle(color: Colors.green, fontSize: 20.0, fontWeight: FontWeight.bold),);

 }
  }

  Widget _viewExpence() {
      return  new Text("\$$spentSoFar", style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),);
  }

 Widget _showGoalAtScreen() {
    if(_showMonthlyGoal){
      return Material(
        color: Colors.blue.shade200,
        child: Row(
          children: <Widget>[
            Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text("Monthly expenditure goal:  \$$monthlyExpenseVal", style: TextStyle( color: Colors.grey.shade900),),
            )),
//               IconButton(icon: Icon(Icons.close), onPressed: (){})
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 10.0, 8.0),
              child: InkWell(
                  onTap: (){
                    setState(() {
                      _showMonthlyGoal = false;
                    });
                  },
                  child: Icon(Icons.close)),
            )
          ],
        ),
      );
    }else{
      return Container();
    }
 }

 Widget _getDrawer() {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: new Text("Settings"),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[

            Divider(),
            Expanded(
              child: ListView(
                children: <Widget>[

                  new ListTile(
                    title: new Text("Show monthly goal"),
                    trailing: new Switch(value: _showMonthlyGoal, onChanged: _onChanged1),
                  ),


                  new ListTile(
                    title: new Text("Set monthly goal"),
                    onTap: (){
                      _alertDialogs.setGoal(_setGoalController);
                    },
                  ),

                  new ListTile(
                    title: new Text("clear datadase"),
                    onTap: (){
                      _alertDialogs.deleteDatabaseAlert();
                    },
                  ),


                  Divider(),
//                  new ListTile(
//                    leading: Icon(Icons.info_outline),
//                    title: new Text("About"),
//                    onTap: (){},
//                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text("developed by: Santos Enoque", style: TextStyle(color: Colors.grey),),
            )
          ],
        ),
      ),
    );
 }

  void clearCategoryAmount() async{

  }

  void _showGoalOrNot() async{
    var value = await monthlyExpenseLimitPref.showExpenseBanner();
    setState(() {
      _showMonthlyGoal =  value;
    });
  }

  void _getGoalValue() async{
    var value = await monthlyExpenseLimitPref.getExpenseAmount();
    setState(() {
      monthlyExpenseVal = value;
    });
  }



}

//this will be the choices class

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
