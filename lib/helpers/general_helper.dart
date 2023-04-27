import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/system_pages.dart';
import '../models/characters/affiliated_person.dart';
import '../models/characters/character.dart';
import '../models/file_tab.dart';
import '../models/language.dart';

class GeneralHelper {
  String id([int length = 32]) {
    const ch = '1234567890QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm';
    String id = '';
    for (var i = 0; i < length; i++) {
      id += ch[math.Random.secure().nextInt(ch.length)];
    }
    return id;
  }

  ProjectLanguage getPlatfromLanguage() {
    final locale = Platform.localeName;

    if (locale.contains('pl')) {
      return ProjectLanguage.pl;
    } else if (locale.contains('en')) {
      return ProjectLanguage.en;
    } else {
      return ProjectLanguage.other;
    }
  }

  /// Person 1 has provided `kinship` to person 2, returns the kinship relation
  /// between person 2 and person one:
  ///
  /// person1 --father-> person 2
  ///
  /// person2 --son-> person1
  ///
  /// returns `null` if no kinship can be determined (for example gender is other or unknown)
  Kinship? getSuggestedKinship({
    required Kinship kinship1,
    required Gender gender1,
  }) {
    switch (kinship1) {
      case Kinship.father:
        if (gender1 == Gender.male) return Kinship.son;
        if (gender1 == Gender.female) return Kinship.daughter;
        return null;
      case Kinship.mother:
        if (gender1 == Gender.male) return Kinship.son;
        if (gender1 == Gender.female) return Kinship.daughter;
        return null;
      case Kinship.brother:
        if (gender1 == Gender.male) return Kinship.brother;
        if (gender1 == Gender.female) return Kinship.sister;
        return null;
      case Kinship.sister:
        if (gender1 == Gender.male) return Kinship.brother;
        if (gender1 == Gender.female) return Kinship.sister;
        return null;
      case Kinship.son:
        if (gender1 == Gender.male) return Kinship.father;
        if (gender1 == Gender.female) return Kinship.mother;
        return null;
      case Kinship.daughter:
        if (gender1 == Gender.male) return Kinship.father;
        if (gender1 == Gender.female) return Kinship.mother;
        return null;
      case Kinship.grandfather:
        if (gender1 == Gender.male) return Kinship.grandson;
        if (gender1 == Gender.female) return Kinship.granddaughter;
        return null;
      case Kinship.grandmother:
        if (gender1 == Gender.male) return Kinship.grandson;
        if (gender1 == Gender.female) return Kinship.granddaughter;
        return null;
      case Kinship.uncle:
        if (gender1 == Gender.male) return Kinship.nephew;
        if (gender1 == Gender.female) return Kinship.niece;
        return null;
      case Kinship.aunt:
        if (gender1 == Gender.male) return Kinship.nephew;
        if (gender1 == Gender.female) return Kinship.niece;
        return null;
      case Kinship.nephew:
        if (gender1 == Gender.male) return Kinship.uncle;
        if (gender1 == Gender.female) return Kinship.aunt;
        return null;
      case Kinship.niece:
        if (gender1 == Gender.male) return Kinship.uncle;
        if (gender1 == Gender.female) return Kinship.aunt;
        return null;
      case Kinship.greatGrandfather:
        if (gender1 == Gender.male) return Kinship.greatGrandson;
        if (gender1 == Gender.female) return Kinship.greatGranddaughter;
        return null;
      case Kinship.greatGrandmother:
        if (gender1 == Gender.male) return Kinship.greatGrandson;
        if (gender1 == Gender.female) return Kinship.greatGranddaughter;
        return null;
      case Kinship.cousin:
        if (gender1 == Gender.male) return Kinship.cousin;
        if (gender1 == Gender.female) return Kinship.cousin;
        return null;
      case Kinship.husband:
        if (gender1 == Gender.male) return Kinship.husband;
        if (gender1 == Gender.female) return Kinship.wife;
        return null;
      case Kinship.wife:
        if (gender1 == Gender.male) return Kinship.husband;
        if (gender1 == Gender.female) return Kinship.wife;
        return null;
      case Kinship.fatherInLaw:
        if (gender1 == Gender.male) return Kinship.sonInLaw;
        if (gender1 == Gender.female) return Kinship.daughterInLaw;
        return null;
      case Kinship.motherInLaw:
        if (gender1 == Gender.male) return Kinship.sonInLaw;
        if (gender1 == Gender.female) return Kinship.daughterInLaw;
        return null;
      case Kinship.brotherInLaw:
        if (gender1 == Gender.male) return Kinship.brotherInLaw;
        if (gender1 == Gender.female) return Kinship.sisterInLaw;
        return null;
      case Kinship.sisterInLaw:
        if (gender1 == Gender.male) return Kinship.brotherInLaw;
        if (gender1 == Gender.female) return Kinship.sisterInLaw;
        return null;
      case Kinship.sonInLaw:
        if (gender1 == Gender.male) return Kinship.fatherInLaw;
        if (gender1 == Gender.female) return Kinship.motherInLaw;
        return null;
      case Kinship.daughterInLaw:
        if (gender1 == Gender.male) return Kinship.fatherInLaw;
        if (gender1 == Gender.female) return Kinship.motherInLaw;
        return null;
      case Kinship.stepFather:
        if (gender1 == Gender.male) return Kinship.stepSon;
        if (gender1 == Gender.female) return Kinship.stepDaughter;
        return null;
      case Kinship.stepMother:
        if (gender1 == Gender.male) return Kinship.stepSon;
        if (gender1 == Gender.female) return Kinship.stepDaughter;
        return null;
      case Kinship.stepBrother:
        if (gender1 == Gender.male) return Kinship.stepBrother;
        if (gender1 == Gender.female) return Kinship.stepSister;
        return null;
      case Kinship.stepSister:
        if (gender1 == Gender.male) return Kinship.stepBrother;
        if (gender1 == Gender.female) return Kinship.stepSister;
        return null;
      case Kinship.stepSon:
        if (gender1 == Gender.male) return Kinship.stepFather;
        if (gender1 == Gender.female) return Kinship.stepMother;
        return null;
      case Kinship.stepDaughter:
        if (gender1 == Gender.male) return Kinship.stepFather;
        if (gender1 == Gender.female) return Kinship.stepMother;
        return null;
      case Kinship.grandson:
        if (gender1 == Gender.male) return Kinship.grandfather;
        if (gender1 == Gender.female) return Kinship.grandmother;
        return null;
      case Kinship.granddaughter:
        if (gender1 == Gender.male) return Kinship.grandfather;
        if (gender1 == Gender.female) return Kinship.grandmother;
        return null;
      case Kinship.greatGrandson:
        if (gender1 == Gender.male) return Kinship.greatGrandfather;
        if (gender1 == Gender.female) return Kinship.greatGrandmother;
        return null;
      case Kinship.greatGranddaughter:
        if (gender1 == Gender.male) return Kinship.greatGrandfather;
        if (gender1 == Gender.female) return Kinship.greatGrandmother;
        return null;
    }
  }

  Icon getTypeIcon(FileType type, [String? path]) {
    switch (type) {
      case FileType.general:
        return const Icon(Icons.info_outline);
      case FileType.timelineEditor:
        return const Icon(Icons.timeline);
      case FileType.threadEditor:
        return const Icon(Icons.upcoming_outlined);
      case FileType.characterEditor:
        return const Icon(Icons.person_outline);
      case FileType.plotDevelopment:
        return const Icon(Icons.rebase_edit);
      case FileType.system:
        break;
      case FileType.editor:
        return const Icon(Icons.history_edu_outlined);
      case FileType.userFile:
        if (path == null) break;
        final fileName = Uri.file(path).pathSegments.where((element) {
          return element.isNotEmpty;
        }).last;
        final extension = fileName
            .substring(
              fileName.lastIndexOf('.') + 1,
            )
            .toLowerCase();
        if (['pdf'].contains(extension)) {
          return const Icon(
            Icons.picture_as_pdf_outlined,
          );
        } else if ([
          'jpeg',
          'png',
          'jpg',
          'svg',
          'jfif',
          'pjpeg',
          'webp',
        ].contains(extension)) {
          return const Icon(
            Icons.photo_camera_back_outlined,
          );
        }
        break;
    }

    return systemPagesIcons[path] ?? const Icon(Icons.note_outlined);
  }

  String getFileName(FileType type, [String? path]) {
    switch (type) {
      case FileType.general:
        return 'project.general';
      case FileType.timelineEditor:
        return 'project.timeline';
      case FileType.threadEditor:
        return 'project.threads';
      case FileType.characterEditor:
        return 'project.characters';
      case FileType.plotDevelopment:
        return 'project.plot_development';
      case FileType.system:
        break;
      case FileType.editor:
        return 'project.editors';
      case FileType.userFile:
        if (path == null) return '...';
        return Uri.file(path)
            .pathSegments
            .where((element) => element.isNotEmpty)
            .last;
    }

    return systemPagesNames[path] ?? 'system_pages.new_tab';
  }

  List<T> getUnifiedList<T>(List<List<T>> collection) {
    final List<T> result = [];
    for (var element in collection) {
      result.addAll(element);
    }
    return result;
  }

  List<T> combineLists<T>(List<T> list1, List<T> list2) {
    List<T> combinedList = List<T>.from(list1)..addAll(list2);
    if (T is Comparable) {
      combinedList.sort();
    }
    return combinedList;
  }

  num average(List<num> collection) {
    if (collection.isEmpty) return 0;
    return (collection.map((e) {
          return e.toDouble();
        }).reduce((a, b) {
          return a + b;
        })) /
        collection.length;
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0B';
    var sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${sizes[i]}';
  }
}
