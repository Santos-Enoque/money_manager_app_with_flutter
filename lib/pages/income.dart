import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/ads.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/utils/database_helper.dart';
import '../pages/home.dart';
class AddIncome extends StatefulWidget {
  String incomeAmount;

  AddIncome(this.incomeAmount);

  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final GlobalKey<FormState> formkey = new GlobalKey();
  var db = new DatabaseHelper();
  Home home;
  int radioGroupValue;
  double income;
  String description = "";
  String category = "";
  String categoryToDisplay = " ";
  final List<CategoryModel> categoryList = <CategoryModel>[];
  TextEditingController _categoryController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    categoryToDisplay = "";
    category = "";
    getIncomeCategories();
  }

  void addTransaction(double amount, String transaction,
      {String category, String description}) async {

    var now = new DateTime.now();
    var day = new DateFormat('dd');
    var weekDay = new DateFormat('EEEE');
    var month = new DateFormat('MMM');
    var year = new DateFormat('y');

    String getDayString = day.format(now);
    String weekDayString = weekDay.format(now);
    String monthString = month.format(now);
    String yearString = year.format(now);
    int convertYear =int.parse(yearString);




    //Add transaction
    int transactionId = await db.insertTransaction(
        new Master(getDayString, weekDayString, monthString, convertYear, amount, transaction, categorytype: category, transactionDescription: description));
//    get the added transaction
    Master item = await db.getSingleTransaction(transactionId);
    Ads.showFullScreenAd();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    print(transactionId);
  }

  // we will use this method to retrieve the transactions
  void getIncomeCategories() async {
    List categories;
    categories = await db.getAllCategories();
    print(categories.toString());
    for (int i = 0; i < categories.length; i++) {
      CategoryModel category = CategoryModel.map(categories[i]);
      if(category.category_type == "income"){
        setState(() {
          categoryList.insert(0, category);
//        getBalance(transactionsList.length);
          print(categoryList.length);
        });
      }
    }
  }

  void _showCategoryAlert() {
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
              addCategory(_categoryController.text, context, "income");
            },
            child: new Text("add category")),

      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void addCategory(String categoryName, context, categoryType) async{
    int categoryId = await db.insertCategory(CategoryModel(categoryName, categoryType));
    CategoryModel item = await db.getSingleCategory(categoryId);
    setState(() {
      categoryList.insert(0, item);
    });
    Navigator.pop(context);
    print(categoryId);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.close), onPressed: (){
            Navigator.pop(context);
          }),
          title: new Text("Income"),
          backgroundColor: Colors.blue.shade900,
          centerTitle: false,
          elevation: 1.0,
          actions: <Widget>[
            FlatButton(
              color: Colors.blue.shade700,
              textColor: Colors.white,
              onPressed: (){
                _showCategoryAlert();
              },
              child: Text("add category"),
            )
          ],

        ),

        drawer: Drawer(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue.shade900,
              title: new Text("Settings"),
              centerTitle: true,
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[

//                    new ListTile(
//                      leading: Icon(Icons.add_alert),
//                      title: new Text("Notifications"),
//                      trailing: new Switch(value: notificationVal, onChanged: _onChanged1),
//                    ),

                      new ListTile(
                        leading: Icon(Icons.clear),
                        title: new Text("clear datadase"),
                        onTap: (){},
                      ),

//                    new ListTile(
//                      leading: Icon(Icons.language),
//                      title: new Text("Language"),
//                      onTap: (){},
//                    ),
                      Divider(),
                      new ListTile(
                        leading: Icon(Icons.info_outline),
                        title: new Text("About"),
                        onTap: (){},
                      ),
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
        ),
        body: Center(
          child: Form(
            key: formkey,
            child: Column(
//            direction: Axis.vertical,
              children: <Widget>[
                Padding(padding: EdgeInsets.all(15)),
                ListTile(
                  title: TextFormField(
                    initialValue: widget.incomeAmount,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Add ncome",
                        hintText: ""),
                    onSaved: (val) {
                      setState(() {
                        income = double.parse(val);
                      });
                    },
                    validator: (val) => val == "" ? val : null,
                  ),
                ),

                ListTile(
                  title: TextFormField(
                    initialValue: "",
                    autocorrect: true,
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Add description",
                        hintText: ""),
                    onSaved: (val){
                      setState(() {
                        description = val;
                      });
                    },
//                    validator: (val) => val == "" ? val : null,
                  ),
                ),

                Divider(),
                Padding(padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Category:", style: TextStyle(color: Colors.black),),
                ),
                   _displaySelectedCategory(),
                  ],
                ),),
                Divider(),

                  Expanded(
                    child: ListView.builder(
                        itemCount: categoryList.length,
                        itemBuilder: (_, index){
                          return ListTile(
                            title: Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.category, color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                      child: Text("${categoryList[index].category_name}", style: TextStyle(color: Colors.blue.shade900, fontSize: 20.0, ),),
                                    ),
                                  ],
                                )),
                            onTap: (){
                              setState(() {
                                categoryToDisplay = categoryList[index].category_name;
                                category = categoryList[index].category_name;
                              });
                            },
                          );
                        }),
                  )


              ],
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        final FormState form = formkey.currentState;
        if (form.validate()) {
          form.save();
          form.reset();
          addTransaction(income, "income", category: category, description: description);
        }
      }, child: Icon(Icons.add), backgroundColor: Colors.blue.shade900,),

    );
    
    
  }


 Widget _displaySelectedCategory() {
    if(categoryToDisplay == ""){
      return Container();
    }else{
      return  Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: MaterialButton(
              onPressed: (){
                setState(() {
                  categoryToDisplay = "";
                  category = "";
                });
              },
              child: Material(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(5.0),
                child: Row(
                    children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:8.0, right: 8.0),
                      child: new Text(categoryToDisplay, style: TextStyle(color: Colors.white,  fontSize: 18.0),),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: new Icon(Icons.close, color: Colors.white, size: 18.0,),
                  )
                  ],
                ),
              )),
   );
    }
 }
}

