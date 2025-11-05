import 'package:flutter/material.dart';
import 'package:ghost_food/domain/entities/recipe_entity.dart';

class RecipeDetailPage extends StatelessWidget {
  final RecipeEntity recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.4),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Descripción', Icons.description_outlined),
                  Text(
                    recipe.description ?? 'No hay descripción disponible.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ingredientes', Icons.local_grocery_store_outlined),
                  if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty)
                    ...recipe.ingredients!.map((ingredient) => _buildListItem(ingredient)).toList()
                  else
                    _buildListItem('No hay ingredientes listados.'),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Pasos de Preparación', Icons.format_list_numbered_outlined),
                  if (recipe.steps != null && recipe.steps!.isNotEmpty)
                    ...recipe.steps!.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String step = entry.value;
                      return _buildStepItem(step, idx + 1);
                    }).toList()
                  else
                    _buildListItem('No hay pasos de preparación listados.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00FFB8), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00FFB8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFF00FFB8), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, int number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              color: Color(0xFF00FFB8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}