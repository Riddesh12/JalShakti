import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GeoJsonParser myGeoJson = GeoJsonParser();
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  bool _dataLoaded = false;
  List<Marker> _pointMarkers = [];
  final Map<Marker, Map<String, dynamic>> _markerProps = {};

  @override
  void initState() {
    super.initState();
    _loadGeoJsonAndCreateMarkers();
  }

  Future<void> _loadGeoJsonAndCreateMarkers() async {
    final uri = Uri.parse(
      'https://api.maptiler.com/data/0199603f-a5a1-7d7d-b5dd-4719c25d9825/features.json?key=g90kJmHXq1GVZglyo3CR',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to load GeoJson: ${response.statusCode}');
      return;
    }

    myGeoJson.parseGeoJsonAsString(response.body);

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> features = (data['features'] as List<dynamic>?) ?? [];

    final List<Marker> markers = [];
    final Map<Marker, Map<String, dynamic>> propsMap = {};

    for (final f in features) {
      final geom = f['geometry'];
      if (geom == null) continue;

      final String type = (geom['type'] ?? '').toString();
      if (type.toLowerCase() == 'point') {
        final coords = List.of(geom['coordinates'] ?? []);
        if (coords.length >= 2) {
          final lon = (coords[0] as num).toDouble();
          final lat = (coords[1] as num).toDouble();
          final properties = (f['properties'] as Map<String, dynamic>?) ?? {};

          final m = Marker(
            point: LatLng(lat, lon),
            width: 36,
            height: 36,
            alignment: Alignment.bottomCenter,
            child: const Icon(
              Icons.location_on,
              size: 32,
              color: Colors.red,
            ),
          );
          markers.add(m);
          propsMap[m] = properties;
        }
      }
    }

    setState(() {
      _pointMarkers = markers;
      _markerProps
        ..clear()
        ..addAll(propsMap);
      _dataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(20.5937, 78.9629),
          initialZoom: 4,
          minZoom: 3,
          maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=g90kJmHXq1GVZglyo3CR',
            userAgentPackageName: 'com.example.app',
          ),
          if (_dataLoaded) PolygonLayer(polygons: myGeoJson.polygons),
          if (_dataLoaded) PolylineLayer(polylines: myGeoJson.polylines),
          if (_dataLoaded) CircleLayer(circles: myGeoJson.circles),
          if (_dataLoaded)
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: _pointMarkers,
                popupController: _popupController,
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    final props = _markerProps[marker] ?? {};

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                props['text']?.toString() ?? 'Location',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                props.isNotEmpty
                                    ? props.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join('\n')
                                    : 'No Properties available',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                onPressed: () {
                                  // Auto-zoom & center map on marker
                                  _mapController.move(
                                    marker.point,
                                    10.0,
                                  );

                                  // Show zoomable image dialog for Solapur
                                  if (props['text']?.toString() == "Solapur") {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                        const Text("Ground Water Graph"),
                                        content: SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: InteractiveViewer(
                                            panEnabled: true,
                                            scaleEnabled: true,
                                            minScale: 1.0,
                                            maxScale: 5.0,
                                            child: Image.asset(
                                              "Assets/solapurContur.jpg",
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else if(props['text']?.toString() == "Amravati") {
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    title:
    const Text("Ground Water Graph"),
    content: SizedBox(
    width: 300,
    height: 300,
    child: InteractiveViewer(
    panEnabled: true,
    scaleEnabled: true,
    minScale: 1.0,
    maxScale: 5.0,
    child: Image.asset(
    "Assets/amravtiContur.jpg",
    fit: BoxFit.contain,
    ),
    ),
    ),
    actions: [
    TextButton(
    onPressed: () =>
    Navigator.pop(context),
    child: const Text("Close"),
    ),
    ],
    ),
    );
                                  }
                                 else if (props['text']?.toString() == "Pune") {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                        const Text("Ground Water Graph"),
                                        content: SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: InteractiveViewer(
                                            panEnabled: true,
                                            scaleEnabled: true,
                                            minScale: 1.0,
                                            maxScale: 5.0,
                                            child: Image.asset(
                                              "Assets/puneContur.jpg",
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: const Text("Ground water Graph"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
