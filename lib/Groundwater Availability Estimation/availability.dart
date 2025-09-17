import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../availability_model.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  String? selectState;
  String? selectDistrict;
  Availability? selectedAvailability;

  Future<List<Availability>> loadAvailability() async {
    final String response =
    await rootBundle.loadString("Assets/district_data.json");
    final List<dynamic> data = json.decode(response);
    return data.map((e) => Availability.fromMap(e)).toList();
  }

  final Map<String, List<String>> stateDistricts = {
    "Maharashtra": [
      "Ahmednagar",
      "Akola",
      "Amravati",
      "Aurangabad",
      "Beed",
      "Nagpur",
      "Nashik",
      "Pune",
      "Solapur"
    ],
    "Gujarat": ["Ahmedabad", "Surat", "Vadodara", "Rajkot"],
    "Delhi": ["New Delhi", "Central Delhi", "North Delhi"],
  };

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ground Water Recharge"),
        centerTitle: true,
        backgroundColor: Colors.green,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // State Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select State",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: selectState,
              isExpanded: true,
              items: stateDistricts.keys.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectState = value;
                  selectDistrict = null;
                });
              },
            ),
            const SizedBox(height: 12),

            // District Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select District",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: selectDistrict,
              isExpanded: true,
              items: (selectState != null
                  ? stateDistricts[selectState] ?? []
                  : [])
                  .map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectDistrict = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Button
            ElevatedButton.icon(
              icon: const Icon(Icons.water_drop_outlined),
              onPressed: () async {
                final list = await loadAvailability();
                setState(() {
                  selectedAvailability = list.firstWhere(
                          (d) => d.district == selectDistrict,
                      orElse: () => list.first);
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: const Text("Show Data"),
            ),
            const SizedBox(height: 20),

            if (selectedAvailability != null) ...[
              Text(
                "📍 ${selectedAvailability!.district}",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildInfoCard("🌧️ Monsoon Season", [
                _buildDetailRow("Recharge From Rainfall",
                    "${selectedAvailability!.rechargeRainfallMonsoon}"),
                _buildDetailRow("Recharge From Other Sources",
                    "${selectedAvailability!.rechargeOtherMonsoon}"),
              ]),

              _buildInfoCard("☀️ Non-Monsoon Season", [
                _buildDetailRow("Recharge From Rainfall",
                    "${selectedAvailability!.rechargeRainfallNonMonsoon}"),
                _buildDetailRow("Recharge From Other Sources",
                    "${selectedAvailability!.rechargeOtherNonMonsoon}"),
              ]),

              _buildInfoCard("📊 Groundwater Data", [
                _buildDetailRow("Total Groundwater Recharge (Annual)",
                    "${selectedAvailability!.totalRecharge}",
                    color: Colors.blue),
                _buildDetailRow("Natural Discharge",
                    "${selectedAvailability!.naturalDischarge}"),
                _buildDetailRow("Net Annual Availability",
                    "${selectedAvailability!.netAnnualAvailability}",
                    color: Colors.green),
                _buildDetailRow("Annual Draft for Irrigation",
                    "${selectedAvailability!.annualDraftIrrigation}"),
                _buildDetailRow("Annual Draft (Domestic & Industrial)",
                    "${selectedAvailability!.annualDraftDomesticIndustrial}"),
                _buildDetailRow(
                    "Total Draft", "${selectedAvailability!.totalDraft}"),
              ]),

              _buildInfoCard("📅 Projections", [
                _buildDetailRow("Projected Demand by 2025",
                    "${selectedAvailability!.projectedDemand2025}"),
                _buildDetailRow("Availability for Future Use",
                    "${selectedAvailability!.availabilityForFuture}",
                    color: Colors.deepPurple),
                _buildDetailRow("Stage of Groundwater Development",
                    "${selectedAvailability!.stageOfDevelopment}%",
                    color: Colors.redAccent),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
