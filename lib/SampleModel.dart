import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SampleStateModel extends ChangeNotifier {
  static const _effects = ["Cats", "DebugWireframe", "PineappleGlasses", "TrollGrandma"];
  int _lastEffectPosition = 0;
  bool _lastFacingFront = true;

  var status = Status.initial;

  // List of required app permissions for applying AR effect on camera and video recording
  final _requiredPermissions = [Permission.camera, Permission.storage, Permission.microphone];

  String? toggleEffect() {
    final String? effectName;
    if (_lastEffectPosition > _effects.length - 1) {
      _lastEffectPosition = 0;
      effectName = null;
    } else {
      effectName = _effects[_lastEffectPosition];
      _lastEffectPosition++;
    }
    return effectName;
  }

  bool toggleFacing() {
    _lastFacingFront = !_lastFacingFront;
    return _lastFacingFront;
  }

  Future<void> requestCameraPermission() async {
    for (var permission in _requiredPermissions) {
      var permissionStatus = await permission.status;
      if (!permissionStatus.isGranted) {
        status = Status.requestPermissions;
        notifyListeners();

        permissionStatus = await permission.request();

        if (permissionStatus.isPermanentlyDenied) {
          status = Status.grantPermissionsAppSettings;
          notifyListeners();
          return;
        }

        if (!permissionStatus.isGranted) {
          return;
        }
      }
    }

    status = Status.choiceList;
    notifyListeners();
  }

  void requestChoiceFullscreen() {
    status = Status.choiceFullscreen;
    notifyListeners();
  }

  void requestChoiceCustom() {
    status = Status.choiceCustom;
    notifyListeners();
  }

  // Provide correct file path for new video recording
  Future<String> generateVideoFilePath() async {
    final directory = await getTemporaryDirectory();
    final filename = 'far_flutter_recorded_video_${DateTime.now().millisecondsSinceEpoch}.m4';
    final filePath = '${directory.path}${Platform.pathSeparator}$filename';
    return filePath;
  }
}

enum Status {
  initial,
  requestPermissions,
  grantPermissionsAppSettings,
  choiceList,
  choiceFullscreen,
  choiceCustom
}
