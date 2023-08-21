import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import '../providers/azkar.dart';

class ZekrScreen extends StatefulWidget {
  final int index;

  ZekrScreen(this.index);

  @override
  _ZekrScreenState createState() => _ZekrScreenState();
}

class _ZekrScreenState extends State<ZekrScreen> {
  late int currentCounter;
  @override
  void initState() {
    // TODO: implement initState
    currentCounter =
        Hive.box('box').get('current${widget.index}', defaultValue: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final azkarData = Provider.of<Azkar>(context);
    return Scaffold(
      body: InkWell(
        onTap: () {
          currentCounter++;
          Provider.of<Azkar>(context, listen: false)
              .increaseCounter(currentCounter, widget.index);
          setState(() {});
        },
        child: Center(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Azkar.azkar[widget
                            .index], // Replace myList with your actual list of strings
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize:
                            Azkar.azkar[widget.index].toString().length < 30
                                ? 40
                                : 30),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 50, right: 50, top: 10, bottom: 10),
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            width: 3),
                      ),
                      child: currentCounter == 0
                          ? Center(
                        child: Text(
                          'ابدأ',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                            fontSize: 40,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : AnimatedFlipCounter(
                        padding: const EdgeInsets.all(1),
                        textStyle:
                        TextStyle(fontFamily: 'Changa', fontSize: 50),
                        duration: const Duration(milliseconds: 300),
                        value:
                        currentCounter, // pass in a value like 2014
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Card(
                  margin: const EdgeInsets.all(0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedFlipCounter(
                      prefix: ' مرة اليوم ',
                      padding: const EdgeInsets.all(1),
                      textStyle: TextStyle(fontFamily: 'Changa', fontSize: 17),
                      duration: const Duration(milliseconds: 300),
                      value: azkarData.getDailyCounter(widget.index), // pass in a value like 2014
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentCounter = 0;
            azkarData.setCurrentCounter(widget.index, currentCounter);
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}