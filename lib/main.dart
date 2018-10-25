import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ToDo List',
      home: new ToDoList(),
      debugShowCheckedModeBanner: false,
    );
  }


}

class ToDoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ToDoListState();
  }

}

class ToDoListState extends State<ToDoList> {
  List<String> _todoItems = [];

  @override
  void initState() {
    /*  new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('ToDo').snapshots(),
      builder: (context, snapshot) {
        final x = snapshot.data.documents;
        for (var value in x) {
          //  final record = Record.fromSnapshot(value);
          setState(() {
            _todoItems.add(value.data['title']);
          });
        }
      },
    );*/

    Firestore.instance.collection('ToDo').document().get().then((snap) {
      debugPrint('data=${snap.data}');
      /*  for (var i = 0; i < 5; i++) {
        setState(() {

        });
      }*/
    });

    // TODO: implement initState
    /* Firestore.instance
        .collection('ToDo')
        .document('6C1RLnbz2cSq1Y1reNrE')
        .get()
        .then((documentsnap) {
      setState(() {
        _todoItems.add(documentsnap.data['title']);
      });
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('ToDo List'),
      ),
      body: _buildToDoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddToDoScreen,
        child: new Icon(Icons.add),
        tooltip: "add Todo task",
      ),
    );
  }


  Widget _buildToDoList() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('ToDo').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return new Text('Loading...');

          return ListView(
            children: snap.data.documents.map((doc) {
              return new ListTile(
                title: Text(doc['title']),
                onTap: () => _promptRemoveToDoItem(doc.documentID),
                onLongPress: () => _updateToDo(doc.documentID, doc['title']),
              );
            }).toList(),
          );
        });
  }

  /*Widget _todoListView(AsyncSnapshot<QuerySnapshot> snap) {
    return ListView.builder(
      itemBuilder: (context, index) {
        snap.data.documents.map((doc) {
          return _buildTodoItem(doc['title'], index);
        });
      },
    );
  }*/

  /*Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
        title: new Text(todoText), onTap: () => _promptRemoveToDoItem(index));
  }*/

  void _updateToDo(String id, String todo) {
    Navigator.of(context).push(new MaterialPageRoute(

        builder: (context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Update Todo'),
        ),
        body: new TextField(
          autofocus: true,
          onSubmitted: (val) {
            _updateToDoFireStore(val, id);

            Navigator.pop(context);
          },
          decoration: new InputDecoration(
              hintText: todo,
              contentPadding: const EdgeInsets.all(16.0)),
        ),
      );
    }));
  }

  void _updateToDoFireStore(String val, String id) {
    Firestore.instance
        .collection('ToDo')
        .document(id)
        .updateData({'title': val});
  }

  void _pushAddToDoScreen() {
    Navigator.of(context).push(new MaterialPageRoute(
        //ToDO:

        builder: (context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Add Your ToDo here'),
        ),
        body: new TextField(
          autofocus: true,
          onSubmitted: (val) {
            _addTodoItem(val);

            Navigator.pop(context);
          },
          decoration: new InputDecoration(
              hintText: 'Enter your todo',
              contentPadding: const EdgeInsets.all(16.0)),
        ),
      );
    }));
  }

  void _addTodoItem(String task) {
    if (task.length > 0) {
      setState(() {
        Firestore.instance
            .collection('ToDo')
            .document()
            .setData({'title': task, 'isCompleted': true});
        initState();
      });
    }
  }

  void _promptRemoveToDoItem(String index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Mark as done?'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    setState(() {
                      _deleteTodo(index);
                    });
                    Navigator.of(context).pop();
                  },
                  child: new Text('Mark As Done?')),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel'))
            ],
          );
        });
  }

  void _deleteTodo(String index) {
    Firestore.instance.collection('ToDo').document(index).delete();
  }
}

/*
import 'package:flutter/material.dart';


void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Todo List',
        home: new TodoList()
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Todo List')
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoScreen, // pressing this button now opens the new screen
          tooltip: 'Add task',
          child: new Icon(Icons.add)
      ),
    );
  }


  void _addTodoItem(String task) {
    // Only add the task if the user actually entered something
    if(task.length > 0) {
      setState(() => _todoItems.add(task));
    }
  }

  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if(index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }
  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
        title: new Text(todoText),
        onTap: () => _promptRemoveTodoItem(index)
    );
  }


  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well
      // as adding a back button to close it
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text('Add a new task')
                  ),
                  body: new TextField(
                    autofocus: true,
                    onSubmitted: (val) {
                      _addTodoItem(val);
                      Navigator.pop(context); // Close the add todo screen
                    },
                    decoration: new InputDecoration(
                        hintText: 'Enter something to do...',
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );
  }

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_todoItems[index]}" as done?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('MARK AS DONE'),
                    onPressed: () {
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }
}
*/
