import 'package:flutter/material.dart';
import '../models/service_model.dart';

class CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _getIconData(String asset) {
    switch (asset) {
      case 'Icons.health_and_safety': return Icons.health_and_safety;
      case 'Icons.school': return Icons.school;
      case 'Icons.house': return Icons.house;
      case 'Icons.work': return Icons.work;
      case 'Icons.volunteer_activism': return Icons.volunteer_activism;
      case 'Icons.local_hospital': return Icons.local_hospital;
      case 'Icons.directions_bus': return Icons.directions_bus;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(category.iconAsset),
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
