import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloudflare_ai/cloudflare_ai.dart';
import 'package:gal/gal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _promptController = TextEditingController();
  TextToImageModel model = TextToImageModel(
    accountId: "",
    apiKey: "",
    model: TextToImageModels.DREAMSHAPER_8_LCM,
  );
  Uint8List? image;
  bool isLoading = false;

  void generateImage(String prompt) async {
    if (prompt != "") {
      try {
        setState(() {
          image = null;
          isLoading = true;
        });
        Uint8List imageRes = await model.generateImage(prompt);
        setState(() {
          image = imageRes;
          isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  void saveToGallery(Uint8List image) async {
    await Gal.putImageBytes(image);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image saved to gallery"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Generation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  label: const Text("Prompt"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.white10,
                    ),
                  ),
                ),
                maxLines: null,
              ),
              ElevatedButton(
                onPressed: () {
                  generateImage(_promptController.text);
                },
                child: const Text("Generate Image"),
              ),
              image != null
                  ? Image.memory(image!)
                  : isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
              image != null
                  ? ElevatedButton(
                      onPressed: () {
                        saveToGallery(image!);
                      },
                      child: const Text("Save to Gallery"),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
