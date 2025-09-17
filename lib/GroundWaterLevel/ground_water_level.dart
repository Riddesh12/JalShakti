import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../DWLR/graph_page.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

class GroundWaterLevel extends StatefulWidget {
  const GroundWaterLevel({super.key});

  @override
  State<GroundWaterLevel> createState() => _GroundWaterLevelState();
}

class _GroundWaterLevelState extends State<GroundWaterLevel> {
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _agencyController =
  TextEditingController(text: "CGWB"); // default
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();

  String result = "";
  bool isLoading = false;
  List<Map<String, dynamic>> parsedData = [];

  final Map<String, List<String>> stateDistricts = {
    "Andhra Pradesh": ["Visakhapatnam", "Vijayawada", "Guntur", "Tirupati"],
    "Arunachal Pradesh": ["Itanagar", "Tawang", "Ziro"],
    "Assam": ["Guwahati", "Dibrugarh", "Silchar", "Jorhat"],
    "Bihar": ["Patna", "Gaya", "Muzaffarpur", "Bhagalpur"],
    "Chhattisgarh": ["Raipur", "Bilaspur", "Durg"],
    "Goa": ["North Goa", "South Goa"],
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
    "Haryana": ["Gurugram", "Faridabad", "Panipat"],
    "Himachal Pradesh": ["Shimla", "Manali", "Dharamshala"],
    "Jharkhand": ["Ranchi", "Jamshedpur", "Dhanbad"],
    "Karnataka": ["Bengaluru Urban", "Mysuru", "Belagavi"],
    "Kerala": ["Thiruvananthapuram", "Kochi", "Kozhikode"],
    "Madhya Pradesh": ["Bhopal", "Indore", "Jabalpur", "Gwalior"],
    "Maharashtra": ["Mumbai", "Pune", "Nashik", "Solapur", "Nagpur"],
    "Manipur": ["Imphal", "Churachandpur"],
    "Meghalaya": ["Shillong", "Tura"],
    "Mizoram": ["Aizawl", "Lunglei"],
    "Nagaland": ["Kohima", "Dimapur"],
    "Odisha": ["Bhubaneswar", "Cuttack", "Puri"],
    "Punjab": ["Amritsar", "Ludhiana", "Patiala", "Jalandhar"],
    "Rajasthan": ["Jaipur", "Udaipur", "Jodhpur", "Ajmer"],
    "Sikkim": ["Gangtok", "Namchi"],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai", "Salem"],
    "Telangana": ["Hyderabad", "Warangal", "Nizamabad"],
    "Tripura": ["Agartala", "Dharmanagar"],
    "Uttar Pradesh": ["Lucknow", "Kanpur", "Varanasi", "Agra"],
    "Uttarakhand": ["Dehradun", "Haridwar", "Nainital"],
    "West Bengal": ["Kolkata", "Howrah", "Darjeeling", "Siliguri"],

    // Union Territories
    "Delhi": ["New Delhi", "Central Delhi", "North Delhi"],
    "Chandigarh": ["Chandigarh"],
    "Andaman and Nicobar Islands": ["Port Blair"],
    "Dadra and Nagar Haveli and Daman and Diu": ["Daman", "Silvassa"],
    "Jammu and Kashmir": ["Srinagar", "Jammu"],
    "Ladakh": ["Leh", "Kargil"],
    "Lakshadweep": ["Kavaratti"],
    "Puducherry": ["Puducherry", "Karaikal"],
  };

  String? selectedState;
  String? selectedDistrict;

  GlobalKey _graphKey = GlobalKey(); // For capturing graph

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  Future<void> fetchGroundWaterData() async {
    final stateName = _stateController.text.trim();
    final districtName = _districtController.text.trim();
    final agencyName = _agencyController.text.trim();
    final startDate = _startDate.text.trim();
    final endDate = _endDate.text.trim();

    final uri = Uri.parse(
      'https://indiawris.gov.in/Dataset/Ground%20Water%20Level'
          '?stateName=$stateName'
          '&districtName=$districtName'
          '&agencyName=$agencyName'
          '&startdate=$startDate'
          '&enddate=$endDate'
          '&download=false'
          '&page=0'
          '&size=20',
    );

    setState(() {
      isLoading = true;
      result = "";
      parsedData = [];
    });

    try {
      final response = await http.post(
        uri,
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        setState(() {
          result = response.body;
          try {
            final decoded = json.decode(response.body);

            parsedData =
                (decoded["data"] ?? []).map<Map<String, dynamic>>((item) {
                  return {
                    "stationName": item["stationName"],
                    "district": item["district"],
                    "date": item["dataTime"],
                    "level": item["dataValue"],
                    "unit": item["unit"],
                    "wellDepth": item["wellDepth"],
                  };
                }).toList();
          } catch (e) {
            parsedData = [];
            result = "Error parsing response: $e";
          }
        });
      } else {
        setState(() {
          result = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildResultView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (parsedData.isNotEmpty) {
      return Column(
        children: parsedData.map((item) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.water_drop, color: Colors.blue),
              ),
              title: Text(
                item['stationName'] ?? "Unknown Station",
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text("District: ${item['district'] ?? '-'}"),
                  const SizedBox(height: 8),
                  Text("Date: ${item['date'] ?? '-'}"),
                  const SizedBox(height: 8),
                  Text(
                      "Level: ${item['level'] ?? '-'} ${item['unit'] ?? ''}"),
                  const SizedBox(height: 8),
                  Text("Well Depth: ${item['wellDepth'] ?? '-'}"),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    if (result.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          result,
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    return const SizedBox(); // nothing yet
  }

  // PDF with graph generation
  Future<void> _generatePdfWithGraph() async {
    if (parsedData.isEmpty) return;

    // Request permission
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }
    }

    // Capture graph image
    Uint8List? graphImageBytes;
    try {
      RenderRepaintBoundary? boundary =
      _graphKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        graphImageBytes = byteData!.buffer.asUint8List();
      }
    } catch (e) {
      print("Error capturing graph: $e");
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text("Ground Water Level Report",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),

          // Add graph if captured
          if (graphImageBytes != null)
            pw.Center(
              child: pw.Image(pw.MemoryImage(graphImageBytes),
                  width: 400, height: 200),
            ),
          pw.SizedBox(height: 20),

          // Add cards data
          ...parsedData.map((item) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Station: ${item['stationName'] ?? '-'}"),
                  pw.Text("District: ${item['district'] ?? '-'}"),
                  pw.Text("Date: ${item['date'] ?? '-'}"),
                  pw.Text(
                      "Level: ${item['level'] ?? '-'} ${item['unit'] ?? ''}"),
                  pw.Text("Well Depth: ${item['wellDepth'] ?? '-'}"),
                ],
              ),
            );
          }),
        ],
      ),
    );

    Directory dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File("${dir.path}/ground_water_report.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved at ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ground Water Level",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // State dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: "State",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            isExpanded: true,
            value: selectedState,
            items: stateDistricts.keys.map((state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(
                  state,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedState = value;
                selectedDistrict = null; // reset district
                _stateController.text = value ?? "";
              });
            },
          ),
          const SizedBox(height: 10),

          // District dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: "District",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            value: selectedDistrict,
            items: (selectedState != null
                ? stateDistricts[selectedState] ?? []
                : [])
                .map((district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(district),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
                _districtController.text = value ?? "";
              });
            },
          ),
          const SizedBox(height: 10),

          // Start Date
          TextFormField(
            controller: _startDate,
            decoration: InputDecoration(
              labelText: "Start Date",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _startDate),
          ),
          const SizedBox(height: 10),

          // End Date
          TextFormField(
            controller: _endDate,
            decoration: InputDecoration(
              labelText: "End Date",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _endDate),
          ),
          const SizedBox(height: 20),

          // Fetch button
          ElevatedButton.icon(
            onPressed: fetchGroundWaterData,
            icon: const Icon(Icons.search),
            label: const Text("Fetch"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Graph button
          ElevatedButton.icon(
            onPressed: parsedData.isNotEmpty
                ? () {
              final List<FlSpot> spots = [];
              final List<DateTime> dates = [];

              for (int i = 0; i < parsedData.length; i++) {
                final item = parsedData[i];
                final dateStr = item['date'];
                final level =
                double.tryParse(item['level']?.toString() ?? '');

                if (dateStr != null && level != null) {
                  try {
                    final parsedDate = DateTime.parse(dateStr);
                    dates.add(parsedDate);
                    spots.add(FlSpot(i.toDouble(), level));
                  } catch (_) {}
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GraphPage(
                     key: _graphKey,
                    spots: spots,
                    dates: dates, graphKey: _graphKey,
                  ),
                ),
              );
            }
                : null,
            icon: const Icon(Icons.show_chart),
            label: const Text("Show Graph"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // PDF button
          ElevatedButton.icon(
            onPressed: parsedData.isNotEmpty ? _generatePdfWithGraph : null,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Generate PDF"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Result view
          _buildResultView(),
        ],
      ),
    );
  }
}
