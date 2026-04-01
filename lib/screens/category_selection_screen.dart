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
  // Map<String, List<String>> categories = {};
  Map<String, dynamic> categories = {};
  bool loading = true;
  List<String> deletedCategories = [];

  String currentLang = "en"; // or "ar" for Arabic

  // --- Helper to convert hex color to Color ---
  Color hexToColor(String hex) {
    hex = hex.trim();
    if (hex.startsWith('0x')) {
      // Already in 0xAARRGGBB format
      return Color(int.parse(hex));
    }
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha if missing
    return Color(int.parse('0x$hex'));
  }

  // --- Helper to convert icon name string to IconData ---
  IconData getMaterialIcon(String name) {
    switch (name) {
      case "fastfood":
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

    // Show all asset categories not deleted, merged with custom overrides if present
    final String response = await rootBundle.loadString(
      'assets/categories.json',
    );
    final Map<String, dynamic> asset = Map<String, dynamic>.from(
      json.decode(response) as Map,
    );
    final Map<String, dynamic> merged = {};
    asset.forEach((k, v) {
      if (!deletedCategories.contains(k)) {
        if (custom.containsKey(k)) {
          merged[k] = custom[k];
        } else {
          merged[k] = v;
        }
      }
    });
    // Add any purely custom categories (not deleted)
    custom.forEach((k, v) {
      if (!asset.containsKey(k) && k != '__deleted__') {
        merged[k] = v;
      }
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
        child: GridView.builder(
          controller: _gridScrollController,
          padding: const EdgeInsets.all(16),
          itemCount: names.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, i) {
            final name = names[i];
            final cat = categories[name]; // JSON map for this category

            final colorValue = cat["color"];
            Color color;
            if (colorValue is int) {
              color = Color(colorValue);
            } else if (colorValue is String) {
              color = hexToColor(colorValue);
            } else {
              color = Colors.grey;
            }
            final icon = getMaterialIcon(cat["icon"]);

            // Always use Arabic
            int wordCount = 0;
            if (cat is Map && cat['ar'] is List) {
              wordCount = (cat['ar'] as List).length;
            }

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerSetupScreen(selectedCategory: name),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withOpacity(0.2),
                        child: Icon(icon, size: 28, color: color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$wordCount كلمة',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    @override
    void dispose() {
      _gridScrollController.dispose();
      super.dispose();
    }
  }
}
