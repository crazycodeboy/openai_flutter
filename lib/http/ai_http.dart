import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:openai_flutter/http/ai_config.dart';
import 'package:openai_flutter/utils/ai_logger.dart';
import 'api_exception.dart';

class AIHttp {
  static Future<T> get<T>({
    required String from,
    bool returnRawResponse = false,
    T Function(Map<String, dynamic>)? onSuccess,
  }) async {
    AILogger.log("starting request to $from");
    final http.Response response = await http.get(
      Uri.parse(from),
      headers: AIConfigBuilder.instance.headers(),
    );

    if (returnRawResponse) {
      return response.body as T;
    }
    AILogger.log(
        "request to $from finished with status code ${response.statusCode}");

    AILogger.log("starting decoding response body");
    Utf8Decoder utf8decoder = const Utf8Decoder();
    final Map<String, dynamic> decodedBody =
        jsonDecode(utf8decoder.convert(response.bodyBytes))
            as Map<String, dynamic>;

    AILogger.log("response body decoded successfully");
    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess!(decodedBody);
    }
  }

  static Stream<T> getStream<T>({
    required String from,
    required T Function(Map<String, dynamic>) onSuccess,
  }) {
    final controller = StreamController<T>();
    final http.Client client = http.Client();

    final request = http.Request("GET", Uri.parse(from));
    request.headers.addAll(AIConfigBuilder.instance.headers());

    void close() {
      client.close();
      controller.close();
    }

    client.send(request).then((streamedResponse) {
      streamedResponse.stream.listen((value) {
        final String data = utf8.decode(value);

        final List<String> dataLines =
            data.split("\n").where((element) => element.isNotEmpty).toList();

        for (String line in dataLines) {
          if (line.startsWith("data: ")) {
            final String data = line.substring(6);
            if (data.startsWith("[DONE]")) {
              AILogger.log("stream response is done");
              return;
            }

            final decoded = jsonDecode(data) as Map<String, dynamic>;
            controller.add(onSuccess(decoded));
          }
        }
      }, onDone: () {
        close();
      }, onError: (err) {
        controller.addError(err);
      });
    });

    return controller.stream;
  }

  static Future<T> post<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    Map<String, dynamic>? body,
  }) async {
    AILogger.log("starting request to $to");

    final http.Response response = await http.post(
      Uri.parse(to),
      headers: AIConfigBuilder.instance.headers(),
      body: body != null ? jsonEncode(body) : null,
    );

    AILogger.log(
        "request to $to finished with status code ${response.statusCode}");

    AILogger.log("starting decoding response body");
    Utf8Decoder utf8decoder = const Utf8Decoder();
    final Map<String, dynamic> decodedBody =
        jsonDecode(utf8decoder.convert(response.bodyBytes))
            as Map<String, dynamic>;
    AILogger.log("response body decoded successfully");

    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess(decodedBody);
    }
  }

  static Stream<T> postStream<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, dynamic> body,
  }) {
    StreamController<T> controller = StreamController<T>();

    final http.Client client = http.Client();
    http.Request request = http.Request(
      "POST",
      Uri.parse(to),
    );
    request.headers.addAll(AIConfigBuilder.instance.headers());
    request.body = jsonEncode(body);

    void close() {
      client.close();
      controller.close();
    }

    AILogger.log("starting request to $to");
    client.send(request).then(
      (respond) {
        AILogger.log("Starting to reading stream response");
        respond.stream.listen((value) {
          final String data = utf8.decode(value);

          final List<String> dataLines =
              data.split("\n").where((element) => element.isNotEmpty).toList();

          for (String line in dataLines) {
            if (line.startsWith("data: ")) {
              final String data = line.substring(6);
              if (data.startsWith("[DONE]")) {
                AILogger.log("stream response is done");
                return;
              }

              final decoded = jsonDecode(data) as Map<String, dynamic>;

              controller.add(onSuccess(decoded));
            }
          }
        }, onDone: () {
          close();
        }, onError: (error) {
          controller.addError(error);
        });
      },
    );

    return controller.stream;
  }

  static Future imageEditForm<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required File image,
    required File? mask,
    required Map<String, String> body,
  }) async {
    AILogger.log("starting request to $to");
    final http.MultipartRequest request = http.MultipartRequest(
      "POST",
      Uri.parse(to),
    );
    request.headers.addAll(AIConfigBuilder.instance.headers());
    final http.MultipartFile file =
        await http.MultipartFile.fromPath("image", image.path);

    final http.MultipartFile? maskFile = mask != null
        ? await http.MultipartFile.fromPath("mask", mask.path)
        : null;

    request.files.add(file);
    if (maskFile != null) request.files.add(maskFile);
    request.fields.addAll(body);
    final http.StreamedResponse response = await request.send();
    AILogger.log(
        "request to $to finished with status code ${response.statusCode}");

    AILogger.log("starting decoding response body");
    final String encodedBody = await response.stream.bytesToString();
    final Map<String, dynamic> decodedBody =
        jsonDecode(encodedBody) as Map<String, dynamic>;
    AILogger.log("response body decoded successfully");
    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess(decodedBody);
    }
  }

  static Future<T> imageVariationForm<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, dynamic> body,
    required File image,
  }) async {
    AILogger.log("starting request to $to");
    final http.MultipartRequest request = http.MultipartRequest(
      "POST",
      Uri.parse(to),
    );
    request.headers.addAll(AIConfigBuilder.instance.headers());
    final http.MultipartFile imageFile =
        await http.MultipartFile.fromPath("image", image.path);
    request.files.add(imageFile);
    final http.StreamedResponse response = await request.send();
    AILogger.log(
        "request to $to finished with status code ${response.statusCode},");

    AILogger.log("starting decoding response body");
    final String encodedBody = await response.stream.bytesToString();
    final Map<String, dynamic> decodedBody =
        jsonDecode(encodedBody) as Map<String, dynamic>;
    AILogger.log("response body decoded successfully");
    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess(decodedBody);
    }
  }

  static Future<T> fileUpload<T>({
    required String to,
    required T Function(Map<String, dynamic>) onSuccess,
    required Map<String, String> body,
    required File file,
  }) async {
    AILogger.log("starting request to $to");
    final http.MultipartRequest request = http.MultipartRequest(
      "POST",
      Uri.parse(to),
    );
    request.headers.addAll(AIConfigBuilder.instance.headers());

    final http.MultipartFile multiPartFile =
        await http.MultipartFile.fromPath("file", file.path);

    request.files.add(multiPartFile);
    request.fields.addAll(body);
    final http.StreamedResponse response = await request.send();

    AILogger.log(
        "request to $to finished with status code ${response.statusCode},");

    AILogger.log("starting decoding response body");

    final String encodedBody = await response.stream.bytesToString();
    final Map<String, dynamic> decodedBody =
        jsonDecode(encodedBody) as Map<String, dynamic>;

    AILogger.log("response body decoded successfully");
    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess(decodedBody);
    }
  }

  static Future<T> delete<T>({
    required String from,
    required T Function(Map<String, dynamic> response) onSuccess,
  }) async {
    AILogger.log("starting request to $from");

    final http.Response response = await http.delete(
      Uri.parse(from),
      headers: AIConfigBuilder.instance.headers(),
    );

    AILogger.log(
        "request to $from finished with status code ${response.statusCode}");

    AILogger.log("starting decoding response body");
    final Map<String, dynamic> decodedBody =
        jsonDecode(response.body) as Map<String, dynamic>;
    AILogger.log("response body decoded successfully");
    if (decodedBody['error'] != null) {
      AILogger.log("an error occurred, throwing exception");
      final Map<String, dynamic> error = decodedBody['error'];
      throw AIRequestException(
        error["message"],
        response.statusCode,
      );
    } else {
      AILogger.log("request finished successfully");
      return onSuccess(decodedBody);
    }
  }
}
