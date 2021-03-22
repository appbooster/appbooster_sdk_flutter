part of appbooster_sdk_flutter;

class _Client {
  static const _domain = 'api.appbooster.com';
  static const _endpoint = '/api/mobile/experiments';

  Map<String, String> _headers;

  _Client({
    @required String sdkToken,
    @required String appId,
    String deviceId,
    String appsFlyerId,
    String amplitudeDeviceId,
  }) {
    assert(sdkToken != null);
    assert(appId != null);

    final jwt = _generateJwt(
      sdkToken: sdkToken,
      amplitudeDeviceId: amplitudeDeviceId,
      appsFlyerId: appsFlyerId,
      deviceId: deviceId,
    );
    _headers = {
      'Authorization': 'Bearer $jwt',
      'SDK-App-ID': appId,
    };
  }

  Future<Map<String, dynamic>> loadExperiments({
    @required List<String> knownExperimentsKeys,
  }) async {
    final params = {'knownKeys': knownExperimentsKeys};
    final uri = Uri.https(_domain, _endpoint, params);
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) _throwError(response);

    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  void _throwError(http.Response response) {
    final message = """
      Appbooster SDK request error.
      Status Code: ${response.statusCode}.
      Body: ${response.body}.
    """;
    throw (message);
  }
}
