import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/models/usuario.dart';

class BlocUsuario {
  final _streamController = StreamController<Usuario>();

  get stream => _streamController.stream;

  recuperarUsuario() async {
    Usuario usuario = Usuario();
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    Firestore db = Firestore.instance;
    String idUsuarioLogado = usuarioLogado.uid;

    var item = await db.collection("usuarios").document(idUsuarioLogado).get();

    usuario.idUsuario = item["uid"];
    usuario.nome = item["nome"];
    usuario.email = item["email"];
    usuario.senha = item["senha"];
    usuario.urlFoto = item["urlFoto"];
    usuario.tipoUsuario = item["tipo"];

    _streamController.add(usuario);
  }

  void dispose() {
    _streamController.close();
  }
}
