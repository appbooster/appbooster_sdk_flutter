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
  static const _experimentsDefaults = {"flutter_test": "green", "test_experiment": "value_1"};
  bool _debugOnShake = false;

  Future<void> _initializeSdk() async {
    await Appbooster.initialize(
      appId: "16897",
      sdkToken: "E44A1C2E762B41A691494FAB045993DF",
      defaults: _experimentsDefaults,
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

  bool _isDebugAllowed() => Appbooster.instance()?.isDebugAllowed ?? false;

  void _showDebug(BuildContext context) {
    Appbooster.instance().showDebugLayer(
      context: context,
      valuesChangedCallback: (_) => setState(() {}),
    );
  }

  void _toggleDebugOnShake(BuildContext context, bool enabled) {
    if (enabled) {
      Appbooster.instance().enableDebugOnShake(
        context: context,
        valuesChangedCallback: (_) => setState(() {}),
      );
    } else {
      Appbooster.instance().disableDebugOnShake();
    }
    setState(() {
      _debugOnShake = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Defaults:\n${_experimentsDefaults.toString()}", style: theme.textTheme.subhead,),
            ),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              direction: Axis.horizontal,
              children: [
                ElevatedButton(
                  onPressed: _sdkInitialized() ? null : _initializeSdk,
                  child: Text('Initialize SDK'),
                ),
                ElevatedButton(
                  onPressed: _sdkInitialized() ? _fetchExperiments : null,
                  child: Text('Fetch Experiments'),
                ),
                ElevatedButton(
                  onPressed:
                      _isDebugAllowed() ? () => _showDebug(context) : null,
                  child: Text('Show debug'),
                ),
                IgnorePointer(
                  ignoring: !_isDebugAllowed(),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _debugOnShake,
                        onChanged: (value) =>
                            _toggleDebugOnShake(context, value),
                      ),
                      Text(
                        'Use shake',
                        style: theme.textTheme.button.copyWith(
                            color: _isDebugAllowed()
                                ? Colors.black87
                                : Colors.black26),
                      ),
                    ],
                  ),
                )
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
