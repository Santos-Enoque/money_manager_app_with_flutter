import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/ads.dart';
import 'package:money_manager/models/master_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/utils/database_helper.dart';
import 'package:money_manager/utils/functions.dart';
import '../pages/home.dart';
class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Functions _functions;
  final GlobalKey<FormState> formkey = new GlobalKey();
  var db = new DatabaseHelper();
  Home home;
  double income;
  String description = "";
  String category = "";
  String categoryToDisplay = " ";
  List<CategoryModel> categoryList = <CategoryModel>[];
  TextEditingController _editCategoryController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getCaegories();
  }



  // we will use this method to retrieve the transactions
  void getCaegories() async {
    List categories;
    categories = await db.getAllCategories();
    print(categories.toString());
    for (int i = 0; i < categories.length; i++) {
      CategoryModel category = CategoryModel.map(categories[i]);
        setState(() {
          categoryList.insert(0, category);
//        getBalance(transactionsList.length);
          print(categoryList.length);
        });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close), onPressed: (){
          Navigator.pop(context);
        }),
        title: new Text("Categories"),
        backgroundColor: Colors.blue.shade900,
        centerTitle: false,
        elevation: 1.0,

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
                        subtitle: Text(categoryList[index].category_type),
                        trailing:
                            IconButton(icon: Icon(Icons.edit), onPressed: (){
                              setState(() {
                                _editCategoryController.text = categoryList[index].category_name;
                              });
                              _showEditCategoryAlert(categoryList[index].category_id);
                            },),
                      );
                    }),
               )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _showCategoryAlert();
      }, child: Icon(Icons.add), backgroundColor: Colors.blue.shade900,),

    );


  }


  void _showEditCategoryAlert(id) {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: _editCategoryController,
              autofocus: true,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "edit category",
                  hintText: "category name"),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              db.updateCategory(_editCategoryController.text ,id);
              setState(() {
                categoryList = <CategoryModel>[];
              });
              getCaegories();
              Navigator.pop(context);
            },
            child: new Text("edit")),

        new FlatButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategoryAlert(id);
            },
            child: new Text("delete category")),
      ],
    );

    showDialog(context: context, builder: (_) => alert);
  }

  void _deleteCategoryAlert(id) {
    var alert = new AlertDialog(
      content: new Text("Are you sure, you want to delete this category?"),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              db.deleteCategory(id);
              setState(() {
                categoryList = <CategoryModel>[];
              });
              getCaegories();
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
            child: new Text("+ Income category")),

        new FlatButton(
            onPressed: () {
              addCategory(_categoryController.text, context, "expense");
            },
            child: new Text("+ Expense category")),
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
}

