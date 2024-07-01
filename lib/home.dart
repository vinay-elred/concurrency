import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String value = 'EMPTY';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("CALCULATE FIBONACCI"),
            const SizedBox(height: 20),
            Text(value),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                value = calculateFib(randomNo).toString();
                setState(() {});
              },
              child: const Text("SYNC"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Future.microtask(
                  () => value = calculateFib(randomNo).toString(),
                );
                setState(() {});
              },
              child: const Text("ASYNC"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final data = await compute(calculateFib, randomNo);
                value = data.toString();
                setState(() {});
              },
              child: const Text("COMPUTE RUN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                final sendPort = receivePort.sendPort;
                final worker = await Isolate.spawn(isolateFunc, sendPort);
                receivePort.listen((message) {
                  if (message is SendPort) {
                    (message).send(randomNo);
                  }
                  if (message is double) {
                    value = message.toString();                
                    setState(() {});
                    worker.kill();
                  }
                });
              },
              child: const Text("ISOLATE RUN"),
            )
          ],
        ),
      ),
    );
  }
}

void isolateFunc(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is int) {
      final data = calculateFib(message);
      sendPort.send(data);
    }
  });
}

int get randomNo => Random().nextInt(50) + 10;

double calculateFib(int n) {
  if (n <= 1) return 1;
  return calculateFib(n - 2) + calculateFib(n - 1);
}
