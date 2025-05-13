import 'package:arbolv1/screens/notificaciones_riego.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class FormRiego extends StatefulWidget {
  final String idAdopcion;

  const FormRiego({super.key, required this.idAdopcion});

  @override
  State<FormRiego> createState() => _FormRiegoState();
}

class _FormRiegoState extends State<FormRiego> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadAguaController = TextEditingController();

  bool isLoading = false;
  late String _fechaHoraActual;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaHoraActual = DateFormat('yyyy-MM-dd HH:mm:ss').format(now); // Ejemplo: 2025-05-13 18:45:00
  }

  Future<void> _guardarRiego() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final data = {
      'id_adopcion': widget.idAdopcion.trim(),
      'cantidad_agua': _cantidadAguaController.text.trim(),
      'fecha_registro': Timestamp.now(),
    };

    print('Guardando riego con ID: ${widget.idAdopcion.trim()}');
    await FirebaseFirestore.instance.collection('riegos').add(data);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Riego')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('ID de la adopción: ${widget.idAdopcion}'),
                    const SizedBox(height: 10),
                    Text(
                      'Fecha y hora actual: $_fechaHoraActual',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      'Cantidad de Agua (L)',
                      _cantidadAguaController,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _guardarRiego,
                      child: const Text('Guardar'),
                    ),
                    const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      mostrarNotificacionRiego('Alerta de Riego', 'Es hora de regar tu planta');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    icon: const Icon(Icons.notifications),
                    label: const Text('Alerta Riego'),
                  ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }
}
