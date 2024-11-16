class Patient {
  final int? id;
  final String name;
  final int age;
  final String condition;
  final String? sex; // New field remains

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.condition,
    this.sex, // New field
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'condition': condition,
      'sex': sex, // New field
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
      condition: map['condition'] as String,
      sex: map['sex'] as String?, // New field
    );
  }
}