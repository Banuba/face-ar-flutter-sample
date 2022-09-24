import 'dart:io';

import 'package:face_ar_flutter_sample/BanubaSdkController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef void BanubaSdkControllerCallback(BanubaSdkController controller);

class BanubaCameraView extends StatefulWidget {
  static const viewType = 'banuba.facear.flutter/camera_view';

  const BanubaCameraView({
    required Key key,
    required this.onControllerCreated,
  }) : super(key: key);

  final BanubaSdkControllerCallback onControllerCreated;

  @override
  State<StatefulWidget> createState() => _BanubaCameraViewState();
}

class _BanubaCameraViewState extends State<BanubaCameraView> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    print('BanubaCameraView. build');
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: BanubaCameraView.viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Text('Running platform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int viewId) {
    widget.onControllerCreated(BanubaSdkController(viewId));
  }
}

