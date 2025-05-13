import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore bd = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getUsuario() async {
  List<Map<String, dynamic>> usuario = [];
  CollectionReference collectionReferenceUsuario = bd.collection('Usuario');

  QuerySnapshot queryUsuario = await collectionReferenceUsuario.get();
  for (var documento in queryUsuario.docs) {
    final data = documento.data() as Map<String, dynamic>;
    data['doc_id'] = documento.id; // Agregamos el ID del documento también
    print('Documento Firestore: $data');
    usuario.add(data);
  }

  return usuario;
}

Future<List<Map<String, dynamic>>> getArbol() async {
  List<Map<String, dynamic>> arbol = [];
  CollectionReference collectionReferenceUsuario = bd.collection('Arbol');

  QuerySnapshot queryArbol = await collectionReferenceUsuario.get();
  for (var documento in queryArbol.docs) {
    final data = documento.data() as Map<String, dynamic>;
    data['doc_id'] = documento.id; // Agregamos el ID del documento también
    print('Documento Firestore: $data');
    arbol.add(data);
  }

  return arbol;
}

/*Future<List<Map<String, dynamic>>> getAdopcion() async {
  List<Map<String, dynamic>> adopcion = [];
  CollectionReference ref = bd.collection('Adopcion');
  QuerySnapshot query = await ref.get();
  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    data['doc_id'] = doc.id;
    adopcion.add(data);
  }
  return adopcion;
}*/

Future<List<Map<String, dynamic>>> getAdopciones() async {
  List<Map<String, dynamic>> adopciones = [];
  CollectionReference collectionReference = bd.collection('Adopcion');

  QuerySnapshot query = await collectionReference.get();
  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    data['doc_id'] = doc.id;
    adopciones.add(data);
  }

  return adopciones;
}

Future<void> agregarArbol(String nombre) async {
  await bd.collection('Arbol').add({
    'nombre': nombre,
    'creado': FieldValue.serverTimestamp(),
  });
}

Future<void> agregarUsuario(String nombre) async {
  await bd.collection('Usuario').add({
    'nombre': nombre,
    'creado': FieldValue.serverTimestamp(),
  });
}

Future<void> guardarAdopcionEnBD(String idArbol, String idUsuario) async {
  await bd.collection('Adopcion').add({
    'id_arbol': idArbol,
    'id_usuario': idUsuario,
    'fecha_adopcion': FieldValue.serverTimestamp(),
  });
}

Future<List<Map<String, dynamic>>> getAdopcion() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('Adopcion').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id_documento'] = doc.id; // Agregamos el ID del documento
    return data;
  }).toList();
}

/*FirebaseFirestore bd = FirebaseFirestore.instance;

Future<List> getUsuario() async {
  List usuario = [];
  CollectionReference collectionReferenceUsuario = bd.collection('Usuario');

  QuerySnapshot queryUsuario = await collectionReferenceUsuario.get();
  queryUsuario.docs.forEach((documento) {
    usuario.add(documento.data());
  });

  return usuario;
}
*/
