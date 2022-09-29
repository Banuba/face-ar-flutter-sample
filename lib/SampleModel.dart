import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class SampleStateModel extends ChangeNotifier {
  static const _effects = ["Cats", "DebugWireframe", "PineappleGlasses", "TrollGrandma"];
  int _lastEffectPosition = 0;
  bool _lastFacingFront = true;

  var status = Status.initial;

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
    var permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) {
      status = Status.ready;
      notifyListeners();
      return;
    }

    status = Status.requestPermissions;
    notifyListeners();

    permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      status = Status.ready;
    } else {
      status = Status.initial;
    }

    notifyListeners();
  }
}

enum Status {
  initial,
  requestPermissions,
  ready,
}
