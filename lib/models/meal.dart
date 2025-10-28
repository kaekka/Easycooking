class Meal {
  final String? idMeal;
  final String? strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;

  // ✅ Tambahan: field ingredients + measures
  final Map<String, String> ingredientMap;

  Meal({
    this.idMeal,
    this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    this.ingredientMap = const {},
  });

  // ✅ Untuk hasil filter (kategori)
  factory Meal.fromFilterJson(Map<String, dynamic> json) => Meal(
        idMeal: json['idMeal'],
        strMeal: json['strMeal'],
        strMealThumb: json['strMealThumb'],
      );

  // ✅ Untuk hasil pencarian/detail (lengkap)
  factory Meal.fromSearchJson(Map<String, dynamic> json) {
    final ingredients = <String, String>{};

    // Ambil semua bahan & takaran dari API TheMealDB
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ing != null && ing.toString().trim().isNotEmpty) {
        ingredients[ing.toString()] = measure?.toString() ?? '';
      }
    }

    return Meal(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strYoutube: json['strYoutube'], // ✅ aktifkan field YouTube
      ingredientMap: ingredients,
    );
  }

  // ✅ Getter agar bisa dipakai di UI
  Map<String, String> get ingredients => ingredientMap;

  // ✅ Getter tambahan untuk thumbnail dan deskripsi singkat
  String get thumbnail => strMealThumb ?? '';

  String get shortDescription => (strInstructions == null)
      ? ''
      : (strInstructions!.length > 100
          ? '${strInstructions!.substring(0, 100)}...'
          : strInstructions!);
}
