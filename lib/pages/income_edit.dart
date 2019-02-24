import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/ads.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/utils/database_helper.dart';
import '../pages/home.dart';
class EditIncome extends StatefulWidget {
  int incomeId;
  double incomeAmount;
  String incomeDescription;
  String incomeCategory;

  EditIncome(this.incomeAmount, this.incomeId, {this.incomeDescription, this.incomeCategory});

  @override
  _EditIncomeState createState() => _EditIncomeState();
}

class _EditIncomeState extends State<EditIncome> {
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
    if(widget.incomeDescription == "" || widget.incomeDescription == null){
      description = " no description";
    }else{
      description = widget.incomeDescription;
    }


    if(widget.incomeCategory == "" || widget.incomeCategory == null){
      categoryToDisplay = "";
      category = "";
    }else{
      categoryToDisplay = widget.incomeCategory;
      category = widget.incomeCategory;
    }


    getIncomeCategories();
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
                  initialValue: widget.incomeAmount.toString(),
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
                  initialValue: description,
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
                  validator: (val) => val == "" ? val : null,
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
          db.updateIncome(income, description, category, widget.incomeId);
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }, child: Icon(Icons.edit), backgroundColor: Colors.blue.shade900,),

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

