import 'dart:convert';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';

class CategoryEditorScreen extends StatefulWidget {
  const CategoryEditorScreen({super.key});

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _wordScrollController = ScrollController();
  static const _prefsKey = 'custom_categories';
  Map<String, dynamic> custom = {};
  Map<String, dynamic> asset = {};
  Map<String, dynamic> merged = {};
  String? selectedCategory;
  final TextEditingController _newCatCtrl = TextEditingController();
  final TextEditingController _newWordCtrl = TextEditingController();
  bool _revealWords = false;
  List<String> deletedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final decoded = json.decode(raw);
        final Map<String, dynamic> normalized = {};
        if (decoded is Map) {
          decoded.forEach((k, v) {
            normalized[k.toString()] = v;
          });
        }
        custom = normalized;
        deletedCategories = List<String>.from(custom['__deleted__'] ?? []);
      } catch (e) {
        custom = {};
      }
    } else {
      custom = {};
    }
  }

  Future<void> _loadAsset() async {
    final String response = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/categories.json');
    final Map<String, dynamic> assetData = Map<String, dynamic>.from(
      json.decode(response),
    );
    asset = assetData;
  }

  Future<void> _loadAll() async {
    await _loadCustom();
    await _loadAsset();
    _mergeCategories();
    setState(() {
      if (merged.isNotEmpty) selectedCategory ??= merged.keys.first;
    });
  }

  void _mergeCategories() {
    merged = {};
    asset.forEach((k, v) {
      if (deletedCategories.contains(k))
        return; // Skip deleted asset categories
      if (custom.containsKey(k)) {
        merged[k] = custom[k];
      } else {
        merged[k] = v;
      }
    });
    // Add any purely custom categories (not deleted)
    custom.forEach((k, v) {
      if (!asset.containsKey(k) && k != '__deleted__') {
        merged[k] = v;
      }
    });
  }

  Future<void> _saveCustom() async {
    custom['__deleted__'] = deletedCategories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(custom));
  }

  void _createCategory() async {
    final name = _newCatCtrl.text.trim();
    final initialWord = _newWordCtrl.text.trim();
    if (name.isEmpty) return;
    if (!merged.containsKey(name)) {
      setState(() {
        custom[name] = {
          "ar": initialWord.isNotEmpty ? [initialWord] : [],
          "color": "#607D8B",
          "icon": "category",
        };
        _mergeCategories();
        selectedCategory = name;
      });
      _newCatCtrl.clear();
      _newWordCtrl.clear();
      await _saveCustom();
    } else {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(lang.t('category_exists'))));
    }
  }

  void _addWord() async {
    if (selectedCategory == null) return;
    final word = _newWordCtrl.text.trim();
    if (word.isEmpty) return;
    final categoryData = merged[selectedCategory]!;
    List list;
    if (categoryData is Map && categoryData.containsKey('ar')) {
      list = categoryData['ar'];
    } else if (categoryData is List) {
      list = categoryData;
    } else {
      list = [];
    }
    if (!list.contains(word)) {
      setState(() {
        // If custom, update custom; if asset, create/extend custom override
        if (custom.containsKey(selectedCategory)) {
          final customCat = custom[selectedCategory];
          if (customCat is Map && customCat.containsKey('ar')) {
            customCat['ar'].add(word);
          }
        } else {
          // Create override for asset category, but preserve all existing words
          final List<String> newList = List<String>.from(
            categoryData['ar'] ?? [],
          );
          newList.add(word);
          custom[selectedCategory!] = {
            "ar": newList,
            "color": categoryData["color"] ?? "#607D8B",
            "icon": categoryData["icon"] ?? "category",
          };
        }
        _mergeCategories();
      });
      _newWordCtrl.clear();
      await _saveCustom();
    } else {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(lang.t('word_exists'))));
    }
  }

  void _removeWord(String word) async {
    if (selectedCategory == null) return;
    // Remove word and update merged map
    if (custom.containsKey(selectedCategory)) {
      final customCat = custom[selectedCategory];
      if (customCat is Map && customCat.containsKey('ar')) {
        (customCat['ar'] as List).remove(word);
      }
    } else {
      // Create override for asset category with removal
      final categoryData = merged[selectedCategory]!;
      final newList = List<String>.from(categoryData['ar'] ?? []);
      newList.remove(word);
      custom[selectedCategory!] = {
        "ar": newList,
        "color": categoryData["color"] ?? "#607D8B",
        "icon": categoryData["icon"] ?? "category",
      };
    }
    _mergeCategories();
    setState(() {});
    await _saveCustom();
  }

  Future<void> _deleteCategory(String name) async {
    if (asset.containsKey(name)) {
      if (!deletedCategories.contains(name)) {
        deletedCategories.add(name);
      }
    } else {
      custom.remove(name);
    }
    _mergeCategories();
    setState(() {
      if (selectedCategory == name) {
        selectedCategory = merged.isEmpty ? null : merged.keys.first;
      } else {
        selectedCategory = merged.isEmpty ? null : selectedCategory;
      }
    });
    await _saveCustom();
  }

  List<String> _getWordsList() {
    if (selectedCategory == null) return [];
    final categoryData = merged[selectedCategory];
    if (categoryData is Map && categoryData.containsKey('ar')) {
      return List<String>.from(categoryData['ar'] ?? []);
    } else if (categoryData is List) {
      return List<String>.from(categoryData);
    }
    return [];
  }

  Future<void> _askDeleteCategory(String name) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${lang.t('delete')} "$name"?'),
        content: Text(
          '${lang.t('delete')} "$name" ${lang.t('and_all_its_words')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              lang.t('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await _deleteCategory(name);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _wordScrollController.dispose();
    _newCatCtrl.dispose();
    _newWordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('edit_category')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Create new category row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCatCtrl,
                      decoration: InputDecoration(
                        hintText: lang.t('new_category'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).inputDecorationTheme.fillColor ??
                            Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createCategory,
                    child: Text(lang.t('add')),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Categories selection horizontal list with scrollbar
              SizedBox(
                height: 100,
                width: double.infinity,
                child: Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  controller: _categoryScrollController,
                  notificationPredicate: (notif) =>
                      notif.metrics.axis == Axis.horizontal,
                  child: ListView(
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    children: merged.keys.map((k) {
                      final isSelected = k == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            ChoiceChip(
                              label: Text(k),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => selectedCategory = k),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => _askDeleteCategory(k),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Removed Divider (yellow underline)

              // Selected category details
              if (selectedCategory != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 14),
                          children: [
                            TextSpan(
                              text: '${lang.t('words_in')} "',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: selectedCategory ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: '"',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _revealWords ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _revealWords = !_revealWords),
                    ),
                  ],
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _wordScrollController,
                    child: ListView(
                      controller: _wordScrollController,
                      children: _getWordsList().map((w) {
                        return ListTile(
                          title: Text(_revealWords ? w : '•' * w.length),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeWord(w),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newWordCtrl,
                        decoration: InputDecoration(
                          hintText: lang.t('add_new_word'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor ??
                              Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addWord,
                      child: Text(lang.t('add')),
                    ),
                  ],
                ),
              ] else
                Expanded(child: Center(child: Text(lang.t('create_category')))),

              // ... confirm button removed ...
            ],
          ),
        ),
      ),
    );
  }
}
