import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  // Fetch recipes from backend
  static Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
    final url = Uri.parse('$baseUrl/generate_recipe');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final recipes = data['recipes'] as List;
      return recipes.map((r) => Recipe.fromJson(r)).toList();
    } else {
      throw Exception('Failed to fetch recipes: ${response.body}');
    }
  }

  // Detect ingredients from image via backend
  static Future<List<String>> detectIngredientsFromImage(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final url = Uri.parse('$baseUrl/detect_ingredients');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"imageBase64": base64Image}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['ingredients']);
    } else {
      throw Exception("Failed to detect ingredients: ${response.body}");
    }
  }
}
