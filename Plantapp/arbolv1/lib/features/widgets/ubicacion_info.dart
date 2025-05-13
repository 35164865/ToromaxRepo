import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UbicacionInfo extends StatelessWidget {
  final Position position;

  const UbicacionInfo({required this.position, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.location_on, size: 50, color: Colors.blue),
        const SizedBox(height: 20),
        Text(
          'Coordenadas:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Latitud: ${position.latitude.toStringAsFixed(6)}',
          style: const TextStyle(fontSize: 18),
        ),
        Text(
          'Longitud: ${position.longitude.toStringAsFixed(6)}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Aquí podrías mover la lógica de compartir ubicación también
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ubicación copiada al portapapeles'),
              ),
            );
          },
          child: const Text('Compartir Ubicación'),
        ),
      ],
    );
  }
}
