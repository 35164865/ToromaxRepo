import 'package:flutter/material.dart';
import 'package:arbolv1/services/firebase_services.dart';

class ArbolPanel extends StatelessWidget {
  const ArbolPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Árboles')),
      body: FutureBuilder(
        future: getArbol(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay árboles registrados'));
          }

          final arboles = snapshot.data!;
          return ListView.builder(
            itemCount: arboles.length,
            itemBuilder: (context, index) {
              final arbol = arboles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  title: Text(arbol['nombre'] ?? 'Nombre desconocido'),
                  subtitle: Text('ID: ${arbol['id_arbol'] ?? 'N/A'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
