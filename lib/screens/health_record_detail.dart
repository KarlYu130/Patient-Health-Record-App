import 'package:flutter/material.dart';
// Add this import
import 'package:syncfusion_flutter_charts/charts.dart'; // Add this import
import '../models/health_record.dart';
import 'package:intl/intl.dart'; // Add this import
import 'edit_health_record.dart'; // Add this import
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import '../helpers/database_helper.dart'; // Add this import
import '../models/patient.dart'; // Import Patient model

class HealthRecordDetail extends StatefulWidget {
  final HealthRecord record;

  const HealthRecordDetail({super.key, required this.record});

  @override
  _HealthRecordDetailState createState() => _HealthRecordDetailState();
}

class _HealthRecordDetailState extends State<HealthRecordDetail> {
  late HealthRecord _record;
  Patient? _patient; // Add Patient variable

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _loadPatient(); // Load patient data
  }

  Future<void> _loadPatient() async {
    final dbHelper = DatabaseHelper.instance;
    Patient? patient = await dbHelper.getPatientById(_record.patientId); // Fetch patient
    setState(() {
      _patient = patient;
    });
  }

  // Helper functions to determine normal ranges (reuse from patient_detail.dart)
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
    } else if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return Colors.yellow;
    } else if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return Colors.orange;
    } else if (systolic >= 140 || diastolic >= 90) {
      return Colors.red;
    } else if (systolic > 180 || diastolic > 120) {
      return Colors.purple;
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

  String _getDiabetesRisk(double? bloodGlucoseLevel) {
    if (bloodGlucoseLevel == null) {
      return 'No data available';
    } else if (bloodGlucoseLevel >= 200) {
      return 'High risk of diabetes';
    } else if (bloodGlucoseLevel >= 140) {
      return 'Prediabetes';
    } else {
      return 'Normal';
    }
  }

  Color _getDiabetesRiskColor(double? bloodGlucoseLevel) {
    if (bloodGlucoseLevel == null) {
      return Colors.black;
    } else if (bloodGlucoseLevel >= 200) {
      return Colors.red;
    } else if (bloodGlucoseLevel >= 140) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getHypertensionRisk(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return 'No data available';
    } else if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic >= 120 && systolic < 130 && diastolic <= 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return 'Hypertension Stage 1';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'Hypertension Stage 2';
    } else if (systolic > 180 || diastolic > 120) {
      return 'Hypertensive Crisis';
    } else {
      return 'Hypertension';
    }
  }

  Color _getHypertensionRiskColor(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return Colors.black;
    } else if (systolic < 120 && diastolic < 80) {
      return Colors.green;
    } else if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return Colors.yellow;
    } else if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return Colors.orange;
    } else if (systolic >= 140 || diastolic >= 90) {
      return Colors.red;
    } else if (systolic > 180 || diastolic > 120) {
      return Colors.purple;
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

  Color _getBloodOxygenStatusColor(double oxygenLevel) {
    if (oxygenLevel >= 95) {
      return Colors.green;
    } else if (oxygenLevel >= 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getHeartRateStatusColor(double heartRate) {
    if (heartRate >= 60 && heartRate <= 100) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  // Add a method to calculate overall risk
  double _calculateOverallRisk() {
    double risk = 0;

    // Example risk calculations based on health metrics
    if (_record.bloodGlucoseLevel != null) {
      if (_record.bloodGlucoseLevel! >= 200) {
        risk += 40;
      } else if (_record.bloodGlucoseLevel! >= 140) {
        risk += 20;
      }
    }

    if (_record.systolic != null && _record.diastolic != null) {
      if (_record.systolic! >= 140 || _record.diastolic! >= 90) {
        risk += 40;
      } else if ((_record.systolic! >= 130 && _record.systolic! < 140) ||
          (_record.diastolic! >= 80 && _record.diastolic! < 90)) {
        risk += 20;
      }
    }

    // Incorporate age
    if (_patient?.age != null) {
      if (_patient!.age > 50) {
        risk += 20;
      }
    }

    // Incorporate sex
    if (_patient?.sex != null) {
      if (_patient!.sex != null && _patient!.sex!.toLowerCase() == 'male') {
        risk += 10;
      }
    }

    return risk.clamp(0, 100);
  }

  // Add methods to calculate individual risks
  double _calculateDiabetesRisk() {
    double risk = 0;

    if (_record.bloodGlucoseLevel != null) {
      if (_record.bloodGlucoseLevel! >= 200) {
        risk += 40;
      } else if (_record.bloodGlucoseLevel! >= 140) {
        risk += 20;
      }
    }

    // Incorporate age
    if (_patient?.age != null) {
      if (_patient!.age > 50) {
        risk += 10;
      }
    }

    // Incorporate sex
    if (_patient?.sex != null && _patient!.sex!.toLowerCase() == 'male') {
      risk += 5;
    }

    return risk.clamp(0, 100);
  }

  double _calculateHypertensionRisk() {
    double risk = 0;

    if (_record.systolic != null && _record.diastolic != null) {
      if (_record.systolic! >= 140 || _record.diastolic! >= 90) {
        risk += 40;
      } else if ((_record.systolic! >= 130 && _record.systolic! < 140) ||
          (_record.diastolic! >= 80 && _record.diastolic! < 90)) {
        risk += 20;
      }
    }

    // Incorporate age
    if (_patient?.age != null) {
      if (_patient!.age > 50) {
        risk += 10;
      }
    }

    // Incorporate sex
    if (_patient?.sex != null && _patient!.sex!.toLowerCase() == 'male') {
      risk += 5;
    }

    return risk.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(
          // ...existing code...
        ),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
      );
    }

    double diabetesRisk = _calculateDiabetesRisk();
    double hypertensionRisk = _calculateHypertensionRisk();

    double overallRisk = _calculateOverallRisk();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.healthRecordDetails ?? 'Health Record Details'), // Updated
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHealthRecord(record: _record),
                ),
              );
              if (updated == true) {
                setState(() {
                  _record = _record; // Refresh the record
                });
              }
            },
            tooltip: AppLocalizations.of(context)?.editHealthRecord ?? 'Edit Health Record', // Updated
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)?.recordedOn ?? 'Recorded On'} ${_record.timestamp.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // Body Temperature Field with Color Indicator
                      Row(
                        children: [
                          const Icon(Icons.thermostat, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.bodyTemperature != null
                                  ? '${AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature'}: ${_record.bodyTemperature} °C'
                                  : '${AppLocalizations.of(context)?.bodyTemperature ?? 'Body Temperature'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _record.bodyTemperature != null
                                    ? _getTemperatureColor(
                                        _record.bodyTemperature!)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Blood Pressure Field with Color Indicator
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.systolic != null &&
                                      _record.diastolic != null
                                  ? '${AppLocalizations.of(context)?.bloodPressure ?? 'Blood Pressure'}: ${_record.systolic}/${_record.diastolic} mm Hg'
                                  : '${AppLocalizations.of(context)?.bloodPressure ?? 'Blood Pressure'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _record.systolic != null &&
                                        _record.diastolic != null
                                    ? _getBloodPressureColor(
                                        _record.systolic!, _record.diastolic!)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Blood Glucose Level Field with Color Indicator
                      Row(
                        children: [
                          const Icon(Icons.bloodtype, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.bloodGlucoseLevel != null
                                  ? '${AppLocalizations.of(context)?.bloodGlucoseLevel ?? 'Blood Glucose Level'}: ${_record.bloodGlucoseLevel} mg/dL'
                                  : '${AppLocalizations.of(context)?.bloodGlucoseLevel ?? 'Blood Glucose Level'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _record.bloodGlucoseLevel != null
                                    ? _getBloodGlucoseColor(
                                        _record.bloodGlucoseLevel!)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Blood Oxygen Level Field
                      Row(
                        children: [
                          const Icon(Icons.air, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.bloodOxygenLevel != null
                                  ? '${AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level'}: ${_record.bloodOxygenLevel} %'
                                  : '${AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _record.bloodOxygenLevel != null
                                    ? _getBloodOxygenColor(
                                        _record.bloodOxygenLevel!)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Heart Rate Field
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.heartRate != null
                                  ? '${AppLocalizations.of(context)?.heartRate ?? 'Heart Rate'}: ${_record.heartRate} bpm'
                                  : '${AppLocalizations.of(context)?.heartRate ?? 'Heart Rate'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _record.heartRate != null
                                    ? _getHeartRateColor(_record.heartRate!)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Condition Field
                      Row(
                        children: [
                          const Icon(Icons.medical_services,
                              color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _record.condition != null &&
                                      _record.condition!.isNotEmpty
                                  ? '${AppLocalizations.of(context)?.condition ?? 'Condition'}: ${_record.condition}'
                                  : '${AppLocalizations.of(context)?.condition ?? 'Condition'}: ${AppLocalizations.of(context)?.notAvailable ?? 'Not Available'}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Risk Assessment Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.riskAssessment ?? 'Risk Assessment',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Diabetes Risk Assessment
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.diabetesRisk ?? 'Diabetes Risk'}: ${diabetesRisk}%',
                              style: TextStyle(
                                fontSize: 18,
                                color: diabetesRisk > 70
                                    ? Colors.red
                                    : diabetesRisk > 40
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Hypertension Risk Assessment
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.hypertensionRisk ?? 'Hypertension Risk'}: ${hypertensionRisk}%',
                              style: TextStyle(
                                fontSize: 18,
                                color: hypertensionRisk > 70
                                    ? Colors.red
                                    : hypertensionRisk > 40
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Progress Circle Charts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Diabetes Risk Circle
                          Column(
                            children: [
                              Text(AppLocalizations.of(context)?.diabetesRisk ?? 'Diabetes Risk'),
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: SfCircularChart(
                                  series: <CircularSeries>[
                                    RadialBarSeries<ChartData, String>(
                                      dataSource: [
                                        ChartData('Diabetes', diabetesRisk),
                                      ],
                                      xValueMapper: (ChartData data, _) => data.category,
                                      yValueMapper: (ChartData data, _) => data.value,
                                      maximumValue: 100,
                                      pointColorMapper: (ChartData data, _) {
                                        if (data.value > 70) {
                                          return Colors.red;
                                        } else if (data.value > 40) {
                                          return Colors.orange;
                                        } else {
                                          return Colors.green;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Hypertension Risk Circle
                          Column(
                            children: [
                              Text(AppLocalizations.of(context)?.hypertensionRisk ?? 'Hypertension Risk'),
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: SfCircularChart(
                                  series: <CircularSeries>[
                                    RadialBarSeries<ChartData, String>(
                                      dataSource: [
                                        ChartData('Hypertension', hypertensionRisk),
                                      ],
                                      xValueMapper: (ChartData data, _) => data.category,
                                      yValueMapper: (ChartData data, _) => data.value,
                                      maximumValue: 100,
                                      pointColorMapper: (ChartData data, _) {
                                        if (data.value > 70) {
                                          return Colors.red;
                                        } else if (data.value > 40) {
                                          return Colors.orange;
                                        } else {
                                          return Colors.green;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Diabetes Risk Assessment
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.diabetesRisk ?? 'Diabetes Risk'}: ${_getDiabetesRisk(_record.bloodGlucoseLevel)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _getDiabetesRiskColor(
                                    _record.bloodGlucoseLevel),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Hypertension Risk Assessment
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.hypertensionRisk ?? 'Hypertension Risk'}: ${_getHypertensionRisk(_record.systolic, _record.diastolic)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: _getHypertensionRiskColor(
                                    _record.systolic, _record.diastolic),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Overall Risk Assessment
                      Row(
                        children: [
                          const Icon(Icons.assessment, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.overallRisk ?? 'Overall Risk'}: $overallRisk%',
                              style: TextStyle(
                                fontSize: 18,
                                color: overallRisk > 70
                                    ? Colors.red
                                    : overallRisk > 40
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Progress Circle Chart
                      Center(
                        child: SfCircularChart(
                          title: ChartTitle(
                              text: AppLocalizations.of(context)?.riskAssessment ?? 'Risk Assessment'),
                          series: <CircularSeries>[
                            RadialBarSeries<ChartData, String>(
                              dataSource: [
                                ChartData('Risk', overallRisk),
                              ],
                              xValueMapper: (ChartData data, _) => data.category,
                              yValueMapper: (ChartData data, _) => data.value,
                              maximumValue: 100,
                              pointColorMapper: (ChartData data, _) {
                                if (data.value > 70) {
                                  return Colors.red;
                                } else if (data.value > 40) {
                                  return Colors.orange;
                                } else {
                                  return Colors.green;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Improved Health Metrics Chart
              Text(
                AppLocalizations.of(context)?.healthMetricsChart ?? 'Health Metrics Chart',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 400,
                width: double.infinity,
                child: SfCartesianChart(
                  title: ChartTitle(
                      text:
                          AppLocalizations.of(context)?.healthMetricsOverview ?? 'Health Metrics Overview'),
                  legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enablePanning: true,
                  ),
                  primaryXAxis: DateTimeAxis(
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    intervalType: DateTimeIntervalType.days,
                    dateFormat: DateFormat.yMMMd(),
                  ),
                  primaryYAxis: NumericAxis(
                    title:
                        AxisTitle(text: AppLocalizations.of(context)?.values ?? 'Values'),
                  ),
                  series: <ChartSeries>[
                    // Body Temperature Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.bodyTemperatureC ?? 'Body Temperature (°C)',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.bodyTemperature,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: _getTemperatureColor(_record.bodyTemperature ?? 0),
                    ),
                    // Systolic BP Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.systolicBpMmHg ?? 'Systolic BP (mm Hg)',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.systolic?.toDouble(),
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: _getBloodPressureColor(
                          _record.systolic ?? 0, _record.diastolic ?? 0),
                    ),
                    // Diastolic BP Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.diastolicBpMmHg ?? 'Diastolic BP (mm Hg)',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.diastolic?.toDouble(),
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: _getBloodPressureColor(
                          _record.systolic ?? 0, _record.diastolic ?? 0),
                    ),
                    // Blood Glucose Level Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.bloodGlucoseMgDl ?? 'Blood Glucose (mg/dL)',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.bloodGlucoseLevel,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color:
                          _getBloodGlucoseColor(_record.bloodGlucoseLevel ?? 0),
                    ),
                    // Blood Oxygen Level Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.bloodOxygenLevel ?? 'Blood Oxygen Level',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.bloodOxygenLevel,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: _getBloodOxygenStatusColor(
                          _record.bloodOxygenLevel ?? 0),
                    ),
                    // Heart Rate Series
                    LineSeries<HealthRecord, DateTime>(
                      name: AppLocalizations.of(context)?.heartRateBpm ?? 'Heart Rate (bpm)',
                      dataSource: [_record],
                      xValueMapper: (HealthRecord record, _) =>
                          record.timestamp,
                      yValueMapper: (HealthRecord record, _) =>
                          record.heartRate?.toDouble(),
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      color: _getHeartRateStatusColor(
                          (_record.heartRate ?? 0).toDouble()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add a data model for the chart
class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}
