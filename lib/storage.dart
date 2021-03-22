part of appbooster_sdk_flutter;

class _Storage {
  static const _deviceIdPrefsKey = 'appbooster-device-id';
  static const _defaultsPrefsKey = 'appbooster-default-experiments';

  SharedPreferences _prefs;

  Future<void> initialize() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  void writeDeviceId(String deviceId) =>
      _prefs.setString(_deviceIdPrefsKey, deviceId);
  String readDeviceId() => _prefs.getString(_deviceIdPrefsKey);

  void writeExperimentsDefaults(Map<String, String> defaults) {
    if (defaults?.isEmpty ?? true) return;
    _prefs.setString(_defaultsPrefsKey, jsonEncode(defaults));
  }

  Map<String, String> readExperimentsDefaults() {
    final defaults = _prefs.getString(_defaultsPrefsKey);
    if (defaults?.isEmpty ?? true) return const {};

    try {
      return Map<String, String>.from(jsonDecode(defaults));
    } catch (_) {
      return const {};
    }
  }
}
