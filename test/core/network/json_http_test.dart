import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide/core/network/api_exception.dart';
import 'package:lucide/core/network/json_http.dart';

final _uri = Uri.https('example.org', '/data');

/// A fake server that always answers [body] with [status].
http.Client answering(int status, String body) =>
    MockClient((_) async => http.Response(body, status));

Matcher throwsKind(ApiErrorKind kind) =>
    throwsA(isA<ApiException>().having((e) => e.kind, 'kind', kind));

void main() {
  test('a 200 answer gives the decoded JSON', () async {
    expect(await getJson(answering(200, '{"a": [1, 2]}'), _uri), {
      'a': [1, 2],
    });
  });

  test('the headers are sent', () async {
    late Map<String, String> sent;
    final client = MockClient((request) async {
      sent = request.headers;
      return http.Response('{}', 200);
    });
    await getJson(client, _uri, headers: {'Authorization': 'apikey k'});
    expect(sent['Authorization'], 'apikey k');
  });

  test('accented text is decoded as UTF-8', () async {
    // Sent as raw bytes with no charset header, as some APIs do.
    final client = MockClient(
      (_) async => http.Response.bytes(utf8.encode('{"n": "Société"}'), 200),
    );
    expect(await getJson(client, _uri), {'n': 'Société'});
  });

  test('HTTP errors become the matching kind', () async {
    expect(
      getJson(answering(401, '{}'), _uri),
      throwsKind(ApiErrorKind.invalidKey),
    );
    expect(
      getJson(answering(429, '{}'), _uri),
      throwsKind(ApiErrorKind.rateLimit),
    );
    expect(
      getJson(answering(403, '{}'), _uri),
      throwsKind(ApiErrorKind.notFound),
    );
    expect(
      getJson(answering(404, ''), _uri),
      throwsKind(ApiErrorKind.notFound),
    );
    expect(getJson(answering(500, ''), _uri), throwsKind(ApiErrorKind.unknown));
  });

  test('a 200 answer that is not JSON is an unknown error', () async {
    expect(
      getJson(answering(200, '<html>'), _uri),
      throwsKind(ApiErrorKind.unknown),
    );
  });

  test('a network failure is a network error', () async {
    final client = MockClient((_) async => throw http.ClientException('down'));
    expect(getJson(client, _uri), throwsKind(ApiErrorKind.network));
  });

  test('checkBody reads the body before the status, even on a 200', () async {
    void check(Object? body) {
      if (body is Map && body['status'] == 'error') {
        throw const ApiException(ApiErrorKind.rateLimit, 'in the body');
      }
    }

    expect(
      getJson(answering(200, '{"status": "error"}'), _uri, checkBody: check),
      throwsKind(ApiErrorKind.rateLimit),
    );
    // The body explains a 400 better than the status alone.
    expect(
      getJson(answering(400, '{"status": "error"}'), _uri, checkBody: check),
      throwsKind(ApiErrorKind.rateLimit),
    );
    // Nothing found in the body: the status decides.
    expect(
      getJson(answering(404, '{}'), _uri, checkBody: check),
      throwsKind(ApiErrorKind.notFound),
    );
  });
}
