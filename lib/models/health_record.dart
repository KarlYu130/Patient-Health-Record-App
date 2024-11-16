class HealthRecord {
  final int? id;
  final int patientId;
  final double? bodyTemperature;
  final int? systolic;
  final int? diastolic;
  final double? bloodGlucoseLevel;
  final double? bloodOxygenLevel; // New field
  final int? heartRate;           // New field
  final String? condition;
  final DateTime timestamp;

  HealthRecord({
    this.id,
    required this.patientId,
    this.bodyTemperature,
    this.systolic,
    this.diastolic,
    this.bloodGlucoseLevel,
    this.bloodOxygenLevel, // Initialize new field
    this.heartRate,         // Initialize new field
    this.condition,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'body_temperature': bodyTemperature,
      'systolic': systolic,
      'diastolic': diastolic,
      'blood_glucose_level': bloodGlucoseLevel,
      'blood_oxygen_level': bloodOxygenLevel, // Add new field
      'heart_rate': heartRate,                 // Add new field
      'condition': condition,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      bodyTemperature: map['body_temperature'] != null ? map['body_temperature'] as double : null,
      systolic: map['systolic'] != null ? map['systolic'] as int : null,
      diastolic: map['diastolic'] != null ? map['diastolic'] as int : null,
      bloodGlucoseLevel: map['blood_glucose_level'] != null ? map['blood_glucose_level'] as double : null,
      bloodOxygenLevel: map['blood_oxygen_level'] != null ? map['blood_oxygen_level'] as double : null, // Map new field
      heartRate: map['heart_rate'] != null ? map['heart_rate'] as int : null,               // Map new field
      condition: map['condition'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}