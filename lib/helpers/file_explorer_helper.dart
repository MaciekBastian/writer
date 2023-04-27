import 'dart:io';

import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

class FileExplorerHelper {
  Future<String?> _getGlobalPath() async {
    final directory = await pp.getDownloadsDirectory();

    return directory?.parent.path;
  }

  Future<String?> getDesktop() async {
    return _getPathToDirectory('Desktop');
  }

  Future<String?> getDocuments() async {
    return _getPathToDirectory('Documents');
  }

  Future<String?> getDownloads() async {
    return _getPathToDirectory('Downloads');
  }

  Future<String?> _getPathToDirectory(String directory) async {
    final dir = await _getGlobalPath();
    if (dir == null) return null;
    final path = p.join(dir, directory);
    if (Directory(path).existsSync()) {
      return path;
    } else {
      return null;
    }
  }

  Future<List<Directory>?> getDirectoriesForPath(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return [];
    try {
      return dir.listSync().whereType<Directory>().toList();
    } catch (e) {
      return null;
    }
  }

  bool? doesPathContainProject(String path) {
    final dir = Directory(path);
    if (!(dir.existsSync())) return false;
    try {
      final containsMWRTFile = dir.listSync().whereType<File>().any((element) {
        return element.path.contains('.mwrt');
      });
      return containsMWRTFile;
    } catch (e) {
      return null;
    }
  }

  String? getParent(String path) {
    final dir = Directory(path);
    if (dir.existsSync()) {
      final parent = dir.parent;
      if (parent.existsSync()) {
        return parent.path;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String macosGetProjectPathName(String name) {
    String path = name.trim().toLowerCase();
    // maximum length is 255, but we leave some space for extension and (in the future) possible
    // changes to this extension
    if (path.length >= 240) path = path.substring(0, 240);
    path = path.replaceAll('.', '');
    path = path.replaceAll(':', '');
    path = path.replaceAll(" ", "_");
    path = path.replaceAll('/', "");
    path = path.replaceAll('\\', "");

    return path;
  }

  Future<bool> macosDoesProjectExists(String name) async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final project = Directory(p.join(
      directory.path,
      macosGetProjectPathName(name),
    ));

    return project.existsSync();
  }

  Future<String> macosCreateProject(String name) async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final project = Directory(p.join(
      directory.path,
      macosGetProjectPathName(name),
    ));

    if (!(project.existsSync())) await project.create();

    return project.path;
  }

  Future<List<String>> macosGetProjects() async {
    final directory = await pp.getApplicationDocumentsDirectory();
    final children = directory.listSync().whereType<Directory>().toList();

    return children.map((e) => e.path).toList();
  }
}
