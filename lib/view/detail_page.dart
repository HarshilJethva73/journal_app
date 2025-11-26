import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:journal/view/home_page.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final Journal journal;
  const DetailPage({super.key, required this.journal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  
  late TextEditingController titleController;
  late TextEditingController contentController;

  bool _isEdit = false;

  int selectedGradient = 0;

  final List<Color> staticColors = [
    Color(0xFFB5FFFC),
    Color(0xFFFFF1C1),
    Color(0xFFFFD1D1),
    Color(0xFFFAFFD1),
    Color(0xFFA1FFCE),
    Color(0xFFFFD6E8),
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.journal.title.isNotEmpty;

    titleController = TextEditingController(text: widget.journal.title);
    contentController = TextEditingController(text: widget.journal.description);
    selectedGradient = widget.journal.gradientIndex;
  }

  bool canSave() {
    return titleController.text.trim().isNotEmpty &&
        contentController.text.trim().isNotEmpty;
  }

   Future<void> saveJournal() async {
    final prefs = await SharedPreferences.getInstance();

    // Load all journals first
    String? saved = prefs.getString("journals");
    List<Journal> allJournals = [];

    if (saved != null) {
      List<dynamic> jsonList = jsonDecode(saved);
      allJournals = jsonList.map((item) => Journal.fromMap(item)).toList();
    }

    // Update or add the current journal
    int index = allJournals.indexWhere((j) => j.id == widget.journal.id);
    if (index != -1) {
      allJournals[index].title = titleController.text;
      allJournals[index].description = contentController.text;
      allJournals[index].gradientIndex = selectedGradient;
    } else {
      // If not found, add it (fallback)
      allJournals.add(
        Journal(
          id: widget.journal.id,
          title: titleController.text,
          description: contentController.text,
          gradientIndex: selectedGradient,
        ),
      );
    }

    // Save back
    List<Map<String, dynamic>> mapList = allJournals.map((j) => j.toMap()).toList();
    await prefs.setString("journals", jsonEncode(mapList));
  }

   void selectColor() async {
    // Show simple dialog to pick a color
    int? picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select Background Color'),
        children: List.generate(staticColors.length, (index) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, index),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: staticColors[index],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedGradient = picked;
      });
    }
  }

  String getUpdatedOnString() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(widget.journal.id);
    return "Updated on ${DateFormat('dd-MM-yyyy  hh:mm a').format(date)}";
  }

  String getCreatedOnString() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(widget.journal.id);
    return "Created on ${DateFormat('dd-MM-yyyy  hh:mm a').format(date)}";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (canSave()) {
        await saveJournal();
        Navigator.pop(
          context,
          Journal(
            id: widget.journal.id,
            title: titleController.text,
            description: contentController.text,
            gradientIndex: selectedGradient,
          ),
        );
        return false;
        }
        return true;
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFCDEDE),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEdit) ...[
              Text("Edit Note"),
              SizedBox(height: 4),
              Text(
                getUpdatedOnString(),
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ] else ...[
              Text(
                getCreatedOnString(),
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
                if (canSave()) {
              await saveJournal();
               Navigator.pop(
                context,
                Journal(
                  id: widget.journal.id,
                  title: titleController.text,
                  description: contentController.text,
                  gradientIndex: selectedGradient,
                ),
              );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill both title and description.'),
                    ),
                  );
                }
            },
              icon: Icon(Icons.save),
            iconSize: 30,
            tooltip: "Save",
          ),
          IconButton(
            onPressed: selectColor,
            icon: Icon(Icons.color_lens),
            iconSize: 30,
            tooltip: "Select Color",
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: staticColors[selectedGradient],
         child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
        child: Column(
             mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 25),
                Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),

                SizedBox(
                  height: 600,
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Write description...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
