// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// Response payload from an HTTP request.
class HttpResponseData {
  final int statusCode;
  final String body;
  final bool isSuccess;

  const HttpResponseData({
    required this.statusCode,
    required this.body,
    required this.isSuccess,
  });
}

/// Make an HTTP GET request (Web Implementation)
Future<HttpResponseData> httpGet(String url, {Map<String, String>? headers}) async {
  final completer = Completer<HttpResponseData>();
  final request = html.HttpRequest();
  request.open('GET', url);
  headers?.forEach((k, v) => request.setRequestHeader(k, v));

  request.onLoadEnd.listen((_) {
    final status = request.status ?? 0;
    completer.complete(HttpResponseData(
      statusCode: status,
      body: request.responseText ?? '',
      isSuccess: status >= 200 && status < 300,
    ));
  });

  request.onError.listen((_) {
    completer.complete(const HttpResponseData(
      statusCode: 500,
      body: 'Network Error',
      isSuccess: false,
    ));
  });

  request.send();
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => const HttpResponseData(
      statusCode: 408,
      body: 'Request Timeout',
      isSuccess: false,
    ),
  );
}

/// Make an HTTP PUT request (Web Implementation)
Future<HttpResponseData> httpPut(String url, String body, {Map<String, String>? headers}) async {
  final completer = Completer<HttpResponseData>();
  final request = html.HttpRequest();
  request.open('PUT', url);
  request.setRequestHeader('Content-Type', 'application/json');
  headers?.forEach((k, v) => request.setRequestHeader(k, v));

  request.onLoadEnd.listen((_) {
    final status = request.status ?? 0;
    completer.complete(HttpResponseData(
      statusCode: status,
      body: request.responseText ?? '',
      isSuccess: status >= 200 && status < 300,
    ));
  });

  request.onError.listen((_) {
    completer.complete(const HttpResponseData(
      statusCode: 500,
      body: 'Network Error',
      isSuccess: false,
    ));
  });

  request.send(body);
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => const HttpResponseData(
      statusCode: 408,
      body: 'Request Timeout',
      isSuccess: false,
    ),
  );
}

/// Make an HTTP POST request (Web Implementation)
Future<HttpResponseData> httpPost(String url, String body, {Map<String, String>? headers}) async {
  final completer = Completer<HttpResponseData>();
  final request = html.HttpRequest();
  request.open('POST', url);
  request.setRequestHeader('Content-Type', 'application/json');
  headers?.forEach((k, v) => request.setRequestHeader(k, v));

  request.onLoadEnd.listen((_) {
    final status = request.status ?? 0;
    completer.complete(HttpResponseData(
      statusCode: status,
      body: request.responseText ?? '',
      isSuccess: status >= 200 && status < 300,
    ));
  });

  request.onError.listen((_) {
    completer.complete(const HttpResponseData(
      statusCode: 500,
      body: 'Network Error',
      isSuccess: false,
    ));
  });

  request.send(body);
  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => const HttpResponseData(
      statusCode: 408,
      body: 'Request Timeout',
      isSuccess: false,
    ),
  );
}
