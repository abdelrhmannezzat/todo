import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// 1.Create database / tables
// 2.Open database
// 3.Insert to database
// 4.Get from database

class Homelayout extends StatefulWidget {
  @override
  State<Homelayout> createState() => _HomelayoutState();
}

class _HomelayoutState extends State<Homelayout> {
  int index = 0;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  bool isBottomSheet = false;
  Database ?database;
  List<Map> tasks = [];
  List<Widget> screen = [
    Center(
      child: Column(
        children: [
          Text("New task"),
        ],
      ),
    ),
    Center(
      child: Column(
        children: [
          Text("Tasks"),
        ],
      ),
    ),
    Center(
      child: Column(
        children: [
          Text("Archived"),
        ],
      ),
    ),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createDatabase();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("TODO App"),
        centerTitle: true,
      ),
      body: screen[index],
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if (isBottomSheet){
            if (formKey.currentState!.validate()){
              insertDatabase(titleController.text, timeController.text);
              Navigator.pop(context);
              isBottomSheet = false;
            }
          }
          else{
            scaffoldKey.currentState!.showBottomSheet((context)=>
              Container(
                padding: EdgeInsets.all(20.0),
                color: Colors.grey[200],
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        validator: (String ?value){
                          if (value!.isEmpty){
                            return "title must not be empty";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Task title",
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      SizedBox(height: 5.0,),
                      TextFormField(
                        //enabled: false,
                        onTap: (){
                          showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                          ).then((value){
                            timeController.text = value!.format(context).toString();
                          });
                        },
                        controller: timeController,
                        keyboardType: TextInputType.datetime,
                        validator: (String ?value){
                          if (value!.isEmpty){
                            return "time must not be empty";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Task time",
                          prefixIcon: Icon(Icons.alarm),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).closed.then((value){
              isBottomSheet = false;
            });
            isBottomSheet = true;
          }
          //insertDatabase();
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        onTap: (index){
          setState(() {
            this.index = index;
          });
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu),label:"tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline),label:"Done"),
          BottomNavigationBarItem(icon: Icon(Icons.archive),label:"Archived"),
        ],
      ),
    );
  }

  void createDatabase() async {
     database = await openDatabase(
      'todo.db',
       version: 1,
       onCreate: (database,version){
          database.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)').then((value) => (){
            print("Database created");
          }).catchError((error){
            print("An error occurred ${error.toString()}");
          });
       },
       onOpen: (database)
       {
         getDatafromDatabase(database).then((value){
           tasks = value;
         });
         print("Database opened");
       },
    );
  }
  Future insertDatabase(String title,String time) async{
    return database!.transaction((txn)async{
      await txn.rawInsert('INSERT INTO tasks(title,date,time,status) VALUES("$title","345","$time","new")').then((value){
        print("$value Inserted successfully");
      }).catchError((error){
        print("An error occurred while insering ${error.toString()}");
      });
      
      //return null!;
    });
  }
  Future<List<Map>> getDatafromDatabase(database)async{
    return await database!.rawQuery('SELECT * FROM tasks');
  }
}

