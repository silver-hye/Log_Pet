class PetInstance {
  String name;
  String species;
  String growthStage;
  DateTime registeredAt;
  int hunger;
  int cleanliness;
  int affection;
  int exp;

  PetInstance({
    required this.name,
    required this.species,
    this.growthStage = 'baby',
    DateTime? registeredAt,
    this.hunger = 100,
    this.cleanliness = 100,
    this.affection = 0,
    this.exp = 0,
  }) : registeredAt = registeredAt ?? DateTime.now();

  void updateStat(String stat, int delta) {
    switch (stat) {
      case 'hunger':
        hunger = (hunger + delta).clamp(0, 100);
        break;
      case 'cleanliness':
        cleanliness = (cleanliness + delta).clamp(0, 100);
        break;
      case 'affection':
        affection = (affection + delta).clamp(0, 100);
        break;
      case 'exp':
        exp += delta;
        break;
    }
  }

  bool checkGrowthReady() {
    if (growthStage == 'baby' && exp >= 100) return true;
    if (growthStage == 'adult' && exp >= 300) return true;
    return false;
  }

  void evolve() {
    if (growthStage == 'baby') {
      growthStage = 'adult';
    } else if (growthStage == 'adult') {
      growthStage = 'senior';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'growthStage': growthStage,
      'registeredAt': registeredAt.toIso8601String(),
      'hunger': hunger,
      'cleanliness': cleanliness,
      'affection': affection,
      'exp': exp,
    };
  }

  factory PetInstance.fromMap(Map<String, dynamic> map) {
    return PetInstance(
      name: map['name'],
      species: map['species'],
      growthStage: map['growthStage'],
      registeredAt: DateTime.parse(map['registeredAt']),
      hunger: map['hunger'],
      cleanliness: map['cleanliness'],
      affection: map['affection'],
      exp: map['exp'],
    );
  }
}