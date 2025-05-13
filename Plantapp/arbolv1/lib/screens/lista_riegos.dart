import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaRiegos extends StatelessWidget {
  final String idAdopcion;

  const ListaRiegos({super.key, required this.idAdopcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riegos del Árbol')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('riegos')
                .where('id_adopcion', isEqualTo: idAdopcion)
                .orderBy('fecha_registro', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay registros de riego.'));
          }

          final riegos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: riegos.length,
            itemBuilder: (context, index) {
              final riego = riegos[index];
              final cantidad = riego['cantidad_agua'];
              final comentarios = riego['comentarios'];
              final fecha = (riego['fecha_registro'] as Timestamp).toDate();

              return ListTile(
                leading: const Icon(Icons.water_drop),
                title: Text('$cantidad litros'),
                subtitle: Text(comentarios),
                trailing: Text(
                  '${fecha.day}/${fecha.month}/${fecha.year}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
