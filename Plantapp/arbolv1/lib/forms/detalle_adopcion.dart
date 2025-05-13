import 'package:arbolv1/forms/form_riegos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleAdopcion extends StatelessWidget {
  final Map<String, dynamic> adopcion;

  const DetalleAdopcion({super.key, required this.adopcion});

  @override
  Widget build(BuildContext context) {
    final idAdopcion = adopcion['id_adopcion']?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Adopción')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (adopcion['foto_adopcion'] != null &&
                adopcion['foto_adopcion'].toString().isNotEmpty)
              Center(
                child: Image.network(
                  adopcion['foto_adopcion'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('No se pudo cargar la imagen');
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailItem('ID Adopción', adopcion['id_adopcion']),
            _buildDetailItem('Usuario', adopcion['usuario']),
            _buildDetailItem('Árbol', adopcion['nombre_arbol']),
            _buildDetailItem('Ubicación', adopcion['ubicacion']),
            _buildDetailItem(
              'Fecha de adopción',
              adopcion['fecha_adopcion'] is Timestamp
                  ? (adopcion['fecha_adopcion'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0]
                  : adopcion['fecha_adopcion']?.toString() ?? 'N/A',
            ),
            _buildDetailItem('Tipo Arbol', adopcion['tipo_arbol']),
            _buildDetailItem('Notas', adopcion['notas']),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final idAdopcion = adopcion['id_adopcion'];

                if (idAdopcion == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ID de adopción no disponible'),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormRiego(idAdopcion: idAdopcion),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop),
              label: const Text('Registrar Riego'),
            ),

            const SizedBox(height: 20),
            const Text(
              'Historial de Riegos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Builder(
              builder: (context) {
                if (idAdopcion == null || idAdopcion.isEmpty) {
                  return const Text('ID de adopción no disponible.');
                }

                return StreamBuilder<QuerySnapshot>(
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
                      return const Text('No hay registros de riego.');
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final riego =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        final fecha =
                            (riego['fecha_registro'] as Timestamp).toDate();

                        return ListTile(
                          leading: const Icon(Icons.water),
                          title: Text('Cantidad: ${riego['cantidad_agua']} L'),
                          subtitle: Text(
                            '${fecha.day}/${fecha.month}/${fecha.year}',
                          ),
                          trailing: Text(riego['comentarios'] ?? ''),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  value != null && value.toString().isNotEmpty
                      ? value.toString()
                      : 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}
