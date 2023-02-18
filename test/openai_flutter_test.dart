import 'package:flutter_test/flutter_test.dart';
import 'package:openai_flutter/openai_flutter.dart';

void main() {
  test('This is an example of using openai_flutter.', () async {
    AIConfigBuilder.init('your apiKey');
    try {
      var response = await AICompletion().create(prompt: '讲个故事', maxTokens: 1000);
      var choices = response.choices?.first;
      expect(choices, isNotNaN);
    } catch (e) {
      //
    }
  });
}
