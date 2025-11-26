import 'package:flutter/material.dart';
import 'package:journal/view/detail_page.dart';
// import 'package:journal/view/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


class Journal {
  final int id;
  String title;
  String description;
  int gradientIndex;

  Journal({
    required this.id,
    required this.title,
    this.description = "",
    this.gradientIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'gradientIndex': gradientIndex,
    };
  }

  static Journal fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      gradientIndex: (map['gradientIndex'] is int)
          ? map['gradientIndex']
          : int.tryParse(map['gradientIndex']?.toString() ?? '') ?? 0,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Journal> _journals = [];
  List<Journal> _allJournals = [];

  bool _isAscending = false; // Sorting order flag, default descending

  final List<Color> staticColors = [
    Color(0xFFB5FFFC),
    Color(0xFFFFF1C1),
    Color(0xFFFFD1D1),
    Color(0xFFFAFFD1),
    Color(0xFFA1FFCE),
    Color(0xFFFFD6E8),
  ];

  String getCreatedOnString(Journal journal) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(journal.id);
    return "Created on ${DateFormat('dd-MM-yyyy  hh:mm a').format(date)}";
  }

  String getUpdatedOnString(Journal journal) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(journal.id);
    return "Updated on ${DateFormat('dd-MM-yyyy  hh:mm a').format(date)}";
  }

  @override
  void initState() {
    super.initState();
    loadJournals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> saveJournals() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mapList = _allJournals
        .map((j) => j.toMap())
        .toList();

    await prefs.setString("journals", jsonEncode(mapList));
  }

  Future<void> loadJournals() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString("journals");

    if (saved != null) {
      List<dynamic> jsonList = jsonDecode(saved);

      setState(() {
        _allJournals = jsonList.map((item) => Journal.fromMap(item)).toList();
        _allJournals.sort(
          (a, b) => b.id.compareTo(a.id),
        ); // Sort descending by id
        _journals = List.from(_allJournals);
      });
    }
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _journals = List.from(_allJournals);
      } else {
        _journals = _allJournals
            .where((j) => j.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      if (_isAscending) {
        _allJournals.sort((a, b) => a.id.compareTo(b.id)); // Ascending
      } else {
        _allJournals.sort((a, b) => b.id.compareTo(a.id)); // Descending
      }
      // Update filtered list with current search filter
      String query = _searchController.text;
      if (query.isEmpty) {
        _journals = List.from(_allJournals);
      } else {
        _journals = _allJournals
            .where((j) => j.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void addJournal(String title) {
    if (title.isEmpty) return;
    setState(() {
      int id = DateTime.now().millisecondsSinceEpoch;
      Journal newEntry = Journal(id: id, title: title);

      _allJournals.add(newEntry);
      _allJournals.sort(
        (a, b) => b.id.compareTo(a.id),
      ); // Sort descending by id
      _journals = List.from(_allJournals);
    });
    saveJournals();
  }

  void deleteJournal(int id) {
    setState(() {
      _allJournals.removeWhere((journal) => journal.id == id);
      _journals.removeWhere((journal) => journal.id == id);
    });

    saveJournals();
  }

void navigateToAddJournal() async {
    int newId = DateTime.now().millisecondsSinceEpoch;
    Journal newJournal = Journal(id: newId, title: '', description: '');

    final createdJournal = await Navigator.push<Journal>(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(journal: newJournal)),
    );

    FocusScope.of(context).requestFocus(FocusNode());

    if (createdJournal != null) {
      setState(() {
        _allJournals.add(createdJournal);
        _allJournals.sort(
          (a, b) => b.id.compareTo(a.id),
        ); // Sort descending by id
        _journals = List.from(_allJournals);
      });
      saveJournals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal created!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void showAlert() {
    // alert box for delete confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Confirmation"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                // calls deleteJournal function
                deleteJournal(_journals.first.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEDE7FF),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Memoir",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Image.asset('assets/images/logo.png', height: 40),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF8FF), Color(0xFFF2F3F7), Color(0xFFF5F2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
              child: TextField(
                controller: _searchController,
                      focusNode: _searchFocusNode,
                onChanged: filterSearch,
                      autofocus: false,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: toggleSortOrder,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      ),
                    ),
                  ],
              ),
            ),

            SizedBox(height: 10),

            Expanded(
        child: _journals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create your first note!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: navigateToAddJournal,
                      child: Text("Add Note"),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _journals.length,
                itemBuilder: (context, index) {
                  final note = _journals[index];
                  return InkWell(
                    onTap: () async {
                      final updatedJournal = await Navigator.push<Journal>( context, MaterialPageRoute(builder: (_) => DetailPage(journal: note),
                      ),
                      );
                            FocusScope.of(context).requestFocus(FocusNode());

                       if (updatedJournal != null) {
                        setState(() {
                          int updateIdx = _allJournals.indexWhere(
                            (element) => element.id == updatedJournal.id,
                          );
                          if (updateIdx != -1) {
                            _allJournals[updateIdx] = updatedJournal;
                          }

                          int displayIdx = _journals.indexWhere(
                            (element) => element.id == updatedJournal.id,
                          );
                          if (displayIdx != -1) {
                            _journals[displayIdx] = updatedJournal;
                          }
                        });
                        saveJournals();

                              bool hasChanged =
                                  updatedJournal.title != note.title ||
                                  updatedJournal.description !=
                                      note.description ||
                                  updatedJournal.gradientIndex !=
                                      note.gradientIndex;
                              if (hasChanged) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Journal updated!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: staticColors[note.gradientIndex],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(50),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [ 
                            Text(
                              note.title,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                  note.description.isNotEmpty
                                      ? note.description
                                      : "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                                SizedBox(height: 4),
                                Text(
                                  (note.id == _journals.first.id)
                                      ? getCreatedOnString(note)
                                      : getUpdatedOnString(note),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.black54),
                              iconSize: 30,
                              onPressed: () {
                                        showAlert();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                    ),
            ),
          ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddJournal,
        tooltip: 'Add Journal',
        child: const Icon(Icons.add),
      ),
    );
  }
}
