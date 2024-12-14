import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

      List<Uint8List> imageList =
          imageBox.get('storedImages', defaultValue: <Uint8List>[])!;

      imageList.add(imageBytes);

      await imageBox.put('storedImages', imageList);

      setState(() {});
    }
  }

  Future<void> deleteImage(int index) async {
    List<Uint8List> imageList =
        imageBox.get('storedImages', defaultValue: <Uint8List>[])!;

    imageList.removeAt(index);

    await imageBox.put('storedImages', imageList);

    setState(() {});
  }

  Future<List<Uint8List>> loadImages() async {
    return imageBox.get('storedImages', defaultValue: <Uint8List>[])!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text("Load Image from LocalDB"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: pickAndSaveImage,
                child: const Text(
                  "Pick and Save Image",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Uint8List>>(
              future: loadImages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No images found");
                } else {
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return Column(
                              children: [
                                Image.memory(snapshot.data![index]),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => deleteImage(index),
                                  child: const Text("Delete Image"),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
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
