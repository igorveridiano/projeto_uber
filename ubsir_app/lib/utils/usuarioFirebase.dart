import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ubsir_app/models/usuario.dart';

class UsuarioFirebase {
  static Future<FirebaseUser> getUsuarioAtual() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    return await auth.currentUser();
  }

  static Future<Usuario> getDadosUsuarioLogado() async {
    FirebaseUser firebaseUser = await getUsuarioAtual();

    String uid = firebaseUser.uid;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(uid).get();

    Map<String, dynamic> dados = snapshot.data;
    String tipoUsuario = dados["tipo"];
    String email = dados["email"];
    String nome = dados["nome"];
    String id = dados["uid"];
    String urlFoto = dados["urlFoto"];

    Usuario usuario = Usuario();

    usuario.tipoUsuario = tipoUsuario;
    usuario.idUsuario = id;
    usuario.email = email;
    usuario.nome = nome;
    usuario.urlFoto = urlFoto;

    return usuario;
  }

  // atualizacao dos dados de localização do usuario no firebase
  static atualizarDadosUsuarios(String idRequisicao, double lat, double long, tipoUsuario) async {
    Firestore db = Firestore.instance;

    if (tipoUsuario == "motorista") {
      Usuario motorista = await getDadosUsuarioLogado();

      motorista.latitude = lat;
      motorista.longitude = long;

      db.collection("requisicoes").document(idRequisicao).updateData({"motorista":motorista.toMap()});

    } else if (tipoUsuario == "passageiro") {
      Usuario passageiro = await getDadosUsuarioLogado();

      passageiro.latitude = lat;
      passageiro.longitude = long;

      db.collection("requisicoes").document(idRequisicao).updateData({"passageiro":passageiro.toMap()});
    }
  }
}
