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
    return ChangeNotifierProvider(
      create: (_) => Azkar(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
          textTheme: TextTheme(
            titleLarge: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text(
            'أذكار',
            style: TextStyle(
              fontFamily: 'Changa',
              fontSize: 30,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: Azkar.azkar.length - 1,
        itemBuilder: (context, index) => Wrap(
          children: [
            ListTile(
              trailing: Text(
                Azkar.azkar[index],
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.fade,
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
            const Divider(),
          ],
        ),
      ),
    );
  }
}

