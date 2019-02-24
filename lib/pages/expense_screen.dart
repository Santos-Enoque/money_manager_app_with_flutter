import 'package:flutter/material.dart';
import 'package:money_manager/ads.dart';
//my own imports
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/home.dart';
import 'package:money_manager/utils/database_helper.dart';
import 'package:money_manager/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/categorySum.dart';


class ExpenseView extends StatefulWidget {
  final List<Master> data;

  ExpenseView(this.data);

  @override
  _ExpenseViewState createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> {
  Functions _functions = new Functions();

  final List<Master> transactionsList = <Master>[];
  final List<CategoryModel> categoryList = <CategoryModel>[];



  SharedPreferences preferences;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double currentBalance = 0.0;

  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
    Ads.setBannerAd();
    print(transactionsList.length);

  } //  the initial



// this will return a different amount depending on the transaction
  Widget _returnAmount( String category ,double amount) {
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


  @override
  Widget build(BuildContext context) {
//    this code is going to give us the width of the screen
    final mediaQuerydata = MediaQuery.of(context);
    final size = mediaQuerydata.size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close), onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
        }),
        title: new Text("All expenses"),
        backgroundColor: Colors.blue.shade900,
        centerTitle: false,
        elevation: 1.0,
      ),

      body: WillPopScope(
        onWillPop: null,
        child: new Stack(
          children: <Widget>[
            Visibility(
              visible: transactionsList.isEmpty ?? true,
              child: new Center(
                child: ListTile(
                  title: new Icon(
                    Icons.monetization_on,
                    size: 64.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            ListView.builder(
                itemCount:widget.data.length,
                itemBuilder: (context, int index){
                  var expense = widget.data[index];
                    return Visibility(
                      child: Card(color: Colors.grey.shade50,
                        child: ListTile(
                          leading: Icon(Icons.attach_money, color: Colors.red.shade900,),
                          title: _returnAmount(expense.categorytype ,expense.amount),
                          subtitle: _functions.displayDate(expense.transactionDay, expense.transactionMonth, expense.transactionYear, expense.transactionWeekDay),
                          trailing: FlatButton(onPressed: (){
                            _viewDialog(expense);
                          }, child: Text("view")),
                        ),
                      ),
                    );
                }),

          ],
        ),
      ),
    );


  }

  void _viewDialog(transactionsList) {
    if(transactionsList.categorytype == null && transactionsList.transactionDescription == null ){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList.transactionType}  \$${transactionsList.amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("No description for this transaction!"),
              ),
            );
          });
    }else if(transactionsList.categorytype == null){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList.transactionType}  \$${transactionsList.amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("Description:"),
                subtitle: new Text("${transactionsList.transactionDescription}"),
              ),
            );
          });
    }else if(transactionsList.transactionDescription == null){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList.categorytype} ${transactionsList.transactionType}  \$${transactionsList.amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("No description for this transaction!"),
              ),
            );
          });
    }else{
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList.categorytype} ${transactionsList.transactionType}  \$${transactionsList.amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("Description:"),
                subtitle: new Text("${transactionsList.transactionDescription}"),
              ),
            );
          });
    }

  }
}
