part of appbooster_sdk_flutter;

class _AppboosterDebug {
  _Client _client;
  bool _isOptionsLoaded = false;
  ShakeDetector _shakeDetector;

  List<Map<String, dynamic>> _experimentsOptions = [];
  Map<String, String> debugExperiments = {};

  _AppboosterDebug({
    @required _Client client,
  }) : _client = client {
    assert(_client != null);
  }

  void enableDebugOnShake({
    @required BuildContext context,
    DebugCallback valuesChangedCallback,
    Map<String, String> experiments,
  }) {
    _shakeDetector?.stopListening();
    _shakeDetector = ShakeDetector.waitForStart(
      onPhoneShake: () => showDebugLayer(
        context: context,
        experiments: experiments,
        valuesChangedCallback: valuesChangedCallback,
      ),
    );
  }

  void disableDebugOnShake() {
    _shakeDetector?.stopListening();
    _shakeDetector = null;
  }

  Future<void> showDebugLayer({
    @required BuildContext context,
    DebugCallback valuesChangedCallback,
    Map<String, String> experiments,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _DebugWidget(
          isOptionsLoaded: _isOptionsLoaded,
          experimentsOptions: _experimentsOptions,
          debugExperiments: debugExperiments,
          experiments: experiments,
          optionsLoadedSetter: (loaded) => _isOptionsLoaded = loaded,
          experimentsOptionsLoader: _client.loadExperimentsOptions,
          valuesChangedCallback: valuesChangedCallback,
        );
      },
    );
  }
}
