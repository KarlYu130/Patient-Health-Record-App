import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/patient.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
class EditPatient extends StatefulWidget {
  final Patient patient;

  const EditPatient({super.key, required this.patient});

  @override
  _EditPatientState createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _condition;
  int? _age;
  String? _sex; // New field remains

  @override
  void initState() {
    super.initState();
    _name = widget.patient.name;
    _age = widget.patient.age;
    _condition = widget.patient.condition;
    _sex = widget.patient.sex; // Initialize new field
    // Removed health-related initializations:
    // _bodyTemperature = widget.patient.bodyTemperature;
    // _systolic = widget.patient.systolic;
    // _diastolic = widget.patient.diastolic;
    // _bloodGlucoseLevel = widget.patient.bloodGlucoseLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.editPatient ?? 'Edit Patient'), // Updated
      ),
      body: SingleChildScrollView( // Make the form scrollable
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
                  // Name Field with Icon
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.name ?? 'Name', // Updated
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _name = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.enterPatientName ?? 'Please enter the patient\'s name'; // Updated
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Sex Field with Icon
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.sex ?? 'Sex', // Updated
                      prefixIcon: const Icon(Icons.transgender),
                      border: const OutlineInputBorder(),
                    ),
                    value: _sex,
                    items: [
                      DropdownMenuItem(
                        value: 'Male',
                        child: Text(AppLocalizations.of(context)?.male ?? 'Male'), // Updated
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text(AppLocalizations.of(context)?.female ?? 'Female'), // Updated
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sex = value;
                      });
                    },
                    onSaved: (value) {
                      _sex = value;
                    },
                    // No validator to make it optional
                  ),
                  const SizedBox(height: 16),
                  // Age Field with Icon
                  TextFormField(
                    initialValue: _age != 0 ? _age.toString() : '',
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.age ?? 'Age', // Updated
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _age = int.tryParse(value ?? '0') ?? 0;
                    },
                    // Removed validator to make Age optional
                  ),
                  const SizedBox(height: 16),
                  // Condition Field with Icon (Moved to last)
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
                    // Removed validator to make Condition optional
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
                      AppLocalizations.of(context)?.update ?? 'Update', // Updated
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
      Patient updatedPatient = Patient(
        id: widget.patient.id,
        name: _name,
        age: _age ?? 0,
        condition: _condition,
        sex: _sex, // New field
        // Removed health-related fields:
        // bodyTemperature: _bodyTemperature,
        // systolic: _systolic,
        // diastolic: _diastolic,
        // bloodGlucoseLevel: _bloodGlucoseLevel,
      );
      await DatabaseHelper.instance.updatePatient(updatedPatient);
      Navigator.pop(context, true);
    }
  }
}
