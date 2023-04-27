enum SideChange {
  fromEnemy,
  toEnemy,
}

enum Kinship {
  father,
  mother,
  brother,
  sister,
  son,
  daughter,
  grandfather,
  grandmother,
  grandson,
  granddaughter,
  uncle,
  aunt,
  nephew,
  niece,
  greatGrandfather,
  greatGrandmother,
  greatGrandson,
  greatGranddaughter,
  cousin,
  husband,
  wife,
  fatherInLaw,
  motherInLaw,
  brotherInLaw,
  sisterInLaw,
  sonInLaw,
  daughterInLaw,
  stepFather,
  stepMother,
  stepBrother,
  stepSister,
  stepSon,
  stepDaughter,
}

class AffiliatedPerson {
  final String id;
  final String name;
  final bool? enemy;
  final SideChange? sideChange;
  final Kinship? kinship;

  AffiliatedPerson.friend({
    required this.id,
    required this.name,
    required this.sideChange,
  })  : kinship = null,
        enemy = false;

  AffiliatedPerson.enemy({
    required this.id,
    required this.name,
    required this.sideChange,
  })  : kinship = null,
        enemy = true;

  AffiliatedPerson.familyMember({
    required this.id,
    required this.name,
    required this.kinship,
  })  : sideChange = null,
        enemy = null;
}
