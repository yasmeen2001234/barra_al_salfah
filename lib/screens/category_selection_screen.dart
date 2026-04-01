import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_setup_screen.dart';
import '../providers/language_provider.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final ScrollController _gridScrollController = ScrollController();
  Map<String, dynamic> categories = {};
  bool loading = true;
  List<String> deletedCategories = [];

  Color hexToColor(String hex) {
    hex = hex.trim();
    if (hex.startsWith('0x')) return Color(int.parse(hex));
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse('0x$hex'));
  }

  IconData getMaterialIcon(String name) {
    switch (name) {
      case "food":
        return Icons.fastfood;
      case "place":
        return Icons.place;
      case "work":
        return Icons.work;
      case "pets":
        return Icons.pets;
      case "movie":
        return Icons.movie;
      case "flag":
        return Icons.flag;
      case "computer":
        return Icons.computer;
      case "music_note":
        return Icons.music_note;
      case "checkroom":
        return Icons.checkroom;
      case "directions_car":
        return Icons.directions_car;
      case "park":
        return Icons.park;
      case "sports_soccer":
        return Icons.sports_soccer;
      case "sentiment_satisfied":
        return Icons.sentiment_satisfied;
      case "chair":
        return Icons.chair;
      case "school":
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('custom_categories');
    final Map<String, dynamic> custom = raw != null
        ? Map<String, dynamic>.from(json.decode(raw))
        : {};
    deletedCategories = List<String>.from(custom['__deleted__'] ?? []);

    final String response = await rootBundle.loadString(
      'assets/categories.json',
    );
    final Map<String, dynamic> asset = Map<String, dynamic>.from(
      json.decode(response) as Map,
    );
    final Map<String, dynamic> merged = {};

    asset.forEach((k, v) {
      if (!deletedCategories.contains(k)) {
        merged[k] = custom.containsKey(k) ? custom[k] : v;
      }
    });

    custom.forEach((k, v) {
      if (!asset.containsKey(k) && k != '__deleted__') merged[k] = v;
    });

    setState(() {
      categories = merged;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final names = categories.keys.toList()..sort();
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('choose_category')),
        automaticallyImplyLeading: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        controller: _gridScrollController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

            // Logic for column count
            int crossAxisCount = width < 350 ? 2 : (width < 600 ? 3 : 4);
            double spacing = width < 400 ? 12 : 16;

            return GridView.builder(
              controller: _gridScrollController,
              padding: EdgeInsets.all(spacing),
              itemCount: names.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                // FIX: Use a taller ratio by default to prevent overflow
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, i) {
                final name = names[i];
                final cat = categories[name];

                Color color = Colors.grey;
                if (cat["color"] is int)
                  color = Color(cat["color"]);
                else if (cat["color"] is String)
                  color = hexToColor(cat["color"]);

                final icon = getMaterialIcon(cat["icon"]);
                int wordCount = (cat is Map && cat['ar'] is List)
                    ? (cat['ar'] as List).length
                    : 0;

                return Card(
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlayerSetupScreen(selectedCategory: name),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Icon area: Uses Expanded so it takes
                          // available space but shrinks if text is long.
                          Expanded(
                            child: Center(
                              child: CircleAvatar(
                                radius: width < 400 ? 22 : 28,
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(
                                  icon,
                                  size: width < 400 ? 22 : 28,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 2. Title: Set to max 1 line with ellipsis
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width < 400 ? 12 : 14,
                                ),
                          ),

                          const SizedBox(height: 2),

                          // 3. Subtitle
                          Text(
                            '$wordCount كلمة',
                            style: TextStyle(
                              fontSize: width < 400 ? 10 : 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }
}
