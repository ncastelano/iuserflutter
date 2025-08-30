import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class EditLocation extends StatefulWidget {
  const EditLocation({Key? key}) : super(key: key);

  @override
  State<EditLocation> createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  String? _currentAddress;
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['latitude'] == null || data['longitude'] == null) return;

    final lat = data['latitude'];
    final lng = data['longitude'];
    _currentLatLng = LatLng(lat, lng);

    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      setState(() {
        _currentAddress = '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}';
      });
    }

    setState(() {}); // para redesenhar com o mapa
  }

  Future<void> _saveLocation() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    try {
      final locations = await locationFromAddress(input);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lng = locations.first.longitude;

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'latitude': lat,
          'longitude': lng,
        });

        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';

          if (mounted) {
            setState(() {
              _currentLatLng = LatLng(lat, lng);
              _currentAddress = address;
            });

            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLatLng!, 17),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Localização atualizada: $address')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      final address =
          '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
      setState(() {
        _currentLatLng = latLng;
        _currentAddress = address;
        _controller.text = address; // atualiza o texto no TextField
      });
    }
  }


  Future<void> _locateMe() async {
    setState(() => _loading = true);
    try {
      // Pede permissão e pega localização atual
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão negada para acessar localização');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão negada permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);

      await _updateAddressFromLatLng(latLng);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 17),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao localizar: $e')),
        );
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Localização'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentAddress != null) ...[
              const Text(
                'Sua ultima localização salva:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _currentAddress!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Digite sua nova localização:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ex: Avenida Paulista, São Paulo',
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white38),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: 'Localizar minha posição atual',
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _locateMe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text('Localizar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Tooltip(
                    message: 'Salvar localização',
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _saveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      icon: _loading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                          : const Icon(Icons.done),
                      label: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            if (_currentLatLng != null)
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLatLng!,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('local'),
                        position: _currentLatLng!,
                      )
                    },
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    liteModeEnabled: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
