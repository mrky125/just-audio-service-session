import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'audio/audio_listener.dart';
import 'audio/ui/audio_progress.dart';
import 'audio/ui/control_buttons.dart';
import 'service_locator.dart';

void main() async {
  await initServiceLocator();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
        .read(audioListenerProvider)
        .startListen(); // initialize and listen stream
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'album name here',
            ),
            Text(
              'song name here',
              style: Theme.of(context).textTheme.headline4,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: AudioProgress(),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: ControlButtons(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
