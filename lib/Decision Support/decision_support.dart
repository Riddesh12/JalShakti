import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// ---------------- PDF Viewer ----------------
class PdfViewerPage extends StatelessWidget {
  final File file;
  const PdfViewerPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview PDF")),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}

/// ---------------- Decision Support Form ----------------
class DecisionSupport extends StatefulWidget {
  const DecisionSupport({super.key});

  @override
  State<DecisionSupport> createState() => _DecisionSupportState();
}

class _DecisionSupportState extends State<DecisionSupport> {
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController startDate = TextEditingController();
  final TextEditingController endDate = TextEditingController();

  /// Generate PDF and open
  Future<void> generatePdf() async {
    final pdf = pw.Document();

    // Add content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "Decision Support Report",
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("State Name: ${_stateController.text.trim().isEmpty ? "Not provided" : _stateController.text.trim()}"),
              pw.SizedBox(height: 10),
              pw.Text("District Name: ${_districtController.text.trim().isEmpty ? "Not provided" : _districtController.text.trim()}"),
              pw.SizedBox(height: 10),
              pw.Text("Start Date: ${startDate.text.trim().isEmpty ? "Not provided" : startDate.text.trim()}"),
              pw.SizedBox(height: 10),
              pw.Text("End Date: ${endDate.text.trim().isEmpty ? "Not provided" : endDate.text.trim()}"),
            ],
          );
        },
      ),
    );

    // Ask permission
    if (await Permission.storage.request().isGranted) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/decision_support.pdf");

      // Save file
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        // Open inside app
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfViewerPage(file: file)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decision Support"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: _stateController,
                decoration: InputDecoration(
                  hintText: "State",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  hintText: "District",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: startDate,
                decoration: InputDecoration(
                  hintText: "Start Date",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: endDate,
                decoration: InputDecoration(
                  hintText: "End Date",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: generatePdf,
                child: const Text("Generate & Open PDF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
