import 'package:face_ar_flutter_sample/BanubaCameraView.dart';
import 'package:flutter/services.dart';

class BanubaSdkController {
  late MethodChannel _channel;

  BanubaSdkController(int id) {
    _channel = MethodChannel('${BanubaCameraView.viewType}_$id');
  }

  Future<void> applyEffect(String? effectName) async {
    return _channel.invokeMethod('applyEffect', effectName);
  }

  Future<void> openCamera() async {
    return _channel.invokeMethod('open');
  }

  Future<void> closeCamera() async {
    return _channel.invokeMethod('close');
  }

  Future<void> setFrontFacing(bool front) async {
    return _channel.invokeMethod('setFrontFacing', front);
  }

  Future<void> startVideoRecording(String filePath, bool recordAudio) async {
    final params = <String, dynamic>{
      'filePath': filePath,
      'recordAudio': recordAudio
    };

    return _channel.invokeMethod('startVideoRecording', params);
  }

  Future<void> stopVideoRecording() async {
    return _channel.invokeMethod('stopVideoRecording');
  }
}
