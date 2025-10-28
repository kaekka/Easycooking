import 'package:dio/dio.dart';
import '../models/category.dart';
import '../models/meal.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  )..interceptors.add(LogInterceptor(responseBody: true)); // 🧩 log otomatis di console

  // 🥗 Ambil kategori
  static Future<List<Category>> fetchCategories() async {
    try {
      final resp = await _dio.get('/categories.php');
      final data = resp.data;
      final List list = data['categories'] ?? [];
      return list.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      print('⚠️ Error fetchCategories: $e');
      return [];
    }
  }

  // 🍳 Cari atau filter resep
  static Future<List<Meal>> searchMeals({String? query, String? category}) async {
    try {
      Response resp;
      if (category != null && category != 'All') {
        resp = await _dio.get('/filter.php', queryParameters: {'c': category});
      } else if (query != null && query.trim().isNotEmpty) {
        resp = await _dio.get('/search.php', queryParameters: {'s': query});
      } else {
        resp = await _dio.get('/search.php', queryParameters: {'s': ''});
      }

      final data = resp.data;
      final List list = data['meals'] ?? [];
      return list.map((e) => Meal.fromSearchJson(e)).toList();
    } catch (e) {
      print('⚠️ Error searchMeals: $e');
      return [];
    }
  }

  // 🍲 Detail resep
  static Future<Meal?> fetchMealDetail(String id) async {
    try {
      final resp = await _dio.get('/lookup.php', queryParameters: {'i': id});
      final data = resp.data;
      final List list = data['meals'] ?? [];
      if (list.isNotEmpty) return Meal.fromSearchJson(list.first);
    } catch (e) {
      print('⚠️ Error fetchMealDetail: $e');
    }
    return null;
  }
}
