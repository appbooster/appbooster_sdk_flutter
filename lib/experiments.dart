part of appbooster_sdk_flutter;

class _Experiments {
  _Storage _storage;

  Map<String, String> defaultExperiments;
  Map<String, String> experiments;
  Map<String, String> detailedExperiments;

  _Experiments({
    @required _Storage storage,
    @required Map<String, String> defaults,
  })  : _storage = storage,
        defaultExperiments = Map.unmodifiable(defaults ?? const {}) {
    assert(_storage != null);
    assert(defaultExperiments.isNotEmpty);
    _restoreDefaultExperiments();
  }

  void update(Iterable loadedExperiments) {
    experiments = _extractExperiments(loadedExperiments);
    _storage.writeExperimentsDefaults(experiments);
    detailedExperiments = _extractDetailedExperiments(loadedExperiments);
  }

  void _restoreDefaultExperiments() {
    final defaults = _storage.readExperimentsDefaults();
    if (defaults?.isEmpty ?? true) return;
    defaultExperiments = defaults;
    detailedExperiments = _extractDefaultDetailedExperiments(defaults);
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
