import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sqlite_noteapp/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomepage(),
    );
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({super.key});

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> notes = [];

  void _refreshNotes() async {
    final data = await SqlHelper.getItems();
    setState(() {
      notes = data;
      _isLoading = false;
    });
  }

  Future<void> _addNote() async {
    await SqlHelper.createItem(titleController.text, descController.text);
    _refreshNotes();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have successfully added a note!")));
  }

  Future<void> _updateNote(int id) async {
    await SqlHelper.updateItem(id, titleController.text, descController.text);
    _refreshNotes();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have successfully updated a note!")));
  }

  Future<void> _deleteNote(int id) async {
    await SqlHelper.deleteItem(id);
    _refreshNotes();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have successfully deleted a note!")));
  }

  void _showForm(int? id) {
    if (id != null) {
      final existingnote = notes.firstWhere((element) => element["id"] == id);
      titleController.text = existingnote["title"];
      descController.text = existingnote["description"];
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        builder: (_) {
          return Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).primaryColorLight)),
                    onPressed: () async {
                      if (id == null) {
                        await _addNote();
                      } else {
                        await _updateNote(id);
                      }
                      titleController.text = "";
                      descController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? "Create New" : "Update"))
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    _isLoading = true;
    _refreshNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sqflite Note App',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (builder, index) {
                  return Card(
                      color: Theme.of(context).primaryColorLight,
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                          title: Text(
                            notes[index]['title'],
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            overflow: TextOverflow.clip,
                          ),
                          subtitle: Text(
                            notes[index]['description'],
                            softWrap: true,
                            overflow: TextOverflow.clip,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showForm(notes[index]["id"])),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteNote(notes[index]["id"]),
                                ),
                              ],
                            ),
                          )));
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
