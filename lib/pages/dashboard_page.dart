import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sustainability Dashboard")),
      body: const Center(
        child: Text(
          "Your Waste Score and savings will appear here!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
