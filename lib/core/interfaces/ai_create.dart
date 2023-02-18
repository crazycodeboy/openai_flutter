import 'package:openai_flutter/model/ai_response.dart';

abstract class AICreateInterface {
  Future<AIResponse> create(
      {String model = 'text-davinci-003',
      dynamic prompt,
      int? maxTokens = 200,
      double? temperature,
      double? topP,
      int? n,
      int? logprobs,
      bool? echo,
      String? stop,
      int? bestOf,
      String? user,
      String? suffix});
}
