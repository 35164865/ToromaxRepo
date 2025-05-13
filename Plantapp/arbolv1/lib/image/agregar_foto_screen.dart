import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

File? imagenSeleccionada;

Future<void> seleccionarImagen() async {
  final ImagePicker picker = ImagePicker();
  final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);

  if (imagen != null) {
    imagenSeleccionada = File(imagen.path);
    print("Imagen seleccionada: ${imagenSeleccionada?.path}");
  } else {
    print("No se seleccionó ninguna imagen.");
  }
}

Future<String?> _subirImagen(File imagen) async {
  try {
    // Referencia al almacenamiento en Firebase
    final storageRef = FirebaseStorage.instance.ref().child(
      'adopcion/${DateTime.now().millisecondsSinceEpoch}.jpg', // Nombre único para cada imagen
    );

    // Subir la imagen a Firebase Storage
    final uploadTask = await storageRef.putFile(imagen);

    // Obtener la URL de la imagen subida
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    print(
      'Imagen subida exitosamente: $downloadUrl',
    ); // Verificación en consola

    return downloadUrl; // Regresa la URL
  } catch (e) {
    print('Error al subir imagen: $e');
    return null; // Si ocurre un error, retornamos null
  }
}
