import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'app_language';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  // Minimal translations - extend as needed with keys used across your app
  final Map<String, Map<String, String>> _t = {
    'en': {
      'app_title': 'Barra Al Salfah',
      'subtitle': 'Who is out of the loop?',
      'start_game': 'Start Game',
      'edit_categories': 'Edit Categories',
      'play_again': 'Play Again',
      'family_friends': 'Family & Friends',
      'saved_members': 'Saved Members:',
      "add_new_member": "Add new member...",
      "category": "Category",
      "choose_category": "Choose Category",
      "edit_category": "Edit Category",
      "cancel": "Cancel",
      'add': 'Add',
      "delete": "Delete",
      "new_category": "New Category name",
      "create_category": "Create a Category to add words to it",
      "add_new_word": "Add new word...",
      "and_all_its_words": "and all its words?",
      "word_exists": "This word already exists in the category.",
      "words_in": "Words in",
      "next": "Next",
      "confirm": "Confirm",
      "start_round": "Start Round",
      "members": "Members",
      "player": "Player",
      "show_my_role": "Show My Role",
      "out_of_the_loop": "You are OUT OF THE LOOP!",
      "the_word_is": "The word is:",
      "next_player": "Next Player",
      "start_voting": "Start Voting",
      "who_is_the_imposter": "Who is the imposter?",
      "time_to_vote": "Time to vote!",
      "the_imposter_was": "The imposter was",
      "the_imposter": "The imposter",
      "secret_word": "What is the secret word?",
      "results": "Results",
      "win": "Win for",
      "lost": "Lost for",
      "guess": "GUESS",
    },
    'ar': {
      'app_title': 'برا السالفة',
      'subtitle': 'من خارج الحلقة؟',
      'start_game': 'ابدأ اللعبة',
      'edit_categories': 'تعديل الفئات',
      'play_again': 'اللعب مرة أخرى',
      'family_friends': 'العائلة والأصدقاء',
      'saved_members': 'الأعضاء المحفوظين:',
      "add_new_member": "أضف عضو جديد...",
      "category": "الفئة",
      "choose_category": "اختر الفئة",
      "edit_category": "تعديل الفئة",
      "cancel": "إلغاء",
      'add': 'أضف',
      "delete": "حذف",
      "new_category": "اسم الفئة الجديدة",
      "create_category": "أنشئ فئة لإضافة كلمات إليها",
      "add_new_word": "أضف كلمة جديدة...",
      "and_all_its_words": "وكل كلماتها؟",
      "word_exists": "هذه الكلمة موجودة بالفعل في الفئة.",
      "words_in": "الكلمات في",
      "next": "التالي",
      "confirm": "تأكيد",
      "start_round": "ابدأ الجولة",
      "members": "الأعضاء",
      "player": "اللاعب",
      "show_my_role": "اعرض دوري",
      "out_of_the_loop": "أنت برا السالفة!",
      "the_word_is": "الكلمة هي:",
      "next_player": "اللاعب التالي",
      "start_voting": "ابدأ التصويت",
      "who_is_the_imposter": "مين برا السالفة؟",
      "time_to_vote": "حان وقت التصويت!",
      "the_imposter_was": "اللي كان برا السالفة هو",
      "the_imposter": "اللي كان برا السالفة",
      "secret_word": "ما هي الكلمة السرية؟",
      "results": "النتائج",
      "win": "فاز",
      "lost": "انكشف",
      "guess": "خمن",
    },
  };

  LanguageProvider() {
    _load();
  }

  String t(String key) {
    final lang = _locale.languageCode;
    return _t[lang]?[key] ?? _t['en']?[key] ?? key;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  Future<void> toggle() async {
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}
