import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/health_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
class EditHealthRecord extends StatefulWidget {
  final HealthRecord record;

  const EditHealthRecord({super.key, required this.record});

  @override
  _EditHealthRecordState createState() => _EditHealthRecordState();
}

class _EditHealthRecordState extends State<EditHealthRecord> {
  final _formKey = GlobalKey<FormState>();
  late double? _bodyTemperature;
  late int? _systolic;
  late int? _diastolic;
  late double? _bloodGlucoseLevel;
  late String? _condition;
  double? _bloodOxygenLevel; // New field
  int? _heartRate;           // New field

  @override
  void initState() {
    super.initState();
    _bodyTemperature = widget.record.bodyTemperature;
    _systolic = widget.record.systolic;
    _diastolic = widget.record.diastolic;
    _bloodGlucoseLevel = widget.record.bloodGlucoseLevel;
    _condition = widget.record.condition;
    _bloodOxygenLevel = widget.record.bloodOxygenLevel;
    _heartRate = widget.record.heartRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.editHealthRecord ?? 'Edit Health Record'), // Updated
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Body Temperature
                  TextFormField(
                    initialValue: _bodyTemperature?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Body Temperature (°C)',
                      prefixIcon: Icon(Icons.thermostat),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) {
                      _bodyTemperature = double.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Systolic
                  TextFormField(
                    initialValue: _systolic?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Systolic (mm Hg)',
                      prefixIcon: Icon(Icons.favorite),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _systolic = int.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Diastolic
                  TextFormField(
                    initialValue: _diastolic?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Diastolic (mm Hg)',
                      prefixIcon: Icon(Icons.favorite_border),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _diastolic = int.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Blood Glucose Level
                  TextFormField(
                    initialValue: _bloodGlucoseLevel?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Blood Glucose Level (mg/dL)',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) {
                      _bloodGlucoseLevel = double.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Blood Oxygen Level Input
                  TextFormField(
                    initialValue: _bloodOxygenLevel?.toString(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level (%)', // Updated
                      prefixIcon: const Icon(Icons.air),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _bloodOxygenLevel = value != null ? double.tryParse(value) : null;
                    },
                    validator: (value) {
                      final val = double.tryParse(value ?? '');
                      if (val == null || val < 0 || val > 100) {
                        return 'Please enter a valid oxygen level between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Heart Rate Input
                  TextFormField(
                    initialValue: _heartRate?.toString(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.heartRateBpm ?? 'Heart Rate (bpm)', // Updated
                      prefixIcon: const Icon(Icons.favorite),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _heartRate = value != null ? int.tryParse(value) : null;
                    },
                    validator: (value) {
                      final val = int.tryParse(value ?? '');
                      if (val == null || val < 30 || val > 200) {
                        return 'Please enter a valid heart rate between 30 and 200';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Condition
                  TextFormField(
                    initialValue: _condition,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.condition ?? 'Condition', // Updated
                      prefixIcon: const Icon(Icons.medical_services),
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _condition = value ?? '';
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      AppLocalizations.of(context)?.updateRecord ?? 'Update Record', // Updated
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      HealthRecord updatedRecord = HealthRecord(
        id: widget.record.id,
        patientId: widget.record.patientId,
        bodyTemperature: _bodyTemperature,
        systolic: _systolic,
        diastolic: _diastolic,
        bloodGlucoseLevel: _bloodGlucoseLevel,
        bloodOxygenLevel: _bloodOxygenLevel, // Save new field
        heartRate: _heartRate,               // Save new field
        condition: _condition,
        timestamp: widget.record.timestamp,
      );
      await DatabaseHelper.instance.updateHealthRecord(updatedRecord);
      Navigator.pop(context, true);
    }
  }
}