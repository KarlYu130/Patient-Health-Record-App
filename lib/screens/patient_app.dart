import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/patient.dart';
import 'patient_detail.dart';
import 'add_patient.dart';
import 'qr_scan_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PatientApp extends StatefulWidget {
  final void Function(Locale) onLocaleChange; // Add this line

  const PatientApp({super.key, required this.onLocaleChange}); // Modify constructor

  @override
  _PatientAppState createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  Locale _locale = const Locale('en'); // Add this line
  final _formKey = GlobalKey<FormState>();
  final String _name = '';
  final int _age = 0;
  final String _condition = '';

  List<Patient> _patients = [];

  // Add a list to keep track of selected patient IDs
  final List<int> _selectedPatientIds = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await DatabaseHelper.instance.getPatients();
    setState(() {
      _patients = patients;
    });
  }

  // Method to toggle selection
  void _onSelectPatient(int id) {
    setState(() {
      if (_selectedPatientIds.contains(id)) {
        _selectedPatientIds.remove(id);
      } else {
        _selectedPatientIds.add(id);
      }
    });
  }

  // Method to delete selected patients
  void _deleteSelectedPatients() async {
    if (_selectedPatientIds.isNotEmpty) {
      await DatabaseHelper.instance.deletePatients(_selectedPatientIds);
      setState(() {
        _selectedPatientIds.clear();
      });
      _loadPatients();
    }
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove MaterialApp from here
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appTitle ?? 'SIGHT Patient Records'),
        actions: [
          // ...existing actions...
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              switch (value) {
                case 'English':
                  widget.onLocaleChange(const Locale('en')); // Use callback
                  break;
                case 'Sinhala':
                  widget.onLocaleChange(const Locale('si'));
                  break;
                case 'Tamil':
                  widget.onLocaleChange(const Locale('ta'));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'English',
                child: Text(AppLocalizations.of(context)?.english ?? 'English'),
              ),
              PopupMenuItem(
                value: 'Sinhala',
                child: Text(AppLocalizations.of(context)?.sinhala ?? 'Sinhala'),
              ),
              PopupMenuItem(
                value: 'Tamil',
                child: Text(AppLocalizations.of(context)?.tamil ?? 'Tamil'),
              ),
            ],
          ),
          if (_selectedPatientIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedPatients,
              tooltip: AppLocalizations.of(context)?.delete ?? 'Delete', // Updated
            )
          else
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                // Made the onPressed callback asynchronous
                bool? scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QRScanScreen()),
                );
                if (scanned == true) {
                  _loadPatients(); // Reload the patient list
                }
              },
              tooltip: AppLocalizations.of(context)?.scanQR ?? 'Scan QR', // Updated
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _patients.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)?.noPatients ?? 'No patients available')) // Updated
            : ListView.builder(
                itemCount: _patients.length,
                itemBuilder: (context, index) {
                  final patient = _patients[index];
                  final isSelected = _selectedPatientIds.contains(patient.id);
                  return Card(
                    // Encapsulate each patient in a Card
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: _selectedPatientIds.isNotEmpty
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (bool? selected) {
                                _onSelectPatient(patient.id!);
                              },
                            )
                          : CircleAvatar(
                              child: Text(patient.name[0].toUpperCase()),
                            ),
                      title: Text(
                        patient.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        patient.condition,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _selectedPatientIds.isNotEmpty
                          ? () => _onSelectPatient(patient.id!)
                          : () async {
                              bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatientDetail(patient: patient),
                                ),
                              );
                              if (updated == true) {
                                _loadPatients();
                              }
                            },
                      onLongPress: () {
                        _onSelectPatient(patient.id!);
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatient()),
          );
          if (added == true) {
            _loadPatients();
          }
        },
        child: const Icon(Icons.add),
        tooltip: AppLocalizations.of(context)?.addPatient ?? 'Add Patient', // Updated
      ),
    );
  }

  // ...existing methods...
}
