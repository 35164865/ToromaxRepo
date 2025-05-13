import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../forms/form_adopcion.dart';

class AdoptarPantalla extends StatefulWidget {
  const AdoptarPantalla({super.key});

  @override
  State<AdoptarPantalla> createState() => _AdoptarPantallaState();
}

class _AdoptarPantallaState extends State<AdoptarPantalla> with WidgetsBindingObserver {
  Position? _currentPosition;
  LatLng? _ubicacionArbol;
  String _error = '';
  bool _isLoading = false;

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getLocation());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Permiso de ubicación denegado';
          _isLoading = false;
        });
        return;
      }

      final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isGpsEnabled) {
        setState(() {
          _error = 'Activa el GPS en tu dispositivo';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("ubicacion_actual"),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
        _isLoading = false;
      });

      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Error al obtener ubicación: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _guardarUbicacionArbol() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero obtén tu ubicación actual')),
      );
      return;
    }

    setState(() {
      _ubicacionArbol = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormAdopcion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopta un Árbol')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _initialCameraPosition,
                        onMapCreated: (GoogleMapController controller) {
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
                        },
                        markers: {
                          if (_currentPosition != null)
                            Marker(
                              markerId: const MarkerId("ubicacion_actual"),
                              position: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                            ),
                          if (_ubicacionArbol != null)
                            Marker(
                              markerId: const MarkerId("ubicacion_arbol"),
                              position: _ubicacionArbol!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen,
                              ),
                              infoWindow: const InfoWindow(title: "Árbol a adoptar"),
                            ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _guardarUbicacionArbol,
                        child: const Text('Guardar ubicación del árbol'),
                      ),
                    ),
                  ],
                ),
      
    );
  }
}
