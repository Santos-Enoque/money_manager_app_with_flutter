//import 'package:flutter/material.dart';
//import 'package:money_manager/components/alert_dialogs.dart';
//
//class MyDrawer {
//  AlertDialogs _alertDialogs;
//
//  Widget getDrawer(){
//   return Drawer(
//      child: Scaffold(
//        appBar: AppBar(
//          backgroundColor: Colors.blue.shade900,
//          title: new Text("Settings"),
//          centerTitle: true,
//        ),
//        body: Column(
//          children: <Widget>[
//
//            Divider(),
//            Expanded(
//              child: ListView(
//                children: <Widget>[
//
//                  new ListTile(
//                    title: new Text("Show monthly goal"),
//                    trailing: new Switch(value: _showMonthlyGoal, onChanged: _onChanged1),
//                  ),
//
//
//                  new ListTile(
//                    title: new Text("Set monthly goal"),
//                    onTap: (){},
//                  ),
//
//                  new ListTile(
//                    title: new Text("clear datadase"),
//                    onTap: (){
//                      _alertDialogs.deleteDatabaseAlert();
//                    },
//                  ),
//
//
//                  Divider(),
//                  new ListTile(
//                    leading: Icon(Icons.info_outline),
//                    title: new Text("About"),
//                    onTap: (){},
//                  ),
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: new Text("developed by: Santos Enoque", style: TextStyle(color: Colors.grey),),
//            )
//          ],
//        ),
//      ),
//    ),
//  }
//}