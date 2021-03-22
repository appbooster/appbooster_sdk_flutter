part of appbooster_sdk_flutter;

class _AppboosterDebug {
  _Client _client;
  bool _useShake;

  _AppboosterDebug({
    @required _Client client,
    @required bool useShake,
  })  : _client = client,
        _useShake = useShake {
    assert(_client != null);
    assert(_useShake != null);
  }
}
