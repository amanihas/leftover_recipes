class Recipe {
  final int id;
  final String title;
  final String image;
  final List<dynamic> usedIngredients;
  final List<dynamic> missedIngredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.usedIngredients,
    required this.missedIngredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      usedIngredients: json['usedIngredients'] ?? [],
      missedIngredients: json['missedIngredients'] ?? [],
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}

