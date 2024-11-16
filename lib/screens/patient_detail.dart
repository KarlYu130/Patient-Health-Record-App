import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import
import 'package:syncfusion_flutter_charts/charts.dart'; // Add this import
import '../models/patient.dart';
import '../models/health_record.dart'; // Import HealthRecord model
import '../helpers/database_helper.dart'; // Import DatabaseHelper
import 'edit_patient.dart'; // Add import for EditPatient
import 'health_record_detail.dart'; // Add this import
import 'ai_doctor_chat.dart'; // Add import for AI Doctor Chat
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart'; // Add this import for PdfPageFormat
import 'dart:convert'; // Add this import
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import

class PatientDetail extends StatefulWidget { // Changed from StatelessWidget to StatefulWidget
  final Patient patient;

  const PatientDetail({super.key, required this.patient});

  @override
  _PatientDetailState createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail> {
  List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
  }

  Future<void> _loadHealthRecords() async {
    final records = await DatabaseHelper.instance.getHealthRecords(widget.patient.id!);
    setState(() {
      _healthRecords = records;
    });
  }

  void _addHealthRecord() async {
    // Navigate to AddHealthRecord screen or show a dialog
    bool? added = await showDialog(
      context: context,
      builder: (context) => AddHealthRecordDialog(patientId: widget.patient.id!),
    );
    if (added == true) {
      _loadHealthRecords();
    }
  }

  // Add helper functions to determine normal ranges
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 36.5 && temperature <= 37.5) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color _getBloodPressureColor(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color _getBloodGlucoseColor(double glucose) {
    if (glucose >= 70 && glucose <= 99) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  Color _getBloodOxygenColor(double oxygenLevel) {
    if (oxygenLevel >= 95) {
      return Colors.green;
    } else if (oxygenLevel >= 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getHeartRateColor(int heartRate) {
    if (heartRate >= 60 && heartRate <= 100) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  // Add function to generate PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/open-sans.ttf");
    final ttf = pw.Font.ttf(font);
    // Serialize patient data
    Map<String, dynamic> patientData = {
      'name': widget.patient.name,
      'age': widget.patient.age,
      'sex': widget.patient.sex ?? 'N/A',
      'condition': widget.patient.condition,
      'health_records': _healthRecords.map((record) => record.toMap()).toList(),
    };
    String patientJson = jsonEncode(patientData);

    // Generate QR code as image
    final qrCode = await QrPainter(
      data: patientJson,
      version: QrVersions.auto,
      gapless: false,
    ).toImageData(200);

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Patient Report', style: pw.TextStyle(font: ttf, fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Name: ${widget.patient.name}', style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.Text('Age: ${widget.patient.age}', style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.Text('Sex: ${widget.patient.sex ?? 'N/A'}', style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.Text('Condition: ${widget.patient.condition}', style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.Text('Health Records:', style: pw.TextStyle(font: ttf, fontSize: 20)),
          pw.ListView.builder(
            itemCount: _healthRecords.length,
            itemBuilder: (context, index) {
              final record = _healthRecords[index];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Record ${index + 1}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Body Temperature: ${record.bodyTemperature ?? 'N/A'} °C'),
                  pw.Text('Blood Pressure: ${record.systolic ?? 'N/A'}/${record.diastolic ?? 'N/A'} mm Hg'),
                  pw.Text('Blood Glucose Level: ${record.bloodGlucoseLevel ?? 'N/A'} mg/dL'),
                  pw.Text('Blood Oxygen Level: ${record.bloodOxygenLevel ?? 'N/A'} %'),
                  pw.Text('Heart Rate: ${record.heartRate ?? 'N/A'} bpm'),
                  pw.Text('Condition: ${record.condition ?? 'N/A'}'),
                  pw.SizedBox(height: 10),
                ],
              );
            },
          ),
          pw.SizedBox(height: 20),
          pw.Text('Backup QR Code:', style: pw.TextStyle(font: ttf, fontSize: 20)),
          pw.SizedBox(height: 10),
          pw.Image(pw.MemoryImage(qrCode!.buffer.asUint8List()), width: 200, height: 200),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.patientDetails ?? 'Patient Details'), // Updated
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPatient(patient: widget.patient),
                ),
              );
              if (updated == true) {
                // Refresh the detail page if needed
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card( // Encapsulate details in a Card
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                    children: [
                      // Name Field
                      Text(
                        '${AppLocalizations.of(context)?.name ?? 'Name'}: ${widget.patient.name}', // Updated
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Sex Field
                      Text(
                        widget.patient.sex != null ? '${AppLocalizations.of(context)?.sex ?? 'Sex'}: ${widget.patient.sex}' : '${AppLocalizations.of(context)?.sex ?? 'Sex'}: N/A', // Updated
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(height: 20, thickness: 2),
                      // Age Field
                      Text(
                        '${AppLocalizations.of(context)?.age ?? 'Age'}: ${widget.patient.age}', // Updated
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      // Condition Field (Moved to last)
                      Text(
                        '${AppLocalizations.of(context)?.condition ?? 'Condition'}: ${widget.patient.condition}', // Updated
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.healthRecords ?? 'Health Records', // Updated
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addHealthRecord,
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)?.addRecord ?? 'Add Record'), // Updated
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildHealthTrendsChart(),
              const SizedBox(height: 20),
              // New AI Doctor Chat Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AiDoctorChat(patient: widget.patient), // Fixed line
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: Text(AppLocalizations.of(context)?.chatWithAiDoctor ?? 'Chat with AI Doctor'), // Updated
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // New PDF Generation Button
              ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(AppLocalizations.of(context)?.generatePdf ?? 'Generate PDF'), // Updated
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHealthRecordsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTrendsChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.healthTrends ?? 'Health Trends', // Updated
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: SfCartesianChart(
                title: ChartTitle(text: AppLocalizations.of(context)?.healthMetricsOverTime ?? 'Health Metrics Over Time'), // Updated
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryXAxis: DateTimeAxis(),
                primaryYAxis: NumericAxis(),
                series: <ChartSeries>[
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature (°C)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.bodyTemperature,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.systolicBp ?? 'Systolic BP (mm Hg)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.systolic?.toDouble(),
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.diastolicBp ?? 'Diastolic BP (mm Hg)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.diastolic?.toDouble(),
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.bloodGlucose ?? 'Blood Glucose (mg/dL)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.bloodGlucoseLevel,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level (%)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.bloodOxygenLevel,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<HealthRecord, DateTime>(
                    name: AppLocalizations.of(context)?.heartRate ?? 'Heart Rate (bpm)', // Updated
                    dataSource: _healthRecords,
                    xValueMapper: (HealthRecord record, _) => record.timestamp,
                    yValueMapper: (HealthRecord record, _) => record.heartRate?.toDouble(),
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modify the health records list to remove fixed height and allow dynamic expansion
  Widget _buildHealthRecordsList() {
    return _healthRecords.isEmpty
        ? Center(child: Text(AppLocalizations.of(context)?.noHealthRecordsAvailable ?? 'No health records available.')) // Updated
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _healthRecords.length,
            itemBuilder: (context, index) {
              final record = _healthRecords[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    '${AppLocalizations.of(context)?.recordedOn ?? 'Recorded on'} ${record.timestamp.toLocal().toString().split(' ')[0]}', // Updated
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Body Temperature Field with Color Indicator
                      Text(
                        record.bodyTemperature != null
                            ? '${AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature'}: ${record.bodyTemperature} °C' // Updated
                            : '${AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature'}: N/A', // Updated
                        style: TextStyle(
                          color: record.bodyTemperature != null
                              ? _getTemperatureColor(record.bodyTemperature!)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Blood Pressure Field with Color Indicator
                      Text(
                        record.systolic != null && record.diastolic != null
                            ? '${AppLocalizations.of(context)?.bloodPressure ?? 'Blood Pressure'}: ${record.systolic}/${record.diastolic} mm Hg' // Updated
                            : '${AppLocalizations.of(context)?.bloodPressure ?? 'Blood Pressure'}: N/A', // Updated
                        style: TextStyle(
                          color: (record.systolic != null && record.diastolic != null)
                              ? _getBloodPressureColor(record.systolic!, record.diastolic!)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Blood Glucose Level Field with Color Indicator
                      Text(
                        record.bloodGlucoseLevel != null
                            ? '${AppLocalizations.of(context)?.bloodGlucoseLevel ?? 'Blood Glucose Level'}: ${record.bloodGlucoseLevel} mg/dL' // Updated
                            : '${AppLocalizations.of(context)?.bloodGlucoseLevel ?? 'Blood Glucose Level'}: N/A', // Updated
                        style: TextStyle(
                          color: record.bloodGlucoseLevel != null
                              ? _getBloodGlucoseColor(record.bloodGlucoseLevel!)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Blood Oxygen Level Field with Color Indicator
                      Text(
                        record.bloodOxygenLevel != null
                            ? '${AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level'}: ${record.bloodOxygenLevel} %' // Updated
                            : '${AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level'}: N/A', // Updated
                        style: TextStyle(
                          color: record.bloodOxygenLevel != null
                              ? _getBloodOxygenColor(record.bloodOxygenLevel!)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Heart Rate Field with Color Indicator
                      Text(
                        record.heartRate != null
                            ? '${AppLocalizations.of(context)?.heartRate ?? 'Heart Rate'}: ${record.heartRate} bpm' // Updated
                            : '${AppLocalizations.of(context)?.heartRate ?? 'Heart Rate'}: N/A', // Updated
                        style: TextStyle(
                          color: record.heartRate != null
                              ? _getHeartRateColor(record.heartRate!)
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Condition Field
                      Text(
                        record.condition != null && record.condition!.isNotEmpty
                            ? '${AppLocalizations.of(context)?.condition ?? 'Condition'}: ${record.condition}' // Updated
                            : '${AppLocalizations.of(context)?.condition ?? 'Condition'}: N/A', // Updated
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthRecordDetail(record: record),
                      ),
                    );
                  },
                  onLongPress: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)?.deleteRecord ?? 'Delete Record'), // Updated
                        content: Text(AppLocalizations.of(context)?.deleteRecordConfirmation ?? 'Are you sure you want to delete this health record?'), // Updated
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'), // Updated
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppLocalizations.of(context)?.delete ?? 'Delete', style: const TextStyle(color: Colors.red)), // Updated
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await DatabaseHelper.instance.deleteHealthRecord(record.id!);
                      _loadHealthRecords();
                    }
                  },
                ),
              );
            },
          );
  }
}

// Dialog to add a new HealthRecord
class AddHealthRecordDialog extends StatefulWidget {
  final int patientId;

  const AddHealthRecordDialog({super.key, required this.patientId});

  @override
  _AddHealthRecordDialogState createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  double? _bodyTemperature;
  int? _systolic;
  int? _diastolic;
  double? _bloodGlucoseLevel;
  double? _bloodOxygenLevel; // New field
  int? _heartRate;           // New field
  String? _condition;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)?.addHealthRecord ?? 'Add Health Record'), // Updated
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Body Temperature
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature (°C)', // Updated
                  prefixIcon: const Icon(Icons.thermostat),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) {
                  _bodyTemperature = double.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 10),
              // Systolic
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.systolicBpMmHg ?? 'Systolic (mm Hg)', // Updated
                  prefixIcon: const Icon(Icons.favorite),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _systolic = int.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 10),
              // Diastolic
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.diastolicBpMmHg ?? 'Diastolic (mm Hg)', // Updated
                  prefixIcon: const Icon(Icons.favorite_border),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _diastolic = int.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 10),
              // Blood Glucose Level
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.bloodGlucoseLevel ?? 'Blood Glucose Level (mg/dL)', // Updated
                  prefixIcon: const Icon(Icons.bloodtype),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) {
                  _bloodGlucoseLevel = double.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 10),
              // Blood Oxygen Level Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level (%)', // Updated
                  prefixIcon: const Icon(Icons.air),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _bloodOxygenLevel = value != null ? double.tryParse(value) : null;
                },
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0 || val > 100) {
                    return AppLocalizations.of(context)?.validOxygenLevel ?? 'Please enter a valid oxygen level'; // Updated
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Heart Rate Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.heartRate ?? 'Heart Rate (bpm)', // Updated
                  prefixIcon: const Icon(Icons.favorite)
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _heartRate = value != null ? int.tryParse(value) : null;
                },
                validator: (value) {
                  final val = int.tryParse(value ?? '');
                  if (val == null || val < 30 || val > 200) {
                    return AppLocalizations.of(context)?.validHeartRate ?? 'Please enter a valid heart rate'; // Updated
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Condition
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.condition ?? 'Condition', // Updated
                  prefixIcon: const Icon(Icons.medical_services),
                ),
                onSaved: (value) {
                  _condition = value ?? '';
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'), // Updated
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)?.add ?? 'Add'), // Updated
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      HealthRecord newRecord = HealthRecord(
        patientId: widget.patientId,
        bodyTemperature: _bodyTemperature,
        systolic: _systolic,
        diastolic: _diastolic,
        bloodGlucoseLevel: _bloodGlucoseLevel,
        bloodOxygenLevel: _bloodOxygenLevel, // Save new field
        heartRate: _heartRate,               // Save new field
        condition: _condition,
        timestamp: DateTime.now(),
      );
      await DatabaseHelper.instance.insertHealthRecord(newRecord);
      Navigator.pop(context, true);
    }
  }
}