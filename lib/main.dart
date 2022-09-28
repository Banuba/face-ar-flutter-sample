import 'dart:io';

import 'package:face_ar_flutter_sample/SampleModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BanubaCameraView.dart';
import 'BanubaSdkController.dart';

void main() {
  runApp(const SampleApp());
}

class SampleApp extends StatelessWidget {
  const SampleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraPage(title: 'Banuba Face AR Flutter Sample'),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.title});

  final String title;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  BanubaSdkController? _controller;

  Future<void> applyEffect(SampleStateModel model) async {
    if (Platform.isAndroid) {
      _controller?.applyEffect(model.toggleEffect());
    }
  }

  void applyFacing(SampleStateModel model) {
    if (Platform.isAndroid) {
      _controller?.setFrontFacing(model.toggleFacing());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SampleStateModel(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Container(
            child: Consumer<SampleStateModel>(builder: (context, model, child) {
              switch (model.status) {
                case Status.initial:
                  return _buildInitialState(model);

                case Status.requestPermissions:
                  return _buildRequestPermissionsState();

                case Status.ready:
                  return _buildCameraState(model);
              }
            }),
          ),
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.openCamera();
    } else if (state == AppLifecycleState.paused) {
      _controller?.closeCamera();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Widget _buildInitialState(SampleStateModel model) => Center(
        child: MaterialButton(
          color: Colors.blue,
          textColor: Colors.white,
          disabledTextColor: Colors.black,
          padding: const EdgeInsets.all(12.0),
          splashColor: Colors.blueAccent,
          onPressed: () => model.requestCameraPermission(),
          child: const Text(
            'Start',
            style: TextStyle(
              fontSize: 17.0,
            ),
          ),
        ),
      );

  Widget _buildRequestPermissionsState() {
    return Container(
      alignment: AlignmentDirectional.topCenter,
      padding: const EdgeInsets.all(16.0),
      child: const Text('Please provide all required permissions to continue.',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 17.0,
          )),
    );
  }

  Widget _buildCameraState(SampleStateModel model) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
            width: screenSize.width,
            height: screenSize.height,
            // !!! Avoid excessive rerender cycles
            child: BanubaCameraView(
              onControllerCreated: _handleCameraViewCreated,
              key: const Key("BanubaCameraView"),
            )),
        Positioned(
            top: screenSize.height * 0.6,
            left: 24,
            child: Column(
              children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledTextColor: Colors.black,
                  padding: const EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () => applyEffect(model),
                  child: const Text(
                    "Toggle Effect",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledTextColor: Colors.black,
                  padding: const EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () => applyFacing(model),
                  child: const Text(
                    "Toggle Facing",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                )
              ],
            ))
      ],
    );
  }

  void _handleCameraViewCreated(BanubaSdkController controller) {
    _controller = controller;
    _controller?.openCamera();
  }
}
