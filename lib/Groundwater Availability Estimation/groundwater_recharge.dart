import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math' as math;

class GroundwaterRecharge extends StatefulWidget {
  const GroundwaterRecharge({super.key});

  @override
  State<GroundwaterRecharge> createState() => _GroundwaterRechargeState();
}

class _GroundwaterRechargeState extends State<GroundwaterRecharge> {
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _agencyController = TextEditingController(text: "CGWB");
  final TextEditingController _year = TextEditingController();

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
    // Add other states as needed
  };

  String? selectedState;
  String? selectedDistrict;

  Future<void> _selectYear(BuildContext context) async {
    final now = DateTime.now();
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int selected = now.year;
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: now,
              initialDate: DateTime(selected),
              selectedDate: DateTime(selected),
              onChanged: (DateTime date) {
                Navigator.pop(ctx, date.year);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
    if (pickedYear != null) {
      setState(() {
        _year.text = pickedYear.toString();
      });
    }
  }

  Future<void> fetchGroundWaterData() async {
    final stateName = _stateController.text.trim();
    final districtName = _districtController.text.trim();
    final agencyName = _agencyController.text.trim();
    final year = _year.text.trim();
    if (year.isEmpty) {
      setState(() {
        result = "Please select a year";
      });
      return;
    }
    setState(() {
      isLoading = true;
      result = "";
      parsedData = [];
    });

    try {
      final now = DateTime.now();
      final yearInt = int.tryParse(year) ?? now.year;
      bool fetchMay = true, fetchOct = true;
      List<Map<String, dynamic>> combined = [];

      if (yearInt == now.year) {
        if (now.month < 5) {
          fetchMay = fetchOct = false;
          combined.addAll(await _fetchRange(stateName, districtName, agencyName, "$year-01-01", "$year-${now.month.toString().padLeft(2, '0')}-01"));
        } else if (now.month < 10) {
          fetchOct = false;
        }
      }

      if (fetchMay) {
        combined.addAll(await _fetchRange(stateName, districtName, agencyName, "$year-05-01", "$year-05-15", monthLabel: "May"));
      }
      if (fetchOct) {
        combined.addAll(await _fetchRange(stateName, districtName, agencyName, "$year-10-01", "$year-10-15", monthLabel: "October"));
      }

      final Map<String, Map<String, dynamic>> stationMap = {};
      for (var rec in combined) {
        final station = rec['stationName'] as String;
        stationMap.putIfAbsent(station, () {
          return {
            'stationName': station,
            'district': rec['district'],
            'May': null,
            'October': null,
          };
        });
        stationMap[station]![rec['month']] = rec['level'];
      }

      final List<Map<String, dynamic>> results = [];
      stationMap.forEach((_, v) {
        results.add({
          'stationName': v['stationName'],
          'district': v['district'],
          'May': v['May'],
          'October': v['October'],
          'difference': (v['October'] ?? 0) - (v['May'] ?? 0),
        });
      });

      setState(() {
        parsedData = results;
        result = results.isEmpty ? "No data found" : "";
      });
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

  Future<List<Map<String, dynamic>>> _fetchRange(String st, String dist, String ag, String start, String end, {String? monthLabel}) async {
    final uri = Uri.parse(
        'https://indiawris.gov.in/Dataset/Ground%20Water%20Level'
            '?stateName=$st&districtName=$dist'
            '&agencyName=$ag&startdate=$start&enddate=$end'
            '&download=false&page=0&size=20');
    try {
      final resp = await http.post(uri, headers: {"Accept": "application/json"});
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final data = (body['data'] as List? ?? []).map((item) {
          final level = double.tryParse(item['dataValue'].toString()) ?? 0.0;
          return {
            'stationName': item['stationName'],
            'district': item['district'],
            'date': item['dataTime'],
            'level': level,
            'month': monthLabel ?? DateFormat('MMMM').format(DateTime.parse(item['dataTime'])),
          };
        }).toList();

        final unique = <String, Map<String, dynamic>>{};
        for (var d in data) {
          final key = "${d['stationName']}_${d['month']}";
          unique.putIfAbsent(key, () => d);
        }
        return unique.values.toList();
      }
    } catch (_) {}
    return [];
  }

  Widget _buildResultView() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (parsedData.isEmpty) return result.isNotEmpty ? Text(result) : const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parsedData.length,
      itemBuilder: (context, index) {
        final item = parsedData[index];
        return WaterWellIndicator(
          stationName: item['stationName'],
          district: item['district'],
          mayLevel: item['May'] as double?,
          octoberLevel: item['October'] as double?,
          difference: item['difference'] as double,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00008B),
        leading: Image.asset("Assets/jalshakti.png"),
        title: const Text("Groundwater Recharge", style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        )),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: const Text("State", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 3),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: "State",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                isExpanded: true,
                value: selectedState,
                items: stateDistricts.keys.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedState = v;
                    _stateController.text = v ?? "";
                    selectedDistrict = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                  alignment: Alignment.topLeft,
                  child: const Text("District", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 3),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: "District",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedDistrict,
                items: (selectedState != null ? stateDistricts[selectedState]! : <String>[])
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedDistrict = v;
                    _districtController.text = v ?? "";
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                  alignment: Alignment.topLeft,
                  child: const Text("Year", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 3),
              TextFormField(
                controller: _year,
                readOnly: true,
                onTap: () => _selectYear(context),
                decoration: InputDecoration(
                  hintText: 'Select Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: fetchGroundWaterData,
                icon: const Icon(Icons.search),
                label: const Text("Fetch Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterWellIndicator extends StatefulWidget {
  final String stationName;
  final String district;
  final double? mayLevel;
  final double? octoberLevel;
  final double difference;
  final double maxDepth;

  const WaterWellIndicator({
    Key? key,
    required this.stationName,
    required this.district,
    this.mayLevel,
    this.octoberLevel,
    required this.difference,
    this.maxDepth = 20.0,
  }) : super(key: key);

  @override
  State<WaterWellIndicator> createState() => _WaterWellIndicatorState();
}

class _WaterWellIndicatorState extends State<WaterWellIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _mayAnimation;
  late Animation<double> _octoberAnimation;
  late Animation<double> _rechargeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    final mayProgress = widget.mayLevel != null
        ? ((widget.maxDepth + widget.mayLevel!) / widget.maxDepth).clamp(0.0, 1.0)
        : 0.0;
    final octoberProgress = widget.octoberLevel != null
        ? ((widget.maxDepth + widget.octoberLevel!) / widget.maxDepth).clamp(0.0, 1.0)
        : 0.0;
    final rechargeProgress = (widget.difference.abs() / 10.0).clamp(0.0, 1.0);

    _mayAnimation = Tween<double>(begin: 0.0, end: mayProgress)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _octoberAnimation = Tween<double>(begin: 0.0, end: octoberProgress)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _rechargeAnimation = Tween<double>(begin: 0.0, end: rechargeProgress)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.stationName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "District: ${widget.district}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWellColumn("Pre-Monsoon", widget.mayLevel, Colors.orange, _mayAnimation),
                _buildWellColumn("Post-Monsoon", widget.octoberLevel, Colors.blue, _octoberAnimation),
                _buildRechargeColumn(widget.difference, _rechargeAnimation),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWellColumn(String title, double? level, Color color, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(37),
                  bottomRight: Radius.circular(37),
                ),
                child: CustomPaint(
                  painter: WaterLevelPainter(
                    progress: animation.value,
                    color: color,
                  ),
                  child: Center(
                    child: level != null
                        ? Text("${level.toStringAsFixed(1)}m",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                      ),
                    )
                        : const Text("-",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level != null ? "${level.toStringAsFixed(2)} m" : "No data",
              style: TextStyle(
                fontSize: 10,
                color: level != null ? Colors.black87 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRechargeColumn(double rechargeValue, Animation<double> animation) {
    bool isPositive = rechargeValue > 0;
    Color rechargeColor = isPositive ? Colors.green : Colors.red;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          children: [
            const Text(
              "Net Recharge",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CustomPaint(
                  painter: WaterLevelPainter(
                    progress: animation.value,
                    color: rechargeColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.white,
                          size: 20,
                        ),
                        Text(
                          "${rechargeValue.toStringAsFixed(1)}m",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${isPositive ? '-' : ''}${rechargeValue.toStringAsFixed(2)} m",
              style: TextStyle(
                fontSize: 10,
                color: rechargeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

class WaterLevelPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaterLevelPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Calculate water level height
    final waterHeight = size.height * progress;
    final waterTop = size.height - waterHeight;

    if (progress > 0) {
      // Create wave effect
      final path = Path();
      path.moveTo(0, waterTop);

      // Create wave using sine function
      for (double x = 0; x <= size.width; x += 1) {
        final y = waterTop + 2 * math.sin((x / size.width) * 4 * math.pi);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
