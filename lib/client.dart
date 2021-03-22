part of appbooster_sdk_flutter;

class _Client {
  static const _domain = 'api.appbooster.com';
  static const _endpoint = '/api/mobile/experiments';

  Future<Iterable> loadExperiments({
    @required String appId,
    @required String jwt,
    @required List<String> knownExperimentsKeys,
  }) async {
    final params = {
      'knownKeys': knownExperimentsKeys,
    };
    final headers = {
      'Authorization': 'Bearer $jwt',
      'SDK-App-ID': appId,
    };
    final uri = Uri.https(_domain, _endpoint, params);
    final response = await http.get(uri, headers: headers);

    // TODO: Process errors
    if (response.statusCode != 200) _throwError(response);

    return jsonDecode(response.body)["experiments"];
  }

  void _throwError(http.Response response) {
    final message = """
      Appbooster SDK request error.
      Status Code: ${response.statusCode}.
      Body: ${response.body}.
    """;
    throw(message);
  }
}
