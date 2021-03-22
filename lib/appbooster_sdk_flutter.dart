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

  factory Appbooster.instance() {
    assert(_instance != null, 'Appbooster SDK must be initialized.');
    return _instance;
  }

  Map<String, String> get experiments => _experiments ?? _defaultExperiments;

  Future<void> loadExperiments() async {
    _experiments = await _client.loadExperiments(
      appId: _appId,
      jwt: _jwt,
      knownExperimentsKeys: _defaultExperiments.keys.toList(),
    );
    _storage.writeExperimentsDefaults(_experiments);
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
}
