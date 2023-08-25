import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:azkar_prayers/providers/azkar.dart';
import 'package:azkar_prayers/screens/zekr_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('box');
  // Hive.box('box').clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Azkar azkar = Azkar();
    azkar.resetIfDayChanged();
    return ChangeNotifierProvider(
      create: (_) => azkar,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
          textTheme: TextTheme(
            titleLarge: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22 / MediaQuery.textScaleFactorOf(context)),
          ),
        ),
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
  @override
  void initState() {
    resetIfDayChanged();
    super.initState();
  }

  bool isSearching = false;
  List azkar = Azkar.azkar;

  @override
  Widget build(BuildContext context) {
    final azkarData = Provider.of<Azkar>(context);
    azkarData.resetIfDayChanged();
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: isSearching
            ? AppBar(
                title: TextField(
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: 22 / MediaQuery.textScaleFactorOf(context),
                  ),
                  textDirection: TextDirection.rtl,
                  onChanged: (query) {
                    if (query.isEmpty) {
                      setState(() {
                        azkar = Azkar.azkar;
                      });
                    } else {
                      setState(() {
                        azkar = azkarData.searchResults(query);
                      });
                    }
                  },
                  onSubmitted: (_) {
                    setState(() {
                      isSearching = false;
                      azkar = Azkar.azkar;
                    });
                  },
                ),
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
                      fontSize: 30 / MediaQuery.textScaleFactorOf(context),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.9),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                      icon: Icon(Icons.search)),
                ],
              ),
        body: ListView.builder(
          itemCount: azkar.length,
          itemBuilder: (context, index) => Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: ListTile(
                  title: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    child: myCard(azkarData.getDailyCounter(index)),
                  ),
                  trailing: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    child: Text(
                      azkar[index],
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ZekrScreen(
                          index,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
          ),
        ),
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
            fontSize: 12 / MediaQuery.textScaleFactorOf(context),
            overflow: TextOverflow.fade,
          ),
          duration: const Duration(milliseconds: 300),
          value: value, // pass in a value like 2014
        ),
      ),
    );
  }

  void reset() {
    for (int i = 0; i < 16; i++) {
      Hive.box('box').put('current$i', 0);
      Hive.box('box').put('daily$i', 0);
    }
    Hive.box('box').put('daily', 0);
  }

  void resetIfDayChanged() {
    if (didDayDateChange()) {
      reset();
    }
  }

  bool didDayDateChange() {
    if (!Hive.box('box').containsKey('dayDate')) {
      Hive.box('box').put('dayDate', DateTime.now());
      return true;
    }
    var date = DateTime.now();
    final savedDate = Hive.box('box').get('dayDate');

    if (date.day != savedDate.day ||
        date.month != savedDate.month ||
        date.year != savedDate.year) {
      Hive.box('box').put('dayDate', DateTime.now());
      return true;
    }
    return false;
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('تأكيد الخروج', textAlign: TextAlign.right),
            content: Text('هل تريد الخروج ؟', textAlign: TextAlign.right),
            contentTextStyle: TextStyle(
              fontFamily: 'Changa',
              fontSize: 20 / MediaQuery.textScaleFactorOf(context),
              color: Colors.black,
            ),
            titleTextStyle: TextStyle(
              fontFamily: 'Changa',
              fontSize: 20 / MediaQuery.textScaleFactorOf(context),
              color: Colors.black,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('نعم',
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: 18 / MediaQuery.textScaleFactorOf(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'لا',
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontSize: 18 / MediaQuery.textScaleFactorOf(context),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
