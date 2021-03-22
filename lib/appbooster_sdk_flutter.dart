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

class Appbooster {
  static Appbooster _instance;

  String _sdkToken;
  String _appId;
  String _deviceId;
  String _appsFlyerId;
  String _amplitudeDeviceId;
  bool _usingShake;
  Map<String, String> _defaultExperiments;

  String _jwt;
  Map<String, String> _experiments;
  Map<String, String> _detailedExperiments;
  _Storage _storage = _Storage();
  _Client _client = _Client();

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
    _instance ??= Appbooster._internal(
      sdkToken: sdkToken,
      appId: appId,
      deviceId: deviceId,
      appsFlyerId: appsFlyerId,
      amplitudeDeviceId: amplitudeDeviceId,
      usingShake: usingShake,
      defaults: defaults,
    );
    await _instance._storage.initialize();
    _instance._fetchAbsentParams();
  }

  Appbooster._internal({
    @required String sdkToken,
    @required String appId,
    String deviceId,
    String appsFlyerId,
    String amplitudeDeviceId,
    bool usingShake,
    @required Map<String, String> defaults,
  })  : _sdkToken = sdkToken,
        _appId = appId,
        _deviceId = deviceId,
        _appsFlyerId = appsFlyerId,
        _amplitudeDeviceId = amplitudeDeviceId,
        _usingShake = usingShake ?? true,
        _defaultExperiments = Map.unmodifiable(defaults ?? const {}) {
    assert(_sdkToken != null);
    assert(_appId != null);
    assert(_defaultExperiments.isNotEmpty);
  }

  factory Appbooster.instance() => _instance;

  Map<String, String> get experiments => _experiments ?? _defaultExperiments;
  Map<String, String> get experimentsWithDetails => _detailedExperiments;
  String experiment(String key) => experiments[key];

  Future<void> loadExperiments() async {
    final loadedExperiments = await _client.loadExperiments(
      appId: _appId,
      jwt: _jwt,
      knownExperimentsKeys: _defaultExperiments.keys.toList(),
    );
    if (loadedExperiments?.isEmpty ?? true) return;

    _experiments = _extractExperiments(loadedExperiments);
    _storage.writeExperimentsDefaults(_experiments);
    _detailedExperiments = _extractDetailedExperiments(loadedExperiments);
  }

  void _fetchAbsentParams() {
    _deviceId ??= _fetchDeviceId();
    _jwt ??= _generateJwt(
      sdkToken: _sdkToken,
      amplitudeDeviceId: _amplitudeDeviceId,
      appsFlyerId: _appsFlyerId,
      deviceId: _deviceId,
    );
    _restoreDefaultExperiments();
    _detailedExperiments =
        _extractDefaultDetailedExperiments(_defaultExperiments);
  }

  String _fetchDeviceId() {
    String deviceId = _storage.readDeviceId();
    if (deviceId?.isNotEmpty ?? false) return deviceId;

    deviceId = Uuid().v4();
    _storage.writeDeviceId(deviceId);
    return deviceId;
  }

  void _restoreDefaultExperiments() {
    final defaults = _storage.readExperimentsDefaults();
    if (defaults?.isEmpty ?? true) return;
    _defaultExperiments = defaults;
  }

  Map<String, String> _extractExperiments(Iterable loadedExperiments) {
    return Map.unmodifiable(
      Map.fromEntries(
        loadedExperiments.map<MapEntry<String, String>>(
            (e) => MapEntry(e['key'] as String, e['value'] as String)),
      ),
    );
  }

  Map<String, String> _extractDetailedExperiments(Iterable loadedExperiments) {
    final detailed = <MapEntry<String, String>>[];
    loadedExperiments.forEach((experiment) {
      detailed.add(MapEntry("[Appbooster] ${experiment['key'] as String}",
          experiment['value'] as String));
      detailed.add(MapEntry(
          "[Appbooster] [internal] ${experiment['key'] as String}",
          experiment['optionId'].toString()));
    });

    return Map.unmodifiable(Map.fromEntries(detailed));
  }

  Map<String, String> _extractDefaultDetailedExperiments(Map experiments) {
    return Map.unmodifiable(
      Map.fromEntries(experiments.entries.map<MapEntry<String, String>>(
          (e) => MapEntry("[Appbooster] ${e.key}", e.value))),
    );
  }
}
