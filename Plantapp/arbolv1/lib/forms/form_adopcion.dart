import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'form_riegos.dart';

class FormAdopcion extends StatefulWidget {
  final Map<String, dynamic>? adopcion;

  const FormAdopcion({super.key, this.adopcion});

  @override
  State<FormAdopcion> createState() => _FormAdopcionState();
}

class _FormAdopcionState extends State<FormAdopcion> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? usuario;
  String? nombreArbol;
  String? ubicacion;
  String? responsable;
  String? notas;
  File? imagenSeleccionada;
  String? urlImagenExistente;

  bool isSaving = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.adopcion != null) {
      _cargarDatosExistente();
    }
  }

  void _cargarDatosExistente() {
    usuario = widget.adopcion?['usuario'];
    nombreArbol = widget.adopcion?['nombre_arbol'];
    ubicacion = widget.adopcion?['ubicacion'];
    responsable = widget.adopcion?['responsable'];
    notas = widget.adopcion?['notas'];
    urlImagenExistente = widget.adopcion?['foto_adopcion'];
  }

  Future<void> _seleccionarImagen() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          imagenSeleccionada = File(pickedFile.path);
          urlImagenExistente = null;
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  Future<String?> _subirImagen(File imagen) async {
    try {
      setState(() => isUploadingImage = true);

      final nombreArchivo =
          'Adopcion_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'Adopcion/$nombreArchivo',
      );

      final uploadTask = storageRef.putFile(
        imagen,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state != TaskState.success) {
        throw Exception('Error al subir la imagen: ${snapshot.state}');
      }

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Imagen subida correctamente. URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('Error en _subirImagen: $e');
      _mostrarError('Error al subir la imagen');
      return null;
    } finally {
      setState(() => isUploadingImage = false);
    }
  }

  Future<String?> _guardarAdopcion() async {
  if (!_formKey.currentState!.validate()) return null;
  _formKey.currentState!.save();

  setState(() => isSaving = true);

  try {
    String? imageUrl = urlImagenExistente;

    if (imagenSeleccionada != null) {
      imageUrl = await _subirImagen(imagenSeleccionada!);
      if (imageUrl == null) return null;
    }

    final data = {
      'usuario': usuario ?? '',
      'nombre_arbol': nombreArbol ?? '',
      'ubicacion': ubicacion ?? '',
      'responsable': responsable ?? '',
      'notas': notas ?? '',
      'fecha_adopcion': Timestamp.now(),
      'foto_adopcion': imageUrl ?? '',
      'ultima_actualizacion': FieldValue.serverTimestamp(),
    };

    if (widget.adopcion == null) {
      final docRef = await FirebaseFirestore.instance.collection('Adopcion').add(data);
      _mostrarExito('Adopción creada exitosamente');
      return docRef.id; // 🔁 Aquí retornas el ID generado
    } else {
      await FirebaseFirestore.instance
          .collection('Adopcion')
          .doc(widget.adopcion?['id'])
          .update(data);
      _mostrarExito('Adopción actualizada exitosamente');
      return widget.adopcion?['id'];
    }
  } on FirebaseException catch (e) {
    _mostrarError('Error de Firebase: ${e.message}');
    return null;
  } catch (e) {
    _mostrarError('Error inesperado: ${e.toString()}');
    return null;
  } finally {
    setState(() => isSaving = false);
  }
}


  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  Future<void> _seleccionarUbicacion() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      _mostrarError('Los servicios de ubicación están desactivados.');
      return;
    }

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        _mostrarError('Permiso de ubicación denegado.');
        return;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      _mostrarError(
        'Permisos de ubicación permanentemente denegados, no podemos solicitar permisos.',
      );
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      ubicacion =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    });
  }

  Widget _buildImagePreview() {
    if (isUploadingImage) {
      return const Center(child: CircularProgressIndicator());
    } else if (imagenSeleccionada != null) {
      return Image.file(imagenSeleccionada!, height: 150, fit: BoxFit.cover);
    } else if (urlImagenExistente != null && urlImagenExistente!.isNotEmpty) {
      return Image.network(urlImagenExistente!, height: 150, fit: BoxFit.cover);
    } else {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.adopcion == null ? 'Nueva Adopción' : 'Editar Adopción',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: usuario,
                decoration: const InputDecoration(labelText: 'Usuario'),
                onSaved: (value) => usuario = value,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: nombreArbol,
                decoration: const InputDecoration(
                  labelText: 'Nombre del árbol',
                ),
                onSaved: (value) => nombreArbol = value,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(ubicacion ?? 'Seleccionar ubicación'),
                trailing: const Icon(Icons.location_on),
                onTap: _seleccionarUbicacion,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: responsable,
                decoration: const InputDecoration(labelText: 'Responsable'),
                onSaved: (value) => responsable = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: notas,
                decoration: const InputDecoration(labelText: 'Notas'),
                onSaved: (value) => notas = value,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.photo),
                label: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 8),
              _buildImagePreview(),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: (isSaving || isUploadingImage)
                      ? null
                      : () async {
                          final adopcionId = await _guardarAdopcion();

                          if (adopcionId != null && context.mounted) {

                            await Future.delayed(const Duration(seconds: 2));

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormRiego(idAdopcion: adopcionId),
                              ),
                            );
                          }
                        },
                  child: (isSaving || isUploadingImage)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.adopcion == null
                              ? 'Guardar Adopción'
                              : 'Actualizar Adopción',
                        ),
                ),

            ],
          ),
        ),
      ),
    );
  }
}
