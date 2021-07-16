import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


enum ScanErrorCode { permissionDenied, notSupport }

extension CodeExtension on ScanErrorCode {
  int get value => this.index;
}

class ScanView extends StatefulWidget {
  final void Function(String)? onCaptureResult;
  final void Function(int)? onErrCodeResult;

  ScanView(
      {Key? key, @required this.onCaptureResult, @required this.onErrCodeResult})
      : super(key: key) {
    event
        .receiveBroadcastStream()
        .map<String>((event) => event)
        .listen(onCaptureResult);
    eventPermission
        .receiveBroadcastStream()
        .map<int>((event) => event)
        .listen(onErrCodeResult);
  }

  final channel = const MethodChannel('io.isa.flutter.plugin.qrscan.channel');
  final event = EventChannel('io.isa.flutter.plugin.qrscan.sink');
  final eventPermission =
      EventChannel('io.isa.flutter.plugin.qrscan.permission.sink');

  @override
  ScanViewState createState() => ScanViewState();
}

class ScanViewState extends State<ScanView> {
  final onBuildFinish = "onBuildFinish";

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => Future.delayed(Duration(milliseconds: 200),
        () => {widget.channel.invokeMethod(onBuildFinish)}));
    return SafeArea(
      top: false,
      bottom: false,
      child: getScanView(),
    );
  }

  getScanView() {
    if (Platform.isIOS)
      return UiKitView(
        viewType: "ScanView",
        creationParamsCodec: StandardMessageCodec(),
      );
    if (Platform.isAndroid)
      return AndroidView(
        viewType: "ScanView",
        creationParamsCodec: const StandardMessageCodec(),
      );
  }

  @override
  void dispose() {
    print('dispose');

    widget.channel.invokeMethod("close");
    super.dispose();
  }

  void resume() {
    print('resume');

    widget.channel.invokeMethod("resume");
  }

  void pause() {
    print('pause');

    widget.channel.invokeMethod("pause");
  }

  scanImagePath(String path) {
    print('scanImagePath');

    widget.channel.invokeMethod('scanImagePath', {'path': path});
  }
  switchFlashlight(bool path) {
    print('scanImagePath');

    widget.channel.invokeMethod('switchFlashlight', {'switchFlashlight': path});
  }
}
