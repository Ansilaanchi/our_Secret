import 'dart:math';
import 'package:flutter/material.dart';
import 'package:secret_note/backgroundColors.dart';
import 'package:secret_note/editScreen.dart';
import 'package:secret_note/note.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<Note> filteredNotes = [];
  bool sorted = false;

  @override
  void initState() {
    super.initState();
    filteredNotes = sampleNotes;
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes.where((note) =>
          note.content.toLowerCase().contains(searchText.toLowerCase()) ||
          note.title.toLowerCase().contains(searchText.toLowerCase())).toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      filteredNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      filteredNotes = sortNotesByModifiedTime(filteredNotes);
                    });
                  },
                  icon: Icon(
                    Icons.sort,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: onSearchTextChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search notes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 30),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    color: getRandomColor(index),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EditScreen(note: filteredNotes[index]),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              int originalIndex =
                                  sampleNotes.indexOf(filteredNotes[index]);

                              sampleNotes[originalIndex] = Note(
                                id: sampleNotes[originalIndex].id,
                                title: result[0],
                                content: result[1],
                                modifiedTime: DateTime.now(),
                              );

                              filteredNotes[index] = Note(
                                id: filteredNotes[index].id,
                                title: result[0],
                                content: result[1],
                                modifiedTime: DateTime.now(),
                              );
                            });
                          }
                        },
                        title: RichText(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: '${filteredNotes[index].title} \n',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: filteredNotes[index].content,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Edited: ',
                            // 'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final result = await confirmDialog(context);
                            if (result != null && result) {
                              deleteNote(index);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              sampleNotes.add(Note(
                id: sampleNotes.length,
                title: result[0],
                content: result[1],
                modifiedTime: DateTime.now(),
              ));
              filteredNotes = sampleNotes;
            });
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          size: 38,
        ),
      ),
    );
  }

  Color getRandomColor(int index) {
    Random random = Random(filteredNotes[index].id);
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          icon: const Icon(
            Icons.info,
            color: Colors.grey,
          ),
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(color: Colors.white),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
