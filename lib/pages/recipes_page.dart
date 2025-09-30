import 'package:flutter/material.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: const Center(
        child: Text(
          "Recipe suggestions will appear here!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
