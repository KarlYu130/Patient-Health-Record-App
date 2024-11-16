import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import '../helpers/database_helper.dart';
import '../models/patient.dart';

class AddPatient extends StatefulWidget {
  const AddPatient({super.key});

  @override
  _AddPatientState createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _age = 0;
  String _condition = '';
  String? _sex; // New field remains

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.addPatient ?? 'Add Patient')), // Updated
      body: SingleChildScrollView(
        // Make the form scrollable
        padding: const EdgeInsets.all(16.0),
        child: Card(
          // Encapsulate form in a Card
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field with Icon
                  TextFormField(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.name ?? 'Name', // Update label
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _name = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)?.enterPatientName ?? 'Please enter the patient\'s name'; // Update validator
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Sex Field with Icon
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.sex ?? 'Sex', // Update label
                      prefixIcon: const Icon(Icons.transgender),
                      border: const OutlineInputBorder(),
                    ),
                    value: _sex,
                    items: ['Male', 'Female'] // Removed 'Other'
                        .map((sex) => DropdownMenuItem(
                              value: sex,
                              child: Text(sex),
                            ))
                        .toList(),
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
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.age ?? 'Age', // Update label
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.condition ?? 'Condition', // Update label
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      AppLocalizations.of(context)?.submit ?? 'Submit', // Updated
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
      Patient newPatient = Patient(
        name: _name,
        age: _age, // Defaults to 0 if not entered
        condition: _condition, // Defaults to '' if not entered
        sex: _sex, // New field
      );
      try {
        await DatabaseHelper.instance.insertPatient(newPatient);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add patient: $e')),
        );
      }
    }
  }
}
