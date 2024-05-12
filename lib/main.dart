import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://crudcrud.com/api/495eacddded544aa9b2c3275f228ebb0/unicorns'));

    if (response.statusCode == 200) {
      setState(() {
        students = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateStudent(
      String id, Map<String, dynamic> updatedStudent) async {
    final response = await http.put(
      Uri.parse(
          'https://crudcrud.com/api/495eacddded544aa9b2c3275f228ebb0/unicorns/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedStudent),
    );

    if (response.statusCode == 200) {
      setState(() {
        int index = students.indexWhere((s) => s['_id'] == id);
        if (index != -1) {
          students[index] = updatedStudent;
        }
      });
    } else {
      throw Exception('Failed to update student');
    }
  }

  void _showEditStudentDialog(Map<String, dynamic> student) {
    final TextEditingController nameController =
        TextEditingController(text: student['name']);
    final TextEditingController classController =
        TextEditingController(text: student['stdClass']);
    bool audience = student['Audience'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: classController,
                decoration: InputDecoration(labelText: 'Class'),
              ),
              Row(
                children: [
                  Text('Audience'),
                  Checkbox(
                    value: audience,
                    onChanged: (bool? value) {
                      audience = value ?? false;
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedStudent = {
                  'name': nameController.text,
                  'stdClass': classController.text,
                  'Audience': audience,
                };

                updateStudent(student['_id'], updatedStudent);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteStudent(String id) {
    setState(() {
      students.removeWhere((student) => student['_id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Table'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 5,
          dataRowMinHeight: 20,
          dataRowMaxHeight: 40,
          columns: const <DataColumn>[
            DataColumn(
              label: Text('Students Name'),
            ),
            DataColumn(
              label: Text('Class'),
            ),
            DataColumn(
              label: Text('    Audience'),
            ),
            DataColumn(
              label: Text('     Action'),
            ),
          ],
          rows: students
              .map(
                (student) => DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(student['name']),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(student['stdClass']),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(student['Audience'] ? "    Yes" : "    No"),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          margin: EdgeInsets.only(right: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditStudentDialog(
                                      student); // Edit function
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteStudent(student['_id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController classController = TextEditingController();
    bool audience = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: classController,
                decoration: InputDecoration(labelText: 'Class'),
              ),
              Row(
                children: [
                  Text('Audience'),
                  Checkbox(
                    value: audience,
                    onChanged: (bool? value) {
                      audience = value ?? false;
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final stdClass = classController.text;
                if (name.isNotEmpty && stdClass.isNotEmpty) {
                  addStudent(name, stdClass, audience);
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStudent(String name, String stdClass, bool audience) async {
    final response = await http.post(
      Uri.parse(
          'https://crudcrud.com/api/495eacddded544aa9b2c3275f228ebb0/unicorns'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'name': name, 'stdClass': stdClass, 'Audience': audience}),
    );

    if (response.statusCode == 201) {
      setState(() {
        students.add(jsonDecode(response.body));
      });
    } else {
      throw Exception('Failed to add student');
    }
  }
}
