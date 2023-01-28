import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_service_session/audio/audio_controller.dart';
import 'package:just_audio_service_session/audio/audio_listener.dart';
import 'package:just_audio_service_session/audio/audio_state_notifier.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: ControlButtons(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ControlButtons extends ConsumerWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sideButtonWidth = 60.0;
    ref.read(audioListenerProvider).startListen(); // initialize and listen stream
    final controller = ref.read(audioControllerProvider);
    final playbackState = ref.watch(playbackStateProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: sideButtonWidth,
          child: FittedBox(
            child: TextButton(
              onPressed: () => {},
              child: const Text(
                'TODO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            (Icons.fast_rewind),
            size: 32,
          ),
        ),
        IconButton(
          onPressed: () {
            if (playbackState.playing) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          iconSize: 64,
          icon: Icon(
            playbackState.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: 64,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            (Icons.fast_forward),
            size: 32,
          ),
        ),
        SizedBox(
          width: sideButtonWidth,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              (Icons.settings),
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}
