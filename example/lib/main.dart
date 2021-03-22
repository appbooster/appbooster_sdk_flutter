import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appbooster_sdk_flutter/appbooster_sdk_flutter.dart';
import 'package:pretty_json/pretty_json.dart';

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
  Future<void> _initializeSdk() async {
    await Appbooster.initialize(
      appId: "16897",
      sdkToken: "E44A1C2E762B41A691494FAB045993DF",
      defaults: {"flutter_test": "green"},
    );
    setState(() {});
  }

  Future<void> _fetchExperiments() async {
    await Appbooster.instance().loadExperiments();
    setState(() {});
  }

  bool _sdkInitialized() => Appbooster.instance() != null;

  String _experimentsStr(Map experiments) {
    if (experiments == null) return '—';
    return "\n${prettyJson(experiments, indent: 2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appbooster SDK Test'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _sdkInitialized() ? null : _initializeSdk,
                  child: Text('Initialize SDK'),
                ),
                ElevatedButton(
                  onPressed: _sdkInitialized() ? _fetchExperiments : null,
                  child: Text('Fetch Experiments'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                  "Current experiments values: ${_experimentsStr(Appbooster.instance()?.experiments)}"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                  "Current detailed experiments values: ${_experimentsStr(Appbooster.instance()?.experimentsWithDetails)}"),
            ),
          ],
        ),
      ),
    );
  }
}
