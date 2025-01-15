import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:student_note/ReminderModule/ReminderScreen.dart';
import 'FileDetailScreen.dart';
import 'package:http/http.dart'as http;

class FileScreen extends StatefulWidget {
  final String folderKey;

  const FileScreen({Key? key, required this.folderKey}) : super(key: key);

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> files = [];
  final TextEditingController _editFileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    final snapshot = await _databaseRef.child("folders/${widget.folderKey}/files").get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        files = data.entries
            .map((entry) => {
          "key": entry.key,
          "name": entry.value['name'],
          "content": entry.value['content'],
          "image": entry.value['image'],
        })
            .toList();
      });
    }
  }

  Future<void> _downloadFile(String fileKey, String fileName, String content, String? imageUrl) async {
    final status = await Permission.storage.status;

    if (!status.isGranted) {
      // Show an alert dialog if permission is not granted
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Storage Permission Required"),
            content: const Text(
                "This app needs storage access to download the file as a PDF. Do you want to allow this?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                 // Close the dialog
                  final newStatus = await Permission.storage.request();
                  if (newStatus.isGranted) {
                    _createAndSavePdf(fileKey, fileName, content, imageUrl); // Proceed to download
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Permission denied. Cannot download the file."),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text("Allow"),
              ),
            ],
          );
        },
      );
      return;
    }

    // If permission is already granted, proceed to download the file
    _createAndSavePdf(fileKey, fileName, content, imageUrl);
  }

  Future<void> _createAndSavePdf(
      String fileKey, String fileName, String content, String? imageUrl) async {

    print("gggggggggggggggggggggggggggggggggg");
    print(imageUrl);
    try {
      final pdf = pw.Document();
      // Check if the imageUrl is a URL or local file path
      pw.ImageProvider? pdfImage;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (imageUrl.startsWith('http')) {
          // If it's a URL, download the image
          final response = await http.get(Uri.parse(imageUrl));
          print("fdggggggggggggggggggggggggg");
          if (response.statusCode == 200) {
            print("fdggggggggggggggggggggggggg");
            // Convert the image into a format suitable for the pdf package
            final imageBytes = Uint8List.fromList(response.bodyBytes);
            pdfImage = pw.MemoryImage(imageBytes);
          } else {
            // If the image couldn't be fetched, handle this case
            print("Failed to load image from URL.");
            pdfImage = null;
          }
        } else {
          print("fdggggggggggggggggggggggggg");
          // If it's a local file path, read it directly
          final file = File(imageUrl);
          if (await file.exists()) {
            print("fdggggggggggggggggggggggggg");
            final imageBytes = await file.readAsBytes();
            pdfImage = pw.MemoryImage(imageBytes);
          } else {
            print("Local file path not found: $imageUrl");
            pdfImage = null;
          }
        }
      }

      print(await pdfImage);
      print(pdfImage);

      // pdf.addPage(pw.Page(build: (pw.Context context) {
      //   return pw.Center(
      //     child: pw.Image(image),
      //   ); // Center
      // }));
      // Add content to PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(fileName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                if (pdfImage != null)
                  pw.Image(pdfImage), // Add image if available

                pw.Text(content, style: pw.TextStyle(fontSize: 16)),

              ],
            );
          },
        ),
      );

      // Get external storage directory (specific for Android)
      final directory = await getExternalStorageDirectory();

      // Specify a path for the Downloads folder
      final downloadPath = Directory("/storage/emulated/0/Download/");
      if (!downloadPath.existsSync()) {
        // Create the folder if it doesn't exist
        downloadPath.createSync();
      }

      // Save the PDF file to the Downloads folder
      final file = File('${downloadPath.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());
      // Open the file after saving
      OpenFile.open(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to Downloads: ${file.path}")),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download the file.")),
      );
    }
  }

  Future<void> _addFile() async {
    final fileRef = _databaseRef.child("folders/${widget.folderKey}/files").push();
    await fileRef.set({"name": " ${files.length + 1}", "content": "", "image": ""});
    _fetchFiles();
  }

  Future<void> _deleteFile(String fileKey) async {
    await _databaseRef.child("folders/${widget.folderKey}/files/$fileKey").remove();
    _fetchFiles();
  }

  Future<void> _editFileName(String fileKey, String currentName) async {
    _editFileController.text = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit File Name"),
          content: TextField(
            controller: _editFileController,
            decoration: const InputDecoration(hintText: "Enter new file name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _databaseRef
                    .child("folders/${widget.folderKey}/files/$fileKey")
                    .update({"name": _editFileController.text});
                Navigator.pop(context);
                _fetchFiles();
              },
              child: const Text("Save"),
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
          backgroundColor: Colors.blue,
          title: Center(child: const Text("Files Screen"))),
      backgroundColor: Colors.blue.shade50,
      body: files.isEmpty
          ? const Center(child: Text("No files available"))
          : GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileDetailScreen(
                    folderKey: widget.folderKey,
                    fileKey: file['key'],
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: const Icon(Icons.insert_drive_file, size: 48)),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        file['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        IconButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ReminderScreen()));
                        }, icon:Icon(Icons.lock_clock)),



                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _editFileName(file['key'], file['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFile(file['key']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        child: const Icon(Icons.add),
      ),
    );
  }
}
