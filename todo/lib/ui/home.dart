import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:toast/toast.dart';

import 'package:todo/models/task.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isChecked = false;
 
  TextEditingController _textEditingController;

  List<Task> _tasks = [];

  final String baseUrl = 'https://tiny-list.herokuapp.com/';

  @override
  void initState(){

    _textEditingController = TextEditingController();

    super.initState();
  }
  
  @override
  void dispose(){

    _textEditingController.dispose();

    super.dispose();
  }

  //HELPER FUNCTIONS

//DELETE TASK

  deleteTask(int index,Task task,context) async{

     try{

      var response = await http.delete(baseUrl+"api/v1/users/137/tasks/${task.id}",headers: {"Content-Type":"application/json"});

      print(response.statusCode);

      if(response.statusCode == 200 || response.statusCode == 204){

        print("Task deleted");

      Toast.show("Task deleted!", context);

    
      }


    }

    catch(er){

      print(er.toString());

      Toast.show("An unknown error occured!", context);
    }

    setState(() {
      
      _tasks.removeAt(index);

    });
  }


//FETCH TASKS


   fetchTasks() async {

    try{

      var res = await http.get(baseUrl+"api/v1/users/137/tasks");

      var response = json.decode(res.body);

      if(res.statusCode == 200 || res.statusCode == 201){

        List<Task> _uncompletedTasks = [];

        List<Task> _completedTasks = [];

        for(int i = 0;i < response.length ; i++){

          var task = response;

          var _checked = task[i]['completed_at'] == null ? false : true;

          var _completed = task[i]['completed_at'];

          var _updatedAt = task[i]['updated_at'];

    //COMPLETED TASKS

          if(_checked) {

            _completedTasks.add(Task(checked: _checked,completedAt: _completed , updatedAt: _updatedAt , task: task[i]['description'],id: task[i]['id'].toString()));

          }

//UN COMPLETED TASKS 

          else{

            _uncompletedTasks.add(Task(checked: _checked,completedAt: _completed , updatedAt: _updatedAt , task: task[i]['description'],id: task[i]['id'].toString()));


          }

          // setState(() {
            
          // });

        }

        return sortTasks(_completedTasks,_uncompletedTasks);
      }

     // Toast.show("Success!", context);


    }

    catch(er){

      print("An error occured!");

      print(er.toString());

      Toast.show("An unknown error occured!", context);

      return null;
    }




  }


  //SORT TASKS

  sortTasks(List<Task> _completedTasks,List<Task> _uncompletedTasks){

          _completedTasks.sort((task1,task2){

           return task2.updatedAt.compareTo(task1.updatedAt);

          });

            _uncompletedTasks.sort((task1,task2){

           return task2.updatedAt.compareTo(task1.updatedAt);

          });

          _tasks = _uncompletedTasks + _completedTasks;

          return _tasks ;


  }



//CREATE A NEW TASK

  createTask(Task task) async {

    try{

      var data = {'task': {'description': task.task}};

      var response = await http.post(baseUrl+"api/v1/users/137/tasks",body: json.encode(data),headers: {"Content-Type":"application/json"});

      print(response.statusCode);

      

      if(response.statusCode == 200 || response.statusCode == 201){

      Toast.show("Task created!", context);

    
      }


    }

    catch(er){

      print(er.toString());

      Toast.show("An unknown error occured!", context);
    }




  }


//UPDATE A TASK

updateTask(Task task) async{

  try{

    var data = {'task' : {'description' : task.task}};

    print(task.id);

    var res = await http.put(baseUrl+"api/v1/users/137/tasks/${task.id}",body: json.encode(data),headers: {"Content-Type":"application/json"});
   
    print(res.statusCode);

    print(res.body);

    if(res.statusCode == 200){

      Toast.show("Task updated!", context);

      setState(() {
        
      });

      print(res.body);
    }
  }

  catch(er){

    print(er.toString());

    Toast.show("Unable to update. Try again!", context);
  }
}




//COMPLETED TASKS

 completeTask(String id) async{

   try{

     var data = {"completed_at" : DateTime.now().toIso8601String()};

     print(id);

     var res = await http.put(baseUrl + 'api/v1/users/137/tasks/$id/completed',body: json.encode(data),headers: {"Content-Type":"application/json"});

     print(res.statusCode);

      if(res.statusCode == 200){

        Toast.show("Task completed!", context);

        print("Task completed!");

      }
   }

   catch(er){

     print(er.toString());

     Toast.show("Unable to complete task!", context);

   }
 }


//UN COMPLETED TASKS

 unCompleteTask(String id) async{

   try{

     var data = {"completed_at" : null};

     print(id);

     var res = await http.put(baseUrl + 'api/v1/users/137/tasks/$id/uncompleted',body: json.encode(data),headers: {"Content-Type":"application/json"});

     print(res.statusCode);

      if(res.statusCode == 200){

        Toast.show("Task pending!", context);

        print("Task pending!");
        
      }
   }

   catch(er){

     print(er.toString());

     Toast.show("An error occured.Try again!", context);

   }
 }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text('ToDo List'),

        centerTitle: true,


      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(10),

          child: Column(

           children: [

             Container(

               child : Form(

                child :  buildTextFormField()
               )
             ),
          

          SizedBox(height: 20,),

          Divider(),

          //DISPLAYING LIST ITEMS

            buildFutureBuilder()
          
           ],
            ),
        ),
      ),
      
    );
  }

  TextFormField buildTextFormField() {
    return TextFormField(

                controller: _textEditingController,

                autofocus: false,         

                onFieldSubmitted: (val){

                  if(val.length > 0 ){

                     setState(() {
                    
                    _tasks.add(Task(task: val,checked: false));

                  createTask(Task(task: val,checked: false));
                    
                  });

                  }

                },

                textAlign: TextAlign.center,

                decoration: InputDecoration(

                  hintText: "+ Add to list ",

                  hintStyle: const TextStyle(color: Colors.black,fontSize: 20,),

                  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

                  suffix: IconButton(icon: Icon(Icons.close),onPressed: ()=> _textEditingController.clear(),)
                ),


               );
  }


//FUTURE BUILDER TO LOAD TASKS

  FutureBuilder buildFutureBuilder() {

    return FutureBuilder(

            future: fetchTasks(),

            builder  :  (context,snapshot ) {

              print(snapshot.data);

              print(snapshot.connectionState);

              print(snapshot.hasData);

              if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){

                return ListView.builder(

              shrinkWrap: true,

               itemCount: _tasks.length,
               
                 itemBuilder  : (BuildContext context,int index) {

                print(_tasks[index].task);
                   
               return  Column(

                 children: [

                   Container(

                    
                     decoration: BoxDecoration(           

                     color: _tasks[index].checked ? Colors.grey[350] : Colors.white
                     
                    ),

                    child: Row
                    (

                      children: [

                        
                        Checkbox(

                        value: _tasks[index].checked,

                        onChanged: (val){ 

                          setState(() {

                           _tasks[index].checked = val;

                           val == true ? completeTask(_tasks[index].id):unCompleteTask(_tasks[index].id);



                          });

                        },


                      ),

                      Expanded(
                        
                        child:
                        
                        _tasks[index].checked ? 

                        Text(_tasks[index].task, style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: 20),) 
                        
                        
                        : 
                        
                         TextFormField(

                          initialValue: _tasks[index].task,

                          style: const TextStyle(fontSize : 20 ),

                          decoration: InputDecoration(

                            border: InputBorder.none,

                          
                          ),


                      onFieldSubmitted: (val){

                        if(val.length > 0 ){

                           setState(() {

                             bool _checked = _tasks[index].checked;

                             String id = _tasks[index].id;

                           _tasks.removeAt(index);
                          
                          _tasks.insert(index,Task(task: val,checked: _checked));

                          updateTask(Task(task: val,checked: _checked,id: id));
                          
                        });

                        }

                        print("Submitted");


                      },

                      onChanged: (val){

                       //  setState(() {
                          
                       //    task = val.trim();

                       //  });

                        print("change");


                      },


                          

                        
                        )),

                      IconButton(

                        icon: Icon(Icons.delete,color: Colors.grey,),

                        onPressed: (){

                          deleteTask(index,_tasks[index],context);

                          print("Item deleted");
                        },
                      ),
                   


                      ],
                   
                    )
              ),
                  
                  SizedBox(height: 10,),

                   Divider()
                  
                 ],
               );
                 }
            );
         
              }

              else{

                return Center(child: CircularProgressIndicator(),);
              }
            }


            
            
         
          );
  }
}


  