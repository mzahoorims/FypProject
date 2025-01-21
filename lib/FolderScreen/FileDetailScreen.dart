import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';

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
  List<String> imageUrls = [];
  List<int> rotationAngles = [];
  List<TextEditingController> textControllers = [];
  bool isEditing = false;
  bool isDownloading = false;
  int zoomLevel = 1;

  @override
  void initState() {
    super.initState();
    _fetchFileDetails();
  }

  Future<void> _fetchFileDetails() async {
    final snapshot = await _databaseRef.child("folders/${widget.folderKey}/files/${widget.fileKey}").get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        if (data['images'] != null) {
          imageUrls = List<String>.from(data['images']);
          rotationAngles = List<int>.from(data['rotations'] ?? List.filled(imageUrls.length, 0));
          List<String> texts = List<String>.from(data['texts'] ?? List.filled(imageUrls.length, ""));
          textControllers = texts.map((text) => TextEditingController(text: text)).toList();
        }
      });
    }
  }

  Future<void> _saveFileDetails() async {
    List<String> texts = textControllers.map((controller) => controller.text).toList();
    await _databaseRef.child("folders/${widget.folderKey}/files/${widget.fileKey}")
        .update({"images": imageUrls, "rotations": rotationAngles, "texts": texts});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File updated successfully!")),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imageUrls = pickedFiles.map((file) => file.path).toList();
        rotationAngles = List.filled(imageUrls.length, 0);
        textControllers = List.generate(imageUrls.length, (index) => TextEditingController());
      });
    }
  }

  void _clearData() {
    setState(() {
      imageUrls.clear();
      rotationAngles.clear();
      textControllers.clear();
    });
  }

  void _rotateImage(int index) {
    setState(() {
      rotationAngles[index] = (rotationAngles[index] + 90) % 360;
    });
    _saveFileDetails(); // Save the rotated state to Firebase
  }

  Future<void> _cropImage(int index) async {
    try {
      File originalFile = File(imageUrls[index]); // Load the image file
      Uint8List imageBytes = await originalFile.readAsBytes(); // Convert to Uint8List

      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) {
        print("Failed to decode image.");
        return;
      }

      // Get user choice (rectangle or square)
      String? cropShape = await _showCropDialog();
      if (cropShape == null) return; // User canceled

      int width = image.width;
      int height = image.height;

      // Define cropping region based on user choice
      int cropWidth, cropHeight, offsetX, offsetY;

      if (cropShape == "Rectangle") {
        cropWidth = (width * 0.8).toInt();
        cropHeight = (height * 0.6).toInt(); // More rectangular
      } else {
        // Square cropping
        int minSize = (width < height ? width : height) * 0.8.toInt();
        cropWidth = minSize;
        cropHeight = minSize;
      }

      offsetX = ((width - cropWidth) / 2).toInt();
      offsetY = ((height - cropHeight) / 2).toInt();

      // Perform cropping
      img.Image croppedImage = img.copyCrop(image, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);

      // Convert back to file
      File croppedFile = File(originalFile.path.replaceAll('.jpg', '_cropped.jpg'))
        ..writeAsBytesSync(img.encodeJpg(croppedImage));

      if (croppedFile.existsSync()) {
        setState(() {
          imageUrls[index] = croppedFile.path;
        });
      } else {
        print("Cropping failed.");
      }
    } catch (e) {
      print("Error during cropping: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to crop image: $e")),
        );
      }
    }
  }

  // New method for cropping out an image (cropping a portion of the image)
  // New method for cropping out an image (zooming out by reducing the crop area)
  Future<void> _cropOutImage(int index) async {
    try {
      File originalFile = File(imageUrls[index]); // Load the image file
      Uint8List imageBytes = await originalFile.readAsBytes(); // Convert to Uint8List

      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) {
        print("Failed to decode image.");
        return;
      }

      int width = image.width;
      int height = image.height;

      // Let's crop a smaller 30% portion from the center to simulate "zoom out"
      int cropWidth = (width * 0.3).toInt();  // 30% of original width
      int cropHeight = (height * 0.3).toInt(); // 30% of original height

      int offsetX = ((width - cropWidth) / 2).toInt();
      int offsetY = ((height - cropHeight) / 2).toInt();

      // Perform cropping
      img.Image croppedImage = img.copyCrop(image, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);

      // Convert back to file
      File croppedFile = File(originalFile.path.replaceAll('.jpg', '_cropped_out.jpg'))
        ..writeAsBytesSync(img.encodeJpg(croppedImage));

      if (croppedFile.existsSync()) {
        setState(() {
          imageUrls[index] = croppedFile.path;  // Update image with the zoomed-out version
        });
      } else {
        print("Cropping out failed.");
      }
    } catch (e) {
      print("Error during cropping out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to crop out image: $e")),
        );
      }
    }
  }


  // Show a dialog to let the user choose crop shape
  Future<String?> _showCropDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Crop Shape"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Rectangle"),
                onTap: () => Navigator.of(context).pop("Rectangle"),
              ),
              ListTile(
                title: Text("Square"),
                onTap: () => Navigator.of(context).pop("Square"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generatePdf() async {
    setState(() {
      isDownloading = true;
    });

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          for (int i = 0; i < imageUrls.length; i++) {
            if (textControllers[i].text.isNotEmpty) {
              content.add(pw.Text(textControllers[i].text, style: pw.TextStyle(fontSize: 16)));
            }

            final image = File(imageUrls[i]).readAsBytesSync();
            final rotatedImage = pw.Transform.rotate(
              angle: (rotationAngles[i] * math.pi / 180),
              child: pw.Image(pw.MemoryImage(image), width: 400, height: 400, fit: pw.BoxFit.contain),
            );

            content.add(rotatedImage);
            content.add(pw.SizedBox(height: 20));
          }

          return content;
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

    setState(() {
      isDownloading = false;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("File Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (imageUrls.isNotEmpty)
                Column(
                  children: List.generate(imageUrls.length, (index) => Column(
                    children: [
                      TextField(
                        controller: textControllers[index],
                        decoration: const InputDecoration(labelText: "Enter text here"),
                        maxLines: 2,
                        enabled: isEditing,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      InteractiveViewer(
                        panEnabled: true, // Allow panning
                        scaleEnabled: true, // Allow scaling (zoom)
                        minScale: 1.0, // Minimum zoom level
                        maxScale: 4.0, // Maximum zoom level
                        child: Transform.rotate(
                          angle: rotationAngles[index] * math.pi / 180,
                          child: SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: Image.file(File(imageUrls[index]), fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.rotate_right),
                            onPressed: () => _rotateImage(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.crop),
                            onPressed: () => _cropImage(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.crop_outlined), // New "Crop Out" icon
                            onPressed: () => _cropOutImage(index), // New method for cropping out
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  )),

                )
              else
                const Text("No images selected"),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _pickImages, child: const Text("Pick Images")),
                  ElevatedButton(onPressed: _saveFileDetails, child: const Text("Save")),
                  ElevatedButton(onPressed: _clearData, child: const Text("Clear")),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _generatePdf, child: const Text("Download PDF")),
                  ElevatedButton(
                    onPressed: () => setState(() => isEditing = !isEditing),
                    child: Text(isEditing ? "Cancel" : "Edit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
