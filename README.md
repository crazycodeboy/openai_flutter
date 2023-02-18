[![pub package](https://img.shields.io/pub/v/openai_flutter.svg)](https://pub.dartlang.org/packages/openai_flutter)
[ ![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](https://github.com/crazycodeboy/openai_flutter/pulls)
[ ![openai_flutter release](https://img.shields.io/github/release/crazycodeboy/openai_flutter.svg?maxAge=2592000?style=flat-square)](https://github.com/crazycodeboy/openai_flutter/releases)


A openai library for flutter,it works on iOS,Android,Web,macOS and Windows.

## How to use

>Step1:init config

```dart
AIConfigBuilder.init('your apiKey');
```

>Step2: to get a completion

```dart
try {
  var response = await AICompletion().create(prompt: '讲个故事', maxTokens: 1000);
  var choices = response.choices?.first;
  print('result:${choices?.text}');
  expect(choices, isNotNaN);
} catch (e) {
  print(e);
}
```

Enjoy!