import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/custom_azkar_storage.dart';

class AzkarProvider with ChangeNotifier {
  static const _azkar = [
    'سِــبْحَةٌ',
    'سُبْحَانَ اَللَّهِ',
    'اَلْحَمْد لِلَّهِ',
    'لَا إِلَهَ إِلَّا اَللَّهُ',
    'اَللَّه أَكْبَرَ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاَللَّهِ',
    'لَا إِلَهَ إِلَّا اَللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ، لَهُ اَلْمَلِكُ وَلَهُ اَلْحَمْدُ وَهُوَ عَلِي كُلَّ شَيْءٍ قَدِيرٍ',
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنْ اَلظَّالِمِينَ',
    'أَسْتَغْفِرُ اَللَّهُ اَلْعَظِيمُ اَلَّذِي لَا إِلَهَ إِلَّا هُوَ اَلْحَيَّ اَلْقَيُّومْ وَأَتُوبُ إِلَيْهِ',
    'اَللَّهُمَّ صَلَّى عَلِي مُحَمَّدْ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلَّمَ',
    'اَللَّهُمَّ صَلَّى عَلِي مُحَمَّدْ وَعَلِي آلَ مُحَمَّدْ ، كَمَا صُلِّيَتْ عَلِي إِبْرَاهِيمْ وَعَلِي آلَ إِبْرَاهِيمْ ، إِنَّكَ حَمِيدْ مَجِيدْ ، وَبَارَكَ عَلِي مُحَمَّدْ وَعَلِي آلَ مُحَمَّدْ كَمَا بَارَكَتْ عَلِي إِبْرَاهِيمْ وَعَلِي آلَ إِبْرَاهِيمْ ، إِنَّكَ حَمِيدْ مَجِيدْ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدِهِ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدٍهِ ، سُبْحَانَ اَللَّهِ اَلْعَظِيمِ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدِهِ ، عَدَدُ خُلُقِهِ ، وَرِضَا نَفْسِهِ ، وَزْنُهُ عَرْشُهُ ، وَمِدَادَ كَلِمَاتِهِ',
    'بِسْمِ اَللَّهِ اَلَّذِي لَا يَضُرُّ مَعَ اِسْمِهِ شَيْءً فِي اَلْأَرْضِ وَلَا فِي اَلسَّمَاءِ وَهُوَ اَلسَّمِيعْ اَلْعَلِيمِ',
  ];

  // Get all azkar (fixed + custom)
  List<String> get azkar {
    final customAzkar = CustomAzkarStorage.getCustomAzkar();
    return [..._azkar, ...customAzkar];
  }
  
  // Get only fixed azkar (for backward compatibility)
  List<String> get fixedAzkar {
    return [..._azkar];
  }
  
  // Get only custom azkar
  List<String> get customAzkar {
    return CustomAzkarStorage.getCustomAzkar();
  }

  String _normalizeArabic(String text) {
    return text.replaceAll(RegExp('[\u064B-\u065F\u0670]'), '');
  }

  List<String> searchResults(String query) {
    final normalizedQuery = _normalizeArabic(query);
    final allAzkar = azkar;
    
    return allAzkar.where((element) {
      final normalizedElement = _normalizeArabic(element);
      return normalizedElement.contains(normalizedQuery);
    }).toList();
  }

  int getLength() {
    return azkar.length;
  }
  
  int getFixedLength() {
    return _azkar.length;
  }
  
  int getCustomLength() {
    return CustomAzkarStorage.getCount();
  }

  final box = Hive.box('box');

  bool didDayDateChange() {
    if (!box.containsKey('dayDate')) {
      box.put('dayDate', DateTime.now());
      return true;
    }
    var date = DateTime.now();
    final savedDate = box.get('dayDate');

    if (date.day != savedDate.day ||
        date.month != savedDate.month ||
        date.year != savedDate.year) {
      box.put('dayDate', DateTime.now());
      return true;
    }
    return false;
  }

  bool didMonthDateChange() {
    if (!box.containsKey('monthDate')) {
      box.put('monthDate', DateTime.now());
      return true;
    }
    var date = DateTime.now();
    final savedDate = box.get('monthDate');

    if (date.month != savedDate.month ||
        date.year != savedDate.year) {
      box.put('monthDate', DateTime.now());
      return true;
    }
    return false;
  }

  void increaseCounter(int c, int index) {
    // Check if this is a custom azkar
    final isCustomAzkar = index >= _azkar.length;
    
    if (isCustomAzkar) {
      // For custom azkar, we need to store counters differently
      final customIndex = index - _azkar.length;
      Hive.box('box').put('custom_current$customIndex', c);
      
      int customDailyCounter = Hive.box('box').get('custom_daily$customIndex', defaultValue: 0);
      int totalDailyCounter = Hive.box('box').get('daily', defaultValue: 0);
      
      if(didDayDateChange()) {
        // Reset counters for both fixed and custom
        _resetAllCounters();
        customDailyCounter = 0;
        totalDailyCounter = 0;
      }
      
      customDailyCounter++;
      totalDailyCounter++;
      
      Hive.box('box').put('custom_daily$customIndex', customDailyCounter);
      Hive.box('box').put('daily', totalDailyCounter);
    } else {
      // Original logic for fixed azkar
      Hive.box('box').put('current$index', c);

      int dailyCounter = Hive.box('box').get('daily$index', defaultValue: 0);
      int totalDailyCounter = Hive.box('box').get('daily', defaultValue: 0);

      if(didDayDateChange()) {
        dailyCounter = 0;
        totalDailyCounter = 0;
        for (int i = 0; i < getLength(); i++) {
          if (i < _azkar.length) {
            Hive.box('box').put('daily$i', 0);
          } else {
            Hive.box('box').put('custom_daily${i - _azkar.length}', 0);
          }
        }
      }

      dailyCounter++;
      totalDailyCounter++;

      Hive.box('box').put('daily$index', dailyCounter);
      Hive.box('box').put('daily', totalDailyCounter);
    }
    
    notifyListeners();
  }

  int getTotalDaily() {
    int total = 0;

    if(didDayDateChange()) {
      _resetAllCounters();
    }

    // Sum fixed azkar counters
    for (int i = 0; i < _azkar.length; i++) {
      total += int.parse(Hive.box('box').get('daily$i', defaultValue: 0).toString());
    }
    
    // Sum custom azkar counters
    for (int i = 0; i < CustomAzkarStorage.getCount(); i++) {
      total += int.parse(Hive.box('box').get('custom_daily$i', defaultValue: 0).toString());
    }
    
    return total;
  }

  void reset() {
    _resetAllCounters();
    notifyListeners();
  }
  
  void _resetAllCounters() {
    // Reset fixed azkar counters
    for (int i = 0; i < _azkar.length; i++) {
      Hive.box('box').put('current$i', 0);
      Hive.box('box').put('daily$i', 0);
    }
    
    // Reset custom azkar counters
    for (int i = 0; i < CustomAzkarStorage.getCount(); i++) {
      Hive.box('box').put('custom_current$i', 0);
      Hive.box('box').put('custom_daily$i', 0);
    }
    
    Hive.box('box').put('daily', 0);
  }

  void resetIfDayChanged() {
    if(didDayDateChange()) {
      reset();
    }
  }

  int getDailyCounter(int index) {
    final isCustomAzkar = index >= _azkar.length;
    
    if (isCustomAzkar) {
      final customIndex = index - _azkar.length;
      return Hive.box('box').get('custom_daily$customIndex', defaultValue: 0);
    } else {
      return Hive.box('box').get('daily$index', defaultValue: 0);
    }
  }

  int getCurrentCounter(int index) {
    final isCustomAzkar = index >= _azkar.length;
    
    if (isCustomAzkar) {
      final customIndex = index - _azkar.length;
      return Hive.box('box').get('custom_current$customIndex', defaultValue: 0);
    } else {
      return Hive.box('box').get('current$index', defaultValue: 0);
    }
  }

  void setCurrentCounter(int index, int value) {
    final isCustomAzkar = index >= _azkar.length;
    
    if (isCustomAzkar) {
      final customIndex = index - _azkar.length;
      Hive.box('box').put('custom_current$customIndex', value);
    } else {
      Hive.box('box').put('current$index', value);
    }
    
    notifyListeners();
  }
  
  // New methods for managing custom azkar
  
  Future<void> addCustomAzkar(String zikr) async {
    await CustomAzkarStorage.addCustomAzkar(zikr);
    
    // Initialize counters for the new custom azkar
    final customIndex = CustomAzkarStorage.getCount() - 1;
    Hive.box('box').put('custom_current$customIndex', 0);
    Hive.box('box').put('custom_daily$customIndex', 0);
    
    notifyListeners();
  }
  
  Future<void> removeCustomAzkar(int index) async {
    // Remove counters for the custom azkar
    final customCount = CustomAzkarStorage.getCount();
    if (index >= 0 && index < customCount) {
      // Shift counters for items after the removed one
      for (int i = index; i < customCount - 1; i++) {
        final nextCurrent = Hive.box('box').get('custom_current${i + 1}', defaultValue: 0);
        final nextDaily = Hive.box('box').get('custom_daily${i + 1}', defaultValue: 0);
        
        Hive.box('box').put('custom_current$i', nextCurrent);
        Hive.box('box').put('custom_daily$i', nextDaily);
      }
      
      // Remove the last counter
      Hive.box('box').delete('custom_current${customCount - 1}');
      Hive.box('box').delete('custom_daily${customCount - 1}');
      
      // Remove the azkar
      await CustomAzkarStorage.removeCustomAzkar(index);
      
      notifyListeners();
    }
  }
  
  Future<void> editCustomAzkar(int index, String newZikr) async {
    await CustomAzkarStorage.editCustomAzkar(index, newZikr);
    notifyListeners();
  }
  
  Future<void> clearAllCustomAzkar() async {
    await CustomAzkarStorage.clearAll();
    
    // Clear all custom azkar counters
    final customCount = CustomAzkarStorage.getCount();
    for (int i = 0; i < customCount; i++) {
      Hive.box('box').delete('custom_current$i');
      Hive.box('box').delete('custom_daily$i');
    }
    
    notifyListeners();
  }
  
  // Check if an azkar at index is custom
  bool isCustomAzkar(int index) {
    return index >= _azkar.length;
  }
  
  // Get the original index of custom azkar
  int getCustomAzkarIndex(int index) {
    return index - _azkar.length;
  }
}