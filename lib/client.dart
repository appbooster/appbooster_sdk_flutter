part of appbooster_sdk_flutter;

class _Client {
  static const _domain = 'api.appbooster.com';
  static const _endpoint = '/api/mobile/experiments';

  Future<Map<String, String>> loadExperiments({
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
    if (response.statusCode != 200) return null;

    final experimentsData = jsonDecode(response.body)["experiments"];

    return Map.unmodifiable(
      Map.fromEntries(
        experimentsData.map<MapEntry<String, String>>(
            (e) => MapEntry(e['key'] as String, e['value'] as String)),
      ),
    );
  }
}
