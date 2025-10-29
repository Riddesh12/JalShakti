import 'package:flutter/material.dart';
import 'package:jal_shakti/Groundwater%20Availability%20Estimation/groundwater_recharge.dart';
import 'package:jal_shakti/map.dart';

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
    MapPage(),
    DwlrStation(),
    GroundWaterLevel(),
    GroundwaterRecharge(),
   //DecisionSupport(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[count],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        backgroundColor:Color(0xFF00008B) ,
        currentIndex: count,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            count = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Map",
          ),
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
