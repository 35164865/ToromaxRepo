import 'package:flutter/material.dart';
import 'package:arbolv1/forms/form_adopcion.dart';
import 'package:arbolv1/forms/detalle_adopcion.dart';
import 'package:arbolv1/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdopcionPanel extends StatelessWidget {
  const AdopcionPanel({super.key});

  Future<void> _eliminarAdopcion(
    BuildContext context,
    String idDocumento,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Seguro que quieres eliminar esta adopción?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('Adopcion')
          .doc(idDocumento)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Adopción eliminada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopciones')),
      body: FutureBuilder(
        future: getAdopcion(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final adopcion = snapshot.data?[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DetalleAdopcion(adopcion: adopcion!),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ID de adopción
                          Text(
                            'ID Adopción: ${adopcion?['id_adopcion'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Imagen
                          if (adopcion?['foto_adopcion'] != null &&
                              adopcion!['foto_adopcion'].toString().isNotEmpty)
                            Image.network(
                              adopcion['foto_adopcion'],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'No se pudo cargar la imagen',
                                );
                              },
                            ),

                          const SizedBox(height: 10),

                          // Información
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoItem(
                                      'Usuario:',
                                      adopcion?['usuario'],
                                    ),
                                    _buildInfoItem(
                                      'Árbol:',
                                      adopcion?['nombre_arbol'],
                                    ),
                                    _buildInfoItem(
                                      'Ubicación:',
                                      adopcion?['ubicacion'],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoItem(
                                      'Fecha:',
                                      adopcion?['fecha_adopcion'] != null
                                          ? (adopcion?['fecha_adopcion']
                                                  is Timestamp
                                              ? (adopcion?['fecha_adopcion']
                                                      as Timestamp)
                                                  .toDate()
                                                  .toString()
                                                  .split(' ')[0]
                                              : adopcion?['fecha_adopcion']
                                                  .toString())
                                          : 'N/A',
                                    ),
                                    _buildInfoItem(
                                      'Tipo Arbol:',
                                      adopcion?['tipo_arbol'],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (adopcion?['notas'] != null &&
                              adopcion!['notas'].toString().isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  'Notas:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(adopcion['notas']),
                              ],
                            ),

                          const SizedBox(height: 10),

                          // Botones de acciones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              FormAdopcion(adopcion: adopcion),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _eliminarAdopcion(
                                      context,
                                      adopcion?['id_documento'],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAdopcion()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${value ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
