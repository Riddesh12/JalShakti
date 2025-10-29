import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class GraphPage extends StatefulWidget {
  final List<FlSpot> spots;
  final List<DateTime> dates;
  final GlobalKey graphKey; // Add this key to capture chart

  const GraphPage({super.key, required this.spots, required this.dates, required this.graphKey, required String cityName});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String _selectedGraph = "Line"; // Default graph type

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat displayFormat = DateFormat('dd-MM-yy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Graph View"),
        actions: [
          DropdownButton<String>(
            value: _selectedGraph,
            items: const [
              DropdownMenuItem(value: "Line", child: Text("Line Graph")),
              DropdownMenuItem(value: "Bar", child: Text("Bar Graph")),
              DropdownMenuItem(value: "Scatter", child: Text("Scatter Graph")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGraph = value;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.spots.isEmpty
            ? const Center(child: Text('No data to display'))
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RepaintBoundary(
            key: widget.graphKey, // wrap chart in RepaintBoundary
            child: SizedBox(
              width: widget.spots.length * 50, // scrollable width
              height: 300,
              child: _selectedGraph == "Line"
                  ? _buildLineChart(displayFormat)
                  : _selectedGraph == "Bar"
                  ? _buildBarChart(displayFormat)
                  : _buildScatterChart(displayFormat),
            ),
          ),
        ),
      ),
    );
  }

  /// 📊 Line Chart
  Widget _buildLineChart(DateFormat displayFormat) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: widget.spots.length - 1,
        minY: widget.spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5,
        maxY: widget.spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5,
        lineBarsData: [
          LineChartBarData(
            spots: widget.spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.green,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: _buildTitles(displayFormat),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  /// 📊 Bar Chart
  Widget _buildBarChart(DateFormat displayFormat) {
    final barGroups = widget.spots
        .asMap()
        .entries
        .map(
          (e) => BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.y,
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    )
        .toList();

    return BarChart(
      BarChartData(
        minY: widget.spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5,
        maxY: widget.spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5,
        barGroups: barGroups,
        titlesData: _buildTitles(displayFormat),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  /// 📊 Scatter Chart
  Widget _buildScatterChart(DateFormat displayFormat) {
    return ScatterChart(
      ScatterChartData(
        minX: 0,
        maxX: widget.spots.length - 1,
        minY: widget.spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5,
        maxY: widget.spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5,
        scatterSpots: widget.spots
            .map(
              (spot) => ScatterSpot(
            spot.x,
            spot.y,
          ),
        )
            .toList(),
        titlesData: _buildTitles(displayFormat),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  /// 🔢 Common Axis Titles
  FlTitlesData _buildTitles(DateFormat displayFormat) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            int index = value.toInt();
            if (index < 0 || index >= widget.dates.length) {
              return const SizedBox.shrink();
            }

            final current = widget.dates[index];
            final prev = index > 0 ? widget.dates[index - 1] : null;

            if ((prev == null ||
                current.day != prev.day ||
                current.month != prev.month ||
                current.year != prev.year) &&
                index % 3 == 0) {
              return Text(
                displayFormat.format(current),
                style: const TextStyle(fontSize: 10, color: Colors.black),
                textAlign: TextAlign.right,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 0.5,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10, color: Colors.black),
              textAlign: TextAlign.left,
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
