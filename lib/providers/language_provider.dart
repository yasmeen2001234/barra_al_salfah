import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Arabic only
  final Map<String, String> _t = {
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
  };

  String t(String key) {
    return _t[key] ?? key;
  }

  bool get isArabic => true;

  // No-op for language toggle
  Future<void> toggle() async {}
}
