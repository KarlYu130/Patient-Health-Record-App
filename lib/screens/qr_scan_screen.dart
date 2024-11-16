import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as qr;
import 'dart:convert';
import '../models/patient.dart';
import '../helpers/database_helper.dart';
import '../models/health_record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  qr.QRViewController? controller;
  bool _isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: qr.QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          ElevatedButton(
            onPressed: _scanFromGallery,
            child: const Text('Scan QR from Gallery'),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _isScanning
                  ? const Text('Scanning...')
                  : const Text('Scan Complete'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(qr.QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isScanning) {
        setState(() {
          _isScanning = false;
        });
        controller.pauseCamera();
        try {
          Map<String, dynamic> data = jsonDecode(scanData.code!);
          // Insert Patient and retrieve the generated ID
          Patient patient = Patient.fromMap(data);
          int patientId = await DatabaseHelper.instance.insertPatient(patient);

          // Check and insert Health Records if available
          if (data.containsKey('health_records')) {
            List<dynamic> records = data['health_records'];
            for (var recordMap in records) {
              recordMap['patientId'] =
                  patientId; // Include patientId in the recordMap
              HealthRecord healthRecord = HealthRecord.fromMap(recordMap);
              await DatabaseHelper.instance.insertHealthRecord(healthRecord);
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Patient data recovered successfully')),
          );
          Navigator.pop(context, true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decode QR code')),
          );
          Navigator.pop(context, true);
        }
      }
    });
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final inputImage = mlkit.InputImage.fromFilePath(image.path);
        final barcodeScanner = mlkit.GoogleMlKit.vision.barcodeScanner();
        final barcodes = await barcodeScanner.processImage(inputImage);
        await barcodeScanner.close();
        String? qrCode;
        for (mlkit.Barcode barcode in barcodes) {
          if (barcode.type == mlkit.BarcodeType.url || barcode.type == mlkit.BarcodeType.text) {
            qrCode = barcode.rawValue;
            break;
          }
        }
        if (qrCode != null) {
          setState(() {
            _isScanning = false;
          });
          try {
            Map<String, dynamic> data = jsonDecode(qrCode);
            // Insert Patient and retrieve the generated ID
            Patient patient = Patient.fromMap(data);
            int patientId =
                await DatabaseHelper.instance.insertPatient(patient);

            // Check and insert Health Records if available
            if (data.containsKey('health_records')) {
              List<dynamic> records = data['health_records'];
              for (var recordMap in records) {
                recordMap['patientId'] =
                    patientId; // Include patientId in the recordMap
                HealthRecord healthRecord = HealthRecord.fromMap(recordMap);
                await DatabaseHelper.instance.insertHealthRecord(healthRecord);
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Patient data recovered successfully')),
            );
            Navigator.pop(context, true);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to decode QR code')),
            );
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No QR code found in the selected image')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decode QR code from image')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
