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

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver, VideoRecording {
  BanubaSdkController? _controller;

  Future<void> applyEffect(SampleStateModel model) async {
    _controller?.applyEffect(model.toggleEffect());
  }

  void applyFacing(SampleStateModel model) {
    _controller?.setFrontFacing(model.toggleFacing());
  }

  @override
  void startVideoRecording(String filePath) {
    const recordAudio = true;
    _controller?.startVideoRecording(filePath, recordAudio);
  }

  @override
  void stopVideoRecording() {
    _controller?.stopVideoRecording();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void _handleCameraViewCreated(BanubaSdkController controller) {
    _controller = controller;
    _controller?.openCamera();
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
                  return _buildWarnMessageState('Please grant all required permissions to continue.');

                case Status.grantPermissionsAppSettings:
                  return _buildWarnMessageState('Some permissions are denied.\nPlease grant permissions in App Settings.');

                case Status.choiceList:
                  return _buildChoiceListState(model);

                case Status.choiceFullscreen:
                  return _buildChoiceFullscreenState(model);

                case Status.choiceCustom:
                  return _buildChoiceCustomState(model);
              }
            }),
          ),
        ));
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

  Widget _buildWarnMessageState(String message) {
    return Container(
      alignment: AlignmentDirectional.topCenter,
      padding: const EdgeInsets.all(16.0),
      child: Text(message,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          )),
    );
  }

  Widget _buildChoiceListState(SampleStateModel model) => Center(
        child: Column(
          children: [
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              onPressed: () => model.requestChoiceFullscreen(),
              child: const Text(
                'Start Fullscreen',
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              onPressed: () => model.requestChoiceCustom(),
              child: const Text(
                'Start Custom',
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            )
          ],
        ),
      );

  Widget _buildChoiceFullscreenState(SampleStateModel model) {
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
            top: screenSize.height * 0.5,
            left: screenSize.width * 0.05,
            child: Column(
              children: [
                MaterialButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledTextColor: Colors.black,
                  padding: const EdgeInsets.all(12.0),
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
                  padding: const EdgeInsets.all(12.0),
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
            )),
        Positioned(
            top: screenSize.height * 0.8,
            left: screenSize.width * 0.35,
            child: VideoRecordingButton(model, this))
      ],
    );
  }

  Widget _buildChoiceCustomState(SampleStateModel model) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
            top: screenSize.height * 0.1,
            right: 24,
            child: Container(
                width: screenSize.width / 3,
                height: screenSize.height / 3,
                // !!! Avoid excessive rerender cycles
                child: BanubaCameraView(
                  onControllerCreated: _handleCameraViewCreated,
                  key: const Key("BanubaCameraView"),
                ))),
        Positioned(
            top: screenSize.height * 0.6,
            left: screenSize.width * 0.05,
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
}

class VideoRecordingButton extends StatefulWidget {
  final SampleStateModel _model;
  final VideoRecording _videoRecording;

  const VideoRecordingButton(this._model, this._videoRecording, {super.key});
  
  @override
  _VideoRecordingButtonState createState() => _VideoRecordingButtonState(_model, _videoRecording);
}

class _VideoRecordingButtonState extends State<VideoRecordingButton> {
  final SampleStateModel _model;
  final VideoRecording _videoRecording;
  
  bool isRecording = false;

  _VideoRecordingButtonState(this._model, this._videoRecording);

  @override
  Widget build(BuildContext context) {
    final text = isRecording ? "Stop Recording" : "Start Recording";
    final activeColor = isRecording ? Colors.red : Colors.green;

    return MaterialButton(
      color: activeColor,
      textColor: Colors.white,
      disabledTextColor: Colors.black,
      padding: const EdgeInsets.all(12.0),
      splashColor: Colors.blueAccent,
      onPressed: () {
        setState(() {
          isRecording = !isRecording;

          if (isRecording) {
            _model.generateVideoFilePath()
                .then((filePath) => _videoRecording.startVideoRecording(filePath));
          } else {
            _videoRecording.stopVideoRecording();
          }
        });
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.0,
        ),
      ),
    );
  }
}

mixin VideoRecording {
  void startVideoRecording(String filePath);

  void stopVideoRecording();
}
