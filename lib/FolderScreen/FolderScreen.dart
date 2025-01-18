import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'FileScreen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref('users');
  final TextEditingController _folderController = TextEditingController();

  List<Map<String, dynamic>> folders = [];
  bool _isLoading = false;
  String _editedFolderName = "";

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _databaseRef.child(userId).child('folders').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        folders = data.entries.map((entry) {
          return {
            'key': entry.key,
            'name': entry.value['name'],
          };
        }).toList();
      });
    } else {
      setState(() {
        folders = [];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addFolder() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final folderName = _folderController.text.trim();

    if (folderName.isNotEmpty) {
      // Check if the folder already exists
      final snapshot = await _databaseRef.child(userId).child('folders').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        bool folderExists = data.entries.any((entry) => entry.value['name'] == folderName);

        if (folderExists) {
          // Show message if the folder already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder already exists')),
          );
          return;
        }
      }

      final newFolderRef = _databaseRef.child(userId).child('folders').push();
      await newFolderRef.set({
        'name': folderName,
      });
      _folderController.clear();
      _fetchFolders();
    }
  }

  Future<void> _deleteFolder(String folderId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await _databaseRef.child(userId).child('folders').child(folderId).remove();
    _fetchFolders();
  }

  Future<void> _editFolder(String folderId, String folderName) async {
    setState(() {
      _editedFolderName = folderName;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Folder Name"),
          content: TextField(
            controller: TextEditingController(text: folderName),
            onChanged: (value) {
              _editedFolderName = value;
            },
            decoration: const InputDecoration(hintText: "New folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_editedFolderName.isNotEmpty) {
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  await _databaseRef
                      .child(userId)
                      .child('folders')
                      .child(folderId)
                      .update({'name': _editedFolderName});
                  Navigator.pop(context); // Close the dialog
                  _fetchFolders();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteFolder(String folderId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Folder"),
          content: const Text("Are you sure you want to delete this folder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteFolder(folderId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // New method to confirm delete all folders
  Future<void> _confirmDeleteAllFolders() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete All Folders"),
          content: const Text("Are you sure you want to delete all folders?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                await _databaseRef.child(userId).child('folders').remove();
                _fetchFolders();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: Colors.blue),
                    title: Text(folder['name']),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editFolder(folder['key'], folder['name']);
                        } else if (value == 'delete') {
                          _confirmDeleteFolder(folder['key']);
                        }
                      },
                    ),
                    onTap: () {
                      // Navigate to file screen for folder
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FileScreen(folderKey: folder['key']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Folder'),
                content: TextField(
                  controller: _folderController,
                  decoration: const InputDecoration(hintText: "Folder name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _addFolder();
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      // New Delete All button below the floating action button
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: _confirmDeleteAllFolders, // Calls the method to delete all folders
            child: const Text('Delete All Folders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Change button color to red
            ),
          ),
        ),
      ],
    );
  }
}
