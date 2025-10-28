import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color textColor;

  const CategoryChip({
    super.key,
    required this.name,
    this.imageUrl,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withOpacity(0.5)),
          boxShadow: selected
              ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              CircleAvatar(backgroundImage: NetworkImage(imageUrl!), radius: 14, backgroundColor: Colors.transparent),
            if (imageUrl != null) const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: selected ? Colors.white : textColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
