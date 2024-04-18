import 'dart:convert';
import 'dart:ui';
import 'package:first_project/screens/add_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddToDo()));
        },
        label: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Todo Lists'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Colors.red]),
              borderRadius: BorderRadius.circular(20)),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: SizedBox(),
        ),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchToDo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                  backgroundColor: Colors.black,
                ),
                title: Text(
                  item['title'],
                ),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      NavigateToAddPage(item);
                    } else if (value == 'delete') {
                      deleteById(id);
                    } else {}
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      //the delete is successfull
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      //show some error message to the user
    }
  }

  Future<void> NavigateToAddPage(Map item) async {
    final route = MaterialPageRoute(builder: ((context) => AddToDo()));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchToDo();
  }

  Future<void> fetchToDo() async {
    //implementation of the api get call
    setState(() {
      isLoading = true;
    });
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    //converting the uri into respective uri
    final uri = Uri.parse(url);
    //sending the request to the server
    final response = await http.get(
      uri,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
//after getting the data we will update the state
      setState(() {
        items = result;
      });
    } else {
      print('Failed to reach and display data from the server');
    }
    //if the code refreshes nothing is observed  that is the api is being called but the data is not displayed in the body
    setState(() {
      isLoading = false;
    });
  }
}
