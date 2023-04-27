import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  final _windowManager = WindowManager.instance;

  Future<void> initialize() async {
    await _windowManager.ensureInitialized();

    if (Platform.isWindows) {
      await _windowManager.setAsFrameless();
      await _windowManager.setBackgroundColor(Colors.transparent);
      await _windowManager.setResizable(true);
      await _windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      appWindow.size = const Size(1200, 700);
      await _windowManager.center();
      await _windowManager.focus();
      appWindow.minSize = const Size(1150, 580);
    } else if (Platform.isMacOS) {
      // await _windowManager.setAsFrameless();
      await _windowManager.setBackgroundColor(Colors.transparent);
      await _windowManager.setResizable(true);
      await _windowManager.setTitle('Plotweaver');
      await _windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: true,
      );
      appWindow.size = const Size(1150, 750);
      await _windowManager.center();
      await _windowManager.focus();
      appWindow.minSize = const Size(1150, 600);
    }
  }

  Future<bool> get isMaximized => _windowManager.isMaximized();

  void restore() {
    _windowManager.restore();
  }

  void maximize() {
    _windowManager.maximize();
  }

  void quit() {
    _windowManager.close();
  }
}
