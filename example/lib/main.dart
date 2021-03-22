import 'package:flutter/material.dart';
import 'package:appbooster_sdk_flutter/appbooster_sdk_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appbooster Flutter SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _experimentsValues = "—";
  bool _sdkInitialized = false;

  Future<void> _initializeSdk() async {
    await Appbooster.initialize(
      appId: "16897",
      sdkToken: "E44A1C2E762B41A691494FAB045993DF",
      defaults: {"flutter_test": "green"},
    );
    setState(() {
      _sdkInitialized = true;
      _experimentsValues = Appbooster.instance().experiments.toString();
    });
  }

  Future<void> _fetchExperiments() async {
    await Appbooster.instance().loadExperiments();
    setState(() {
      _experimentsValues = Appbooster.instance().experiments.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appbooster SDK Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _sdkInitialized ? null : _initializeSdk,
              child: Text('Initialize SDK'),
            ),
            ElevatedButton(
              onPressed: _sdkInitialized ? _fetchExperiments : null,
              child: Text('Fetch Experiments'),
            ),
            Text("Current experiments values: $_experimentsValues"),
          ],
        ),
      ),
    );
  }
}
