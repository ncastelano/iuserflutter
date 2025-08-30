import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMap extends StatelessWidget {
  final Set<Marker> userMarkers;

  FullScreenMap({required this.userMarkers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: 'user_map',
          child: Container(

              height: 600,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(-10.787717, -65.336855),
                  zoom: 24,
                  tilt: 90,
                  bearing: 90,
                ),
                markers: userMarkers, // <- Agora direto, sem .toSet()
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                            ),
              ),
          ),
        ),
      ),
    );
  }
}
