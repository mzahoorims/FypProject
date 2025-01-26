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
  late img.Image _image;
  late File _imageFile;
  Rect _cropRect = Rect.fromLTWH(50, 50, 200, 200); // Default crop area
  bool _isDragging = false;
  Offset _dragStart = Offset.zero;

  final _databaseRef = FirebaseDatabase.instance.ref();
  List<String> imageUrls = []; // List to store image URLs
  List<int> rotationAngles = []; // List to store rotation angles
  List<TextEditingController> textControllers = []; // List to store text controllers
  List<String> originalImagePaths = []; // List to store original image paths
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

          // Store the original image paths
          originalImagePaths = List<String>.from(imageUrls);
        }

        // Ensure at least one text field is available
        if (textControllers.isEmpty) {
          textControllers.add(TextEditingController()); // Add a default text field if no images are picked
        }
      });
    }
  }

  // Save the file details to Firebase
  Future<void> _saveFileDetails() async {
    List<String> texts = textControllers.map((controller) => controller.text).toList();
    await _databaseRef.child("folders/${widget.folderKey}/files/${widget.fileKey}")
        .update({"images": imageUrls, "rotations": rotationAngles, "texts": texts});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File updated successfully!")),
    );

  }

  // Pick multiple images
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      if (pickedFiles.isNotEmpty) {
        // Append the new images to the existing ones
        imageUrls.addAll(pickedFiles.map((file) => file.path));
        rotationAngles.addAll(List.filled(pickedFiles.length, 0)); // Add default rotation value
        textControllers.addAll(List.generate(pickedFiles.length, (index) => TextEditingController())); // Add text controllers for the new images
        originalImagePaths.addAll(pickedFiles.map((file) => file.path)); // Add the new paths to original image paths
      }
    });
    Navigator.pop(context);
  }

  // Reset the image to its original state
  void _resetImage(int index) {
    setState(() {
      // Revert to the original image path and reset rotation and zoom level
      imageUrls[index] = originalImagePaths[index];
      rotationAngles[index] = 0;
      zoomLevel = 1;
    });
  }

  // Rotate the image by 90 degrees
  void _rotateImage(int index) {
    setState(() {
      rotationAngles[index] = (rotationAngles[index] + 90) % 360;
    });
    _saveFileDetails(); // Save the rotated state to Firebase
  }

  // Crop the image (zoom in or zoom out)
  void _cropImage(int index) async {
    try {
      setState(() {
        if (zoomLevel < 3) {
          zoomLevel += 1;
        } else if (zoomLevel == 3) {
          zoomLevel--;
        }
      });

      File originalFile = File(imageUrls[index]);
      Uint8List imageBytes = await originalFile.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) {
        print("Failed to decode image.");
        return;
      }

      String? cropShape = await _showCropDialog();
      if (cropShape == null) return;

      if (cropShape == "Reset") {
        _resetImage(index); // Reset the image to its original state
        return;
      }

      int width = image.width;
      int height = image.height;
      int cropWidth = (width * 0.8).toInt();
      int cropHeight = (height * 0.6).toInt();
      int offsetX = ((width - cropWidth) / 2).toInt();
      int offsetY = ((height - cropHeight) / 2).toInt();

      img.Image croppedImage = img.copyCrop(image, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);
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

  // Show crop options (reset, crop, etc.)
  Future<String?> _showCropDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Crop Option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Crop Image"),
                onTap: () => Navigator.of(context).pop("Rectangle"),
              ),
              ListTile(
                title: Text("Reset"),
                onTap: () => Navigator.of(context).pop("Reset"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete a specific image
  void _deleteImage(int index) {

    setState(() {
      imageUrls.removeAt(index);
      rotationAngles.removeAt(index);
      textControllers.removeAt(index);
      originalImagePaths.removeAt(index); // Remove original image path
    });
    _saveFileDetails(); // Update the Firebase database after deletion


  }

  // Generate PDF from images and texts
  Future<void> _generatePdf() async {
    setState(() {
      isDownloading = true;
      Navigator.pop(context);
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
              child: pw.Image(pw.MemoryImage(image), width: 1000, height: 400, fit: pw.BoxFit.contain),
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
      appBar: AppBar(
        title: const Text("File Details"),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Options"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        TextButton(
                          onPressed: _pickImages,
                          child: const Text("Pick Images"),
                        ),
                        TextButton(
                          onPressed: _saveFileDetails,
                          child: const Text("Save"),
                        ),
                        TextButton(
                          onPressed: _clearData,
                          child: const Text("Clear"),
                        ),
                        TextButton(
                          onPressed: _generatePdf,
                          child: const Text("Download PDF"),
                        ),
                        TextButton(
                          onPressed: () => setState(() => isEditing = !isEditing),
                          child: Text(isEditing ? "Cancel Edit" : "Edit"),
                        ),
                      ],
                    ),
                  );

                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display text field if no image is picked
              if (imageUrls.isEmpty)
                Column(
                  children: [
                    TextField(
                      controller: textControllers.isNotEmpty ? textControllers[0] : TextEditingController(), // Ensure it's initialized
                      decoration: const InputDecoration(labelText: "Enter text"),
                      maxLines: 2,
                      enabled: isEditing,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              // Display images if available
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
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: zoomLevel == 1 ? 1.0 : 3.0,
                        maxScale: zoomLevel == 1 ? 4.0 : 9.0,
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
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteImage(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  )),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Clear all the data and reset everything
  void _clearData() {
    setState(() {
      imageUrls.clear();
      rotationAngles.clear();
      textControllers.clear();
      originalImagePaths.clear();
      // Add a new text field if no images are selected
      textControllers.add(TextEditingController());
    });
    Navigator.pop(context);
  }
}
