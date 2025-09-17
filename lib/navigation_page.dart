import 'package:flutter/material.dart';

import 'DWLR/dwlr_station.dart';
import 'Decision Support/decision_support.dart';
import 'GroundWaterLevel/ground_water_level.dart';
import 'Groundwater Availability Estimation/availability.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});


  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int count = 0;

  final List<Widget> pages = [
    DwlrStation(),
    GroundWaterLevel(),
    AvailabilityScreen(),
   //DecisionSupport(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[count],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        currentIndex: count,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            count = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_rounded),
            label: "DWLR",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: "Patterns",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: "Availability",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.support_agent), // fixed
          //   label: "Decisions", // fixed typo
          // ),
        ],
      ),
    );
  }
}
