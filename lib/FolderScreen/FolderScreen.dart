import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loginScreen.dart';
import 'FileScreen.dart';


class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final TextEditingController _folderController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Controller for the search bar

  List<Map<String, dynamic>> folders = [];
  List<String> selectedFolders = []; // To store selected folder keys
  bool _isLoading = false; // To track loading state
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user ID
    if (_userId != null) {
      _fetchFolders();
    }

    // Add listener to the search text field
    _searchController.addListener(() {
      setState(() {});
    });
  }

  // Fetch folders from Firebase for the logged-in user
  Future<void> _fetchFolders() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final snapshot = await _database.ref("users/$_userId/folders").get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        folders = data.entries
            .map((entry) {
          final folderName = entry.value['name'];
          return {
            "key": entry.key,
            "name": folderName != null && folderName is String
                ? folderName
                : 'Unnamed Folder',
          };
        })
            .toList();
      });
    } else {
      setState(() {
        folders = [];
      });
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  // Fetch the file count inside a folder from Firebase
  Future<int> _fetchFileCount(String folderKey) async {
    final filesRef = _database.ref('users/$_userId/folders/$folderKey/files');
    final snapshot = await filesRef.get();
    if (snapshot.exists) {
      final files = snapshot.value as Map<dynamic, dynamic>;
      return files.length;
    }
    return 0;
  }

  // Add a new folder to Firebase for the current user
  Future<void> _addFolder(String folderName) async {
    bool folderExists = folders.any((folder) => folder['name'] == folderName);
    if (folderExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This folder name is already in use. Kindly choose another name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final folderRef = _database.ref("users/$_userId/folders").push();
    await folderRef.set({"name": folderName});
    _fetchFolders();
  }

  // Delete a folder from Firebase for the current user
  Future<void> _deleteFolder(String folderKey) async {
    await _database.ref("users/$_userId/folders/$folderKey").remove();
    _fetchFolders();
  }

  // Edit the folder name in Firebase for the current user
  Future<void> _editFolder(String folderKey, String newName) async {
    await _database.ref("users/$_userId/folders/$folderKey").update({"name": newName});
    _fetchFolders();
  }

  // Show dialog to add a folder
  void _showAddFolderDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Folder"),
        content: TextField(
          controller: _folderController,
          decoration: const InputDecoration(hintText: "Enter folder name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_folderController.text.isNotEmpty) {
                _addFolder(_folderController.text.trim());
                _folderController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Show dialog to edit folder name
  void _showEditFolderDialog(String folderKey, String currentName) {
    _folderController.text = currentName;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Folder"),
        content: TextField(
          controller: _folderController,
          decoration: const InputDecoration(hintText: "Enter new folder name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_folderController.text.isNotEmpty) {
                _editFolder(folderKey, _folderController.text.trim());
                _folderController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Show the 3-dot menu dialog with "Edit" and "Delete" options
  void _showFolderOptionsDialog(String folderKey, String folderName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Folder Options"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Folder"),
              onTap: () {
                Navigator.pop(context); // Close the dialog
                _showEditFolderDialog(folderKey, folderName); // Show Edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Folder"),
              onTap: () {
                Navigator.pop(context); // Close the dialog
                _deleteFolder(folderKey); // Delete folder
              },
            ),
          ],
        ),
      ),
    );
  }

  // Toggle folder selection for deletion
  void _toggleSelection(String folderKey) {
    setState(() {
      if (selectedFolders.contains(folderKey)) {
        selectedFolders.remove(folderKey);
      } else {
        selectedFolders.add(folderKey);
      }
    });
  }

  // Delete selected folders
  Future<void> _deleteSelectedFolders() async {
    for (var key in selectedFolders) {
      await _deleteFolder(key);
    }
    setState(() {
      selectedFolders.clear();
    });
  }

  // Delete all folders
  Future<void> _deleteAllFolders() async {
    for (var folder in folders) {
      await _deleteFolder(folder['key']);
    }
    setState(() {
      selectedFolders.clear();
    });
  }

  // Search folders based on the search query
  List<Map<String, dynamic>> get filteredFolders {
    String query = _searchController.text.toLowerCase();
    return folders
        .where((folder) =>
        folder['name'].toLowerCase().contains(query)) // Filter folders by name
        .toList();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all saved preferences

      await FirebaseAuth.instance.signOut(); // Sign out from Firebase

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const loginScreen()), // Ensure `LoginScreen` is correctly imported
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Do you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              onPressed: () {
                _logout(context); // Clear shared preferences and log out
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
        title: Center(
            child: const Text("Folders Screen",
                style: TextStyle(fontSize: 20))),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show progress indicator while loading
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child:
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a folder...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: Colors.black, // Set the color for the focused border
                          width: 2, // Adjust the width as needed
                        ),
                      ),
                    ),
                  )

                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'deleteSelected') {
                      _deleteSelectedFolders();
                    } else if (value == 'deleteAll') {
                      _deleteAllFolders();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'deleteSelected',
                      child: Text('Delete Selected'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'deleteAll',
                      child: Text('Delete All Folders'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert,),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredFolders.isEmpty
                ? const Center(child: Text('No folders found'))
                : Padding(
              padding: const EdgeInsets.all(19.0),
              child: ListView.builder(
                itemCount: filteredFolders.length,
                itemBuilder: (context, index) {
                  final folder = filteredFolders[index];
                  bool isSelected = selectedFolders.contains(folder['key']);
                  return FutureBuilder<int>( // Fetch file count inside the folder
                    future: _fetchFileCount(folder['key']),
                    builder: (context, snapshot) {
                      String fileCountText = '0 files'; // Default file count text

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        fileCountText = 'Loading...';
                      } else if (snapshot.hasData) {
                        final fileCount = snapshot.data!;
                        fileCountText = '$fileCount files';
                      }

                      return Card(
                        elevation: 4,
                        color: isSelected
                            ? Colors.blueAccent.withOpacity(0.4) // Highlight selected folder
                            : Color(0xFF939FAD), // Default folder color
                        child: GestureDetector(
                          onTap: () {
                            // On tap, open the folder
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileScreen(folderKey: folder['key']),
                              ),
                            );
                          },
                          onLongPress: () {
                            // On long press, toggle selection for deletion
                            _toggleSelection(folder['key']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.folder, size: 40, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    folder['name'],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Text(fileCountText,
                                    style: const TextStyle(fontSize: 14, color: Colors.black)),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () =>
                                      _showFolderOptionsDialog(folder['key'], folder['name']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF5893BB),
        onPressed: _showAddFolderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
