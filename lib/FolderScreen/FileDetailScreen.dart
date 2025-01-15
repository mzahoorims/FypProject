import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/rendering.dart';
import 'package:printing/printing.dart';

class FileDetailScreen extends StatefulWidget {
  final String folderKey;
  final String fileKey;

  const FileDetailScreen({Key? key, required this.folderKey, required this.fileKey})
      : super(key: key);

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController _contentController = TextEditingController();
  String? imageUrl;

  bool isDownloading = false;
  final GlobalKey _globalKey = GlobalKey<ScaffoldState>();

  Future<void> _captureAndSavePdf() async {
    setState(() {
      isDownloading = true;
    });

    // Ensure the widget is fully rendered before capturing
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Capture the widget as an image
        Uint8List imageBytes = await _captureAsPng(_globalKey);

        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.fill,
                alignment: pw.Alignment.center,
              );
            },
          ),
        );

        // Save the PDF to a file or print directly
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );

        setState(() {
          isDownloading = false;
        });

        // Optionally, show a success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved successfully!')),
          );
        }
      } catch (e) {
        setState(() {
          isDownloading = false;
        });
        // Handle any errors here
        print('Error capturing widget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture the widget.')),
        );
      }
    });
  }

  Future<Uint8List> _captureAsPng(GlobalKey key) async {
    RenderRepaintBoundary boundary =
    key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }


  @override
  void initState() {
    super.initState();
    _fetchFileDetails();
  }

  Future<void> _fetchFileDetails() async {
    final snapshot =
    await _databaseRef.child("folders/${widget.folderKey}/files/${widget.fileKey}").get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        _contentController.text = data['content'] ?? '';
        imageUrl = data['image'];
      });
    }
  }

  Future<void> _saveFileDetails() async {
    _databaseRef
        .child("folders/${widget.folderKey}/files/${widget.fileKey}")

        .update({"content": _contentController.text, "image": imageUrl});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File updated successfully!")),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path; // Placeholder for local image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: _globalKey,
            child: Column(
              children: [
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: "Content"),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: imageUrl != null
                      ? Image.file(File(imageUrl!))
                      : const Text("No image selected"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Image"),
                ),
                ElevatedButton(
                  onPressed: _saveFileDetails,
                  child: const Text("Save"),
                ),
                ElevatedButton(
                  onPressed: _captureAndSavePdf,
                  child: const Text("download"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
