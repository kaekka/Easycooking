import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal.dart';

class RecipeDetailPage extends StatelessWidget {
  final Meal meal;
  const RecipeDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    const Color mainGreen = Color(0xFF02462E);
    const Color accentYellow = Color(0xFFFEC700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🍳 Gambar utama
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      meal.thumbnail,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: accentYellow,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // 🍴 Informasi utama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal ?? "Unknown Recipe",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meal.strCategory ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        color: mainGreen.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ⭐ Rating & Info
                    Row(
                      children: [
                        _buildInfoIcon(Icons.star, "4.5", accentYellow),
                        _buildInfoIcon(Icons.schedule, "35 min", accentYellow),
                        _buildInfoIcon(Icons.local_fire_department, "103 cal", accentYellow),
                        _buildInfoIcon(Icons.restaurant_menu, "2 servings", accentYellow),
                      ],
                    ),
                  ],
                ),
              ),

              // 🍽️ Bahan-bahan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ingredients",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (meal.ingredients != null && meal.ingredients.isNotEmpty)
                      ...meal.ingredients.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6, color: mainGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${entry.value} ${entry.key}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      const Text(
                        "No ingredients available.",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                  ],
                ),
              ),

              // 🔪 Langkah-langkah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Instructions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meal.strInstructions ?? "",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // 🎥 Tombol YouTube
              if (meal.strYoutube != null && meal.strYoutube!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri youtubeUrl = Uri.parse(meal.strYoutube!);
                        if (await canLaunchUrl(youtubeUrl)) {
                          await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not open YouTube link")),
                          );
                        }
                      },
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                      label: const Text(
                        "Watch on YouTube",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ teks jadi putih
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text, Color accent) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
