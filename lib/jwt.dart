part of appbooster_sdk_flutter;

String _generateJwt({
  @required String sdkToken,
  String deviceId,
  String appsFlyerId,
  String amplitudeUserId,
}) {
  final jwt = JWT({
    'deviceId': deviceId,
    if (appsFlyerId?.isNotEmpty ?? false) 'appsFlyerId': appsFlyerId,
    if (amplitudeUserId?.isNotEmpty ?? false)
      'amplitudeId': amplitudeUserId,
  });
  return jwt.sign(SecretKey(sdkToken), algorithm: JWTAlgorithm.HS256);
}
