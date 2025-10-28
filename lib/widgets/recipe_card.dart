import 'package:flutter/material.dart';
import '../models/meal.dart';

class RecipeCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final Color color;
  final Color accentColor;

  const RecipeCard({
    super.key,
    required this.meal,
    required this.onTap,
    required this.color,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  meal.thumbnail,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.strMeal ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      meal.strCategory ?? '',
                      style: TextStyle(color: color.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
