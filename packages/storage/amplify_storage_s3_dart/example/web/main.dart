import 'dart:html';

import 'package:amplify_core/amplify_core.dart';
import 'package:storage_s3_example/common.dart';

// TODO(HuiSF): Add example Web App
Future<void> main() async {
  AWSLogger().logLevel = LogLevel.debug;

  final outputElement = querySelector('#output')!;

  try {
    await configureAmplify();
    outputElement.text = 'Amplify plugin have been configured!';
  } on Exception catch (e) {
    outputElement.text = 'Could not configure: $e';
  }
}
