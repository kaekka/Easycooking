// CookEasy - Flutter (fixed main.dart)
// Dependencies (pubspec.yaml):
//   http: ^1.2.0
//   cached_network_image: ^3.3.1
//   url_launcher: ^6.2.4

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const CookEasyApp());

class CookEasyApp extends StatelessWidget {
  const CookEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookEasy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const RecipeHomePage(),
    );
  }
}

class RecipeHomePage extends StatefulWidget {
  const RecipeHomePage({super.key});

  @override
  State<RecipeHomePage> createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  List<Category> categories = [];
  List<Meal> meals = [];
  String searchQuery = '';
  String activeCategory = 'All';
  bool loading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchCategories();
    await _searchMeals();
  }

  Future<void> _fetchCategories() async {
    try {
      final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final List list = data['categories'] ?? [];
        setState(() {
          categories = list.map((e) => Category.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _searchMeals({String? query, String? category}) async {
    setState(() => loading = true);
    try {
      List<Meal> result = [];
      if ((category ?? activeCategory) != 'All') {
        final cat = category ?? activeCategory;
        final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${Uri.encodeComponent(cat)}');
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final List list = data['meals'] ?? [];
          result = list.map((e) => Meal.fromFilterJson(e)).toList();
        }
      } else if (query != null && query.trim().isNotEmpty) {
        final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(query)}');
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final List list = data['meals'] ?? [];
          result = list.map((e) => Meal.fromSearchJson(e)).toList();
        }
      } else {
        final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=');
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          final List list = data['meals'] ?? [];
          result = list.map((e) => Meal.fromSearchJson(e)).toList();
        }
      }
      setState(() => meals = result);
    } catch (_) {} finally {
      setState(() => loading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      activeCategory = 'All';
    });
    _searchMeals(query: value);
  }

  void _onSelectCategory(String cat) {
    setState(() {
      activeCategory = cat;
      searchQuery = '';
      _searchController.clear();
    });
    _searchMeals(category: cat == 'All' ? null : cat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CookEasy'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search resep...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      CategoryChip(
                        name: 'All',
                        imageUrl: null,
                        selected: activeCategory == 'All',
                        onTap: () => _onSelectCategory('All'),
                      ),
                      ...categories.map((cat) => CategoryChip(
                            name: cat.strCategory,
                            imageUrl: cat.strCategoryThumb,
                            selected: activeCategory == cat.strCategory,
                            onTap: () => _onSelectCategory(cat.strCategory),
                          )),
                    ],
                  ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : meals.isEmpty
                    ? const Center(child: Text('No recipes found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: meals.length,
                        itemBuilder: (context, i) {
                          final m = meals[i];
                          return RecipeCard(
                            meal: m,
                            onTap: () async {
                              final full = await fetchMealDetail(m.idMeal);
                              if (full != null && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => RecipeDetailPage(meal: full)),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;
  const CategoryChip({super.key, required this.name, this.imageUrl, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
              backgroundColor: selected ? Colors.deepOrange.shade100 : Colors.grey.shade200,
              child: imageUrl == null ? const Icon(Icons.food_bank) : null,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  const RecipeCard({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: meal.thumbnail,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (c, s) => Container(width: 100, height: 80, color: Colors.grey[200]),
                  errorWidget: (c, s, e) => Container(width: 100, height: 80, color: Colors.grey[200]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.strMeal ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(meal.strCategory ?? '', style: const TextStyle(color: Colors.grey)),
                    Text(meal.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Meal meal;
  const RecipeDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal.strMeal ?? 'Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: meal.thumbnail,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(meal.strMeal ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (meal.strCategory != null) Text('Category: ${meal.strCategory}') else const SizedBox(),
            if (meal.strArea != null) Text('Origin: ${meal.strArea}') else const SizedBox(),
            const SizedBox(height: 12),
            const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(meal.strInstructions ?? ''),
            const SizedBox(height: 16),
            if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(meal.strYoutube!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Tutorial on YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String idCategory;
  final String strCategory;
  final String strCategoryThumb;
  final String strCategoryDescription;

  Category({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        idCategory: json['idCategory'] ?? '',
        strCategory: json['strCategory'] ?? '',
        strCategoryThumb: json['strCategoryThumb'] ?? '',
        strCategoryDescription: json['strCategoryDescription'] ?? '',
      );
}

class Meal {
  final String? idMeal;
  final String? strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;

  Meal({
    this.idMeal,
    this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
  });

  factory Meal.fromFilterJson(Map<String, dynamic> json) => Meal(
        idMeal: json['idMeal'],
        strMeal: json['strMeal'],
        strMealThumb: json['strMealThumb'],
      );

  factory Meal.fromSearchJson(Map<String, dynamic> json) => Meal(
        idMeal: json['idMeal'],
        strMeal: json['strMeal'],
        strCategory: json['strCategory'],
        strArea: json['strArea'],
        strInstructions: json['strInstructions'],
        strMealThumb: json['strMealThumb'],
        strYoutube: json['strYoutube'],
      );

  String get thumbnail => strMealThumb ?? '';
  String get shortDescription =>
      (strInstructions == null) ? '' : (strInstructions!.length > 100 ? '${strInstructions!.substring(0, 100)}...' : strInstructions!);
}

Future<Meal?> fetchMealDetail(String? id) async {
  if (id == null) return null;
  final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id');
  final resp = await http.get(url);
  if (resp.statusCode == 200) {
    final data = json.decode(resp.body);
    final List list = data['meals'] ?? [];
    if (list.isNotEmpty) {
      return Meal.fromSearchJson(list.first);
    }
  }
  return null;
}