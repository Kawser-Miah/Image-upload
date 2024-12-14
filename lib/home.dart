import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';

class SaveAndDisplayImagePage extends StatefulWidget {
  const SaveAndDisplayImagePage({super.key});

  @override
  State<SaveAndDisplayImagePage> createState() =>
      _SaveAndDisplayImagePageState();
}

class _SaveAndDisplayImagePageState extends State<SaveAndDisplayImagePage> {
  final ImagePicker picker = ImagePicker();
  late Box imageBox;

  @override
  void initState() {
    super.initState();
    openImageBox();
  }

  Future<void> openImageBox() async {
    imageBox = await Hive.openBox('imageBox');
  }

  Future<void> pickAndSaveImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      await imageBox.put('storedImage', imageBytes);
      setState(() {});
    }
  }

  Future<void> deleteImage() async {
    await imageBox.delete('storedImage');
    setState(() {});
  }

  Future<Uint8List?> loadImage() async {
    return imageBox.get('storedImage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text("Load Image from LocalDB "),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: pickAndSaveImage,
                child: const Text("Pick and Save Image"),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Uint8List?>(
              future: loadImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData) {
                  return const Text("No image found");
                } else {
                  return Column(
                    children: [
                      Image.memory(snapshot.data!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: deleteImage,
                        child: const Text("Delete Image"),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
