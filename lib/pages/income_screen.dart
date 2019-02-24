import 'package:flutter/material.dart';
//my own imports
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/home.dart';
import 'package:money_manager/utils/database_helper.dart';
import 'package:money_manager/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/ads.dart';

class ViewIncome extends StatefulWidget {
  final List<Master> data;

  ViewIncome(this.data);

  @override
  _ViewIncomeState createState() => _ViewIncomeState();
}

class _ViewIncomeState extends State<ViewIncome> {
  Functions _functions = new Functions();

   List<Master> transactionsList = <Master>[];
  final List<CategoryModel> categoryList = <CategoryModel>[];


  bool visible;
  SharedPreferences preferences;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double currentBalance = 0.0;

  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
    transactionsList = widget.data;
    Ads.setBannerAd();
  } //  the initial



//  this method will return a different icon depending on the transaction
  Widget _returnIcon(String transactionType) {
    if(transactionType == "income"){
      return Icon(Icons.attach_money, color: Colors.green,);
    }
  }


// this will return a different amount depending on the transaction
  Widget _returnAmount(String transactiontype, String category ,double amount) {
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
        title: new Text("All incomes"),
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
                itemCount: transactionsList.length,
                itemBuilder: (context, int index){
                  if(transactionsList[index].transactionType == "income"){
                    return Visibility(
                      child: Card(color: Colors.grey.shade50,
                        child: ListTile(
                          leading: _returnIcon(transactionsList[index].transactionType),
                          title: _returnAmount(transactionsList[index].transactionType, transactionsList[index].categorytype ,transactionsList[index].amount),
                          subtitle: _functions.displayDate(transactionsList[index].transactionDay, transactionsList[index].transactionMonth, transactionsList[index].transactionYear, transactionsList[index].transactionWeekDay),
                          trailing: FlatButton(onPressed: (){
                            _viewDialog(index, transactionsList);
                          }, child: Text("view")),
                        ),
                      ),
                    );
                  }else{
                    return Visibility(
                      child: Card(color: Colors.grey.shade50,
                      ),
                    );
                  }
                  }),

          ],
        ),
      ),
    );


}

  void _viewDialog(int index, List<Master> transactionsList) {
    if(transactionsList[index].categorytype == null && transactionsList[index].transactionDescription == null ){
      showDialog(context: context,
          builder: (_){
            return new AlertDialog(
              title:
              new Text("${transactionsList[index].transactionType}  \$${transactionsList[index].amount}", style: TextStyle(color: Colors.blue.shade900),),
              content: new ListTile(
                title: new Text("No description for this transaction!"),
              ),
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
            );
          });
    }

  }
}
