import 'package:openai_flutter/http/api_exception.dart';

class AIConfigBuilder {
  // This is used to store the API key.
  String? _apiKey;

  // This is used to store the organization id.
  String? _organization;

  late String _completionsUrl;
  static final AIConfigBuilder _instance = AIConfigBuilder._();

  static void init(String apiKey,
      {String? organization,
      String completionsUrl = 'https://api.openai.com/v1/completions'}) {
    _instance._apiKey = apiKey;
    _instance._organization = organization;
    _instance._completionsUrl = completionsUrl;
  }

  static AIConfigBuilder get instance {
    if (_instance._apiKey == null) {
      throw AIException("Please call AIHeadersBuilder.init() first");
    }
    return _instance;
  }

  /// This is used to build the headers for all the requests, it will return a [Map<String, String>].
  /// if an organization id is set, it will be added to the headers as well.
  /// If in anyhow the API key is not set, it will throw an [AssertionError].
  Map<String, String> headers() {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };

    assert(
      _apiKey != null,
      "You must set the API key before making building any headers for a request.",
    );
    if (_organization != null) {
      headers['OpenAI-Organization'] = _organization!;
    }
    if (_apiKey?.startsWith('Bearer ') ?? false) {
      headers["Authorization"] = _apiKey!;
    } else {
      headers["Authorization"] = "Bearer $_apiKey";
    }
    return headers;
  }

  String get completionsUrl => _completionsUrl;

  AIConfigBuilder._();
}
