import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Longest wait for one answer before reporting a network error.
const requestTimeout = Duration(seconds: 20);

/// The single way the app calls a JSON API: a GET with a timeout, whose
/// failures all become an [ApiException] of the right kind.
///
/// [checkBody] reads the decoded body before the HTTP status is checked:
/// some APIs (Twelve Data) explain an error inside the body, sometimes with
/// a 200 status. It throws its own [ApiException] when it finds one.
Future<Object?> getJson(
  http.Client client,
  Uri uri, {
  Map<String, String> headers = const {},
  void Function(Object? body)? checkBody,
}) async {
  final http.Response response;
  try {
    response = await client.get(uri, headers: headers).timeout(requestTimeout);
  } on TimeoutException {
    throw const ApiException(ApiErrorKind.network, 'Timeout');
  } on http.ClientException catch (e) {
    throw ApiException(ApiErrorKind.network, e.message);
  } on Exception catch (e) {
    // Socket and TLS errors.
    throw ApiException(ApiErrorKind.network, '$e');
  }

  Object? body;
  try {
    body = jsonDecode(utf8.decode(response.bodyBytes));
  } on FormatException {
    body = null;
  }
  checkBody?.call(body);

  if (response.statusCode != 200) {
    throw ApiException(
      errorKindForStatus(response.statusCode),
      'HTTP ${response.statusCode}',
    );
  }
  if (body == null) {
    throw const ApiException(ApiErrorKind.unknown, 'Unreadable JSON');
  }
  return body;
}

/// The meaning of an HTTP error status for the app.
ApiErrorKind errorKindForStatus(int status) => switch (status) {
  401 => ApiErrorKind.invalidKey,
  429 => ApiErrorKind.rateLimit,
  // 403: the data exists but needs a paid plan, so for us it is missing.
  403 || 404 => ApiErrorKind.notFound,
  _ => ApiErrorKind.unknown,
};
