import 'dart:convert';
import 'dart:io';

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

/// Make an HTTP GET request (Native Implementation)
Future<HttpResponseData> httpGet(String url, {Map<String, String>? headers}) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    headers?.forEach((k, v) => request.headers.set(k, v));
    final response = await request.close().timeout(const Duration(seconds: 8));
    final body = await response.transform(utf8.decoder).join();
    client.close();
    return HttpResponseData(
      statusCode: response.statusCode,
      body: body,
      isSuccess: response.statusCode >= 200 && response.statusCode < 300,
    );
  } catch (e) {
    return HttpResponseData(
      statusCode: 500,
      body: e.toString(),
      isSuccess: false,
    );
  }
}

/// Make an HTTP PUT request (Native Implementation)
Future<HttpResponseData> httpPut(String url, String body, {Map<String, String>? headers}) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse(url);
    final request = await client.putUrl(uri);
    headers?.forEach((k, v) => request.headers.set(k, v));
    request.headers.contentType = ContentType.json;
    request.write(body);
    final response = await request.close().timeout(const Duration(seconds: 8));
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();
    return HttpResponseData(
      statusCode: response.statusCode,
      body: responseBody,
      isSuccess: response.statusCode >= 200 && response.statusCode < 300,
    );
  } catch (e) {
    return HttpResponseData(
      statusCode: 500,
      body: e.toString(),
      isSuccess: false,
    );
  }
}

/// Make an HTTP POST request (Native Implementation)
Future<HttpResponseData> httpPost(String url, String body, {Map<String, String>? headers}) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse(url);
    final request = await client.postUrl(uri);
    headers?.forEach((k, v) => request.headers.set(k, v));
    request.headers.contentType = ContentType.json;
    request.write(body);
    final response = await request.close().timeout(const Duration(seconds: 8));
    final responseBody = await response.transform(utf8.decoder).join();
    client.close();
    return HttpResponseData(
      statusCode: response.statusCode,
      body: responseBody,
      isSuccess: response.statusCode >= 200 && response.statusCode < 300,
    );
  } catch (e) {
    return HttpResponseData(
      statusCode: 500,
      body: e.toString(),
      isSuccess: false,
    );
  }
}
