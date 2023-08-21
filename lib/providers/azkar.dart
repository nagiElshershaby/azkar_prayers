import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Azkar with ChangeNotifier {
  static const _azkar = [
    'سُبْحَانَ اَللَّهِ',
    'اَلْحَمْد لِلَّهِ',
    'لَا إِلَهَ إِلَّا اَللَّهُ',
    'اَللَّه أَكْبَرَ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاَللَّهِ',
    'لَا إِلَهَ إِلَّا اَللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ ، لَهُ اَلْمَلِكُ وَلَهُ اَلْحَمْدُ وَهُوَ عَلِي كُلَّ شَيْءٍ قَدِيرٍ',
    'اَللَّهُمَّ صَلَّى عَلِي مُحَمَّدْ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلَّمَ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدِهِ',
    'أَسْتَغْفِرُ اَللَّهُِ',
    'أَسْتَغْفِرُ اَللَّهُ اَلْعَظِيمُ وَأَتُوبُ إِلَيْهِ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدٍ ، سُبْحَانَ اَللَّهِ اَلْعَظِيمِ',
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنْ اَلظَّالِمِينَ',
    'سُبْحَانَ اَللَّهِ وَبِحَمْدِهِ ، عَدَدُ خُلُقِهِ ، وَرِضَا نَفْسِهِ ، وَزْنُهُ عَرْشُهُ ، وَمِدَادَ كَلِمَاتِهِ',
    'بِسْمِ اَللَّهِ اَلَّذِي لَا يَضُرُّ مَعَ اِسْمِهِ شَيْءً فِي اَلْأَرْضِ وَلَا فِي اَلسَّمَاءِ وَهُوَ اَلسَّمِيعْ اَلْعَلِيمِ',
    'اَللَّهُمَّ صَلَّى عَلِي مُحَمَّدْ وَعَلِي آلَ مُحَمَّدْ ، كَمَا صُلِّيَتْ عَلِي إِبْرَاهِيمْ وَعَلِي آلَ إِبْرَاهِيمْ ، إِنَّكَ حَمِيدْ مَجِيدْ ، وَبَارَكَ عَلِي مُحَمَّدْ وَعَلِي آلَ مُحَمَّدْ كَمَا بَارَكَتْ عَلِي إِبْرَاهِيمْ وَعَلِي آلَ إِبْرَاهِيمْ ، إِنَّكَ حَمِيدْ مَجِيدْ',
    '',
  ];

  static List get azkar {
    return [..._azkar];
  }

  int getLength() {
    return azkar.length;
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
    Hive.box('box').put('current$index', c);

    int dailyCounter = Hive.box('box').get('daily$index', defaultValue: 0);
    int totalDailyCounter = Hive.box('box').get('daily', defaultValue: 0);

    if(didDayDateChange()) {
      dailyCounter = 0;
      totalDailyCounter = 0;
      for (int i = 0; i < azkar.length; i++) {
        Hive.box('box').put('daily$i', 0);
        print(Hive.box('box').get('daily$i'));
      }
    }

    dailyCounter++;
    totalDailyCounter++;

    Hive.box('box').put('daily$index', dailyCounter);
    Hive.box('box').put('daily', totalDailyCounter);
    notifyListeners();
  }

  int getTotalDaily() {
    int total = 0;

    if(didDayDateChange()) {
      for (int i = 0; i < azkar.length; i++) {
        Hive.box('box').put('daily$i', 0);
      }
    }

    for (int i = 0; i < azkar.length; i++) {
      total += int.parse(Hive.box('box').get('daily$i', defaultValue: 0).toString());
    }
    return total;
  }

  void reset () {
    for (int i = 0; i < azkar.length; i++) {
      Hive.box('box').put('current$i', 0);
      Hive.box('box').put('daily$i', 0);
    }
    Hive.box('box').put('daily', 0);
    notifyListeners();
  }
  void resetIfDayChanged() {
    if(didDayDateChange()) {
      reset();
    }
  }

  int getDailyCounter(int index) {
    return Hive.box('box').get('daily$index', defaultValue: 0);
  }

  int getCurrentCounter(int index) {
    return Hive.box('box').get('current$index', defaultValue: 0);
  }

  void setCurrentCounter(int index, int value) {
    Hive.box('box').put('current$index', value);
    notifyListeners();
  }
}