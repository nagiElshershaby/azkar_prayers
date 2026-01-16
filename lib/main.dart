import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:azkar_prayers/providers/azkar_provider.dart';
import 'package:azkar_prayers/screens/zekr_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/custom_azkar_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open the main box
  await Hive.openBox('box');

  // Initialize custom azkar storage
  await CustomAzkarStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AzkarProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
          textTheme: TextTheme(
            titleLarge: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MediaQuery.textScalerOf(context).scale(22)),
          ),
        ),
        
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSearching = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final azkarData = Provider.of<AzkarProvider>(context);
    azkarData.resetIfDayChanged();

    // Get azkar list based on search state
    List<String> displayAzkar = isSearching && searchQuery.isNotEmpty
        ? azkarData.searchResults(searchQuery)
        : azkarData.azkar;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onWillPop(context),
      child: Scaffold(
        appBar: isSearching
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: MediaQuery.textScalerOf(context).scale(22),
                  ),
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن ذكر...',
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  onSubmitted: (_) {
                    setState(() {
                      isSearching = false;
                      searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                actions: [
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
                ],
              )
            : AppBar(
                title: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  child: myCard(azkarData.getTotalDaily()),
                ),
                actions: [
                  Text(
                    'عداد الأذكار',
                    style: TextStyle(
                      fontFamily: 'Changa',
                      fontSize: MediaQuery.textScalerOf(context).scale(30),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(229), // Approximately 0.9 opacity
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = true;
                      });
                    },
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
        body: displayAzkar.isEmpty && isSearching
            ? Center(
                child: Text(
                  'لا توجد نتائج',
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: MediaQuery.textScalerOf(context).scale(20),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: displayAzkar.length,
                padding: EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) {
                  // We need to find the actual index in the full list for this display item
                  int actualIndex = index;
                  if (isSearching && searchQuery.isNotEmpty) {
                    // Find the index in the full list for search results
                    final fullList = azkarData.azkar;
                    actualIndex = fullList.indexOf(displayAzkar[index]);
                    if (actualIndex == -1) actualIndex = index;
                  }

                  return Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: ListTile(
                          title: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.2,
                            child:
                                myCard(azkarData.getDailyCounter(actualIndex)),
                          ),
                          trailing: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayAzkar[index],
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                if (azkarData.isCustomAzkar(actualIndex))
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded,
                                        size: 18),
                                    onPressed: () {
                                      _showEditCustomAzkarDialog(
                                        context,
                                        azkarData,
                                        actualIndex,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ZekrScreen(
                                  actualIndex,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
        floatingActionButton: !isSearching
            ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                onPressed: null,
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black26,
                  color: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 10),
                  onSelected: (value) {
                    if (value == 'add') {
                      _showAddCustomAzkarDialog(context, azkarData);
                    } else if (value == 'manage') {
                      _showManageCustomAzkarDialog(context, azkarData);
                    } else if (value == 'reset') {
                      _showResetConfirmationDialog(context, azkarData);
                    }
                  },
                  itemBuilder: (context) => [
                    // Header with title
                    PopupMenuItem<String>(
                      enabled: false,
                      height: 40,
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الإعدادات',
                            style: TextStyle(
                              fontFamily: 'Changa',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    const PopupMenuDivider(),

                    // Add new zikr option
                    PopupMenuItem<String>(
                      value: 'add',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'إضافة ذكر جديد',
                              style: TextStyle(
                                fontFamily: 'Changa',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Manage custom azkar option
                    PopupMenuItem<String>(
                      value: 'manage',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.1),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'إدارة الأذكار المضافة',
                              style: TextStyle(
                                fontFamily: 'Changa',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider before reset option
                    const PopupMenuDivider(),

                    // Reset counters option (with warning color)
                    PopupMenuItem<String>(
                      value: 'reset',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.withValues(alpha: 0.1),
                              Colors.red.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'تصفير جميع العدادات',
                              style: TextStyle(
                                fontFamily: 'Changa',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.shade500,
                              ),
                              child: const Icon(
                                Icons.restart_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.7),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget myCard(int value) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedFlipCounter(
          prefix: ' مرة اليوم ',
          padding: const EdgeInsets.all(1),
          textStyle: TextStyle(
            fontFamily: 'Changa',
            fontSize: MediaQuery.textScalerOf(context).scale(12),
            overflow: TextOverflow.fade,
          ),
          duration: const Duration(milliseconds: 300),
          value: value,
        ),
      ),
    );
  }

  void _showAddCustomAzkarDialog(
      BuildContext context, AzkarProvider azkarData) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ذكر جديد', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'أدخل الذكر هنا...',
            hintTextDirection: TextDirection.rtl,
            border: OutlineInputBorder(),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await azkarData.addCustomAzkar(controller.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إضافة الذكر بنجاح'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Text(
              'إضافة',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCustomAzkarDialog(
      BuildContext context, AzkarProvider azkarData, int index) {
    final TextEditingController controller = TextEditingController();
    final customIndex = azkarData.getCustomAzkarIndex(index);
    final customAzkar = azkarData.customAzkar;

    if (customIndex < 0 || customIndex >= customAzkar.length) return;

    controller.text = customAzkar[customIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الذكر', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'عدل الذكر هنا...',
                hintTextDirection: TextDirection.rtl,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await azkarData.editCustomAzkar(
                        customIndex, controller.text.trim());
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تعديل الذكر بنجاح'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'تعديل',
                    style: TextStyle(
                      fontFamily: 'Changa',
                      fontSize: MediaQuery.textScalerOf(context).scale(16),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await azkarData.removeCustomAzkar(customIndex);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف الذكر بنجاح'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(
                    'حذف',
                    style: TextStyle(
                        fontFamily: 'Changa',
                        fontSize: MediaQuery.textScalerOf(context).scale(16),
                        color: Theme.of(context).colorScheme.onError),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManageCustomAzkarDialog(
      BuildContext context, AzkarProvider azkarData) {
    final customAzkar = azkarData.customAzkar;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إدارة الأذكار المضافة (${customAzkar.length})',
          textAlign: TextAlign.right,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: customAzkar.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد أذكار مضافة',
                    style: TextStyle(
                      fontFamily: 'Changa',
                      fontSize: MediaQuery.textScalerOf(context).scale(18),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: customAzkar.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      title: Text(
                        customAzkar[index],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: MediaQuery.textScalerOf(context).scale(16),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditCustomAzkarDialog(
                                context,
                                azkarData,
                                index + azkarData.getFixedLength(),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () async {
                              await azkarData.removeCustomAzkar(index);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف الذكر بنجاح'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        actions: [
          if (customAzkar.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                await azkarData.clearAllCustomAzkar();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف جميع الأذكار المضافة'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                'حذف الكل',
                style: TextStyle(
                  fontFamily: 'Changa',
                  fontSize: MediaQuery.textScalerOf(context).scale(16),
                  color: Theme.of(context)
                      .colorScheme
                      .onError,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(
      BuildContext context, AzkarProvider azkarData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير العدادات', textAlign: TextAlign.right),
        content: const Text(
          'هل تريد تصفير جميع العدادات اليومية؟',
          textAlign: TextAlign.right,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Changa',
          fontSize: MediaQuery.textScalerOf(context).scale(20),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Changa',
          fontSize: MediaQuery.textScalerOf(context).scale(20),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              azkarData.reset();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصفير جميع العدادات'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'نعم',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'لا',
              style: TextStyle(
                fontFamily: 'Changa',
                fontSize: MediaQuery.textScalerOf(context).scale(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (isSearching) {
      setState(() {
        isSearching = false;
        searchQuery = '';
        _searchController.clear();
      });
      return false;
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الخروج', textAlign: TextAlign.right),
            content: const Text('هل تريد الخروج؟', textAlign: TextAlign.right),
            contentTextStyle: TextStyle(
              fontFamily: 'Changa',
              fontSize: MediaQuery.textScalerOf(context).scale(20),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            titleTextStyle: TextStyle(
              fontFamily: 'Changa',
              fontSize: MediaQuery.textScalerOf(context).scale(20),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'نعم',
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: MediaQuery.textScalerOf(context).scale(18),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'لا',
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: MediaQuery.textScalerOf(context).scale(18),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
