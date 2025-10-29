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
  @override
  void initState(){
    super.initState();
    _startDate.text="2025-09-01";
  }
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
    "Maharashtra": [
      "Ahmednagar",
      "Akola",
      "Amravati",
      "Aurangabad",
      "Beed",
      "Bhandara",
      "Buldhana",
      "Chandrapur",
      "Dhule",
      "Gadchiroli",
      "Gondia",
      "Hingoli",
      "Jalgaon",
      "Jalna",
      "Kolhapur",
      "Latur",
      "Mumbai City",
      "Mumbai Suburban",
      "Nagpur",
      "Nanded",
      "Nandurbar",
      "Nashik",
      "Osmanabad",
      "Palghar",
      "Parbhani",
      "Pune",
      "Raigad",
      "Ratnagiri",
      "Sangli",
      "Satara",
      "Sindhudurg",
      "Solapur",
      "Thane",
      "Wardha",
      "Washim",
      "Yavatmal"
    ],
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

            // Sort the data by date (newest first)
            parsedData.sort((a, b) {
              try {
                final dateA = DateTime.parse(a['date'] ?? '');
                final dateB = DateTime.parse(b['date'] ?? '');
                return dateB.compareTo(dateA); // Descending order (newest first)
                // Use dateA.compareTo(dateB) for ascending order (oldest first)
              } catch (e) {
                return 0; // Keep original order if date parsing fails
              }
            });

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
      final stationName = parsedData.first['stationName'] ?? "Unknown Station";
      final districtName = parsedData.first['district'] ?? "-";
      final wellDepth=parsedData.first['wellDepth']??"-";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Section (shown only once)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Station: $stationName",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "District: $districtName",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text("Well Depth: $wellDepth",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black
                          ),)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          const Divider(thickness: 1),

          // Add a sorting indicator


          // Data Cards (date, level, well depth) - now sorted
          ...parsedData.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;

            // Format the date for better display
// Format the date and time for display
            String formattedDate = item['date'] ?? '-';
            try {
              final parsedDate = DateTime.parse(item['date'] ?? '');
              formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
            } catch (e) {
              formattedDate = item['date'] ?? '-';
            }


            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  "Date: $formattedDate",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.water_drop, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Level: ${item['level'] ?? '-'} ${item['unit'] ?? ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // trailing: Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: Colors.green.shade50,
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(color: Colors.green.shade200),
                //   ),
                //   child: Text(
                //     '${item['level'] ?? '-'}',
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //       color: Colors.green[700],
                //     ),
                //   ),
                // ),
              ),
            );
          }).toList(),
        ],
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

          // Add note about sorting
          pw.Text("Data sorted by date (newest first)",
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
          pw.SizedBox(height: 10),

          // Add cards data (sorted)
          ...parsedData.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;

            String formattedDate = item['date'] ?? '-';
            try {
              final parsedDate = DateTime.parse(item['date'] ?? '');
              formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);

            } catch (e) {
              formattedDate = item['date'] ?? '-';
            }

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
                  pw.Text("${index + 1}. Station: ${item['stationName'] ?? '-'}"),
                  pw.Text("District: ${item['district'] ?? '-'}"),
                  pw.Text("Date: $formattedDate"),
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
        leading: Image.asset("Assets/jalshakti.png"),
        backgroundColor: Color(0xFF00008B),
        title: const Text(
          "Ground Water Level",
          style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // State dropdown
              Align(alignment: Alignment.topLeft,child: Text("State:",style: TextStyle(fontWeight: FontWeight.bold),)),
              SizedBox(height: 3,),
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
              Align(alignment: Alignment.topLeft,child: Text("District:",style: TextStyle(fontWeight: FontWeight.bold),)),
              SizedBox(height: 3,),
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
              Align(alignment: Alignment.topLeft,child: Text("Start Date & End Date:",style: TextStyle(fontWeight: FontWeight.bold),)),
              SizedBox(height: 5,),
              Center(
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      child: TextFormField(
                        controller: _startDate,
                        decoration: InputDecoration(
                          hintText: "Start Date",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _startDate),
                      ),
                    ),
                    SizedBox(width: 50,),
                    Container(
                      width: 120,
                      child: TextFormField(
                        controller: _endDate,
                        decoration: InputDecoration(
                          hintText: "End Date",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _endDate),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: (_stateController.text.isEmpty || _districtController.text.isEmpty || _startDate.text.isEmpty || _endDate.text.isEmpty)?
                        null:fetchGroundWaterData,
                        icon: const Icon(Icons.search),
                        label: const Text("Fetch"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          minimumSize: const Size(0, 50), // only control height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: parsedData.isNotEmpty
                            ? () {
                          final List<FlSpot> spots = [];
                          final List<DateTime> dates = [];

                          // Sort data chronologically for graph (oldest first for proper line graph)
                          List<Map<String, dynamic>> sortedForGraph = List.from(parsedData);
                          sortedForGraph.sort((a, b) {
                            try {
                              final dateA = DateTime.parse(a['date'] ?? '');
                              final dateB = DateTime.parse(b['date'] ?? '');
                              return dateA.compareTo(dateB); // Ascending order for graph
                            } catch (e) {
                              return 0;
                            }
                          });

                          for (int i = 0; i < sortedForGraph.length; i++) {
                            final item = sortedForGraph[i];
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
                                dates: dates,
                                graphKey: _graphKey, cityName: '${_districtController.text}',
                              ),
                            ),
                          );
                        }
                            : null,
                        icon: const Icon(Icons.show_chart),
                        label: const Text("Show Graph"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: parsedData.isNotEmpty ? _generatePdfWithGraph : null,
                        label: const Text("Generate PDF"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(20, 50),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Result view
              _buildResultView(),

            ],
          ),
        ),
      ),
    );
  }
}