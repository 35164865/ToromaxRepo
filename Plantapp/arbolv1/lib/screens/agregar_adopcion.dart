import 'package:arbolv1/services/firebase_services.dart';
import 'package:flutter/material.dart';

class AgregarAdopcionDialog extends StatefulWidget {
  const AgregarAdopcionDialog({super.key});

  @override
  _AgregarAdopcionDialogState createState() => _AgregarAdopcionDialogState();
}

class _AgregarAdopcionDialogState extends State<AgregarAdopcionDialog> {
  final nombreController = TextEditingController();
  final idUsuarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Adopción'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: 'Nombre del árbol'),
          ),
          TextField(
            controller: idUsuarioController,
            decoration: InputDecoration(labelText: 'ID Usuario'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await bd.collection('Adopcion').add({
              'nombre': nombreController.text,
              'id_usuario': idUsuarioController.text,
              'fecha': DateTime.now().toString(),
            });
            Navigator.pop(context);
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
