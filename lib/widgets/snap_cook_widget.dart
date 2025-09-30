import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../services/api_service.dart';

class SnapCookWidget extends StatefulWidget {
  final Function(List<String>) onIngredientsDetected;

  const SnapCookWidget({super.key, required this.onIngredientsDetected});

  @override
  State<SnapCookWidget> createState() => _SnapCookWidgetState();
}

class _SnapCookWidgetState extends State<SnapCookWidget> {
  Uint8List? _image;
  bool loading = false;

  void pickImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();
    if (image == null) return;

    setState(() {
      _image = image;
      loading = true;
    });

    try {
      final ingredients = await ApiService.detectIngredientsFromImage(image);
      widget.onIngredientsDetected(ingredients);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error detecting ingredients: $e')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _image != null
            ? Image.memory(_image!, height: 200)
            : const Placeholder(fallbackHeight: 200),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: loading ? null : pickImage,
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Snap & Detect Ingredients"),
        ),
      ],
    );
  }
}
