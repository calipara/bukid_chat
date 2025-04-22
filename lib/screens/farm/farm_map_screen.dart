import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class FarmMapScreen extends StatefulWidget {
  final Function(List<LatLng>) onPolygonCompleted;
  final List<LatLng>? existingPolygon;

  const FarmMapScreen({
    Key? key,
    required this.onPolygonCompleted,
    this.existingPolygon,
  }) : super(key: key);

  @override
  State<FarmMapScreen> createState() => _FarmMapScreenState();
}

class _FarmMapScreenState extends State<FarmMapScreen> {
  GoogleMapController? _mapController;
  final List<LatLng> _polygonPoints = [];
  LatLng? _initialLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
    if (widget.existingPolygon != null) {
      _polygonPoints.addAll(widget.existingPolygon!);
    }
  }

  Future<void> _initLocation() async {
    Location location = Location();
    final hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      await location.requestPermission();
    }
    final loc = await location.getLocation();
    setState(() {
      _initialLocation = LatLng(loc.latitude ?? 14.676, loc.longitude ?? 121.043);
      _loading = false;
    });
  }

  void _onTapMap(LatLng latLng) {
    setState(() => _polygonPoints.add(latLng));
  }

  void _savePolygon() {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kailangan ng hindi bababa sa 3 points.')),
      );
      return;
    }
    widget.onPolygonCompleted(_polygonPoints);
    Navigator.pop(context);
  }

  void _clearPolygon() {
    setState(() => _polygonPoints.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _initialLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('I-draw ang iyong Bukid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePolygon,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearPolygon,
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation!,
          zoom: 15,
        ),
        polygons: {
          if (_polygonPoints.length > 2)
            Polygon(
              polygonId: const PolygonId('farm'),
              points: _polygonPoints,
              fillColor: Colors.green.withOpacity(0.3),
              strokeColor: Colors.green,
              strokeWidth: 2,
            )
        },
        onTap: _onTapMap,
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
