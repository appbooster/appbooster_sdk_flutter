part of appbooster_sdk_flutter;

String _generateJwt({
  @required String sdkToken,
  String deviceId,
  String appsFlyerId,
  String amplitudeDeviceId,
}) {
  final jwt = JWT({
    'deviceId': deviceId,
    if (appsFlyerId?.isNotEmpty ?? false) 'appsFlyerId': appsFlyerId,
    if (amplitudeDeviceId?.isNotEmpty ?? false)
      'amplitudeId': amplitudeDeviceId,
  });
  return jwt.sign(SecretKey(sdkToken), algorithm: JWTAlgorithm.HS256);
}
