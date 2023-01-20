import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ScreenCaptureEvent {
  final _screenRecordListener = <String, Function(bool recorded)>{};
  final _screenshotListener = <String, Function(String filePath)>{};
  final _id = DateTime.now().microsecondsSinceEpoch.toString();

  static const MethodChannel _channel = MethodChannel('screencapture_method');

  ScreenCaptureEvent([bool requestPermission = true]) {
    if (requestPermission && Platform.isAndroid) storagePermission();
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "screenshot":
          for (var callback in _screenshotListener.values) {
            callback.call(call.arguments);
          }
          break;
        case "screenrecord":
          for (var callback in _screenRecordListener.values) {
            callback.call(call.arguments);
          }
          break;
        default:
      }
    });
  }

  ///Request storage permission for Android usage
  Future<void> storagePermission() {
    return _channel.invokeMethod("request_permission");
  }

  ///It will prevent user to screenshot/screenrecord on Android by set window Flag to WindowManager.LayoutParams.FLAG_SECURE
  Future<void> preventAndroidScreenShot(bool value) {
    return _channel.invokeMethod("prevent_screenshot", value);
  }

  ///Listen when user screenrecord the screen
  ///You can add listener multiple time, and every listener will be executed
  void addScreenRecordListener(Function(bool recorded) callback, {String? id}) {
    _screenRecordListener[id ?? _id] = callback;
  }

  ///Listen when user screenshot the screen
  ///You can add listener multiple time, and every listener will be executed
  ///Note : filePath only work for android
  void addScreenShotListener(Function(String filePath) callback, {String? id}) {
    _screenshotListener[id ?? _id] = callback;
  }

  void removeScreenRecordListener({String? id}) {
    _screenRecordListener.remove(id ?? _id);
  }

  void removeScreenShotListener({String? id}) {
    _screenshotListener.remove(id ?? _id);
  }

  ///Start watching capture behavior
  void watch() {
    _channel.invokeMethod("watch");
  }

  ///Dispose all listener on native side
  void dispose() {
    _channel.invokeMethod("dispose");
  }

  ///You can get record status to check if screenrecord still active
  Future<bool> isRecording() {
    return _channel.invokeMethod("isRecording").then((value) => value ?? false);
  }
}
