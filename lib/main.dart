import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'services/api_service.dart';
import 'widgets/snap_cook_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftover Recipe Generator',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const RecipesPage(),
    );
  }
}

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController _controller = TextEditingController();
  List<Recipe> recipes = [];
  bool loading = false;

  void fetchRecipes() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final ingredients =
          _controller.text.split(',').map((e) => e.trim()).toList();
      final fetchedRecipes = await ApiService.fetchRecipes(ingredients);
      setState(() {
        recipes = fetchedRecipes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget recipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Image.network(recipe.image, height: 150),
            const SizedBox(height: 8),
            const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.usedIngredients.map((i) => Text("✔ ${i['original']}")),
            ...recipe.missedIngredients.map((i) => Text("✖ ${i['original']}")),
            const SizedBox(height: 8),
            const Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.steps.asMap().entries.map((e) => Text("${e.key + 1}. ${e.value}")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leftover Recipe Generator")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SnapCookWidget(
              onIngredientsDetected: (ingredients) {
                _controller.text = ingredients.join(", ");
                fetchRecipes();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Or enter ingredients separated by commas",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loading ? null : fetchRecipes,
              child:
                  loading ? const CircularProgressIndicator() : const Text("Get Recipes"),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) => recipeCard(recipes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
