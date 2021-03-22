library appbooster_sdk_flutter;

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';

part 'client.dart';
part 'storage.dart';
part 'jwt.dart';
part 'debug.dart';
part 'experiments.dart';

class Appbooster {
  static Appbooster _instance;

  bool _usingShake;
  _Storage _storage = _Storage();
  _Client _client;
  _Experiments _experiments;
  _AppboosterDebug _debug;

  static Future<void> initialize({
    @required String sdkToken,
    @required String appId,
    String deviceId,
    String appsFlyerId,
    String amplitudeDeviceId,
    bool usingShake,
    @required Map<String, String> defaults,
  }) async {
    assert(_instance == null, 'Appbooster SDK is already initialized.');

    _instance ??= Appbooster._internal(usingShake: usingShake);
    await _instance._storage.initialize();
    _instance._experiments = _Experiments(
      storage: _instance._storage,
      defaults: defaults,
    );
    deviceId ??= _instance._fetchDeviceId();
    _instance._client = _Client(
      appId: appId,
      sdkToken: sdkToken,
      deviceId: deviceId,
      appsFlyerId: appsFlyerId,
      amplitudeDeviceId: amplitudeDeviceId,
    );
  }

  Appbooster._internal({bool usingShake}) : _usingShake = usingShake ?? true;
  factory Appbooster.instance() => _instance;

  Map<String, String> get experiments =>
      _experiments.experiments ?? _experiments.defaultExperiments;
  Map<String, String> get experimentsWithDetails =>
      _experiments.detailedExperiments;
  String experiment(String key) => experiments[key];

  Future<void> loadExperiments() async {
    final loadedData = await _client.loadExperiments(
        knownExperimentsKeys: experiments.keys.toList(growable: false));

    if (loadedData['meta']['debug'] && _debug == null) {
      _debug = _AppboosterDebug(client: _client, useShake: _usingShake);
    }

    final loadedExperiments = loadedData['experiments'];
    if (loadedExperiments?.isEmpty ?? true) return;

    _experiments.update(loadedExperiments);
  }

  String _fetchDeviceId() {
    String deviceId = _storage.readDeviceId();
    if (deviceId?.isNotEmpty ?? false) return deviceId;

    deviceId = Uuid().v4();
    _storage.writeDeviceId(deviceId);
    return deviceId;
  }
}
