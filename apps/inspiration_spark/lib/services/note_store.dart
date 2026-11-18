import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

class NoteStore {
  NoteStore._();
  static final NoteStore instance = NoteStore._();

  static const _key = 'inspiration_spark_notes_v1';

  Future<List<NoteItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(List<NoteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<List<NoteItem>> upsert(NoteItem item) async {
    final items = await load();
    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    await saveAll(items);
    return items;
  }

  Future<List<NoteItem>> remove(String id) async {
    final items = await load();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
    return items;
  }
}
