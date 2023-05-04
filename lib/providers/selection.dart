import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// kind of internal manager of selection for almost any input in app
class SelectionManager with ChangeNotifier {
  String _text = '';
  TextSelection? _selection;
  DateTime? _lastSelection;
  TextEditingController? _currentController;

  void updateSelection(TextSelection textSelection, String content) {
    _selection = textSelection;
    _text = content;
    _lastSelection = DateTime.now();
    notifyListeners();
  }

  /// does what `updateSelection`, but does not notify listeners
  void updateSelectionSilently(TextSelection textSelection, String content) {
    _selection = textSelection;
    _text = content;
    _lastSelection = DateTime.now();
  }

  /// calls notify listeners inside this class
  void refresh() {
    notifyListeners();
  }

  void clear() {
    if (isClear) return;
    _text = '';
    _selection = null;
    _lastSelection = null;
    notifyListeners();
  }

  void clearSilently() {
    if (isClear) return;
    _text = '';
    _selection = null;
    _lastSelection = null;
  }

  void initializeController(TextEditingController controller) {
    _currentController = controller;
    notifyListeners();
  }

  void removeController() {
    _currentController = null;
    notifyListeners();
  }

  void copy() {
    Clipboard.setData(ClipboardData(text: _text));
  }

  void paste() async {
    // there is no controller that the text can be pasted to
    if (_currentController == null) return;
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      if (data.text != null) {
        // has data that is text in clipboard
        final text = _currentController!.text;
        final selection = _currentController!.selection;
        _currentController!.text =
            selection.textBefore(text) + data.text! + selection.textAfter(text);
        _currentController!.selection = TextSelection(
          baseOffset: selection.textBefore(text).length + data.text!.length,
          extentOffset: selection.textBefore(text).length + data.text!.length,
        );
        _selection = _currentController!.selection;
        _lastSelection = DateTime.now();
        _text = '';
        notifyListeners();
      }
    }
  }

  void cut() async {
    if (_currentController == null) return;
    if (isClear) return;
    // we can use null expressions since isClear checks for it
    final content = _currentController!.text;
    final text = _selection!.textInside(content);
    await Clipboard.setData(ClipboardData(text: text));
    _currentController!.text =
        _selection!.textBefore(content) + _selection!.textAfter(content);
    _currentController!.selection = TextSelection(
      baseOffset: _selection!.textBefore(content).length,
      extentOffset: _selection!.textBefore(content).length,
    );
    _selection = _currentController!.selection;
    _text = '';
    _lastSelection = DateTime.now();
    notifyListeners();
  }

  bool get isClear => _lastSelection == null && _selection == null;
  String get selectedText => _text;
  int get selectedWords => _text.split(' ').where((element) {
        return element.trim().isNotEmpty;
      }).length;
}
