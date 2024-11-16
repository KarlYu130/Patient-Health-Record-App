import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/health_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
class AddHealthRecord extends StatefulWidget {
  final int patientId;

  const AddHealthRecord({super.key, required this.patientId});

  @override
  _AddHealthRecordState createState() => _AddHealthRecordState();
}

class _AddHealthRecordState extends State<AddHealthRecord> {
  final _formKey = GlobalKey<FormState>();
  double? _bodyTemperature;
  int? _systolic;
  int? _diastolic;
  double? _bloodGlucoseLevel;
  String? _condition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.addHealthRecord ?? 'Add Health Record'), // Updated
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card( // Encapsulate form in a Card
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.bodyTemperatureC ?? 'Body Temperature (°C)', // Updated
                      prefixIcon: const Icon(Icons.thermostat),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) {
                      _bodyTemperature = double.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Systolic
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.systolicBpMmHg ?? 'Systolic (mm Hg)', // Updated
                      prefixIcon: const Icon(Icons.favorite),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _systolic = int.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Diastolic
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.diastolicBpMmHg ?? 'Diastolic (mm Hg)', // Updated
                      prefixIcon: const Icon(Icons.favorite_border),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _diastolic = int.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Blood Glucose Level
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.bloodGlucoseMgDl ?? 'Blood Glucose Level (mg/dL)', // Updated
                      prefixIcon: const Icon(Icons.bloodtype),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (value) {
                      _bloodGlucoseLevel = double.tryParse(value ?? '');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Condition
                  TextFormField(
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
                      AppLocalizations.of(context)?.addRecord ?? 'Add Record', // Updated
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
      HealthRecord newRecord = HealthRecord(
        patientId: widget.patientId,
        bodyTemperature: _bodyTemperature,
        systolic: _systolic,
        diastolic: _diastolic,
        bloodGlucoseLevel: _bloodGlucoseLevel,
        condition: _condition,
        timestamp: DateTime.now(),
      );
      await DatabaseHelper.instance.insertHealthRecord(newRecord);
      Navigator.pop(context, true);
    }
  }
}