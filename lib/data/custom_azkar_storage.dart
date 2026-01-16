import 'package:hive_flutter/hive_flutter.dart';

class CustomAzkarStorage {
  static const _boxName = 'custom_azkar_box';
  static const _customAzkarKey = 'custom_azkar_list';
  
  static late Box<List<String>> _box;
  
  /// Initialize Hive box for custom azkar
  static Future<void> init() async {
    _box = await Hive.openBox<List<String>>(_boxName);
  }
  
  /// Get all custom azkar
  static List<String> getCustomAzkar() {
    return _box.get(_customAzkarKey, defaultValue: []) ?? [];
  }
  
  /// Add a new custom azkar
  static Future<void> addCustomAzkar(String zikr) async {
    final currentAzkar = getCustomAzkar();
    currentAzkar.add(zikr);
    await _box.put(_customAzkarKey, currentAzkar);
  }
  
  /// Remove a custom azkar by index
  static Future<void> removeCustomAzkar(int index) async {
    final currentAzkar = getCustomAzkar();
    if (index >= 0 && index < currentAzkar.length) {
      currentAzkar.removeAt(index);
      await _box.put(_customAzkarKey, currentAzkar);
    }
  }
  
  /// Edit a custom azkar at specific index
  static Future<void> editCustomAzkar(int index, String newZikr) async {
    final currentAzkar = getCustomAzkar();
    if (index >= 0 && index < currentAzkar.length) {
      currentAzkar[index] = newZikr;
      await _box.put(_customAzkarKey, currentAzkar);
    }
  }
  
  /// Clear all custom azkar
  static Future<void> clearAll() async {
    await _box.delete(_customAzkarKey);
  }
  
  /// Get count of custom azkar
  static int getCount() {
    return getCustomAzkar().length;
  }
  
  /// Check if there are any custom azkar
  static bool hasCustomAzkar() {
    return getCustomAzkar().isNotEmpty;
  }
}