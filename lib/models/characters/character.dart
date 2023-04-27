import 'package:xml/xml.dart';

import '../working_tree.dart';
import 'affiliated_person.dart';
import 'occupation.dart';
import 'relationship.dart';
import 'story_plan_entry.dart';

enum Gender {
  female,
  male,
  other,
  unknown,
}

enum CharacterStatus {
  alive,
  dead,
  unknown,
}

class Birthday {
  final int? day;
  final int? month;
  final int? year;

  Birthday({
    this.day,
    this.month,
    this.year,
  });
}

class Character {
  final String id;
  final String name;
  final int? age;
  final Gender gender;
  final CharacterStatus status;
  final List<Occupation> occupationHistory;

  /// scene `id`, null if unknown
  final String? firstApperance;

  /// scene `id`, null if unknown
  final String? lastApperance;
  final String? portrayedBy;
  final List<String> aliases;
  final List<AffiliatedPerson> familyMembers;
  final List<AffiliatedPerson> friends;
  final List<AffiliatedPerson> enemies;
  final List<Relationship> relationships;
  final List<StoryPlanEntry> storyPlan;

  final List<String> notes;
  final String description;
  final String apperance;
  final String goals;

  final WorkingTree<Character>? workingTree;

  // extra fields
  final Birthday? birthday;
  final String? socialNumber;
  final String? phoneNumber;
  final String? emailAddress;
  final String? bloodType;
  final int? height;
  final int? weight;

  Character({
    required this.id,
    required this.name,
    this.age,
    this.gender = Gender.unknown,
    this.status = CharacterStatus.unknown,
    this.occupationHistory = const [],
    this.firstApperance,
    this.lastApperance,
    this.portrayedBy,
    this.aliases = const [],
    this.enemies = const [],
    this.familyMembers = const [],
    this.friends = const [],
    this.relationships = const [],
    this.storyPlan = const [],
    this.apperance = '',
    this.description = '',
    this.goals = '',
    this.notes = const [],
    this.workingTree,
    // extra fields
    this.birthday,
    this.bloodType,
    this.emailAddress,
    this.height,
    this.phoneNumber,
    this.socialNumber,
    this.weight,
  });

  /// `xml` must be `character` tag taken from `Character.getCharacterTag`
  Character.fromXml(XmlElement xml)
      : id = xml.getElement('id')?.text ?? '',
        name = xml.getElement('name')?.text ?? '',
        age = int.tryParse(xml.getElement('age')?.text ?? ''),
        gender = Gender.values.firstWhere((element) =>
            element.name ==
            (xml.getElement('gender')?.text ?? Gender.unknown.name)),
        status = CharacterStatus.values.firstWhere((element) =>
            element.name ==
            (xml.getElement('status')?.text ?? CharacterStatus.unknown.name)),
        occupationHistory = xml
                .getElement('occupation-history')
                ?.children
                .map((occupation) {
                  final occupationId = occupation.getElement('id')?.text;
                  final occupationName =
                      occupation.getElement('occupation')?.text;
                  final start = occupation.getElement('start')?.text;
                  final end = occupation.getElement('end')?.text;

                  if (occupationId == null ||
                      occupationName == null ||
                      start == null ||
                      end == null) {
                    return null;
                  }

                  return Occupation(
                    id: occupationId,
                    occupation: occupationName,
                    start: start,
                    end: end,
                  );
                })
                .whereType<Occupation>()
                .toList() ??
            [],
        firstApperance =
            (xml.getElement('first-apperance')?.text.isEmpty ?? true)
                ? null
                : xml.getElement('first-apperance')?.text,
        lastApperance = (xml.getElement('last-apperance')?.text.isEmpty ?? true)
            ? null
            : xml.getElement('last-apperance')?.text,
        portrayedBy = (xml.getElement('portrayed-by')?.text.isEmpty ?? true)
            ? null
            : xml.getElement('portrayed-by')?.text,
        aliases = xml
                .getElement('aliases')
                ?.children
                .map((p0) {
                  return p0.text;
                })
                .whereType<String>()
                .toList() ??
            [],
        familyMembers = xml
                .getElement('family-members')
                ?.children
                .map((p0) {
                  final id = p0.getElement('id')?.text;
                  final name = p0.getElement('name')?.text;
                  final kinship = p0.getElement('kinship')?.text;
                  if (id == null || name == null) {
                    return null;
                  }
                  return AffiliatedPerson.familyMember(
                    id: id,
                    name: name,
                    kinship: (kinship == null ||
                            kinship.isEmpty ||
                            kinship == 'null')
                        ? null
                        : Kinship.values.firstWhere((element) {
                            return element.name == kinship;
                          }),
                  );
                })
                .whereType<AffiliatedPerson>()
                .toList() ??
            [],
        friends = xml
                .getElement('friends')
                ?.children
                .map((p0) {
                  final id = p0.getElement('id')?.text;
                  final name = p0.getElement('name')?.text;
                  final sideChange = p0.getElement('side-change')?.text;
                  if (id == null || name == null) {
                    return null;
                  }
                  return AffiliatedPerson.friend(
                    id: id,
                    name: name,
                    sideChange: (sideChange == null ||
                            sideChange.isEmpty ||
                            sideChange == 'null')
                        ? null
                        : SideChange.values.firstWhere((element) {
                            return element.name == sideChange;
                          }),
                  );
                })
                .whereType<AffiliatedPerson>()
                .toList() ??
            [],
        enemies = xml
                .getElement('enemies')
                ?.children
                .map((p0) {
                  final id = p0.getElement('id')?.text;
                  final name = p0.getElement('name')?.text;
                  final sideChange = p0.getElement('side-change')?.text;
                  if (id == null || name == null) {
                    return null;
                  }
                  return AffiliatedPerson.enemy(
                    id: id,
                    name: name,
                    sideChange: (sideChange == null ||
                            sideChange.isEmpty ||
                            sideChange == 'null')
                        ? null
                        : SideChange.values.firstWhere((element) {
                            return element.name == sideChange;
                          }),
                  );
                })
                .whereType<AffiliatedPerson>()
                .toList() ??
            [],
        relationships = xml
                .getElement('relationships')
                ?.children
                .map((p0) {
                  final id = xml.getElement('id')?.text;
                  final name = xml.getElement('name')?.text;
                  final personId = p0.getElement('person-id')?.text;
                  final personName = p0.getElement('name')?.text;
                  final description = p0.getElement('description');

                  if (id == null ||
                      name == null ||
                      personId == null ||
                      personName == null ||
                      description == null) {
                    return null;
                  }

                  return Relationship(
                    description: description.text,
                    person1Id: id,
                    person1Name: name,
                    person2Id: personId,
                    person2Name: personName,
                  );
                })
                .whereType<Relationship>()
                .toList() ??
            [],
        storyPlan = xml
                .getElement('story-plan')
                ?.children
                .map((p0) {
                  final moment = p0.getElement('moment')?.text;
                  final index = int.tryParse(
                    p0.getElement('index')?.text ?? '',
                  );
                  final content = p0.getElement('content');

                  if (index == null || moment == null || content == null) {
                    return null;
                  }

                  return StoryPlanEntry(
                    content: content.text,
                    index: index,
                    momentId: moment,
                  );
                })
                .whereType<StoryPlanEntry>()
                .toList() ??
            [],
        notes = xml
                .getElement('notes')
                ?.children
                .map((p0) {
                  return p0.text;
                })
                .whereType<String>()
                .toList() ??
            [],
        description = xml.getElement('description')?.text ?? '',
        apperance = xml.getElement('apperance')?.text ?? '',
        goals = xml.getElement('goals')?.text ?? '',
        bloodType = xml.getElement('bloodType')?.text ?? '',
        emailAddress = xml.getElement('emailAddress')?.text ?? '',
        height = int.tryParse(xml.getElement('height')?.text ?? ''),
        phoneNumber = xml.getElement('phoneNumber')?.text ?? '',
        socialNumber = xml.getElement('socialNumber')?.text ?? '',
        weight = int.tryParse(xml.getElement('weight')?.text ?? ''),
        birthday = xml.getElement('birthday ') == null
            ? null
            : Birthday(
                day: int.tryParse(
                  xml.getElement('birthday')?.getElement('day')?.text ?? '',
                ),
                month: int.tryParse(
                  xml.getElement('birthday')?.getElement('month')?.text ?? '',
                ),
                year: int.tryParse(
                  xml.getElement('birthday')?.getElement('year')?.text ?? '',
                ),
              ),
        workingTree = null;

  static XmlElement getCharacterTag(String xml) {
    final element = XmlDocument.parse(xml).getElement('character');

    if (element == null) {
      throw Exception('there is no character tag');
    } else {
      return element;
    }
  }

  String toXML() {
    final builder = XmlBuilder();
    builder.declaration(
      version: '1.0',
      encoding: 'UTF-8',
    );
    builder.element('character', nest: () {
      builder.element('id', nest: id);
      builder.element('name', nest: name);
      builder.element('age', nest: age);
      builder.element('gender', nest: gender.name);
      builder.element('status', nest: status.name);
      builder.element('occupation-history', nest: () {
        for (var element in occupationHistory) {
          builder.element('occupation', nest: () {
            builder.element('id', nest: element.id);
            builder.element('occupation', nest: element.occupation);
            builder.element('start', nest: element.start);
            builder.element('end', nest: element.end);
          });
        }
      });
      builder.element('first-apperance', nest: firstApperance ?? '');
      builder.element('last-apperance', nest: lastApperance ?? '');
      builder.element('portrayed-by', nest: portrayedBy ?? '');
      builder.element('aliases', nest: () {
        for (var element in aliases) {
          builder.element('nickname', nest: element);
        }
      });
      builder.element('family-members', nest: () {
        for (var element in familyMembers) {
          builder.element('person', nest: () {
            builder.element('id', nest: element.id);
            builder.element('name', nest: element.name);
            builder.element('kinship', nest: element.kinship?.name ?? '');
          });
        }
      });
      builder.element('friends', nest: () {
        for (var element in friends) {
          builder.element('person', nest: () {
            builder.element('id', nest: element.id);
            builder.element('name', nest: element.name);
            builder.element(
              'side-change',
              nest: element.sideChange?.name ?? '',
            );
          });
        }
      });
      builder.element('enemies', nest: () {
        for (var element in enemies) {
          builder.element('person', nest: () {
            builder.element('id', nest: element.id);
            builder.element('name', nest: element.name);
            builder.element(
              'side-change',
              nest: element.sideChange?.name ?? '',
            );
          });
        }
      });
      builder.element('relationships', nest: () {
        for (var element in relationships) {
          builder.element('relationship', nest: () {
            builder.element(
              'person-id',
              nest: element.person1Id == id
                  ? element.person2Id
                  : element.person1Id,
            );
            builder.element(
              'name',
              nest: element.person1Id == id
                  ? element.person2Name
                  : element.person1Name,
            );
            builder.element('description', nest: element.description);
          });
        }
      });
      builder.element('story-plan', nest: () {
        for (var element in storyPlan) {
          builder.element('plan-entry', nest: () {
            builder.element(
              'moment',
              nest: element.momentId,
            );
            builder.element(
              'index',
              nest: element.index,
            );
            builder.element('content', nest: element.content);
          });
        }
      });
      builder.element('notes', nest: () {
        for (var element in notes) {
          builder.element('note', nest: element);
        }
      });
      builder.element('description', nest: description);
      builder.element('apperance', nest: apperance);
      builder.element('goals', nest: goals);
      if (birthday != null) {
        builder.element('birthday', nest: () {
          builder.element('day', nest: birthday!.day);
          builder.element('month', nest: birthday!.month);
          builder.element('year', nest: birthday!.year);
        });
      }
      builder.element('bloodType', nest: bloodType);
      builder.element('emailAddress', nest: emailAddress);
      builder.element('height', nest: height);
      builder.element('phoneNumber', nest: phoneNumber);
      builder.element('socialNumber', nest: socialNumber);
      builder.element('weight', nest: weight);
    });

    final document = builder.buildDocument();
    return document.toXmlString();
  }

  Character copyWith({
    String? name,
    int? age,
    Gender? gender,
    CharacterStatus? status,
    List<Occupation>? occupationHistory,
    String? firstApperance,
    String? lastApperance,
    String? portrayedBy,
    List<String>? aliases,
    List<AffiliatedPerson>? familyMembers,
    List<AffiliatedPerson>? friends,
    List<AffiliatedPerson>? enemies,
    List<Relationship>? relationships,
    List<StoryPlanEntry>? storyPlan,
    List<String>? notes,
    String? description,
    String? apperance,
    String? goals,
    Birthday? birthday,
    String? socialNumber,
    String? phoneNumber,
    String? emailAddress,
    String? bloodType,
    int? height,
    int? weight,
  }) {
    var tree = workingTree ?? WorkingTree.empty(this);
    final change = Character(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      aliases: aliases ?? this.aliases,
      enemies: enemies ?? this.enemies,
      familyMembers: familyMembers ?? this.familyMembers,
      firstApperance: firstApperance ?? this.firstApperance,
      friends: friends ?? this.friends,
      gender: gender ?? this.gender,
      lastApperance: lastApperance ?? this.lastApperance,
      occupationHistory: occupationHistory ?? this.occupationHistory,
      portrayedBy: portrayedBy ?? this.portrayedBy,
      relationships: relationships ?? this.relationships,
      status: status ?? this.status,
      apperance: apperance ?? this.apperance,
      description: description ?? this.description,
      goals: goals ?? this.goals,
      notes: notes ?? this.notes,
      storyPlan: storyPlan ?? this.storyPlan,
      birthday: birthday ?? this.birthday,
      bloodType: bloodType ?? this.bloodType,
      emailAddress: emailAddress ?? this.emailAddress,
      height: height ?? this.height,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      socialNumber: socialNumber ?? this.socialNumber,
      weight: weight ?? this.weight,
    );

    tree = tree.newChange(this, change);

    return Character(
      id: id,
      name: change.name,
      age: change.age,
      aliases: change.aliases,
      enemies: change.enemies,
      familyMembers: change.familyMembers,
      firstApperance: change.firstApperance,
      friends: change.friends,
      gender: change.gender,
      lastApperance: change.lastApperance,
      occupationHistory: change.occupationHistory,
      portrayedBy: change.portrayedBy,
      relationships: change.relationships,
      status: change.status,
      apperance: change.apperance,
      description: change.description,
      goals: change.goals,
      notes: change.notes,
      storyPlan: change.storyPlan,
      birthday: change.birthday,
      bloodType: change.bloodType,
      emailAddress: change.emailAddress,
      height: change.height,
      weight: change.weight,
      phoneNumber: change.phoneNumber,
      socialNumber: change.socialNumber,
      workingTree: tree,
    );
  }

  Character.fromWorkingTree(WorkingTree<Character> tree)
      : id = tree.currentVersion.id,
        name = tree.currentVersion.name,
        age = tree.currentVersion.age,
        gender = tree.currentVersion.gender,
        status = tree.currentVersion.status,
        occupationHistory = tree.currentVersion.occupationHistory,
        firstApperance = tree.currentVersion.firstApperance,
        lastApperance = tree.currentVersion.lastApperance,
        portrayedBy = tree.currentVersion.portrayedBy,
        aliases = tree.currentVersion.aliases,
        enemies = tree.currentVersion.enemies,
        familyMembers = tree.currentVersion.familyMembers,
        friends = tree.currentVersion.friends,
        relationships = tree.currentVersion.relationships,
        storyPlan = tree.currentVersion.storyPlan,
        apperance = tree.currentVersion.apperance,
        description = tree.currentVersion.description,
        goals = tree.currentVersion.goals,
        notes = tree.currentVersion.notes,
        birthday = tree.currentVersion.birthday,
        bloodType = tree.currentVersion.bloodType,
        emailAddress = tree.currentVersion.emailAddress,
        height = tree.currentVersion.height,
        phoneNumber = tree.currentVersion.phoneNumber,
        socialNumber = tree.currentVersion.socialNumber,
        weight = tree.currentVersion.weight,
        workingTree = tree;

  /// `true` replaces value with null
  Character removeNullableValues({
    bool age = false,
    bool firstApperance = false,
    bool lastApperance = false,
    bool portrayedBy = false,
    bool birthday = false,
    bool socialNumber = false,
    bool phoneNumber = false,
    bool emailAddress = false,
    bool bloodType = false,

    /// value in cm
    bool height = false,

    /// value in kg
    bool weight = false,
  }) {
    return Character(
      id: id,
      name: name,
      age: age ? null : this.age,
      aliases: aliases,
      enemies: enemies,
      familyMembers: familyMembers,
      firstApperance: firstApperance ? null : this.firstApperance,
      friends: friends,
      gender: gender,
      lastApperance: lastApperance ? null : this.lastApperance,
      occupationHistory: occupationHistory,
      portrayedBy: portrayedBy ? null : this.portrayedBy,
      relationships: relationships,
      status: status,
      apperance: apperance,
      description: description,
      goals: goals,
      notes: notes,
      storyPlan: storyPlan,
      birthday: birthday ? null : this.birthday,
      socialNumber: socialNumber ? null : this.socialNumber,
      phoneNumber: phoneNumber ? null : this.phoneNumber,
      emailAddress: emailAddress ? null : this.emailAddress,
      bloodType: bloodType ? null : this.bloodType,
      height: height ? null : this.height,
      weight: weight ? null : this.weight,
      workingTree: workingTree,
    );
  }

  @override
  String toString() {
    return name;
  }
}
